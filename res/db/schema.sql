-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2016-06-23 02:42:22.714

-- tables
-- Table: catagories
CREATE TABLE catagories (
    catagory text NOT NULL,
    shop_id integer NOT NULL,
    cat_id integer NOT NULL CONSTRAINT catagories_pk PRIMARY KEY,
    CONSTRAINT catagories_shop FOREIGN KEY (shop_id)
    REFERENCES shop (id)
);

-- Table: shop
CREATE TABLE shop (
    id integer NOT NULL CONSTRAINT shop_pk PRIMARY KEY,
    name text NOT NULL,
    price real NOT NULL,
    thumbnail text NOT NULL,
    description text NOT NULL
);

-- End of file.

