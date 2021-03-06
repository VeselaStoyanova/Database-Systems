CREATE TABLE PARKS
(
    NAME    VARCHAR(100) PRIMARY KEY NOT NULL,
    ADDRESS VARCHAR(200)             NOT NULL
);

CREATE TABLE ATTRACTIONS
(
    NAME           VARCHAR(100) PRIMARY KEY NOT NULL,
    PARK_NAME      VARCHAR(100)             NOT NULL REFERENCES PARKS (NAME),
    TYPE           VARCHAR(10) CHECK ( TYPE IN ('FAST', 'CALM', 'WATER', 'DARK', 'NOISY', 'DANGER', 'CHILD')),
    MINIMUM_AGE    INT CHECK ( MINIMUM_AGE > 0 ),
    DURATION       INT CHECK ( DURATION > 0 ),
    SPEED          INT CHECK ( SPEED > 0 ),
    DANGERS        VARCHAR(200),
    MINIMUM_HEIGHT DOUBLE CHECK ( MINIMUM_HEIGHT > 0 ),
    WORK_TIME      VARCHAR(50),
    HEIGHT         DOUBLE CHECK ( HEIGHT > 0 ),
    LENGTH         DOUBLE CHECK ( LENGTH > 0 ),
    CONDITIONS     VARCHAR(10) CHECK ( CONDITIONS IN ('OPEN', 'CLOSE'))
);

CREATE TABLE GETS_ON
(
    ATTRACTION_NAME        VARCHAR(100) NOT NULL REFERENCES ATTRACTIONS (NAME),
    VISITORS_UNIQUE_NUMBER CHAR(10)     NOT NULL REFERENCES VISITORS (UNIQUE_NUMBER)
);

CREATE TABLE GOES_TO
(
    PARKS_NAME             VARCHAR(100) NOT NULL REFERENCES PARKS (NAME),
    VISITORS_UNIQUE_NUMBER CHAR(10)     NOT NULL REFERENCES VISITORS (UNIQUE_NUMBER),
    FROM_DATE              DATE,
    TO_DATE                DATE,
    DURATION               INT CHECK ( DURATION > 0 )
);

CREATE TABLE VISITORS
(
    UNIQUE_NUMBER CHAR(10)     NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    HEIGHT        DOUBLE CHECK ( HEIGHT > 0 ),
    AGE           INT CHECK ( AGE > 0 ),
    NAME          VARCHAR(100) NOT NULL,
    EMAIL         VARCHAR(100) CHECK (EMAIL LIKE '%_@_%.__%'),
    PHONE_NUMBER  CHAR(10)
);

CREATE TABLE OWNS
(
    VISITORS_UNIQUE_NUMBER CHAR(10) NOT NULL REFERENCES VISITORS (UNIQUE_NUMBER),
    TICKETS_UNIQUE_NUMBER  CHAR(10) NOT NULL REFERENCES TICKETS (UNIQUE_NUMBER)
);

CREATE TABLE TICKETS
(
    UNIQUE_NUMBER      CHAR(10)                   NOT NULL PRIMARY KEY,
    PARK_NAME          VARCHAR(100)               NOT NULL REFERENCES PARKS (NAME),
    TYPE               VARCHAR(50) CHECK ( TYPE IN ('ONE_DAY', 'TWO_DAYS', 'WEEKLY', 'FAMILY', 'COMBO', 'CHILD')),
    NUMBER_OF_VISITORS INT CHECK ( NUMBER_OF_VISITORS > 0 ),
    PRICE              DOUBLE CHECK ( PRICE > 0 ) NOT NULL
);

CREATE TABLE EMPLOYEES
(
    WORK_NUMBER   CHAR(10)     NOT NULL PRIMARY KEY,
    PARK_NAME     VARCHAR(100) NOT NULL REFERENCES PARKS (NAME),
    SHOP_NAME     VARCHAR(100) NOT NULL REFERENCES SHOPS (NAME),
    EMAIL         VARCHAR(100),
    PHONE_NUMBER  CHAR(10),
    EMPLOYEE_NAME VARCHAR(100) NOT NULL
);

CREATE TABLE SHOPS
(
    NAME       VARCHAR(100) NOT NULL PRIMARY KEY,
    PARK_NAME  VARCHAR(100) NOT NULL REFERENCES PARKS (NAME),
    CONDITIONS VARCHAR(10) CHECK ( CONDITIONS IN ('OPEN', 'CLOSE'))
);

CREATE TABLE PRODUCTS
(
    INVENTORY_NUMBER     CHAR(10)                   NOT NULL PRIMARY KEY,
    SUPPLIER_WORK_NUMBER CHAR(10)                   NOT NULL REFERENCES SUPPLIERS (WORK_NUMBER),
    SHOP_NAME            VARCHAR(100)               NOT NULL REFERENCES SHOPS (NAME),
    PRICE                DOUBLE CHECK ( PRICE > 0 ) NOT NULL,
    PRODUCT_NAME         VARCHAR(100)               NOT NULL,
    TYPE                 VARCHAR(50) CHECK (TYPE IN ('FOOD', 'CLOTHES', 'OTHERS'))
);

CREATE TABLE FOOD
(
    INVENTORY_NUMBER CHAR(10) NOT NULL REFERENCES PRODUCTS (INVENTORY_NUMBER),
    EXPIRY_DATE      DATE
);

CREATE TABLE CLOTHES
(
    INVENTORY_NUMBER CHAR(10) NOT NULL REFERENCES PRODUCTS (INVENTORY_NUMBER),
    SIZE             INT CHECK ( SIZE > 0 ),
    GENDER           CHAR(1) CHECK (GENDER IN ('M', 'F')),
    COLOR            VARCHAR(20)
);

CREATE TABLE OTHERS
(
    INVENTORY_NUMBER CHAR(10) NOT NULL REFERENCES PRODUCTS (INVENTORY_NUMBER),
    SIZE             INT CHECK ( SIZE > 0 ),
    MATERIAL         VARCHAR(30)
);

CREATE TABLE SUPPLIERS
(
    WORK_NUMBER  CHAR(10)     NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    NAME         VARCHAR(100) NOT NULL,
    EMAIL        VARCHAR(100),
    PHONE_NUMBER CHAR(10)
);
