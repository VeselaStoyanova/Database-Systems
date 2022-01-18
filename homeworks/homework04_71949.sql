SET SCHEMA FN71949@

CREATE MODULE MODULE_HOMEWORK04@

--Процедура, която намира броя на служителите в даден отдел
ALTER MODULE FN71949.MODULE_HOMEWORK04 PUBLISH PROCEDURE count_employees2(IN depart_no CHAR(3), OUT emp_count INT)
LANGUAGE SQL
SPECIFIC count_employees2
BEGIN 
	SELECT COUNT(E.EMPNO)
	INTO emp_count
	FROM EMPL1 AS E, DEPART1 AS D
	WHERE E.WORKDEPT = D.DEPTNO
	AND D.DEPTNO = depart_no
	GROUP BY D.DEPTNO;
END@
	
--Тестване на процедурата
CALL FN71949.MODULE_HOMEWORK04.count_employees2('A00', ?)@

--Процедура, която намира кандидатите за нов мениджър на даден отдел
--Кандидати са тези служители, които са били наети преди техния мениджър
--Вдигането на заплатите са е с толкова процента, колкото са служителите в съответния отдел
ALTER MODULE FN71949.MODULE_HOMEWORK04 PUBLISH PROCEDURE find_candidates1(IN depart_no CHAR(3), OUT candidates_result INT)
LANGUAGE SQL
SPECIFIC find_candidates1
BEGIN
	DECLARE empCount INT DEFAULT 0;
	DECLARE mngNo CHAR(6) DEFAULT ' ';
	DECLARE mngName VARCHAR(30) DEFAULT ' ';
	DECLARE empNo CHAR(6) DEFAULT ' ';
	DECLARE empName VARCHAR(28) DEFAULT ' ';
	DECLARE empSalary DECIMAL(9, 2) DEFAULT 0;
	DECLARE candidatesCount INT DEFAULT 0;
	DECLARE atEnd INTEGER DEFAULT 0;
	DECLARE notFound CONDITION FOR SQLSTATE '02000';
	DECLARE myCursor CURSOR FOR 
		SELECT MAN.EMPNO, MAN.FIRSTNME || ' ' || MAN.LASTNAME,
							E.EMPNO, E.FIRSTNME || ' ' || E.LASTNAME, E.SALARY
				FROM EMPL1 AS E, DEPART1 AS DEP, EMPL1 AS MAN
				WHERE E.WORKDEPT = DEP.DEPTNO
				AND MAN.EMPNO = DEP.MGRNO
				AND DEPTNO = depart_no
				AND E.HIREDATE < MAN.HIREDATE;
	DECLARE CONTINUE HANDLER FOR notFound
		SET atEnd = 1;
	CALL FN71949.MODULE_HOMEWORK04.count_employees2(depart_no, empCount);
OPEN myCursor;
	firstLoop: LOOP
		FETCH myCursor INTO mngNo, mngName, empNo, empName, empSalary;
		IF atEnd = 1 THEN
			LEAVE firstLoop;
		END IF;
		INSERT INTO CANDIDATES_INFO
		VALUES (CURRENT_TIMESTAMP, depart_no, mngNo || ' - ' || mngName,
											empNo || ' - ' || empName,
											empSalary,
											empSalary + empSalary * (empCount / 100.0));
		SET candidatesCount = candidatesCount + 1;
	END LOOP;
SET candidates_result = candidatesCount;
CLOSE myCursor;
END@

--Тестване на процедурата
CALL FN71949.MODULE_HOMEWORK04.find_candidates1('A00', ?)@

--Таблицата, в която се записват кандидатите за нов мениджър
CREATE TABLE CANDIDATES_INFO(
	CTIME TIMESTAMP,
	WORKDEPT CHAR(3),
	MNGINFO VARCHAR(200),
	EMPINFO VARCHAR(200),
	EMP_OLDSALARY DECIMAL(9,2),
	EMP_NEWSALARYY DECIMAL(9,2)
)@

SELECT * FROM CANDIDATES_INFO@

SELECT * FROM EMPL1@

--Тестване на заявките от процедурите
SELECT COUNT(E.EMPNO)
FROM EMPL1 AS E, DEPART1 AS D
WHERE E.WORKDEPT = D.DEPTNO
AND D.DEPTNO = 'A00'
GROUP BY D.DEPTNO@

SELECT MAN.EMPNO, MAN.FIRSTNME || ' ' || MAN.LASTNAME,
							E.EMPNO, E.FIRSTNME || ' ' || E.LASTNAME, E.SALARY
				FROM EMPL1 AS E, DEPART1 AS DEP, EMPL1 AS MAN
				WHERE E.WORKDEPT = DEP.DEPTNO
				AND MAN.EMPNO = DEP.MGRNO
				AND DEPTNO = 'A00'
				AND E.HIREDATE < MAN.HIREDATE@
				
				