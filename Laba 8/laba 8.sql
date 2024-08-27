

-- Создание объектного типа данных для лицензии
CREATE OR REPLACE TYPE LicenseType AS OBJECT (
    license_id INTEGER,
    software_id INTEGER,
    user_id INTEGER,
    start_date DATE,
    end_date DATE,
    license_cost DECIMAL(10, 2),

    CONSTRUCTOR FUNCTION LicenseType(
        license_id INTEGER,
        software_id INTEGER,
        user_id INTEGER,
        start_date DATE,
        end_date DATE,
        license_cost DECIMAL
    ) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION LicenseTypeMap RETURN VARCHAR2,
    MEMBER FUNCTION getLicenseCost RETURN DECIMAL,
    MEMBER PROCEDURE printLicenseInfo
);
/

-- Создание объектного типа данных для класса комнаты
CREATE OR REPLACE TYPE RoomClassType AS OBJECT (
    class_id INTEGER,
    class_name NVARCHAR2(50),
    user_id INTEGER,

    CONSTRUCTOR FUNCTION RoomClassType(
        class_id INTEGER,
        class_name NVARCHAR2,
        user_id INTEGER
    ) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION RoomClassMap RETURN VARCHAR2,
    MEMBER FUNCTION getClass RETURN DECIMAL DETERMINISTIC,
    MEMBER PROCEDURE printClassInfo
);
/

-- Реализация конструктора для лицензии
CREATE OR REPLACE TYPE BODY LicenseType AS
    CONSTRUCTOR FUNCTION LicenseType(
        license_id INTEGER,
        software_id INTEGER,
        user_id INTEGER,
        start_date DATE,
        end_date DATE,
        license_cost DECIMAL
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.license_id := license_id;
        self.software_id := software_id;
        self.user_id := user_id;
        self.start_date := start_date;
        self.end_date := end_date;
        self.license_cost := license_cost;
        RETURN;
    END;


    MAP MEMBER FUNCTION LicenseTypeMap RETURN VARCHAR2 IS
    BEGIN
        RETURN user_id || ' | ' || start_date || ' | ' || end_date || ' | ' || license_cost;
    END;

    MEMBER FUNCTION getLicenseCost RETURN DECIMAL IS
    BEGIN
        RETURN self.license_cost;
    END getLicenseCost;

    MEMBER PROCEDURE printLicenseInfo IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('License ID: ' || self.license_id);
        DBMS_OUTPUT.PUT_LINE('Software ID: ' || self.software_id);
        DBMS_OUTPUT.PUT_LINE('User ID: ' || self.user_id);
        DBMS_OUTPUT.PUT_LINE('Start Date: ' || TO_CHAR(self.start_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('End Date: ' || TO_CHAR(self.end_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('License Cost: ' || self.license_cost);
    END printLicenseInfo;
END;
/

DECLARE
    license1 LicenseType := LicenseType(1, 101, 201, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'), 100.00);
    license2 LicenseType := LicenseType(2, 102, 202, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'), 200.00);
    result INTEGER;
BEGIN
    result := license1.compareLicense(license2);
    DBMS_OUTPUT.PUT_LINE('Comparison result: ' || result);
END;

DECLARE
    license LicenseType := LicenseType(1, 101, 201, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'), 100.00);
    cost DECIMAL;
BEGIN
    cost := license.getLicenseCost();
    DBMS_OUTPUT.PUT_LINE('License cost: ' || cost);
END;

DECLARE
    license LicenseType := LicenseType(1, 101, 201, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'), 100.00);
BEGIN
    license.printLicenseInfo();
END;

-- Реализация конструктора для класса комнаты
CREATE OR REPLACE TYPE BODY RoomClassType AS
    CONSTRUCTOR FUNCTION RoomClassType(
        class_id INTEGER,
        class_name NVARCHAR2,
        user_id INTEGER
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.class_id := class_id;
        self.class_name := class_name;
        self.user_id := user_id;
        RETURN;
    END;


    MAP MEMBER FUNCTION RoomClassMap RETURN VARCHAR2 IS
    BEGIN
        RETURN class_name || ' | ' || class_id || ' | ' || user_id;
    END;

    MEMBER FUNCTION getClass RETURN DECIMAL DETERMINISTIC  IS
    BEGIN
        RETURN self.class_name;
    END getClass;

    MEMBER PROCEDURE printClassInfo IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Class ID: ' || self.class_id);
        DBMS_OUTPUT.PUT_LINE('Class Name: ' || self.class_name);
        DBMS_OUTPUT.PUT_LINE('User ID: ' || self.user_id);
    END printClassInfo;
END;
/

CREATE TABLE Object_Licenses (
    license_obj LicenseType
);

CREATE TABLE Object_RoomClasses (
    room_class_obj RoomClassType
);


/
DECLARE
    licenses_cursor SYS_REFCURSOR;
    license_row LICENSES%ROWTYPE;
BEGIN
    OPEN licenses_cursor FOR SELECT * FROM LICENSES;
    LOOP
        FETCH licenses_cursor INTO license_row;
        EXIT WHEN licenses_cursor%NOTFOUND;

        -- Создание объекта типа лицензии и вставка его в объектную таблицу
        INSERT INTO Object_Licenses VALUES (
            LicenseType(
                license_row.LICENSE_ID,
                license_row.SOFTWARE_ID,
                license_row.USER_ID,
                license_row.START_DATE,
                license_row.END_DATE,
                license_row.LICENSE_COST
            )
        );
    END LOOP;
    CLOSE licenses_cursor;
END;
/

DECLARE
    room_classes_cursor SYS_REFCURSOR;
    room_class_row ROOM_CLASSES%ROWTYPE;
BEGIN
    OPEN room_classes_cursor FOR SELECT * FROM ROOM_CLASSES;
    LOOP
        FETCH room_classes_cursor INTO room_class_row;
        EXIT WHEN room_classes_cursor%NOTFOUND;

        -- Создание объекта типа класса комнаты и вставка его в объектную таблицу
        INSERT INTO Object_RoomClasses VALUES (
            RoomClassType(
                room_class_row.CLASS_ID,
                room_class_row.CLASS_NAME,
                room_class_row.USER_ID
            )
        );
    END LOOP;
    CLOSE room_classes_cursor;
END;
/


CREATE VIEW License_View AS
SELECT *
FROM Object_Licenses license_obj;

CREATE VIEW RoomClass_View AS
SELECT *
FROM Object_RoomClasses room_class_obj;

SELECT * FROM  License_View;
SELECT * FROM  RoomClass_View;



create table res_with_index(
    resv RoomClassType
);

CREATE INDEX software_id_idx ON Object_Licenses (license_obj.software_id);
create bitmap index  reserv_method_index on res_with_index(resv.getClass());

select  * from  Object_Licenses e where  e.LICENSE_OBJ.software_id = 1;

select * from res_with_index e
         where e.resv.getClass() = 'Classroom';