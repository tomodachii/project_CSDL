-- Hàm chuẩn hóa chuỗi --> whatsup

CREATE OR REPLACE FUNCTION whatsup (  _str text)
    RETURNS text
    AS
    $$
        DECLARE
            i int;
        BEGIN
            SELECT position(' ' in _str) INTO i;
            LOOP 
                exit when i = 0;
                select overlay(_str placing '' from i for 1)
                into _str;
                i := position(' ' in _str);
            END LOOP;
            return _str;
        END;
    $$
LANGUAGE plpgsql;


-- a. Tìm theo loại hàng (điện thoại, ….) --> search_by_type

CREATE OR REPLACE FUNCTION search_by_type (_type varchar) 
    RETURNS TABLE (
        shop_name varchar(40),
        product_name varchar(40),
        product_type varchar(40),
        product_manufacturer varchar(20),
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
                tab.name, 
                tab.type, 
                tab.manufacturer, 
                tab.year,
                tab.price, 
                tab.quantity
            FROM 
            (
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
                        FROM products
                        WHERE lower(type) LIKE '%' || lower(_type) || '%'
                        ) p, 
                    (SELECT id_shop, price, quantity, id_product
                        FROM supply
                        ) s
                WHERE 
                    p.id_product = s.id_product
            ) tab, (
                    SELECT id_shop, name_shop
                    FROM shops
                    ORDER BY is_vip DESC
                ) sh 
            WHERE
                tab.id_shop = sh.id_shop;
            IF NOT found THEN
                RAISE NOTICE 'Khong tim thay san pham phu hop';
            END IF
            ;
        END
    $$
LANGUAGE plpgsql;



--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__


-- b. Tìm theo giá thấp -> cao  --> search_by_price_order_by_asc

CREATE OR REPLACE FUNCTION search_by_price_order_by_asc ()
    RETURNS table (
        shop_name varchar(40),
        product_name varchar(40),
        product_type varchar(40),
        product_manufacturer varchar(20),
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
                tab.name, 
                tab.type, 
                tab.manufacturer, 
                tab.year,
                tab.price, 
                tab.quantity
            FROM 
            (
                SELECT 
                    p.name, 
                    p.type, 
                    p.manufacturer, 
                    p.year, 
                    s.id_shop, 
                    s.price, 
                    s.quantity
                FROM products p, 
                    (
                        SELECT *
                        FROM supply
                        ORDER BY price ASC
                    ) s
                    WHERE 
                        p.id_product = s.id_product
                ) tab, (
                    SELECT *
                    FROM shops
                    ORDER BY is_vip DESC
                ) sh 
            WHERE tab.id_shop = sh.id_shop;
            IF NOT found THEN
                RAISE NOTICE 'Khong tim thay san pham phu hop';
            END IF
            ;
        END
    $$
LANGUAGE plpgsql;

--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__



-- c. Tìm theo giá trong khoảng chỉ định --> search_by_range_price



CREATE OR REPLACE FUNCTION search_by_range_price (price_min real, price_max real)
    RETURNS table (
        shop_name varchar(40),
        product_name varchar(40),
        product_type varchar(40),
        product_manufacturer varchar(20),
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
                tab.name, 
                tab.type, 
                tab.manufacturer, 
                tab.year,
                tab.price, 
                tab.quantity
            FROM 
            (
                SELECT 
                    p.name, 
                    p.type, 
                    p.manufacturer, 
                    p.year, 
                    s.id_shop, 
                    s.price, 
                    s.quantity
                FROM products p, 
                    (
                    SELECT * FROM supply
                    WHERE price <= price_max AND price >= price_min
                    ORDER BY price ASC
                    ) s
                    WHERE 
                        p.id_product = s.id_product
                ) tab, (
                    SELECT * FROM shops
                    ORDER BY is_vip DESC
                ) sh  
            WHERE tab.id_shop = sh.id_shop;
            IF NOT found THEN
                RAISE NOTICE 'Khong tim thay san pham phu hop';
            END IF
            ;
        END
    $$
LANGUAGE plpgsql;


--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__


-- * tìm kiếm theo khoảng giá và loại sp --> search_by_type_and_range_price

CREATE OR REPLACE FUNCTION search_by_type_and_range_price (
        _type varchar, 
        price_min real, 
        price_max real
        )
    RETURNS TABLE (
        shop_name varchar(40),
        product_name varchar(40),
        product_type varchar(40),
        product_manufacturer varchar(20),
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
                tab.name, 
                tab.type, 
                tab.manufacturer, 
                tab.year,
                tab.price, 
                tab.quantity
            FROM 
                (
                SELECT 
                    p.name, 
                    p.type, 
                    p.manufacturer, 
                    p.year, 
                    s.id_shop, 
                    s.price, 
                    s.quantity
                FROM 
                    (SELECT *
                        FROM products
                        WHERE lower(type) LIKE '%' || lower(_type) || '%'
                        ) p, 
                    (SELECT *
                    FROM supply
                        WHERE price <= price_max AND price >= price_min                                
                        ORDER BY price ASC
                        ) s
                WHERE p.id_product = s.id_product
            ) tab, (
                    SELECT *
                    FROM shops
                    ORDER BY is_vip DESC
                ) sh  
        WHERE tab.id_shop = sh.id_shop;
        IF NOT found THEN
            RAISE NOTICE 'Khong tim thay san pham phu hop';
        END IF
        ;
        END
    $$
LANGUAGE plpgsql;


--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__

    -- d. Xoá sản phẩm đang bán

CREATE OR REPLACE PROCEDURE delete_product (_id_product int, _id_shop int)
        AS
        $$
        DECLARE
            id_product_d int;
            id_shop_d int;
        BEGIN
            SELECT id_product, id_shop
            INTO id_product_d, id_shop_d
            FROM supply
            WHERE 
                id_product = _id_product 
                AND id_shop = _id_shop;
            IF NOT FOUND THEN
                raise warning 'Product does not exist';
            ELSE
                DELETE FROM supply
                WHERE id_product = _id_product AND id_shop = _id_shop
                ;
                raise notice 'DELETE COMPLETE!'
                ; 
            END IF;
        END
        $$
LANGUAGE plpgsql;

--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__

-- e. Chức năng thanh toán (lấy sản phẩm trong cart, đưa ra thanh toán, gộp theo từng shop)

CREATE OR REPLACE FUNCTION personal_bill (_id int) 
    RETURNS TABLE (
        idShop int,
        nameShop varchar(40),
        Product text,
        Price double precision
    )
    AS
    $$
        BEGIN
            RETURN QUERY
                SELECT
                    sh.id_shop,
                    sh.name_shop,
                    string_agg(
                        p.name || ' x ' || c.quantity || ' ', 
                        ','),
                    sum (c.quantity * s.price)
                FROM
                products p, supply s, shops sh, (
                            SELECT * FROM cart
                            WHERE id_buyer = _id
                        ) c
                WHERE c.id_supply = s.id_supply
                    AND s.id_product = p.id_product
                    AND s.id_shop = sh.id_shop
                GROUP BY sh.id_shop, sh.name_shop
            ;
        END
    $$
LANGUAGE plpgsql;

--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__


-- f. Thêm sản phẩm bán

--**** Insert mặt hàng vào supply. Trước đó nếu sản phẩm này chưa có trong products thì phải insert chi tiết về sản phẩm vào đó trước

--** Hàm tìm kiếm id sản phẩm trong bảng products, nếu có trả về id, không có thì sẽ trả về 0
CREATE OR REPLACE FUNCTION find_product (_product_name varchar(40))
    RETURNS int
        AS
        $$
        DECLARE
            id_product_d int;
        BEGIN
            SELECT id_product
            INTO id_product_d
            FROM products
            WHERE lower(name) = lower(_product_name)
            ;
            IF NOT found THEN
            return 0;
            ELSE 
            return id_product_d;
            END IF;
        END
        $$
LANGUAGE plpgsql;

-- Thủ tục thêm mặt hàng vào supply --> sell_product

CREATE OR REPLACE PROCEDURE sell_product (
    _id_shop int, 
    _product_name varchar(40),
    _price real,
    _quantity int
    )
        AS
        $$
        DECLARE
            id_product_d int;
            old_quantity int;
            id_supply_max int;
        BEGIN
            SELECT find_product(_product_name)
            INTO id_product_d;
            IF id_product_d = 0 THEN
            --Nếu không tồn tại sản phẩm trong bảng products thì phải quay lại nhập chi tiết về sản phẩm trong bảng products bằng hàm insert_into_products
                raise notice 'Khong ton tai san pham %. Moi nhap chi tiet san pham', _product_name;
            ELSE
                SELECT quantity
                INTO old_quantity
                FROM supply
                WHERE id_product = id_product_d AND id_shop = _id_shop;
                IF NOT FOUND THEN
                    -- Nếu shop này chưa từng bán sản phẩm đó thì insert, nếu đã bán rồi thì update price và quantity
                    SELECT max(id_supply)
                    INTO id_supply_max
                    FROM supply;
                    INSERT INTO supply 
                    VALUES (id_supply_max + 1, _id_shop, id_product_d, _price, _quantity, 0);
                ELSE 
                    UPDATE supply
                    set quantity = old_quantity + _quantity , price = _price
                    WHERE id_product = id_product_d;
                END IF;
            END IF
            ;
        END
        $$
LANGUAGE plpgsql;

--** Thủ tục insert thêm sản phẩm mới vào bảng products --> insert_into_products

CREATE OR REPLACE PROCEDURE insert_into_products (
    _name varchar(40),
    _type varchar(40),
    _manufacturer varchar(40)
    )
        AS
        $$
        DECLARE
            id_product_d int;
            id_product_z int;
        BEGIN
            
            SELECT id_product
            INTO id_product_z
            FROM products
            WHERE lower(name) = lower(_name);
            IF NOT FOUND THEN
                SELECT max(id_product)
                INTO id_product_d
                FROM products;
                INSERT into products
                VALUES (id_product_d + 1, _name, _type, _manufacturer, CURRENT_TIMESTAMP);
            ELSE
                raise notice 'San pham % da ton tai. Hay thu lai!', _name;
            END IF
            ;
        END
        $$
LANGUAGE plpgsql;

--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--..__..--**--__


-- g. Đăng kí vip, Gia hạn vip


CREATE OR REPLACE PROCEDURE registration_or_extend_vip (_id_shop int, _use_time varchar(10))
    AS
    $$
        DECLARE
            id_shop_d int;
            use_time_d interval;
        BEGIN
            SELECT id_shop, cast(use_time AS interval)
            INTO id_shop_d, use_time_d
            FROM vip
            WHERE id_shop = _id_shop;
            IF NOT FOUND THEN
                INSERT INTO vip
                VALUES (_id_shop, CURRENT_TIMESTAMP, cast(_use_time AS interval));
            ELSE
                UPDATE vip
                SET use_time = use_time_d + cast(_use_time AS interval)
                WHERE id_shop = _id_shop;
            END IF
            ;
        END
    $$
LANGUAGE plpgsql;

--** Trigger xóa các tài khoản vip hết hiệu lực quá 7 ngày sau mỗi thao tác insert hoặc update vào bảng vip

CREATE OR REPLACE FUNCTION expire_table_delete_old_rows() 
    RETURNS trigger
    AS 
    $$
        BEGIN
            DELETE FROM vip WHERE use_time < NOW() - start_date + interval '7 day';
            RETURN NEW;
        END
    $$
LANGUAGE plpgsql;

CREATE TRIGGER expire_table_delete_old_rows_trigger
AFTER INSERT OR UPDATE 
ON vip
EXECUTE PROCEDURE expire_table_delete_old_rows();