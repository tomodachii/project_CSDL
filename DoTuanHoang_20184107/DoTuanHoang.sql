
-----------------------------------------------
--a
CREATE OR REPLACE FUNCTION search_by_product_name(_name VARCHAR(40)) 
    RETURNS TABLE (
        shop_name VARCHAR(40),
        product_name VARCHAR(40),
        product_type VARCHAR(40),
        product_manufacturer VARCHAR(20),
        product_year DATE,
        product_price REAL,
        product_quantity INTEGER
    )
    AS
    $$
        BEGIN
            RETURN QUERY
                SELECT 
                    sh.name_shop,
                    x.name, 
                    x.type, 
                    x.manufacturer, 
                    x.year,
                    x.price, 
                    x.quantity
                FROM (
                        SELECT 
                            p.name, 
                            p.type, 
                            p.manufacturer, 
                            p.year, 
                            s.id_shop, 
                            s.price, 
                            s.quantity
                        FROM 
                            (SELECT name, type, manufacturer, year, id_product
                                FROM products) p, 
                            (SELECT id_shop, price, quantity, id_product
                                FROM supply) s
                        WHERE 
                            p.name = _name
                            AND p.id_product = s.id_product
                ) x, shops sh 
                WHERE
                    x.id_shop = sh.id_shop
                ORDER BY sh.is_vip DESC;
                IF NOT found THEN
                    RAISE NOTICE 'Khong tim thay san pham phu hop';
                END IF
                ;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--b
CREATE OR REPLACE FUNCTION search_by_product_year(_year INTEGER) 
    RETURNS TABLE (
        shop_name VARCHAR(40),
        product_name VARCHAR(40),
        product_type VARCHAR(40),
        product_manufacturer VARCHAR(20),
        product_year DATE,
        product_price REAL,
        product_quantity INTEGER
    )
    AS
    $$
        BEGIN
            RETURN QUERY
                SELECT 
                    sh.name_shop,
                    x.name, 
                    x.type, 
                    x.manufacturer, 
                    x.year,
                    x.price, 
                    x.quantity
                FROM (
                        SELECT 
                            p.name, 
                            p.type, 
                            p.manufacturer, 
                            p.year, 
                            s.id_shop, 
                            s.price, 
                            s.quantity
                        FROM 
                            (SELECT name, type, manufacturer, year, id_product
                                FROM products) p, 
                            (SELECT id_shop, price, quantity, id_product
                                FROM supply) s
                        WHERE 
                            EXTRACT(YEAR FROM p.year) = _year
                            AND p.id_product = s.id_product
                ) x, shops sh 
                WHERE
                    x.id_shop = sh.id_shop
                ORDER BY sh.is_vip DESC;
                IF NOT found THEN
                    RAISE NOTICE 'Khong tim thay san pham phu hop';
                END IF
                ;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--c
CREATE OR REPLACE FUNCTION search_by_product_manufacturer(_manufacturer VARCHAR(40))
    RETURNS TABLE (
        shop_name VARCHAR(40),
        product_name VARCHAR(40),
        product_type VARCHAR(40),
        product_manufacturer VARCHAR(20),
        product_year DATE,
        product_price REAL,
        product_quantity INTEGER
    )
    AS
    $$
        BEGIN
            RETURN QUERY
                SELECT 
                    sh.name_shop,
                    x.name, 
                    x.type, 
                    x.manufacturer, 
                    x.year,
                    x.price, 
                    x.quantity
                FROM (
                        SELECT 
                            p.name, 
                            p.type, 
                            p.manufacturer, 
                            p.year, 
                            s.id_shop, 
                            s.price, 
                            s.quantity
                        FROM 
                            (SELECT name, type, manufacturer, year, id_product
                                FROM products) p, 
                            (SELECT id_shop, price, quantity, id_product
                                FROM supply) s
                        WHERE 
                            p.manufacturer = _manufacturer
                            AND p.id_product = s.id_product
                ) x, shops sh 
                WHERE
                    x.id_shop = sh.id_shop
                ORDER BY sh.is_vip DESC;
                IF NOT found THEN
                    RAISE NOTICE 'Khong tim thay san pham phu hop';
                END IF
                ;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--d
CREATE OR REPLACE FUNCTION search_by_top_sales (_limit INTEGER)
    RETURNS table (
        product_name varchar(40), 
        product_sales INTEGER
        )
        AS
        $$
            BEGIN
            return query
                SELECT p.name, SUM(s.sold)::INTEGER AS sales
                FROM products p NATURAL JOIN supply s
                GROUP BY p.id_product
                ORDER BY sales DESC
                LIMIT _limit
            ;
        END
        $$
LANGUAGE plpgsql;
-----------------------------------------------
--e
CREATE OR REPLACE FUNCTION search_by_price_order_by_desc ()
    RETURNS table (
        product_name varchar(40), 
        shop_name varchar(40), 
        product_type varchar(40),
        product_price real
        )
        AS
        $$
            BEGIN
            return query
                SELECT p.name, sh.name_shop, p.type, s.price
                FROM products p
                NATURAL JOIN supply s
                NATURAL JOIN shops sh
                ORDER BY s.price DESC
                LIMIT 500
            ;
        END
        $$
LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION search_by_price_order_by_desc ()
--     RETURNS table (
--         product_name varchar(40), 
--         shop_name varchar(40), 
--         product_type varchar(40),
--         product_price real
--         )
--         AS
--         $$
--             BEGIN
--             return query
--                 SELECT x.name, sh.name_shop, x.type, x.price
--                 FROM (
--                     SELECT p.name, p.type, s.price, s.id_shop
--                     FROM (SELECT name, type, id_product 
--                         FROM products) p, 
--                         (SELECT price, id_product, id_shop
--                         FROM supply) s
--                     WHERE p.id_product = s.id_product
--                 ) x, (
--                     SELECT id_shop, name_shop
--                     FROM shops
--                 ) sh
--                 WHERE sh.id_shop = x.id_shop
--                 ORDER BY x.price DESC
--                 LIMIT 500
--             ;
--         END
--         $$
-- LANGUAGE plpgsql;
-----------------------------------------------
--f
CREATE OR REPLACE PROCEDURE change_shop_name (_name VARCHAR(40), _new_name VARCHAR(40))
    AS
    $$
    DECLARE
        id_shop_d int;
        name_shop_d VARCHAR(40);
    BEGIN
        SELECT id_shop, name_shop
        INTO id_shop_d, name_shop_d
        FROM shops
        WHERE name_shop = _name;
        IF NOT FOUND THEN
            raise warning 'Shop does not exist';
        ELSE
            UPDATE shops
            SET name_shop = _new_name
            WHERE name_shop = _name;
            RAISE NOTICE 'Change name completed!';
        END IF;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--g
CREATE OR REPLACE FUNCTION is_buyer(_id_seller INTEGER)
    RETURNS BOOLEAN
    AS
    $$
    DECLARE
        v_id INTEGER;
    BEGIN
        SELECT id_buyer FROM buyer
        INTO v_id
        WHERE id_buyer = _id_seller;
        IF NOT found THEN
            RAISE warning 'Buyer doesnt exist!';
            RETURN FALSE;
        ELSE 
            RAISE NOTICE 'We have this buyer';
            RETURN TRUE;
        END IF;
    END
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_seller(_id_seller INTEGER)
    RETURNS BOOLEAN
    AS
    $$
    DECLARE
        v_id INTEGER;
    BEGIN
        SELECT id_seller FROM seller
        INTO v_id
        WHERE id_seller = _id_seller;
        IF NOT found THEN
            RAISE NOTICE 'Seller doesnt exist!';
            RETURN FALSE;
        ELSE
            RAISE warning 'This guy has already been a seller!';
            RETURN TRUE;
        END IF;
    END
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_seller()
    RETURNS TRIGGER
    AS
    $$
        BEGIN
            INSERT INTO seller(id_seller) VALUES (NEW.id_shop);
            RETURN NULL;
    END
    $$
LANGUAGE plpgsql;

CREATE TRIGGER insert_shop
    BEFORE INSERT  
    ON shops
    FOR EACH ROW
    EXECUTE FUNCTION insert_into_seller();

CREATE OR REPLACE FUNCTION open_new_shop(
    _name_shop VARCHAR(40), 
    _is_vip INTEGER,
    _id_location INTEGER
    )
    RETURNS void
    AS
    $$
    DECLARE
        v_id INTEGER;
    BEGIN
        v_id := concat(v_id,  '(SELECT COUNT(id_shop) FROM shops) + 100');
        IF is_buyer(v_id) THEN
            IF NOT is_seller(v_id) THEN
                -- INSERT INTO seller VALUES (_id_seller);
                INSERT INTO shops VALUES
                ((SELECT COUNT(id_shop) FROM shops) + 100, _name_shop, _is_vip, _id_location, now());
            END IF;
        END IF;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--h
CREATE OR REPLACE FUNCTION back_up_shop()
    RETURNS TRIGGER
    AS
    $$
        BEGIN
            INSERT INTO shops_deleted
            SELECT (OLD).*
            FROM shops;
            RETURN NULL;
    END
    $$
LANGUAGE plpgsql;
CREATE TRIGGER save_to_shop_delete
    BEFORE INSERT  
    ON shops
    FOR EACH ROW
    EXECUTE FUNCTION back_up_shop();

DROP TRIGGER save_to_shop_delete ON shops
-----------------------------------------------
--i
CREATE OR REPLACE FUNCTION buy_transaction(_id_customer INTEGER)
    RETURNS TABLE (
            buyer_first_name VARCHAR(40),
            buyer_last_name VARCHAR(40),
            product_name VARCHAR(40),
            shop_name VARCHAR(40),
            product_quantity INTEGER,
            product_price REAL,
            transaction_buy_date DATE
        )
    AS
    $$
    BEGIN
        RETURN query
            SELECT
                y.first_name,
                y.last_name,
                y.name AS p_name,
                sh.name_shop,
                y.quantity,
                y.price, 
                y.buy_date
            FROM
                (
                    SELECT *
                    FROM (
                        SELECT *
                        FROM (
                            SELECT first_name, last_name, id_buyer 
                            FROM buyer
                            WHERE id_buyer = _id_customer
                        ) b, transactions t 
                        WHERE b.id_buyer = t.id_customer
                    ) x, (
                        SELECT id_product, name 
                        FROM products
                    ) p
                    WHERE x.id_product = p.id_product
                ) y, (
                    SELECT id_shop, name_shop
                    FROM shops
                ) sh 
            WHERE y.id_shop = sh.id_shop;
            IF NOT FOUND THEN
                raise warning 'Shop does not exist';
            END IF;
    END
    $$
LANGUAGE plpgsql;
-----------------------------------------------
--j
CREATE OR REPLACE FUNCTION sell_transaction(_id_shop INTEGER)
    RETURNS TABLE (
            shop_name VARCHAR(40),
            product_name VARCHAR(40),
            buyer_first_name VARCHAR(40),
            buyer_last_name VARCHAR(40),
            product_quantity INTEGER,
            product_price REAL,
            transaction_buy_date DATE
        )
    AS
    $$
    BEGIN
        RETURN query
            SELECT
                y.name_shop,
                y.name AS product_name,
                b.first_name,
                b.last_name,     
                y.quantity,
                y.price, 
                y.buy_date
            FROM
                (
                    SELECT *
                    FROM (
                        SELECT *
                        FROM (
                            SELECT id_shop, name_shop
                            FROM shops
                            WHERE id_shop = _id_shop
                        ) sh, transactions t 
                        WHERE sh.id_shop = t.id_shop
                    ) x, (
                        SELECT id_product, name 
                        FROM products
                    ) p
                    WHERE x.id_product = p.id_product
                ) y, (
                    SELECT first_name, last_name, id_buyer 
                    FROM buyer
                ) b 
            WHERE b.id_buyer = y.id_customer;
            IF NOT FOUND THEN
                raise warning 'Shop does not exist';
            END IF;
    END
    $$
LANGUAGE plpgsql;
SELECT * FROM transactions WHERE id_shop = 130

DELETE FROM shops WHERE id_shop = 990
SELECT * FROM shops_deleted

INSERT INTO shops VALUES (2051, 'NewShop', 1, 1, now())
SELECT * FROM open_new_shop('Ceb', 2179, 1, 25)
SELECT * from buyer WHERE id_buyer = 2179
SELECT * FROM seller WHERE id_seller = 2179
SELECT * FROM shops WHERE id_shop = 2051;
SELECT * FROM search_by_product_name('Iphone0')
NATURAL JOIN search_by_product_year(2010);
SELECT * FROM search_by_product_year(2010);
SELECT * FROM search_by_product_manufacturer('Apple');
SELECT * FROM search_by_top_sales (100);
SELECT * FROM search_by_price_order_by_desc();
SELECT * FROM buy_transaction(5300);
SELECT * FROM sell_transaction(1440);
CALL change_shop_name('Shop1151', 'AdidasPhatShop');
