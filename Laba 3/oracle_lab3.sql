
-- Заполнение таблицы USERS
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, ROLE)
VALUES ('user1', 'password1', 'user1@example.com', 'admin');
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, ROLE)
VALUES ('user2', 'password2', 'user2@example.com', 'user');
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, ROLE)
VALUES ('user3', 'password3', 'user3@example.com', 'user');

-- Заполнение таблицы SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, PreviousLevelID)
VALUES ('Software A', '1.0', 'Vendor X', 'Single User', NULL);
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, PreviousLevelID)
VALUES ('Software B', '2.0', 'Vendor Y', 'Multi User', 1);
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, PreviousLevelID)
VALUES ('Software C', '3.0', 'Vendor Z', 'Enterprise', 1);

-- Заполнение таблицы LICENSES
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE)
VALUES (1, 1, TO_DATE('2024-02-25', 'YYYY-MM-DD'), TO_DATE('2025-02-25', 'YYYY-MM-DD'));
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE)
VALUES (2, 2, TO_DATE('2024-02-26', 'YYYY-MM-DD'), TO_DATE('2025-02-26', 'YYYY-MM-DD'));
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE)
VALUES (3, 3, TO_DATE('2024-02-27', 'YYYY-MM-DD'), TO_DATE('2025-02-27', 'YYYY-MM-DD'));


CREATE OR REPLACE TYPE software_type AS OBJECT (
    software_id NUMBER,
    name NVARCHAR2(100),
    version NVARCHAR2(50),
    vendor NVARCHAR2(100),
    license_type NVARCHAR2(50),
    previous_level_id NUMBER,
    node_level NUMBER
);

CREATE OR REPLACE TYPE software_type_table AS TABLE OF software_type;


CREATE OR REPLACE FUNCTION ShowChildNodesWithLevel (p_id IN NUMBER)
RETURN software_type_table PIPELINED IS
BEGIN
    FOR rec IN (
        SELECT
            SOFTWARE_ID,
            NAME,
            VERSION,
            VENDOR,
            LICENSE_TYPE,
            PreviousLevelID, -- Используйте CONNECT_BY_ROOT для получения корневого узла
            LEVEL as node_level
        FROM
            SOFTWARE
        START WITH SOFTWARE_ID = p_id
        CONNECT BY PRIOR SOFTWARE_ID = PreviousLevelID
    ) LOOP
        PIPE ROW(software_type(rec.SOFTWARE_ID, rec.NAME, rec.VERSION, rec.VENDOR, rec.LICENSE_TYPE, rec.PreviousLevelID, rec.node_level));
    END LOOP;
    RETURN;
END;
/

/

-- запуск
SELECT * FROM TABLE(ShowChildNodesWithLevel(1));

-- добавление узла (задание 3)
CREATE OR REPLACE PROCEDURE AddSoftwareNode (
    p_name NVARCHAR2,
    p_version NVARCHAR2,
    p_vendor NVARCHAR2,
    p_license_type NVARCHAR2,
    p_previous_level_id IN NUMBER
) IS
BEGIN
    INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, PreviousLevelID)
    VALUES (p_name, p_version, p_vendor, p_license_type, p_previous_level_id);
    COMMIT;
END;
/

-- запуск
BEGIN AddSoftwareNode('Software E', '4.0', 'Vendor X', 'Single User', 2);
END;
SELECT * FROM TABLE(ShowChildNodesWithLevel(1));

-- перемещение ветки (задание 4)
CREATE OR REPLACE PROCEDURE MoveSoftwareBranch (
    p_old_parent IN NUMBER,
    p_new_parent IN NUMBER
) IS
BEGIN
    UPDATE SOFTWARE
    SET PreviousLevelID = p_new_parent
    WHERE PreviousLevelID = p_old_parent;
    COMMIT;
END;
/

-- запуск
BEGIN MoveSoftwareBranch(3, 4);
END;
SELECT * FROM TABLE(ShowChildNodesWithLevel(1));

-- Вывод узлов после перемещения (можно изменить параметр в соответствии с вашей структурой)
SELECT * FROM TABLE(ShowChildNodesWithLevel(1));