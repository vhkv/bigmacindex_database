create table dates (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day TINYINT,
    month TINYINT,
    month_name varchar(9),
    quarter TINYINT,
    year SMALLINT,
    financial_year SMALLINT
)

--indeksy tworzę po zasileniu tabeli danymi, rekordów jest sporo, nie chcę żeby ustoworzone wcześniej indeksy spowalniały dodawanie rekordów