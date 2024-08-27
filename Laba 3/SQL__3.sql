
select * from SOFTWARE;

-- тест для понимания

INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('Software_NEW', '1.4', 'Vendor D', 'Single User', HIERARCHYID::GetRoot())
GO;


GO
DECLARE @ManagerNode hierarchyid;
DECLARE @Level hierarchyid;
SELECT @ManagerNode= HIERARCHY_NODE FROM SOFTWARE where SOFTWARE_ID = 1;
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('222', '1.4_2', 'Vendor D', 'Single User', @ManagerNode.GetDescendant(NULL ,NULL))
GO;

GO
DECLARE @ManagerNode hierarchyid;
DECLARE @Level hierarchyid;
SELECT @ManagerNode= HIERARCHY_NODE FROM SOFTWARE where SOFTWARE_ID = 1;
SELECT @Level = HIERARCHY_NODE FROM SOFTWARE where HIERARCHY_NODE.ToString() like '/1/';
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('22', '1.4_2', 'Vendor D', 'Single User', @ManagerNode.GetDescendant(@Level ,NULL))
GO;

GO
DECLARE @ManagerNode hierarchyid;
DECLARE @Level hierarchyid;
SELECT @ManagerNode= HIERARCHY_NODE FROM SOFTWARE where SOFTWARE_ID = 1;
SELECT @Level = HIERARCHY_NODE FROM SOFTWARE where HIERARCHY_NODE.ToString() like '/2/';
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('Software_NEW_2233_2', '1.4_2', 'Vendor D', 'Single User', @ManagerNode.GetDescendant(@Level, NULL))
GO;


DECLARE @ManagerNode hierarchyid;
SELECT @ManagerNode = HIERARCHY_NODE FROM SOFTWARE where HIERARCHY_NODE.ToString() like '/1/';
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
VALUES
    ('Software_NEW_2_322', '1.4_2', 'Vendor D', 'Single User', @ManagerNode.GetDescendant(NULL, NULL))
GO;



CREATE OR ALTER PROCEDURE ShowChildNodesWithLevel(@Node hierarchyid)
AS
BEGIN
	WITH RecursiveCTE AS (
		SELECT B.SOFTWARE_ID,B.NAME,B.VERSION,B.VENDOR, B.LICENSE_TYPE, B.HIERARCHY_NODE.GetLevel() AS NodeLevel
		FROM SOFTWARE B
		WHERE B.HIERARCHY_NODE = @Node

		UNION ALL

		SELECT B.SOFTWARE_ID,B.NAME,B.VERSION,B.VENDOR, B.LICENSE_TYPE, B.HIERARCHY_NODE.GetLevel() AS NodeLevel
		FROM SOFTWARE B
		JOIN RecursiveCTE R ON B.HIERARCHY_NODE.GetAncestor(1) = R.NodeLevel
	)
	SELECT NodeLevel, * FROM RecursiveCTE
	ORDER BY RecursiveCTE.NodeLevel;
END;

-- вывод данных (запуск этой процедуры)
GO
DECLARE @Node hierarchyid;
SET @Node = 0x;
EXEC ShowChildNodesWithLevel @Node;
GO

--добавление вершины(3 задание)

GO
CREATE OR ALTER PROCEDURE AddNode
	@NAME NVARCHAR(100),
    @VERSION NVARCHAR(50),
    @VENDOR NVARCHAR(100),
    @LICENSE_TYPE NVARCHAR(50),
    @HIERARCHY_NODE HIERARCHYID
AS
BEGIN
	INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE, HIERARCHY_NODE)
	VALUES (@NAME, @VERSION, @VENDOR, @LICENSE_TYPE, @HIERARCHY_NODE.GetDescendant(NULL, NULL))
END;
GO

GO
-- запуск
DECLARE @ParentNode hierarchyid;

SET @ParentNode = CAST('/2/' AS hierarchyid);

DECLARE @SubNode hierarchyid;
EXEC AddNode 'Software_NEW_32_2_33', '1.4_3', 'Vendor D', 'Single User', @ParentNode;
GO


-- ввывод
GO
DECLARE @Node hierarchyid;
SET @Node = 0x;

EXEC ShowChildNodesWithLevel @Node;
GO

-- перемещение подчинённых(4 задание)
GO
CREATE OR ALTER PROCEDURE MoveBranch
    @old_parent hierarchyid,
    @new_parent hierarchyid
AS
BEGIN
    DECLARE @old_parent_string nvarchar(max) = @old_parent.ToString();
    DECLARE @new_parent_string nvarchar(max) = @new_parent.ToString();

    UPDATE SOFTWARE
    SET HIERARCHY_NODE = hierarchyid::Parse(
        replace(HIERARCHY_NODE.ToString(), @old_parent_string, @new_parent_string)
    )
    WHERE HIERARCHY_NODE.IsDescendantOf(@old_parent) = 1
    AND HIERARCHY_NODE <> @old_parent;
END;
GO

-- запуск

EXEC MoveBranch @old_parent = '/2/', @new_parent = '/3/';


 -- вывод
DECLARE @Node hierarchyid;
SET @Node = 0x;

EXEC ShowChildNodesWithLevel @Node;
GO
