create table bigmac (
    id INT,
    date_id INT NOT NULL INDEX IX_date_id,
    geography_id INT NOT NULL INDEX IX_georaphy_id,
    local_price FLOAT, 
    dollar_price FLOAT, 
    dollar_ppp FLOAT,
    CONSTRAINT PK_id  PRIMARY KEY (id),
    CONSTRAINT FK_bigmac_date FOREIGN KEY (date_id) REFERENCES dates(date_id) ON UPDATE CASCADE,
    CONSTRAINT FK_bigmac_geography FOREIGN KEY (geography_id) REFERENCES geographies(geography_id) ON UPDATE CASCADE
)