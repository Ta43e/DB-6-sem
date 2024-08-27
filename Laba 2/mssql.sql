-- Создание таблицы "Пользователи"

select  @@servername;
CREATE TABLE USERS (
    USER_ID INT PRIMARY KEY IDENTITY, -- Изменено на PRIMARY KEY
    USERNAME NVARCHAR(50) NOT NULL UNIQUE,
    [PASSWORD] NVARCHAR(50) NOT NULL,
    EMAIL NVARCHAR(100) NOT NULL UNIQUE,
    [ROLE] NVARCHAR(50) NOT NULL
);

-- Создание таблицы "Программное обеспечение"
CREATE TABLE SOFTWARE (
    SOFTWARE_ID INT PRIMARY KEY IDENTITY,
    NAME NVARCHAR(100) NOT NULL UNIQUE,
    
    VERSION NVARCHAR(50) NOT NULL,
    VENDOR NVARCHAR(100) NOT NULL,
    LICENSE_TYPE NVARCHAR(50) NOT NULL,
    HIERARCHY_NODE HIERARCHYID, -- Новое поле иерархического типа
    Level AS HIERARCHY_NODE.GetLevel() PERSISTED
);

-- Создание таблицы "Лицензии"
CREATE TABLE LICENSES (
    LICENSE_ID INTEGER PRIMARY KEY IDENTITY,
    SOFTWARE_ID INT NOT NULL,
    USER_ID INTEGER NOT NULL,
    START_DATE DATE NOT NULL,
    END_DATE DATE NOT NULL,
    FOREIGN KEY (SOFTWARE_ID) REFERENCES SOFTWARE(SOFTWARE_ID),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Процедура для добавления пользователя
CREATE OR ALTER PROCEDURE ADD_USER_PROCEDURE
    @p_username NVARCHAR(50),
    @p_password NVARCHAR(50),
    @p_email NVARCHAR(100),
    @p_role NVARCHAR(50)
AS
BEGIN
    INSERT INTO USERS (USERNAME, [PASSWORD], EMAIL, [ROLE])
    VALUES (@p_username, @p_password, @p_email, @p_role);
END;
GO

-- Процедура для изменения информации о пользователе
CREATE OR ALTER PROCEDURE UPDATE_USER_PROCEDURE
    @p_user_id INT,
    @p_username NVARCHAR(50),
    @p_password NVARCHAR(50),
    @p_email NVARCHAR(100),
    @p_role NVARCHAR(50)
AS
BEGIN
    UPDATE USERS
    SET USERNAME = @p_username,
        [PASSWORD] = @p_password,
        EMAIL = @p_email,
        [ROLE] = @p_role
    WHERE USER_ID = @p_user_id;
END;
GO

-- Процедура для удаления пользователя
CREATE OR ALTER PROCEDURE DELETE_USER_PROCEDURE
    @p_user_id INT
AS
BEGIN
    DELETE FROM USERS
    WHERE USER_ID = @p_user_id;
END;
GO

-- Процедура для создания нового программного обеспечения
CREATE OR ALTER PROCEDURE ADD_SOFTWARE_PROCEDURE
    @p_name NVARCHAR(100),
    @p_version NVARCHAR(50),
    @p_vendor NVARCHAR(100),
    @p_license_type NVARCHAR(50)
AS
BEGIN
    INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE)
    VALUES (@p_name, @p_version, @p_vendor, @p_license_type);
END;
GO

-- Представление для таблицы "Пользователи"
CREATE VIEW USERS_VIEW AS
SELECT USER_ID, USERNAME, [PASSWORD], EMAIL, [ROLE]
FROM USERS;
GO

-- Представление для таблицы "Программное обеспечение"
CREATE VIEW SOFTWARE_VIEW AS
SELECT SOFTWARE_ID, NAME, VERSION, VENDOR, LICENSE_TYPE
FROM SOFTWARE;
GO

-- Представление для таблицы "Лицензии"
CREATE VIEW LICENSES_VIEW AS
SELECT LICENSE_ID, SOFTWARE_ID, USER_ID, START_DATE, END_DATE
FROM LICENSES;
GO

-- Представление для комбинированных данных по лицензиям, пользователям и программному обеспечению
CREATE VIEW LICENSE_USER_INFO AS
SELECT l.LICENSE_ID, s.NAME AS SOFTWARE_NAME, s.VERSION AS SOFTWARE_VERSION,
       s.VENDOR AS SOFTWARE_VENDOR, s.LICENSE_TYPE,
       u.USERNAME, u.EMAIL,
       l.START_DATE, l.END_DATE
FROM LICENSES l
JOIN SOFTWARE s ON l.SOFTWARE_ID = s.SOFTWARE_ID
JOIN USERS u ON l.USER_ID = u.USER_ID;
GO


CREATE OR ALTER FUNCTION EXTEND_LICENSE (
    @p_user_id INT,
    @p_software_id INT
) RETURNS INT AS
BEGIN
    DECLARE @v_end_date DATE;

    -- Получаем текущую дату окончания лицензии
    SELECT @v_end_date = END_DATE
    FROM LICENSES
    WHERE USER_ID = @p_user_id AND SOFTWARE_ID = @p_software_id;

    -- Проверяем, существует ли лицензия для данного пользователя и программного обеспечения
    IF @v_end_date IS NOT NULL
    BEGIN
        -- Продлеваем лицензию на один месяц
        SET @v_end_date = DATEADD(MONTH, 1, @v_end_date);

        -- Обновляем дату окончания лицензии
        UPDATE LICENSES
        SET END_DATE = @v_end_date
        WHERE USER_ID = @p_user_id AND SOFTWARE_ID = @p_software_id;

        -- Возвращаем 1, если лицензия успешно продлена
        RETURN 1;
    END
    ELSE
    BEGIN
        -- Возвращаем 0, если лицензия не найдена
        RETURN 0;
    END;
END;


-- Индекс для таблицы USERS по полю USERNAME
CREATE INDEX IDX_USERS_USERNAME ON USERS (USERNAME);
GO

-- Индекс для таблицы USERS по полю EMAIL
CREATE INDEX IDX_USERS_EMAIL ON USERS (EMAIL);
GO

