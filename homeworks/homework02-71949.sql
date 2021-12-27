--1. �������� ������� �� ������������ �� ������� � ����� �� (�������� FN71000).
SET SCHEMA FN71949@

--2. ��������� ����� ��� ������ �����.
CREATE MODULE HOMEWORK_2@

--3.��������� ����������� ����� � ������ ��� � ��������� �� ������ ���� ������.
ALTER MODULE HOMEWORK_2 ADD TYPE EMPDEPT_NAMES_ARR AS VARCHAR(30) ARRAY[VARCHAR(36)]@

ALTER MODULE HOMEWORK_2 ADD VARIABLE EMPDEPT_CURSOR
CURSOR CONSTANT (CURSOR FOR SELECT FIRSTNME || ' ' || LASTNAME, DEPTNAME, SALARY 
							FROM EMPL1 AS E, DEPART1 AS D 
							WHERE E.WORKDEPT = D.DEPTNO)@
							
--4. ��������� ���������, � ����� �� ����� ���������� ���� ���� cursor, ���� ����� (for, while ��� ����) 
--   � �� ���������� ������������ �� ��� ����������� �����.
-- 	 (����������� ������ �� ���� ���� �� ������). ����������� ��������� EMP � DEPT �� ������� 1.
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
		SET EMP_NAME = ARRAY_NEXT(EMPDEPT_ARRVAR, EMP_NAME); -- ������ �� ��������� ������ �� ������
	END WHILE;
END@

-- ������� �������, � ����� �� �������� ������� �� ���������� ����������� �����
CREATE TABLE EMP_INFO2(
	EMPINFO VARCHAR(200)
)@


--5. ��������� �����������.
CALL FN71949.HOMEWORK_2.EMP_INFO_LIST3(10000)@

SELECT * FROM EMP_INFO2@

