SET SCHEMA FN71949;

--Функция, която по подадено име на парк връща средната възраст на посетителите на този парк
CREATE FUNCTION FN71949.averageAgeOfVisitors(parkName VARCHAR(100))
RETURNS TABLE(
    park_name VARCHAR(100),
    avg_visitors_age INTEGER
    )
RETURN
    SELECT PARK.NAME AS PARK_NAME, AVG(VISITOR.AGE) AS AVG_VISITORS_AGE
    FROM PARKS AS PARK, VISITORS AS VISITOR, GOES_TO AS GOES_TO
    WHERE GOES_TO.PARKS_NAME = PARK.NAME
    AND GOES_TO.VISITORS_UNIQUE_NUMBER = VISITOR.UNIQUE_NUMBER
    AND PARK.NAME = parkName
    GROUP BY PARK.NAME;

SELECT * FROM TABLE (FN71949.averageAgeOfVisitors('Plovdiv'));

SELECT * FROM TABLE (FN71949.averageAgeOfVisitors('Montana'));

--Функция, която по подадено име на парк връща най-важната информация за атракциите в него
CREATE FUNCTION FN71949.attractionsBasicInfo(parkName VARCHAR(100))
RETURNS TABLE(
    attractionName VARCHAR(100),
    attractionWorkTime VARCHAR(50),
    attractionType VARCHAR(10),
    attractionMinimumHeight DOUBLE
)
RETURN
    SELECT ATTR.NAME AS ATTRACTION_NAME, ATTR.WORK_TIME AS ATTRACTION_WORK_TIME,
           ATTR.TYPE AS ATTRACTION_TYPE, ATTR.MINIMUM_HEIGHT AS ATTRACTION_MIN_HEIGHT
    FROM PARKS AS PARK, ATTRACTIONS AS ATTR
    WHERE PARK.NAME = ATTR.PARK_NAME
    AND PARK_NAME = parkName;

SELECT * FROM TABLE (FN71949.attractionsBasicInfo('Gabrovo'));

SELECT * FROM TABLE (FN71949.attractionsBasicInfo('Sofia'));

--Фунцкия, която по подадено име на атракция връща информация за посетителите, които са се качили на нея
CREATE FUNCTION FN71949.attractionVisitorBasicInfo(attractionName VARCHAR(100))
RETURNS TABLE(
    attractionName VARCHAR(100),
    visitorName VARCHAR(100),
    visitorAge INTEGER,
    visitorPhoneNumber CHAR(10)
)
RETURN
    SELECT ATTR.NAME AS ATTR_NAME, VISITOR.NAME AS VISITOR_NAME, VISITOR.AGE AS VISITOR_AGE, VISITOR.PHONE_NUMBER AS VISITOR_PHONE_NUMBER
    FROM ATTRACTIONS AS ATTR, VISITORS AS VISITOR, GETS_ON AS GETS
    WHERE ATTR.NAME = GETS.ATTRACTION_NAME
    AND VISITOR.UNIQUE_NUMBER = GETS.VISITORS_UNIQUE_NUMBER
    AND ATTR.NAME = attractionName;

SELECT * FROM TABLE (FN71949.attractionVisitorBasicInfo('Jungle Snake'));

SELECT * FROM TABLE (FN71949.attractionVisitorBasicInfo('Pirates of Caribbean'));