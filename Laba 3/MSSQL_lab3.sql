-- Заполнение таблицы USERS
INSERT INTO USERS (USERNAME, [PASSWORD], EMAIL, [ROLE])
VALUES
    ( 'user1', 'password1', 'user1@example.com', 'user'),
    ( 'user2', 'password2', 'user2@example.com', 'user'),
    ( 'admin1', 'adminpass1', 'admin1@example.com', 'admin'),
    ( 'admin2', 'adminpass2', 'admin2@example.com', 'admin');

-- Заполнение таблицы SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('Software A', '1.0', 'Vendor A', 'Single User', HIERARCHYID::GetRoot()),
    ('Software B', '2.0', 'Vendor B', 'Multi User', HIERARCHYID::GetRoot()),
    ('Software C', '3.0', 'Vendor C', 'Single User', HIERARCHYID::GetRoot()),
    ('Software D', '4.0', 'Vendor D', 'Multi User', HIERARCHYID::GetRoot());

-- Заполнение таблицы LICENSES
INSERT INTO LICENSES (USER_ID, SOFTWARE_ID, START_DATE, END_DATE)
VALUES
    ( 1, 1,'2024-01-01', '2024-12-31'), -- Лицензия на Software A для пользователя user1
    ( 2, 2,'2024-02-01', '2024-12-31'), -- Лицензия на Software B для пользователя user2
    ( 3, 3,'2024-01-01', '2024-12-31'), -- Лицензия на Software C для пользователя admin1
    ( 4, 4,'2024-02-01', '2024-12-31'); -- Лицензия на Software D для пользователя admin2

select * from SOFTWARE;
SELECT HIERARCHY_NODE FROM SOFTWARE WHERE SOFTWARE_ID = 1;

-------------------




-- Процедура добавления узла иерархии
CREATE OR ALTER PROCEDURE AddSoftwareNode
    @name NVARCHAR(100),
    @version NVARCHAR(50),
    @vendor NVARCHAR(100),
    @license_type NVARCHAR(50),
    @parent_hierarchy_node HIERARCHYID
AS
BEGIN
    DECLARE @new_hierarchy_node HIERARCHYID;

    SELECT @new_hierarchy_node = ISNULL(MAX(HIERARCHY_NODE.GetDescendant(@parent_hierarchy_node, NULL)), @parent_hierarchy_node.GetDescendant(NULL, NULL))
    FROM SOFTWARE
    WHERE HIERARCHY_NODE.GetAncestor(1) = @parent_hierarchy_node;

    INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
    VALUES (@name, @version, @vendor, @license_type, @new_hierarchy_node.GetDescendant(@parent_hierarchy_node, NULL));
END;
GO





-- Теперь вы можете использовать @parent_hierarchy_node для добавления новых узлов
DECLARE @parent_hierarchy_node_a HIERARCHYID;
DECLARE @last_child_node HIERARCHYID;

-- Получаем корневой узел из таблицы SOFTWARE
SELECT @parent_hierarchy_node_a = HIERARCHY_NODE FROM SOFTWARE WHERE SOFTWARE_ID = 1;

-- Находим последний дочерний узел непосредственно под корневым узлом
SELECT TOP 1 @last_child_node = HIERARCHY_NODE
FROM SOFTWARE
WHERE HIERARCHY_NODE.GetAncestor(1) = @parent_hierarchy_node_a
ORDER BY HIERARCHY_NODE DESC;

-- Добавляем новый узел программного обеспечения
DECLARE @name NVARCHAR(100) = N'Новое программное обеспечение';
DECLARE @version NVARCHAR(50) = '1.0';
DECLARE @vendor NVARCHAR(100) = N'Новый вендор';
DECLARE @license_type NVARCHAR(50) = N'Однопользовательское';

EXEC AddSoftwareNode @name, @version, @vendor, @license_type, @last_child_node;

select * from SOFTWARE;

-- Процедура перемещения ветки
CREATE OR ALTER PROCEDURE MoveSoftwareBranch
    @old_parent_hierarchy_node HIERARCHYID,
    @new_parent_hierarchy_node HIERARCHYID
AS
BEGIN
    UPDATE SOFTWARE
    SET HIERARCHY_NODE = hierarchyid::Parse(
        REPLACE(HIERARCHY_NODE.ToString(), @old_parent_hierarchy_node.ToString(), @new_parent_hierarchy_node.ToString())
    )
    WHERE HIERARCHY_NODE.IsDescendantOf(@old_parent_hierarchy_node) = 1
    AND HIERARCHY_NODE <> @old_parent_hierarchy_node;
END;
GO

DECLARE @old_parent_hierarchy_node HIERARCHYID;
SET @old_parent_hierarchy_node = HIERARCHYID::Parse('/1/'); -- Устанавливаем старый родительский узел

DECLARE @new_parent_hierarchy_node HIERARCHYID;
SET @new_parent_hierarchy_node = HIERARCHYID::Parse('/2/'); -- Устанавливаем новый родительский узел

EXEC MoveSoftwareBranch @old_parent_hierarchy_node, @new_parent_hierarchy_node;
select * from SOFTWARE;

-- Процедура для отображения всех подчиненных узлов с указанием уровня иерархии
CREATE OR ALTER PROCEDURE ShowChildNodesWithLevel(@node HIERARCHYID)
AS
BEGIN
	WITH RecursiveCTE AS (
		SELECT S.SOFTWARE_ID, S.NAME, S.VERSION, S.VENDOR, S.LICENSE_TYPE, S.HIERARCHY_NODE, S.HIERARCHY_NODE.GetLevel() AS NodeLevel
		FROM SOFTWARE S
		WHERE S.HIERARCHY_NODE = @node

		UNION ALL

		SELECT S.SOFTWARE_ID, S.NAME, S.VERSION, S.VENDOR, S.LICENSE_TYPE, S.HIERARCHY_NODE, S.HIERARCHY_NODE.GetLevel() AS NodeLevel
		FROM SOFTWARE S
		JOIN RecursiveCTE R ON S.HIERARCHY_NODE.GetAncestor(1) = R.HIERARCHY_NODE
	)
	SELECT HIERARCHY_NODE.ToString(), SOFTWARE_ID, NAME, VERSION, VENDOR, LICENSE_TYPE, NodeLevel FROM RecursiveCTE
	ORDER BY HIERARCHY_NODE;
END;
GO

DECLARE @node HIERARCHYID;
SET @node = HIERARCHYID::Parse('/'); -- Устанавливаем узел для отображения его подчиненных

EXEC ShowChildNodesWithLevel @node;
