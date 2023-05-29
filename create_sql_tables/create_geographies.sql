create table geographies (
    geography_id INT PRIMARY KEY, 
    country_code CHAR(3) NOT NULL INDEX IX_country_code,
    country_name VARCHAR(60) NOT NULL INDEX IX_country_name,
    region VARCHAR(6) NOT NULL INDEX IX_region,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    active BIT NOT NULL
)