CREATE TABLE USERS (
    USER_ID INT PRIMARY KEY IDENTITY, -- �������� �� PRIMARY KEY
    USERNAME NVARCHAR(50) NOT NULL UNIQUE,
    [PASSWORD] NVARCHAR(50) NOT NULL,
    EMAIL NVARCHAR(100) NOT NULL UNIQUE,
	DEVICE NVARCHAR(50) NOT NULL,
    [ROLE] NVARCHAR(50) NOT NULL
);

-- �������� ������� "����������� �����������"
CREATE TABLE SOFTWARE (
    SOFTWARE_ID INT PRIMARY KEY IDENTITY,
    NAME NVARCHAR(100) NOT NULL UNIQUE,
    VERSION NVARCHAR(50) NOT NULL,
    VENDOR NVARCHAR(100) NOT NULL,
    LICENSE_TYPE NVARCHAR(50) NOT NULL,
    HIERARCHY_NODE HIERARCHYID, -- ����� ���� �������������� ����
    Level AS HIERARCHY_NODE.GetLevel() PERSISTED

);

-- �������� ������� "��������"
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


-- ������� ������ � ������� USERS
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE) VALUES
('user1', 'password1', 'user1@example.com', 'PC' , 'admin'),
('user2', 'password2', 'user2@example.com', 'SMARTPHONE' ,'user'),
('user3', 'password3', 'user3@example.com', 'PC' ,'user');

-- ������� ������ � ������� SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE) VALUES
('Microsoft Office', '2019', 'Microsoft', 'Perpetual'),
('Adobe Photoshop', '2022', 'Adobe', 'Subscription'),
('Autodesk AutoCAD', '2021', 'Autodesk', 'Perpetual');

-- ������� ������ � ������� LICENSES
-- �����������, ��� �������� ���������� � 1 ������ 2024 ���� � ������������� 31 ������� 2024 ����
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

--���������� ������ ��������� ������������� ���� �� ���������, �� �������, �� �������, �� ���:
-- ���������


SELECT 
    YEAR(START_DATE) AS Year,
    CASE 
        WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN MONTH(START_DATE) -- ���� �������� ������ ���� �����
        ELSE MONTH(START_DATE) + 1 -- ���� �������� ������ ����� ������ ������, ��������� ��������� ����� ����� ������
    END AS Month,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- ���� �������� ������ ����� ��� �����
                CASE 
                    WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN LICENSE_COST -- ���� �������� ������ ���� �����
                    ELSE DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 1, START_DATE)) / 30.0 * LICENSE_COST -- ����� ������
                END
            ELSE 0 -- ���� �������� ����������� � ���������� ������
        END
    ) AS MonthlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- ���� �������� ������ ����� ��� �����
                CASE 
                    WHEN DATEPART(QUARTER, START_DATE) = DATEPART(QUARTER, END_DATE) THEN -- ���� �������� ������ ���� �������
                        CASE 
                            WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN LICENSE_COST -- ���� �������� ������ ���� �����
                            ELSE DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 3 * (DATEPART(QUARTER, START_DATE) - 1) + 3, START_DATE)) / 30.0 * LICENSE_COST -- ����� ��������
                        END
                    ELSE -- ���� �������� ������ ����� ������ ��������
                        CASE 
                            WHEN MONTH(START_DATE) = 1 AND MONTH(END_DATE) = 12 THEN -- �������� �� ����� ���
                                DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- ����� ����
                            ELSE -- �������� �� ����� ����
                                DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 3 * (DATEPART(QUARTER, START_DATE) - 1) + 3, START_DATE)) / 30.0 * LICENSE_COST -- ����� ��������
                        END
                END
            ELSE 0 -- ���� �������� ����������� � ���������� ��������
        END
    ) AS QuarterlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- ���� �������� ������ ����� ��� �����
                CASE 
                    WHEN MONTH(START_DATE) = MONTH(END_DATE) THEN -- ���� �������� ������ ���� �����
                        CASE 
                            WHEN MONTH(START_DATE) <= 6 THEN DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 6, START_DATE)) / 30.0 * LICENSE_COST -- ����� ��������
                            ELSE (DATEDIFF(DAY, DATEADD(MONTH, 6, START_DATE), DATEADD(YEAR, 1, START_DATE)) / 30.0) * LICENSE_COST -- ����� �������� + ����� ����
                        END
                    ELSE -- ���� �������� ������ ����� ������ ������
                        CASE 
                            WHEN MONTH(START_DATE) <= 6 AND MONTH(END_DATE) > 6 THEN -- �������� �� ����� ���� �������� ����
                                (DATEDIFF(DAY, DATEADD(MONTH, 6, START_DATE), DATEADD(YEAR, 1, START_DATE)) / 30.0) * LICENSE_COST -- ����� �������� + ����� ����
                            ELSE -- �������� �� ���������
                                DATEDIFF(DAY, START_DATE, DATEADD(MONTH, 6, START_DATE)) / 30.0 * LICENSE_COST -- ����� ��������
                        END
                END
            ELSE 0 -- ���� �������� ����������� � ���������� ���������
        END
    ) AS HalfYearlyProfit,
    SUM(
        CASE 
            WHEN DATEDIFF(MONTH, START_DATE, END_DATE) >= 0 THEN -- ���� �������� ������ ����� ��� �����
                CASE 
                    WHEN MONTH(START_DATE) = 1 AND MONTH(END_DATE) = 12 THEN -- ���� �������� ������ ���
                        DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- ����� ����
                    ELSE -- ���� �������� ������ ����� ����
                        DATEDIFF(DAY, START_DATE, DATEADD(YEAR, 1, START_DATE)) / 30.0 * LICENSE_COST -- ����� ����
                END
            ELSE 0 -- ���� �������� ����������� � ���������� ����
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

---- ������� 4 
WITH LicenseStats AS (
    SELECT 
        SOFTWARE_ID,
        COUNT(*) AS LicenseCount,
        SUM(LICENSE_COST) AS TotalCost
    FROM 
        LICENSES
    WHERE 
        START_DATE <= '2024-12-31' AND END_DATE >= '2024-01-01' -- ������� ��� ������ �����
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
        START_DATE <= '2024-12-31' AND END_DATE >= '2024-01-01' -- ������� ��� ������ �����
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
---- ������� 5

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
    RowNum BETWEEN 21 AND 40; -- ������ ��������

-- ������� 6 
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
