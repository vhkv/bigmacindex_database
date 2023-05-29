# bigmacindex database project
Projekt bazy danych bigmacindex i zasilania jej tabel

## 1. Projekt bazy danych


bazę utworzyłem w MS SQL Server

dane potrzebne do logowania:

adres serwera: bigmacindex.database.windows.net

port: 1433

login: viewer

hasło: 1zCV59^O2h1g

nazwa bazy: bigmacindex

Zdecydowałem się na utworzenie 3 tabel:


### a) dates - tabela wymiarów składająca się z kolumn:

-date_id (format liczbowy, zawiere unikalny identyfikator pozwalający na łączenie się z tabelą faktów bigmac)

-full_date (format daty, zawierający datę w formacie YYYY-MM-DD. Nie była wyspecyfikowana w wymaganiach, ale uznałem że użytkownik może chcieć korzystać z funkcji, które są dostępne tylko dla pól o formacie daty)

-day (format liczbowy, zawierający dzień miesiąca danej daty, zgodnie z wymaganiami pozwalający na analizę per dzień)

-month (format liczbowy, zwierający numer miesiąca danej daty, zgodnie z wymaganiami pozwalający na analizę per miesiąc)

-month_name (format varchar, zawierający angielską nazwę miesiąca, zgodnie z wymaganiami pozwalający na analizę per miesiąc, chciałem dać użytkownikowi możliwość analizy zarówno nazwie miesiąca jak i np sortowania wg kolejności miesiąca, dlatego są dwa pola odnośnie miesiąca)

-quarter (format liczbowy, zawierający numer kwartału, zgodnie z wymaganiami pozwalający na analizę per kwartał)

-year (format liczbowy, zawierający numer roku, zgodnie z wymaganiami pozwalający na analizę per rok)

-financial_year (format liczbowy, zawierający numer roku finansowego, zgodnie z wymaganiami pozwalający na analizę per rok financowy)

zdecydowałem się na format liczbowy dla większości pól ze względu na lepsze działanie funkcji sortującej



### b) georgaphies - tabela wymiarów składająca się z kolumn:

-geography_id (format liczbowy, zawierający unikalny identyfikator połozenia pozwalający na łączenie się z tabelą faktów bigmac)

-country_code (format tekstowy, zawierający kod kraju zgodny z plikim csv. Kodu kraju nie było w wymaganiach, ale pomaga mi w późniejszym zasilaniu tabel danymi i może być przydatny dla użytkownika)

-country_name (format tekstowy, zawierający nazwę kraju zgodną z plikiem źródłowym, zgodnie z wymaganiami pozwala na analizę per kraj)

-region (format tekstowy, zawierający region zgodny z plikiem źródłowym, zgodnie z wymaganiami pozwala na analizę per region)

-valid_from (format daty, zawiera datę przypisania kraju do danego regionu, zgodnie z wymaganiami pozwala na implementację podejścia SCD2)

-valid_to (format daty, zawiera datę wygaśnięcia przypisania kraju do danego regionu, zgodnie z wymaganiami pozwala na implementację podejścia SCD2)

-active (format zero-jedynkowy, zawiera informację czy rekord jest aktualny (1) czy historyczny (0), zgodnie z wymaganiami pozwala na implementację podejścia SCD2)



### c) bigmac - tabela faktów skłądająca się z kolumn:

-id (unikalny identyfikator rekordu)

-date_id (klucz obcy pozwalający na łączenie się z tabelą dates, identyfikator daty)

-geography_id (klucz obcy pozwalający na łączenie się z tabelą geographies, identyfikator położenia)

-local_price (format liczbowy, miara zgodna z wymaganiami)

-dollar_price (format liczbowy, miara zgodna z wymaganiami)

-dollar_ppp (format liczbowy, miara zgodna z wymaganiami)



Uznałem że dalsza normalizacja i tworzenie kolejnych nie ma sensu ze względu na niską częstotliwość dodawania danych, mały rozmiar tabel oraz wygodę użytkownika.



Tabele utworzyłem bezpośrednio w Azure Data Studio. Wykorzystane przeze mnie kwerendy znajdują się w folderze create_sql_tables



## 2. Inicjalne zasilenie tabel

Skrypty zasilające inicjalnie tabele znajdują się w repozytorium. W każdym skrypcie znajdują się komentarze dotyczące tego co robię, ale przedstawiam tutaj też mój tok myślowy. 


### a) tabela dates - populate_dates.ipynb 

Z wykorzystaniem biblioteki pandas tworzę ciąg dat od minimalnej występującej w danych nasdaq do arbitralnie wybranej przeze mnie daty w przyszłości, a następnie za pomocą różnych transformacji tworzę wymagane kolumny. Następnie łączę się z bazą danych i wrzucam dane do odpowiedniej tabeli, tworzę indeksy. Indeksy stworzyłem dopiero po załadowaniu danych, żeby proces ładowania przebiegał szybciej. 

Miałem tu jedną wątpliwość - czy nie wyrzucić z tabeli przeszłych dat, które nie występują w danych nasdaq. Ostatecznie zdecydowałem się tego nie robić. Uznałem że nie znam w pełni specyfiki danych (nie wiem czy w danych nasdaq nie pojawią się któregoś dnia rekordy z wsteczną datą) oraz kolejność poleceń zasugerowała mi żeby tego nie robić.



### b) tabela geographies - populate_geographies.ipnyb

Zaczytuję dane z przesłanego pliku csv, dodaję odpowiednie kolumny. Jako valid_from przyjmuję datę zasilenia tabeli, a valid_to '9999-01-01' (nieskończoność). Pole valid_to mógłbym teoretycznie zostawić puste, ale nie lubię pustych rekordów w tabeli. Następnie łączę się z bazą i ładuję dane do odpowiedniej tabeli. Ze względu na mały rozmiar tabeli indeksy utworzyłem już wcześniej.



### c) tabela bigmac - populate_bigmac.ipnyb

Pobieram dane z tabeli geographies, żeby wiedzieć jakie geography_id nadać rekordom oraz wiedzieć dla jakich krajów pobrać dane. Używam tylko aktualnych, niehistorycznych rekordów (przed updatem tabeli geographies to nie ma znaczenia, ale mogłoby mieć przy updatowaniu tabeli bigmac w przyszłości). 

Następnie łączę się z nasdaq API za pomocą biblioteki quandl. Ustawiam odpowiednie parametry API w tak isposób, żeby skrypt nie zwrócił błędu z powodu przekroczenia liczby zapytań. Pobieram dane partiami ustawiając dla każdej partii odpowiedni kod kraju, po którym następnie łączę się z rekordami z tabeli geographies (nadawanie odpowiedniego geography_id). Za pomocą odpowiednich transformacji tworzę kolumnę date_id spoójną z kolumną date_id z tabeli dates oraz kolumnę id.

Ładuję rekordy do bazy, a następnie nadaję tabeli odpowiednie indeksy.



## 3. Aktualizowanie tabeli geographies

skrypt - update_geographies.ipynb

Pobieram aktualne dane z tabeli geographies zapisaną w bazie danych oraz dane z aktualnego pliku csv (stworzyłem 2 pliki - economist_country_codes0.csv, który zawiera oryginalne dane z zadania oraz plik economist_country_codes_actual.csv, który zawiera dane po modyfikacji. Do modyfikacji tabeli w bazie wystarczy zmodyfikować region w pliku economist_country_codes_actual.csv, nie trzeba tworzyć nowego. Zrobiłem to bo chciałem żeby projekt można było odtworzyć 1:1) 

Łączę tabele outer joinem po parze (kod kraju, region) i na podstawie brakujących wartości identyfikuje które rekordy się zmieniły. Wysyłam do bazy kwerendy UPDATE, które zmieniają 'starym' rekordom flagę active na 0 oraz zmieniają kolumnę valid_to na dzisiejszą datę. Na koniec wrzucam nowe rekordy do tabeli na takich samych zasadach co przy inicjalnym zasileniu tabeli. 

To podejście zakłada, że w pliku economist_country_codes_actual.csv zmieni się tylko region, a pozostałe wartości pozostaną bez zmian. Będzie działał dobrze również w przypadku dodania nowego rekordu. W przypadku zmiany nazwy kraju/kodu kraju mogą wystąpić problemy.
