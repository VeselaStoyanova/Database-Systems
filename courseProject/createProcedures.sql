SET SCHEMA FN71949@

--процедура с курсор и входни и изходни параметри;
--процедура, която има за цел да създаде нова таблица, където ще се пази
--информация за името, годините и имейла на всички посетители, които са се качили на дадена атракция
--Името на таблицата се задава от потребителя като входен параметър, заедно с името на атракцията
--Процедурата връща като резултат дали успешно е създадена таблицата и броя на добавените редове в нея

--Помощна процедура за създаване на таблицата
CREATE PROCEDURE FN71949.createTableByAttractionName(IN p_tableName VARCHAR(50))
BEGIN
    DECLARE p_tableQuery VARCHAR(1000);
    SET p_tableQuery = 'CREATE TABLE ' || p_tableName || '(NAME VARCHAR(100), AGE INT, EMAIL VARCHAR(100))';
    PREPARE s1 FROM p_tableQuery;
    EXECUTE s1;
    end@

--Помощна процедура за добавяне на данни в таблицата
CREATE PROCEDURE FN71949.insertIntoAttractionTable(IN p_tableName VARCHAR(50), IN v_name VARCHAR(100), IN v_age INT, IN v_email VARCHAR(100))
LANGUAGE SQL
BEGIN
    DECLARE statement VARCHAR(1000);
        SET statement = 'INSERT INTO ' || p_tableName || ' VALUES (''' || v_name || ''', '''
					|| v_age || ''', ''' || v_email || ''')';
    PREPARE s1 FROM statement;
    EXECUTE s1;
end@

CREATE PROCEDURE FN71949.createAttractionInfo(IN p_attractionName VARCHAR(100), IN p_tableName VARCHAR(50),
                                                OUT p_isSuccessfullAdded VARCHAR(150), OUT p_insertedRows VARCHAR(150))
LANGUAGE SQL
SPECIFIC createAttractionInfo
BEGIN
    DECLARE v_countVisitors INTEGER DEFAULT 0;
    DECLARE v_visitorName VARCHAR(100) DEFAULT ' ';
    DECLARE v_visitorAge INTEGER DEFAULT 0;
    DECLARE v_visitorEmail VARCHAR(100) DEFAULT ' ';
    DECLARE at_End INTEGER DEFAULT 0;
    DECLARE not_found CONDITION FOR SQLSTATE '02000';
    DECLARE firstCursor CURSOR FOR
        SELECT V.NAME, V.AGE, V.EMAIL
               FROM VISITORS AS V, GETS_ON AS G, ATTRACTIONS AS A
    WHERE p_attractionName = G.ATTRACTION_NAME
    AND V.UNIQUE_NUMBER = G.VISITORS_UNIQUE_NUMBER
    AND A.NAME = G.ATTRACTION_NAME;
    DECLARE CONTINUE HANDLER FOR not_found
        SET at_end = 1;
    CALL FN71949.createTableByAttractionName(p_tableName);
OPEN firstCursor;
    firstLoop: LOOP
        FETCH firstCursor INTO v_visitorName, v_visitorAge, v_visitorEmail;
        IF at_end = 1 THEN
            LEAVE firstLoop;
        end if;
        CALL FN71949.insertIntoAttractionTable(p_tableName, v_visitorName, v_visitorAge, v_visitorEmail);
    SET v_countVisitors = v_countVisitors + 1;
    end loop;
SET p_isSuccessfullAdded = 'Table with name ' || p_tableName || 'was successful created.';
SET p_insertedRows = v_countVisitors || ' rows were inserted.';
end@

CALL FN71949.createAttractionInfo('Splash Mountain', 'INFO_ABOUT_SPLASH_MOUNTAIN', ?, ?)@

SELECT * FROM INFO_ABOUT_SPLASH_MOUNTAIN@

DROP TABLE INFO_ABOUT_SPLASH_MOUNTAIN@

--Процедура, която извежда информация за номер на служител, име на служител и магазин, в който работи служителя.
--Ако се появи грешка, тя ще бъде прихваната с UNDO handler-a 
--Тоест ако е намерена null стойност, то ще се прекрати обхождането на редовете и ще се изведе резултата до тук

--Таблица, в която ще се извежда резултата от процедурата
CREATE TABLE FN71949.EMPLOYEE_WORKNUMBER_CHANGE(CTIME TIMESTAMP, MESSAGE VARCHAR(5000))@
DROP TABLE FN71949.EMPLOYEE_WORKNUMBER_CHANGE@

CREATE PROCEDURE FN71949.EMPLOYEES_ITERATE()
LANGUAGE SQL
BEGIN ATOMIC
	DECLARE nullValue INTEGER DEFAULT 0;
	DECLARE outOfRange INTEGER DEFAULT 0;
	
	DECLARE employeeWorkNumber CHAR(10) DEFAULT ' ';
	DECLARE employeeName VARCHAR(100) DEFAULT ' ';
	DECLARE employeeShopName VARCHAR(100) DEFAULT ' ';
	
	DECLARE nullNotAllowed CONDITION FOR SQLSTATE '22004';
	DECLARE outRange CONDITION FOR SQLSTATE '02000';
	
	--Курсор, с който щеобходим редовете на таблицата EMPLOYEE
	DECLARE firstCursor CURSOR FOR SELECT WORK_NUMBER, EMPLOYEE_NAME, SHOP_NAME FROM FN71949.EMPLOYEES;
	
	--Декларирам типовете condition handlers
	DECLARE UNDO HANDLER FOR nullNotAllowed SET nullValue = 1;
	DECLARE CONTINUE HANDLER FOR outRange SET outOfRange = 1;
	
	OPEN firstCursor;
	firstLoop: LOOP
		FETCH firstCursor INTO employeeWorkNumber, employeeName, employeeShopName;
		IF nullValue = 1 OR outOfRange = 1 THEN LEAVE firstLoop;
		ELSEIF employeeWorkNumber = '0000000001' THEN ITERATE firstLoop;
		END IF;
		
		INSERT INTO FN71949.EMPLOYEE_WORKNUMBER_CHANGE(CTIME, MESSAGE) 
		VALUES(CURRENT_TIMESTAMP, 'WNumber:' || employeeWorkNumber || ' EName:' || employeeName || ' Shop:' || employeeShopName);
	END LOOP;
	CLOSE firstCursor;
END@

DROP PROCEDURE FN71949.EMPLOYEES_ITERATE()@

SELECT * FROM FN71949.EMPLOYEE_WORKNUMBER_CHANGE@
CALL FN71949.EMPLOYEES_ITERATE()@
SELECT * FROM FN71949.EMPLOYEE_WORKNUMBER_CHANGE@
		
--Процедура, която по въведено име на продукт връща служебния номер на доставчика на този продукт
CREATE TABLE PRODUCT_SUPPL(
	PRODUCT_NAME VARCHAR(100),
	SUPPL_WORK_NUMBER CHAR(10)
)@

CREATE PROCEDURE FN71949.productSupplier(IN productName VARCHAR(100), OUT supplierWorkNumber CHAR(10))
LANGUAGE SQL
BEGIN 
	DECLARE atEnd INTEGER DEFAULT 0;
	DECLARE v_product_name VARCHAR(100);
	DECLARE v_supplier_work_number CHAR(10);
	
	DECLARE firstCursor CURSOR FOR SELECT SUPPLIER_WORK_NUMBER, PRODUCT_NAME FROM PRODUCTS;
	
	OPEN firstCursor;
	
	WHILE atEnd = 0 DO
		FETCH firstCursor INTO v_supplier_work_number, v_product_name;
		IF productName = v_product_name THEN SET atEnd = 1;
		END IF;
	END WHILE;
	
	SET supplierWorkNumber = v_supplier_work_number;
	INSERT INTO PRODUCT_SUPPL(PRODUCT_NAME, SUPPL_WORK_NUMBER) VALUES (v_product_name, v_supplier_work_number);
	
	CLOSE firstCursor;
END@	

DROP PROCEDURE FN71949.productSupplier@
 

CALL FN71949.productSupplier('DRESS', ?)@
SELECT * FROM PRODUCT_SUPPL@