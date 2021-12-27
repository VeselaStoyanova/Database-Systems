SET SCHEMA FN71949@

--1. ��������� ���������, � ����� �� ����� ���������� ���� ���� cursor, 
--���� ����� (for, while ��� ����) � ��� Condition Handling. 
--����������� ��������� EMP � DEPT �� ������� 1 .

CREATE PROCEDURE FN71949.INC_BONUS_HW3()
LANGUAGE SQL
BEGIN
	DECLARE cursorEnd INTEGER DEFAULT 0;
	DECLARE nullData CONDITION FOR SQLSTATE '22002';
	DECLARE vDeptNo CHAR(3) DEFAULT ' ';
	DECLARE vMngNo CHAR(6) DEFAULT ' ';
	DECLARE vMngBonus DECIMAL(9, 2) DEFAULT 0;
	DECLARE vEmpCount INTEGER DEFAULT 0;
	DECLARE vAvgSalary DECIMAL(9, 2) DEFAULT 0;
	DECLARE notNextLine CONDITION FOR SQLSTATE '02000';
	DECLARE firstCursor CURSOR
		FOR SELECT DEPART.DEPTNO, MANAGER.EMPNO, MANAGER.BONUS, COUNT(EMP.EMPNO) AS EMP_CNT,
		DECIMAL(AVG(EMP.SALARY), 8, 2) AS AVG_SALARY
		FROM EMPL1 AS EMP, EMPL1 AS MANAGER, DEPART1 AS DEPART
		WHERE EMP.WORKDEPT = DEPART.DEPTNO
		AND MANAGER.EMPNO = DEPART.MGRNO
		GROUP BY DEPART.DEPTNO, MANAGER.EMPNO, MANAGER.BONUS;
	DECLARE CONTINUE HANDLER FOR notNextLine
		SET cursorEnd = 1;
	DECLARE CONTINUE HANDLER FOR nullData
		CALL DBMS_OUTPUT.PUT_LINE('No bonus received');
OPEN firstCursor;
	firstLoop: LOOP
		FETCH firstCursor INTO vDeptNo, vMngNo, vMngBonus, vEmpCount, vAvgSalary;
		IF cursorEnd = 1 THEN 
			LEAVE firstLoop;
		END IF;
		IF vEmpCount >= 5 THEN
			IF vMngBonus IS NULL THEN
				SIGNAL nullData;
			ELSE
				UPDATE EMPL1
					SET BONUS = vMngBonus + vAvgSalary * 0.05
				WHERE EMPNO = vMngNo;
			END IF;
		END IF;
	END LOOP;
CLOSE firstCursor;
END@

SELECT DEPART.DEPTNO, MANAGER.EMPNO, MANAGER.BONUS, COUNT(EMP.EMPNO) AS EMP_CNT,
		DECIMAL(AVG(EMP.SALARY), 8, 2) AS AVG_SALARY
		FROM EMPL1 AS EMP, EMPL1 AS MANAGER, DEPART1 AS DEPART
		WHERE EMP.WORKDEPT = DEPART.DEPTNO
		AND MANAGER.EMPNO = DEPART.MGRNO
		GROUP BY DEPART.DEPTNO, MANAGER.EMPNO, MANAGER.BONUS@
	
CALL FN71949.INC_BONUS_HW3()@
		