-- Câu 1: Tìm shop theo khu vực

-- FUNCTION: public.find_shop_location(character varying, character varying)

-- DROP FUNCTION public.find_shop_location(character varying, character varying);

CREATE OR REPLACE FUNCTION public.find_shop_location(
    str_city character varying,
    str_district character varying)
    RETURNS TABLE(id integer, name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    DROP TABLE IF EXISTS shop_temp;
    IF length(str_city) > 0 AND length(str_district) > 0 THEN
        RETURN QUERY
            SELECT id_shop, name_shop
            FROM shops, locations
            WHERE shops.id_location = locations.id_location
                AND city = str_city AND district = str_district
            ORDER BY is_vip DESC;

            IF NOT FOUND THEN
                raise notice 'The shop in %, % could not be found', str_city, str_district;
            END IF;
    elsif length(str_city) > 0 THEN
        RETURN QUERY
            SELECT id_shop, name_shop
            FROM shops, locations
            WHERE shops.id_location = locations.id_location
                AND city = str_city
            ORDER BY is_vip DESC;

            IF NOT FOUND THEN
                raise notice 'The shop in % could not be found', str_city;
            END IF;
    ELSE
        RETURN QUERY
            SELECT id_shop, name_shop
            FROM shops
            ORDER BY is_vip DESC;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.find_shop_location(character varying, character varying)
    OWNER TO postgres;

-- Tìm kiếm Shop theo tên
-- FUNCTION: public.find_shop_name(character varying)

-- DROP FUNCTION public.find_shop_name(character varying);

CREATE OR REPLACE FUNCTION public.find_shop_name(
    str_name character varying)
    RETURNS TABLE(id integer, name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT id_shop, name_shop
        FROM shops
        WHERE name_shop LIKE str_name || '%';

        IF NOT FOUND THEN
            raise notice 'The shop % could not be found', str_name;
        END IF;
END;
$BODY$;

ALTER FUNCTION public.find_shop_name(character varying)
    OWNER TO postgres;

-- Câu 2: Tìm kiếm tích hợp

-- hàm tìm trên bảng supply
-- FUNCTION: public.find_price(integer, integer)

-- DROP FUNCTION public.find_price(integer, integer);

CREATE OR REPLACE FUNCTION public.find_price(
    min_price integer,
    max_price integer)
    RETURNS TABLE(_id_shop integer, _id_product integer, _price real, _quantity integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT id_shop, id_product, price, quantity
        FROM supply
        WHERE price BETWEEN min_price AND max_price;
END;
$BODY$;

ALTER FUNCTION public.find_price(integer, integer)
    OWNER TO postgres;

-- hàm tìm trên bảng products
-- FUNCTION: public.find_product(character varying, character varying, character varying, integer)

-- DROP FUNCTION public.find_product(character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION public.find_product(
    str_name character varying,
    str_type character varying,
    str_manu character varying,
    int_year integer)
    RETURNS TABLE(_id_product integer, _name character varying, _type character varying, _manu character varying, _year date) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT *
        FROM products
        WHERE name LIKE str_name || '%'
            AND (type = (str_type) OR str_type = '')
            AND (manufacturer = (str_manu) OR str_manu = '')
            AND (date_part('year', year) = int_year OR int_year = 0);
END;
$BODY$;

ALTER FUNCTION public.find_product(character varying, character varying, character varying, integer)
    OWNER TO postgres;

-- hàm tìm kiếm bảng shops join locations
-- FUNCTION: public.find_shop(character varying, character varying, character varying)

-- DROP FUNCTION public.find_shop(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION public.find_shop(
    str_name character varying,
    str_city character varying,
    str_district character varying)
    RETURNS TABLE(_id integer, _name character varying, _vip integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT id_shop, name_shop, is_vip
        FROM shops, locations
        WHERE shops.id_location = locations.id_location
                AND (city = str_city OR str_city = '')
                AND (district = str_district OR str_district = '') 
                AND name_shop LIKE str_name || '%';
        IF NOT FOUND THEN
            raise notice 'The shop could not be found';
        END IF;
END;
$BODY$;

ALTER FUNCTION public.find_shop(character varying, character varying, character varying)
    OWNER TO postgres;

-- hàm tìm kiếm tích hợp
CREATE OR REPLACE FUNCTION public.find_all(
    str_name_shop character varying,
    str_city character varying,
    str_district character varying,
    min_price integer,
    max_price integer,
    ord integer,
    str_name_product character varying,
    str_type character varying,
    str_manu character varying,
    int_year integer)
    RETURNS TABLE(_name_product character varying, _name_shop character varying, _manu character varying, _price real, _quantity integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT prd._name as "Product", shp._name as "Shop", prd._manu, pre._price, pre._quantity
        FROM
            find_price(min_price, max_price) as pre,
            find_product(str_name_product, str_type, str_manu, int_year) as prd,
            find_shop(str_name_shop, str_city, str_district) as shp
            
        WHERE shp._id = pre._id_shop
                AND pre._id_product = prd._id_product
        ORDER BY shp._vip DESC,
            CASE
                WHEN ord = -1 THEN pre._price
            END DESC,
            CASE
                WHEN ord = 1 THEN pre._price
            END ASC;
END;
$BODY$;

ALTER FUNCTION public.find_all(character varying, character varying, character varying, integer, integer, integer, character varying, character varying, character varying, integer)
    OWNER TO postgres;

-- Câu 3: Thêm sản phẩm vào giỏ hàng

-- FUNCTION: public.add_to_cart(integer, integer, integer, integer)

-- DROP FUNCTION public.add_to_cart(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.add_to_cart(
    id_b integer,
    id_s integer,
    id_p integer,
    q integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    quantity_d int;
    supply_d int;
BEGIN
    IF id_b < 0 OR id_s < 0 OR id_p < 0 OR q < 0 THEN
        raise notice 'input must bigger than 0';
    ELSE
        SELECT quantity, id_supply
        into quantity_d, supply_d
        FROM supply
        WHERE id_shop = id_s AND id_product = id_p;

        IF NOT FOUND THEN
            raise notice 'The product % could not be found', id_p;
        elsif q > quantity_d THEN
            raise notice 'The remaining quantity in stock is not enough';
        ELSE
            SELECT quantity
            into quantity_d
            FROM cart
            WHERE id_shop = id_s AND id_product = id_p AND id = id_b;

            IF NOT FOUND THEN
                INSERT INTO cart VALUES (id_b, supply_d, q);
                raise notice 'Add product % supply by shop % successed', id_p, id_s;
            ELSE
                DELETE FROM cart
                WHERE id_shop = id_s AND id_product = id_p AND id = id_b;

                INSERT INTO cart VALUES (id_b, supply_d, q + quantity_d);
                raise notice 'Add product % supply by shop % successed', id_p, id_s;
            END IF;
        END IF;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.add_to_cart(integer, integer, integer, integer)
    OWNER TO postgres;

-- Câu 4: Xoá sản phẩm khỏi giỏ hàng

-- FUNCTION: public.remove_from_cart(integer, integer, integer, integer)

-- DROP FUNCTION public.remove_from_cart(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.remove_from_cart(
    id_b integer,
    id_s integer,
    id_p integer,
    q integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    quantity_d int;
    supply_d int;
BEGIN
    IF id_b < 0 OR id_s < 0 OR id_p < 0 OR q < 0 THEN
        raise notice 'input must bigger than 0';
    ELSE
        SELECT quantity, id_supply
        INTO quantity_d, supply_d
        FROM supply
        WHERE id_shop = id_s AND id_product = id_p;

        IF NOT FOUND THEN
            raise notice 'This product % supply by % has been deleted', id_p, id_s;
            DELETE FROM cart
            WHERE id_supply = supply_d AND id = id_b;
        ELSE
            SELECT quantity
            into quantity_d
            FROM cart
            WHERE id_supply = supply_d AND id = id_b;

            IF NOT FOUND THEN
                raise notice 'This product does not exist in the cart';
            ELSE
                IF q > quantity_d THEN
                    raise notice 'The number of % in the cart is not enough', id_p;
                ELSIF q = quantity_d THEN
                    DELETE FROM cart
                    WHERE id_supply = supply_d AND id = id_b;
                    raise notice 'Delete product % supply by shop % successed', id_p, id_s;
                ELSE
                    DELETE FROM cart
                    WHERE id_supply = supply_d AND id = id_b;

                    INSERT INTO cart VALUES (id_b, supply_d, quantity_d - q);
                    raise notice 'Delete product % supply by shop % successed', id_p, id_s;
                END IF;
            END IF;
        END IF;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.remove_from_cart(integer, integer, integer, integer)
    OWNER TO postgres;


-- Câu 5: Tạo trigger để tự động cộng trừ số lượng sản phẩm trong supply khi người mua thêm hàng vào giỏ

-- tự động cộng số lượng sản phẩm

-- FUNCTION: public.incresequantity()

-- DROP FUNCTION public.incresequantity();

CREATE FUNCTION public.incresequantity()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE supply
    SET quantity = quantity + OLD.quantity
    WHERE id_supply = OLD.id_supply;
    RETURN NULL;
end;
$BODY$;

ALTER FUNCTION public.incresequantity()
    OWNER TO postgres;

-- tự động trừ số lượng sản phẩm

-- FUNCTION: public.decresequantity()

-- DROP FUNCTION public.decresequantity();

CREATE FUNCTION public.decresequantity()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE supply
    SET quantity = quantity - NEW.quantity
    WHERE id_supply = NEW.id_supply;
    RETURN NULL;
end;
$BODY$;

ALTER FUNCTION public.decresequantity()
    OWNER TO postgres;

-- tạo trigger

-- Trigger: add_cart

-- DROP TRIGGER add_cart ON public.cart;

CREATE TRIGGER add_cart
    AFTER INSERT
    ON public.cart
    FOR EACH ROW
    EXECUTE PROCEDURE public.decresequantity();

-- Trigger: delete_cart

-- DROP TRIGGER delete_cart ON public.cart;

CREATE TRIGGER delete_cart
    AFTER DELETE
    ON public.cart
    FOR EACH ROW
    EXECUTE PROCEDURE public.incresequantity();

-- Câu 7: Trả về các sản phẩm shop đang bán

-- FUNCTION: public.find_shop_product(integer)

-- DROP FUNCTION public.find_shop_product(integer);

CREATE OR REPLACE FUNCTION public.find_shop_product(
    id_s integer)
    RETURNS TABLE(_id integer, _name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    id_shop_d int;
BEGIN
    SELECT id_shop
    INTO id_shop_d
    FROM shops
    WHERE id_seller = id_s;

    IF NOT FOUND THEN
        raise notice 'User is not seller';
    ELSE
        RETURN QUERY
            SELECT products.id_product, products.name
            FROM supply, products
            WHERE supply.id_product = products.id_product
                AND supply.id_shop = id_shop_d;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.find_shop_product(integer)
    OWNER TO postgres;

-- Câu 8: Thay đổi thông tin sản phẩm
-- FUNCTION: public.update_product(integer, integer, real, integer)

-- DROP FUNCTION public.update_product(integer, integer, real, integer);

CREATE OR REPLACE FUNCTION public.update_product(
    id_s integer,
    id_p integer,
    p real,
    q integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    quantity_d int;
    sold_d int;
BEGIN
    IF q < 0 OR p < 0 THEN
        raise notice 'Price and quantity must bigger than 0';
    ELSE
    SELECT quantity, sold
    INTO quantity_d, sold_d
    FROM supply
    WHERE id_shop = id_s AND id_product = id_p;

    IF NOT FOUND THEN
        raise notice 'You dont sell product %', id_p;
    ELSE
        DELETE FROM supply
        WHERE id_shop = id_s AND id_product = id_p;

        INSERT INTO supply VALUES (id_s, id_p, p, q, sold_d);
        raise notice 'Update product %d successed', id_p;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.update_product(integer, integer, real, integer)
    OWNER TO postgres;

-- Tạo trigger tự động thay đổi thuộc tính is_vip trong bảng Shop khi có
-- thay đổi trong bảng Vip

-- FUNCTION: public.addvip()

-- DROP FUNCTION public.addvip();

CREATE FUNCTION public.addvip()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE shops
    SET isVip = 1
    WHERE id_shop = NEW.id_shop;
    RETURN NULL;
end;
$BODY$;

ALTER FUNCTION public.add_vip()
    OWNER TO postgres;

CREATE TRIGGER add_vip
    AFTER INSERT
    ON public.vip
    FOR EACH ROW
    EXECUTE PROCEDURE public.addvip();

-- FUNCTION: public.deletevip()

-- DROP FUNCTION public.deletevip();

CREATE FUNCTION public.deletevip()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE shops
    SET isVip = 0
    WHERE id_shop = OLD.id_shop;
    RETURN NULL;
end;
$BODY$;

ALTER FUNCTION public.deletevip()
    OWNER TO postgres;

CREATE TRIGGER delete_vip
    AFTER DELETE
    ON public.vip
    FOR EACH ROW
    EXECUTE PROCEDURE public.deletevip();

-- Tìm và xoá những sản phẩm không được shop nào bán

DELETE FROM products
WHERE id_product NOT IN (
    SELECT products.id_product
    FROM products, supply
    WHERE products.id_product = supply.id_product
);












