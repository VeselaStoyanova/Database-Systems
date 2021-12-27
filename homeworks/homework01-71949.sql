--1. �������� ������� �� ������������ �� ������� � ����� �� (�������� FN71000)
SET SCHEMA FN71949@

--2. �������� ����������� �� ��������� EMP � DEPT �� ������� DB2INST1 ��� ������ �����
CREATE TABLE EMPL1 LIKE DB2INST1.EMPLOYEE@

CREATE TABLE DEPART1 LIKE DB2INST1.DEPARTMENT@

--3. ��������� PK, FK �� ���������� �������
ALTER TABLE EMPL1 ADD CONSTRAINT EMPL_PK PRIMARY KEY(EMPNO)@
ALTER TABLE DEPART1 ADD CONSTRAINT DEPART_PK PRIMARY KEY(DEPTNO)@

ALTER TABLE EMPL1 ADD CONSTRAINT EMPDEPT_FK FOREIGN KEY (WORKDEPT) REFERENCES DEPART1(DEPTNO)@
ALTER TABLE DEPART1 ADD CONSTRAINT DEPTEMP_FK FOREIGN KEY (MGRNO) REFERENCES EMPL1(EMPNO)@

--4. �������� ������� �� ��������� EMP � DEPT �� ������� DB2INST1 ��� ������ �����
INSERT INTO EMPL1 (SELECT * FROM DB2INST1.EMPLOYEE)@
SELECT * FROM EMPL1@

INSERT INTO DEPART1 (SELECT * FROM DB2INST1.DEPARTMENT)@
SELECT * FROM DEPART1@

--5. ��������� ����� ��� ������ �����
CREATE MODULE MOD2_EMPDEPT@

--6. ��������� ���������, ����� �� ����� �� ����� ����� ���������� ��������� ��������� ��� �� ������, ����� �� ������� ���, 
--���� ��������� ��� ������ � ������ ������� �� ������ (����������� ������ �� ���� ���� �� ������)
--��������� �� �����������
ALTER MODULE MOD2_EMPDEPT
PUBLISH PROCEDURE DEPT_INFO(IN in_deptno ANCHOR DEPART1.DEPTNO)@

--������������� �� �����������
ALTER MODULE MOD2_EMPDEPT
ADD PROCEDURE DEPT_INFO(IN in_deptno ANCHOR DEPART1.DEPTNO)
RESULT SET 1
BEGIN 								
DECLARE C1 CURSOR WITH RETURN FOR	--���������� �� ������
	SELECT D.DEPTNAME,
	   		   M.FIRSTNME || ' ' || M.LASTNAME AS MGR_NAME, 
	   		   COUNT(E.EMPNO) AS CNT_EMP, 
	   		   DECIMAL(AVG(E.SALARY), 8, 2) AS AVG_SAL
		FROM EMPL1 AS E, EMPL1 AS M, DEPART1 AS D
		WHERE E.WORKDEPT = D.DEPTNO
		AND M.EMPNO = D.MGRNO
		AND E.WORKDEPT = in_deptno
		GROUP BY D.DEPTNAME, M.FIRSTNME, M.LASTNAME;
	OPEN C1;					
END@							

--7. ��������� �����������
CALL FN71949.MOD2_EMPDEPT.DEPT_INFO('C01')@
CALL FN71949.MOD2_EMPDEPT.DEPT_INFO('E11')@
CALL FN71949.MOD2_EMPDEPT.DEPT_INFO('B01')@
SELECT * FROM DEPART1@
SELECT * FROM EMPL1@


