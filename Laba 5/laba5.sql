CREATE TABLE USERS (
    USER_ID INT PRIMARY KEY IDENTITY, -- Изменено на PRIMARY KEY
    USERNAME NVARCHAR(50) NOT NULL UNIQUE,
    [PASSWORD] NVARCHAR(50) NOT NULL,
    EMAIL NVARCHAR(100) NOT NULL UNIQUE,
	DEVICE NVARCHAR(50) NOT NULL,
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
	LICENSE_COST DECIMAL(10, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (SOFTWARE_ID) REFERENCES SOFTWARE(SOFTWARE_ID),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);


-- Вставка данных в таблицу USERS
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE) VALUES
('user1', 'password1', 'user1@example.com', 'PC' , 'admin'),
('user2', 'password2', 'user2@example.com', 'SMARTPHONE' ,'user'),
('user3', 'password3', 'user3@example.com', 'PC' ,'user');

-- Вставка данных в таблицу SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE) VALUES
('Microsoft Office', '2019', 'Microsoft', 'Perpetual'),
('Adobe Photoshop', '2022', 'Adobe', 'Subscription'),
('Autodesk AutoCAD', '2021', 'Autodesk', 'Perpetual');

-- Вставка данных в таблицу LICENSES
-- Предположим, что лицензии начинаются с 1 января 2024 года и заканчиваются 31 декабря 2024 года
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST) VALUES
(1, 2, '2024-01-01', '2024-12-31', 200.00),
(1, 3, '2024-01-01', '2024-03-31', 200.00),
(1, 3, '2024-01-01', '2024-03-31', 200.00),
(1, 3, '2024-01-01', '2024-01-31', 200.00),
(1, 3, '2024-01-01', '2024-01-31', 200.00),
(1, 2, '2024-01-01', '2024-01-31', 200.00),
(1, 2, '2024-01-01', '2024-02-29', 200.00), --
(1, 2, '2024-01-01', '2024-03-29', 200.00), -- 
(1, 3, '2024-01-01', '2024-04-29', 200.00), --
(1, 3, '2024-01-01', '2024-04-30', 200.00),
(2, 2, '2024-01-01', '2024-12-31', 140.00),
(3, 3, '2024-01-01', '2024-02-29', 340.00); -- 

select * from LICENSES;

--Вычисление итогов стоимости определенного вида ПО помесячно, за квартал, за полгода, за год:
-- Помесячно


SELECT 
    YEAR(START_DATE) AS Year,
    CASE 
        WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN MONTH(START_DATE) -- если лицензия длится один месяц
        ELSE MONTH(START_DATE) + 1 -- если лицензия длится более одного месяца, учитываем следующий месяц после начала
    END AS Month,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- если лицензия длится месяц или более
                CASE 
                    WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN LICENSE_COST -- если лицензия длится один месяц
                    ELSE DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 1, START_DATE)) / 30.0 * LICENSE_COST -- часть месяца
                END
            ELSE 0 -- если лицензия закончилась в предыдущем месяце
        END
    ) AS MonthlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- если лицензия длится месяц или более
                CASE 
                    WHEN DATEPART(QUARTER, START_DATE) = DATEPART(QUARTER, END_DATE) THEN -- если лицензия длится один квартал
                        CASE 
                            WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN LICENSE_COST -- если лицензия длится один месяц
                            ELSE DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 3 * (DATEPART(QUARTER, START_DATE) - 1) + 3, START_DATE)) / 30.0 * LICENSE_COST -- часть квартала
                        END
                    ELSE -- если лицензия длится более одного квартала
                        CASE 
                            WHEN MONTH(START_DATE) = 1 AND MONTH(END_DATE) = 12 THEN -- лицензия на целый год
                                DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- часть года
                            ELSE -- лицензия на часть года
                                DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 3 * (DATEPART(QUARTER, START_DATE) - 1) + 3, START_DATE)) / 30.0 * LICENSE_COST -- часть квартала
                        END
                END
            ELSE 0 -- если лицензия закончилась в предыдущем квартале
        END
    ) AS QuarterlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- если лицензия длится месяц или более
                CASE 
                    WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN -- если лицензия длится один месяц
                        CASE 
                            WHEN MONTH(START_DATE) <= 6 THEN DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 6, START_DATE)) / 30.0 * LICENSE_COST -- часть полугода
                            ELSE (DATEDIFF(DAY, DATEADD(MONTH, 6, START_DATE), DATEADD(YEAR, 1, START_DATE)) / 30.0) * LICENSE_COST -- часть полугода + часть года
                        END
                    ELSE -- если лицензия длится более одного месяца
                        CASE 
                            WHEN MONTH(START_DATE) <= 6 AND MONTH(END_DATE) > 6 THEN -- лицензия на более одну половину года
                                (DATEDIFF(DAY, DATEADD(MONTH, 6, START_DATE), DATEADD(YEAR, 1, START_DATE)) / 30.0) * LICENSE_COST -- часть полугода + часть года
                            ELSE -- лицензия на полугодие
                                DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 6, START_DATE)) / 30.0 * LICENSE_COST -- часть полугода
                        END
                END
            ELSE 0 -- если лицензия закончилась в предыдущем полугодии
        END
    ) AS HalfYearlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- если лицензия длится месяц или более
                CASE 
                    WHEN MONTH(START_DATE) = 1 AND MONTH(END_DATE) = 12 THEN -- если лицензия длится год
                        DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- часть года
                    ELSE -- если лицензия длится менее года
                        DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- часть года
                END
            ELSE 0 -- если лицензия закончилась в предыдущем году
        END
    ) AS YearlyProfit
FROM 
    LICENSES L
    INNER JOIN SOFTWARE S ON L.SOFTWARE_ID = S.SOFTWARE_ID
WHERE 
    S.NAME = 'Microsoft Office'
GROUP BY 
    YEAR(START_DATE),
    CASE 
        WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN MONTH(START_DATE)
        ELSE MONTH(START_DATE) + 1
    END
ORDER BY 
    Year, Month;

---- Задание 4 
WITH LicenseStats AS (
    SELECT 
        SOFTWARE_ID,
        COUNT(*) AS LicenseCount,
        SUM(LICENSE_COST) AS TotalCost
    FROM 
        LICENSES
    WHERE 
        START_DATE <= '2024-12-31' AND END_DATE >= '2024-01-01' -- Укажите ваш период здесь
    GROUP BY 
        SOFTWARE_ID
),
TotalStats AS (
    SELECT 
        COUNT(*) AS TotalLicenseCount,
        SUM(LICENSE_COST) AS TotalLicenseCost
    FROM 
        LICENSES
    WHERE 
        START_DATE <= '2024-12-31' AND END_DATE >= '2024-01-01' -- Укажите ваш период здесь
)
SELECT 
    LS.SOFTWARE_ID,
    LS.LicenseCount,
    LS.TotalCost,
    LS.LicenseCount * 100.0 / TS.TotalLicenseCount AS LicenseCountPercentage,
    LS.TotalCost * 100.0 / TS.TotalLicenseCost AS TotalCostPercentage
FROM 
    LicenseStats LS
JOIN 
    TotalStats TS ON 1=1;
---- Задание 5

WITH VendorLicenseCost AS (
    SELECT 
        S.VENDOR,
        LM.MonthStart,
        DATENAME(MONTH, LM.MonthStart) AS [Month],
        YEAR(LM.MonthStart) AS [Year],
        SUM(L.LICENSE_COST) AS MonthlyLicenseCost,
        ROW_NUMBER() OVER (ORDER BY S.VENDOR, YEAR(LM.MonthStart), MONTH(LM.MonthStart)) AS RowNum
    FROM (
        SELECT DATEADD(MONTH, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1), GETDATE()) AS MonthStart
        FROM sys.objects
    ) LM
    CROSS JOIN 
        SOFTWARE S
    LEFT JOIN 
        LICENSES L ON S.SOFTWARE_ID = L.SOFTWARE_ID
                   AND L.START_DATE >= DATEADD(MONTH, -5, LM.MonthStart)
                   AND L.END_DATE <= LM.MonthStart
    GROUP BY 
        S.VENDOR, LM.MonthStart, YEAR(LM.MonthStart), MONTH(LM.MonthStart)
)
SELECT 
    VENDOR,
    [Month],
    [Year],
    ISNULL(MonthlyLicenseCost, 0) AS MonthlyLicenseCost
FROM 
    VendorLicenseCost
WHERE 
    RowNum BETWEEN 21 AND 40; -- Первая страница

-- Задание 6 
WITH UsageCount AS (
    SELECT 
        S.NAME AS SoftwareName,	
        U.DEVICE AS DeviceType,
        COUNT(*) AS UsageCount,
        RANK() OVER (PARTITION BY U.DEVICE ORDER BY COUNT(*) DESC) AS RankByUsageCount
    FROM 
        LICENSES L
    INNER JOIN 
        SOFTWARE S ON L.SOFTWARE_ID = S.SOFTWARE_ID
    INNER JOIN 
        USERS U ON L.USER_ID = U.USER_ID
    GROUP BY 
        S.NAME, U.DEVICE
)
SELECT 
    UC.DeviceType,
    UC.SoftwareName AS MostUsedSoftware,
    UC.UsageCount
FROM 
    UsageCount UC
WHERE 
    UC.RankByUsageCount = 1
ORDER BY 
    UC.DeviceType;



	----------

select * from LICENSES;

	WITH RankedLicenses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY SOFTWARE_ID, USER_ID ORDER BY START_DATE DESC) AS RowNum
    FROM LICENSES
)
DELETE FROM RankedLicenses WHERE RowNum > 1;
