SET SCHEMA FN71949;

--Тригер, който в отделна таблица записва информация за промененото работно време на дадена атракция
CREATE TABLE FN71949.ATTR_WORKTIME_CHANGES(
    CHANGETIME TIMESTAMP,
    ATTR_WORKTIME VARCHAR(5000)
);

DROP TABLE FN71949.ATTR_WORKTIME_CHANGES;

CREATE TRIGGER triggerUpdateWorkTime
    AFTER UPDATE OF WORK_TIME ON FN71949.ATTRACTIONS
    REFERENCING OLD AS O NEW AS N
    FOR EACH ROW
        INSERT INTO FN71949.ATTR_WORKTIME_CHANGES
        VALUES (CURRENT_TIMESTAMP, 'Attraction ' || O.NAME || ' changes the work time from ' || O.WORK_TIME || ' to ' || N.WORK_TIME);

SELECT * FROM FN71949.ATTR_WORKTIME_CHANGES;

UPDATE FN71949.ATTRACTIONS
SET WORK_TIME = '08:00 - 20:00'
WHERE NAME = 'Splash Mountain';

--Second trigger
CREATE TABLE DELETED_ATTRACTIONS(
    ATTR_NAME VARCHAR(100)
);

--DROP TABLE DELETED_ATTRACTIONS;

-- CREATE TRIGGER deleteAttraction
--     AFTER DELETE ON ATTRACTIONS
--     REFERENCING OLD AS O
--     FOR EACH ROW
--     WHEN ( O.NAME = 'Autopia' )
--         CALL FN71949.attractionsProcedure(O.NAME);
--
-- DROP TRIGGER deleteAttraction;
--
--  INSERT INTO ATTRACTIONS(NAME, PARK_NAME, TYPE, MINIMUM_AGE, DURATION, SPEED, DANGERS, MINIMUM_HEIGHT, WORK_TIME, HEIGHT, LENGTH, CONDITIONS)
--  VALUES('Autopia', 'Gabrovo', 'CHILD', null, 20, 5, null, null, '08:00 - 21:00', 3, null, 'OPEN');
--
-- DELETE FROM ATTRACTIONS
--     WHERE NAME = 'Autopia';
--
-- CREATE PROCEDURE FN71949.attractionsProcedure(IN attractionName VARCHAR(100))
-- RESULT SETS 1
-- LANGUAGE SQL
-- SPECIFIC attractionsProcedure
-- BEGIN
--     DECLARE firstCursor CURSOR WITH RETURN FOR SELECT * FROM ATTRACTIONS WHERE ATTRACTIONS.NAME <> attractionName;
--     INSERT INTO DELETED_ATTRACTIONS VALUES (attractionName);
-- 	OPEN firstCursor;
-- end;
--
-- DROP PROCEDURE FN71949.attractionsProcedure;
--
-- SELECT * FROM DELETED_ATTRACTIONS;

--Тригер 3
--Целта е при update на цената на даден продукт да се запише в таблица новата цена
CREATE TABLE NEW_PRODUCT_PRICE(
    PRODUCT_NAME VARCHAR(100),
    PRODUCT_PRICE DOUBLE
);

DROP TABLE NEW_PRODUCT_PRICE;

CREATE TRIGGER updatePriceForProduct
AFTER UPDATE OF PRICE ON FN71949.PRODUCTS
    REFERENCING OLD AS O NEW AS N
    FOR EACH ROW
    WHEN (O.PRICE > 0)
        CALL FN71949.productProcedure(O.PRODUCT_NAME, N.PRICE);

DROP TRIGGER updatePriceForProduct;

SELECT * FROM FN71949.NEW_PRODUCT_PRICE;

CREATE PROCEDURE FN71949.productProcedure(IN productName VARCHAR(100), IN productNewPrice DOUBLE)
RESULT SETS 1
LANGUAGE SQL
SPECIFIC productProcedure
BEGIN
    DECLARE firstCursor CURSOR WITH RETURN FOR SELECT * FROM PRODUCTS WHERE PRODUCTS.PRODUCT_NAME<>productName;
    INSERT INTO NEW_PRODUCT_PRICE VALUES (productName, productNewPrice);
	OPEN firstCursor;
end;

UPDATE FN71949.PRODUCTS
SET PRICE = 40
WHERE PRODUCT_NAME = 'DRESS';