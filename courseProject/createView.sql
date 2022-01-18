SET SCHEMA FN71949;

--Изглед, който показва за всеки посетител на кои атракции може да се качва
--Спрямо височината му и възрастта му
CREATE VIEW FN71949.whereVisitorCanGetsOn(VISITOR_NAME, VISITOR_UNIQUE_NUMBER, VISITOR_AGE, VISITOR_HEIGHT, ATTRACTION_NAME, ATTRACTION_PARK_NAME)
AS
    SELECT DISTINCT (V.NAME), V.UNIQUE_NUMBER,V.AGE, V.HEIGHT, A.NAME, A.PARK_NAME
    FROM VISITORS AS V, ATTRACTIONS AS A
    WHERE V.AGE >= A.MINIMUM_AGE
    AND V.HEIGHT >= A.MINIMUM_HEIGHT;

DROP VIEW FN71949.whereVisitorCanGetsOn;

SELECT * FROM whereVisitorCanGetsOn;

--Изглед, който показва за всеки доставчик какъв продукт е доставил
CREATE VIEW FN71949.supplierProducts(SUPPLIER_NAME, SUPPLIER_WORK_NUMBER, PRODUCT_NAME)
AS
    SELECT S.NAME, S.WORK_NUMBER, P.PRODUCT_NAME
    FROM SUPPLIERS S, PRODUCTS P
    WHERE S.WORK_NUMBER = P.SUPPLIER_WORK_NUMBER;

SELECT * FROM supplierProducts;