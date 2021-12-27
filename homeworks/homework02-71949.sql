--1. Задавате схемата по подразбиране на схемата с вашия ФН (Например FN71000).
SET SCHEMA FN71949@

--2. Създавате модул във вашата схема.
CREATE MODULE HOMEWORK_2@

--3.Създавате асоциативен масив с индекс низ и стойности на масива също низове.
ALTER MODULE HOMEWORK_2 ADD TYPE EMPDEPT_NAMES_ARR AS VARCHAR(30) ARRAY[VARCHAR(36)]@

ALTER MODULE HOMEWORK_2 ADD VARIABLE EMPDEPT_CURSOR
CURSOR CONSTANT (CURSOR FOR SELECT FIRSTNME || ' ' || LASTNAME, DEPTNAME, SALARY 
							FROM EMPL1 AS E, DEPART1 AS D 
							WHERE E.WORKDEPT = D.DEPTNO)@
							
--4. Създавате процедура, в която да имате реализиран поне един cursor, един цикъл (for, while или друг) 
--   и да използвате дефинираният от вас асоциативен масив.
-- 	 (Процедурата трябва да бъде част от модула). Използвайте таблиците EMP и DEPT от Домашно 1.
ALTER MODULE HOMEWORK_2 ADD TYPE EMP_ROW AS 
ROW (EMP_NAME VARCHAR(30), DEPT_NAME ANCHOR DEPART1.DEPTNAME, EMP_SALARY ANCHOR EMPL1.SALARY)@

ALTER MODULE FN71949.HOMEWORK_2 PUBLISH PROCEDURE EMP_INFO_LIST3(IN IN_SALARY ANCHOR EMPL1.SALARY)
BEGIN
	DECLARE EMPVAR EMP_ROW;
	DECLARE EMPDEPT_ARRVAR EMPDEPT_NAMES_ARR;
	DECLARE sqlcode INT;
	DECLARE EMP_NAME VARCHAR(30);
	
	OPEN EMPDEPT_CURSOR;
	
	FETCH EMPDEPT_CURSOR INTO EMPVAR;
	WHILE sqlcode = 0 DO
		IF EMPVAR.EMP_SALARY > IN_SALARY
		THEN
			SET EMPDEPT_ARRVAR[EMPVAR.EMP_NAME] = EMPVAR.DEPT_NAME;
		END IF;
		FETCH EMPDEPT_CURSOR INTO EMPVAR;
	END WHILE;
	
	SET EMP_NAME = ARRAY_FIRST(EMPDEPT_ARRVAR);
	WHILE EMP_NAME IS NOT NULL DO
		INSERT INTO FN71949.EMP_INFO2 
		VALUES('EMPLOYEE NAME: ' || EMP_NAME || ' - DEPARTMENT NAME: ' || EMPDEPT_ARRVAR[EMP_NAME]);
		SET EMP_NAME = ARRAY_NEXT(EMPDEPT_ARRVAR, EMP_NAME); -- минава на следващия индекс от масива
	END WHILE;
END@

-- отделна таблица, в която се записват данните от създадения асоциативен масив
CREATE TABLE EMP_INFO2(
	EMPINFO VARCHAR(200)
)@


--5. Извиквате процедурата.
CALL FN71949.HOMEWORK_2.EMP_INFO_LIST3(10000)@

SELECT * FROM EMP_INFO2@

