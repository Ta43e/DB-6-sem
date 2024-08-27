DECLARE
    TYPE LicenseCollection IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE RoomCollection IS TABLE OF Object_RoomClasses%ROWTYPE INDEX BY PLS_INTEGER;

    licenses_collection LicenseCollection;
    rooms_collection RoomCollection;
BEGIN
    SELECT * BULK COLLECT INTO licenses_collection FROM Object_Licenses;
    SELECT * BULK COLLECT INTO rooms_collection FROM Object_RoomClasses;
END;

DECLARE
    TYPE LicenseCollection IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE RoomCollection IS TABLE OF Object_RoomClasses%ROWTYPE INDEX BY PLS_INTEGER;

    licenses_collection LicenseCollection;
    rooms_collection RoomCollection;
    is_member BOOLEAN;
BEGIN
    -- Populate collections
    SELECT * BULK COLLECT INTO licenses_collection FROM Object_Licenses;
    SELECT * BULK COLLECT INTO rooms_collection FROM Object_RoomClasses;

    -- Check membership
    FOR i IN licenses_collection.FIRST .. licenses_collection.LAST LOOP
        is_member := FALSE;
        FOR j IN rooms_collection.FIRST .. rooms_collection.LAST LOOP
            IF rooms_collection(j).room_class_obj.user_id = licenses_collection(i).license_obj.user_id THEN
                is_member := TRUE;
                EXIT;
            END IF;
        END LOOP;
        IF is_member THEN
            DBMS_OUTPUT.PUT_LINE('Element ' || i || ' in LicenseCollection is a member of RoomCollection.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Element ' || i || ' in LicenseCollection is not a member of RoomCollection.');
        END IF;
    END LOOP;
END;

DECLARE
    TYPE LicenseCollection IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;

    licenses_collection LicenseCollection;
    empty_collections VARCHAR2(1000);
BEGIN
    -- Populate licenses_collection
    SELECT * BULK COLLECT INTO licenses_collection FROM Object_Licenses;

    -- Check for empty collections
    empty_collections := '';
    FOR i IN licenses_collection.FIRST .. licenses_collection.LAST LOOP
        -- Check if any field within the record is null
        IF licenses_collection(i).license_obj.license_id IS NULL OR
           licenses_collection(i).license_obj.software_id IS NULL OR
           licenses_collection(i).license_obj.user_id IS NULL OR
           licenses_collection(i).license_obj.start_date IS NULL OR
           licenses_collection(i).license_obj.end_date IS NULL OR
           licenses_collection(i).license_obj.license_cost IS NULL THEN
            empty_collections := empty_collections || ' ' || i;
        END IF;
    END LOOP;

    IF empty_collections = '' THEN
        DBMS_OUTPUT.PUT_LINE('There are no empty collections in LicenseCollection.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Empty collections in LicenseCollection: ' || empty_collections);
    END IF;
END;



DECLARE
    TYPE LicenseCollection IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;

    licenses_collection LicenseCollection;
    TYPE LicenseCollectionNew IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;
    new_licenses_collection LicenseCollectionNew;
BEGIN
    SELECT * BULK COLLECT INTO licenses_collection FROM Object_Licenses;

    FOR i IN licenses_collection.FIRST .. licenses_collection.LAST LOOP
        new_licenses_collection(i) := licenses_collection(i);
    END LOOP;
END;

select  * from  Example_Licensess;

DECLARE
    TYPE LicenseCollection IS TABLE OF Object_Licenses%ROWTYPE INDEX BY PLS_INTEGER;
    licenses_collection LicenseCollection;
BEGIN
    -- Заполним licenses_collection данными
    SELECT * BULK COLLECT INTO licenses_collection FROM Object_Licenses;

    -- Вставим данные из licenses_collection в таблицу Example_Licenses
    FOR i IN 1 .. licenses_collection.COUNT LOOP
        INSERT INTO Example_Licensess (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
        VALUES (
            licenses_collection(i).license_obj.software_id,
            licenses_collection(i).license_obj.user_id,
            licenses_collection(i).license_obj.start_date,
            licenses_collection(i).license_obj.end_date,
            licenses_collection(i).license_obj.license_cost
        );
    END LOOP;
END;

create  TABLE Example_Licensess (
    LICENSE_ID INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    SOFTWARE_ID INT NOT NULL,
    USER_ID INT NOT NULL,
    START_DATE DATE NOT NULL,
    END_DATE DATE NOT NULL,
    LICENSE_COST DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (SOFTWARE_ID) REFERENCES SOFTWARE(SOFTWARE_ID),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);










