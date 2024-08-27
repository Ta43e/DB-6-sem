-- СОЗДАНИЕ ТАБЛИЦЫ "ПОЛЬЗОВАТЕЛИ"
CREATE  TABLE USERS (
USER_ID INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
USERNAME NVARCHAR2(50) NOT NULL UNIQUE,
PASSWORD NVARCHAR2(50) NOT NULL,
EMAIL NVARCHAR2(100) NOT NULL UNIQUE,
ROLE NVARCHAR2(50) NOT NULL
);

-- СОЗДАНИЕ ТАБЛИЦЫ "ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ"
CREATE TABLE SOFTWARE (
SOFTWARE_ID INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
NAME NVARCHAR2(100) NOT NULL UNIQUE,
VERSION NVARCHAR2(50) NOT NULL,
VENDOR NVARCHAR2(100) NOT NULL,
LICENSE_TYPE NVARCHAR2(50) NOT NULL,
PreviousLevelID NUMBER REFERENCES SOFTWARE (SOFTWARE_ID)
);



-- СОЗДАНИЕ ТАБЛИЦЫ "ЛИЦЕНЗИИ"
CREATE TABLE LICENSES (
LICENSE_ID INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
SOFTWARE_ID INT NOT NULL,
USER_ID INT NOT NULL,
START_DATE DATE NOT NULL,
END_DATE DATE NOT NULL,
FOREIGN KEY (SOFTWARE_ID) REFERENCES SOFTWARE(SOFTWARE_ID),
FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Процедура для добавления пользователя
CREATE OR REPLACE PROCEDURE ADD_USER_PROCEDURE (
    p_username IN USERS.USERNAME%TYPE,
    p_password IN USERS.PASSWORD%TYPE,
    p_email IN USERS.EMAIL%TYPE,
    p_role IN USERS.ROLE%TYPE
) AS
BEGIN
    INSERT INTO USERS ( USERNAME, PASSWORD, EMAIL, ROLE)
    VALUES (p_username, p_password, p_email, p_role);
    COMMIT;
END ADD_USER_PROCEDURE;
/

-- Процедура для изменения информации о пользователе
CREATE OR REPLACE PROCEDURE UPDATE_USER_PROCEDURE (
    p_user_id IN USERS.USER_ID%TYPE,
    p_username IN USERS.USERNAME%TYPE,
    p_password IN USERS.PASSWORD%TYPE,
    p_email IN USERS.EMAIL%TYPE,
    p_role IN USERS.ROLE%TYPE
) AS
BEGIN
    UPDATE USERS
    SET USERNAME = p_username,
        PASSWORD = p_password,
        EMAIL = p_email,
        ROLE = p_role
    WHERE USER_ID = p_user_id;
    COMMIT;
END UPDATE_USER_PROCEDURE;
/

-- Процедура для удаления пользователя
CREATE OR REPLACE PROCEDURE DELETE_USER_PROCEDURE (
    p_user_id IN USERS.USER_ID%TYPE
) AS
BEGIN
    DELETE FROM USERS
    WHERE USER_ID = p_user_id;
    COMMIT;
END DELETE_USER_PROCEDURE;
/

-- Процедура для создания нового программного обеспечения
CREATE OR REPLACE PROCEDURE ADD_SOFTWARE_PROCEDURE (
    p_name IN SOFTWARE.NAME%TYPE,
    p_version IN SOFTWARE.VERSION%TYPE,
    p_vendor IN SOFTWARE.VENDOR%TYPE,
    p_license_type IN SOFTWARE.LICENSE_TYPE%TYPE,
    PreviousLevelID  IN SOFTWARE.PreviousLevelID %TYPE
) AS
BEGIN
    INSERT INTO SOFTWARE ( NAME, VERSION, VENDOR, LICENSE_TYPE, PreviousLevelID)
    VALUES ( p_name, p_version, p_vendor, p_license_type, PreviousLevelID);
    COMMIT;
END ADD_SOFTWARE_PROCEDURE;
/


CREATE OR REPLACE FUNCTION EXTEND_LICENSE (
    p_user_id IN INTEGER,
    p_software_id IN INTEGER
) RETURN BOOLEAN AS
    v_end_date DATE;
BEGIN
    -- Получаем текущую дату окончания лицензии
    SELECT END_DATE INTO v_end_date
    FROM LICENSES
    WHERE USER_ID = p_user_id AND SOFTWARE_ID = p_software_id;

    -- Проверяем, существует ли лицензия для данного пользователя и программного обеспечения
    IF v_end_date IS NOT NULL THEN
        -- Продлеваем лицензию на один месяц
        v_end_date := ADD_MONTHS(v_end_date, 1);

        -- Обновляем дату окончания лицензии
        UPDATE LICENSES
        SET END_DATE = v_end_date
        WHERE USER_ID = p_user_id AND SOFTWARE_ID = p_software_id;

        -- Возвращаем TRUE, если лицензия успешно продлена
        RETURN TRUE;
    ELSE
        -- Возвращаем FALSE, если лицензия не найдена
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Обработка ошибки, если лицензия не найдена
        RETURN FALSE;
END EXTEND_LICENSE;
/


-- Представление для таблицы "Пользователи"
CREATE VIEW USERS_VIEW AS
SELECT USER_ID, USERNAME, PASSWORD, EMAIL, ROLE
FROM USERS;

-- Представление для таблицы "Программное обеспечение"
CREATE VIEW SOFTWARE_VIEW AS
SELECT SOFTWARE_ID, NAME, VERSION, VENDOR, LICENSE_TYPE
FROM SOFTWARE;

-- Представление для таблицы "Лицензии"
CREATE VIEW LICENSES_VIEW AS
SELECT LICENSE_ID, l.SOFTWARE_ID, s.NAME AS SOFTWARE_NAME, l.USER_ID, u.USERNAME AS USER_NAME, START_DATE, END_DATE
FROM LICENSES l
JOIN SOFTWARE s ON l.SOFTWARE_ID = s.SOFTWARE_ID
JOIN USERS u ON l.USER_ID = u.USER_ID;

CREATE OR REPLACE VIEW LICENSE_USER_INFO AS
SELECT l.LICENSE_ID, s.NAME AS SOFTWARE_NAME, s.VERSION AS SOFTWARE_VERSION,
       s.VENDOR AS SOFTWARE_VENDOR, s.LICENSE_TYPE,
       u.USERNAME, u.EMAIL,
       l.START_DATE, l.END_DATE
FROM LICENSES l
JOIN SOFTWARE s ON l.SOFTWARE_ID = s.SOFTWARE_ID
JOIN USERS u ON l.USER_ID = u.USER_ID;

-- Индекс для таблицы USERS по полю USERNAME
CREATE INDEX IDX_USERS_USERNAME ON USERS (USERNAME);

-- Индекс для таблицы USERS по полю EMAIL
CREATE INDEX IDX_USERS_EMAIL ON USERS (EMAIL);


SELECT  * FROM  LICENSE_USER_INFO;