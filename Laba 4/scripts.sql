USE DBLabs;

-- 6.  ���������� ��� ���������������� ������ �� ���� ��������
-- ��� ������ ��������� �������������� �������� � ������������ � ����� ���� ������������ ��� ������������� � ������� �������������� � ���������������� �������.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
--
-- 7.  ���������� SRID - ������������� ������� ���������
-- ������� SRID �������� SRID 4326, ������� ���������� ������� ��������� WGS 84 (������/�������), ������� ������������ ��� ���-���� � �������� Web Mercator.
SELECT srid FROM dbo.geometry_columns

-- 8.  ���������� ������������ �������
-- �������� ���������� �� ��������� (���������������) �������������� ��������
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND DATA_TYPE != 'geometry'

-- 9.  ������� �������� ���������������� �������� � ������� WKT
--  ��������� ������ ��� ������������� �������������� �������� � ������������
SELECT geom.STAsText() AS WKT_Description
FROM myPackage


-- 10.1.  ���������� ����������� ���������������� ��������;
-- ����������� �������, ����� ��� ���� ��� ����� ���������������� ��������.
SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 10 AND obj2.qgs_fid = 10

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 28 AND obj2.qgs_fid = 28

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 3 AND obj2.qgs_fid = 29

-- 10.2.  ���������� ��������� ������ ����������������� ��������
SELECT geom.STPointN(1).ToString() AS Coordinates
FROM myPackage
WHERE qgs_fid = 28
-- 10.3  ���������� ������� ���������������� ��������;
-- ������� (Area): ��������� ������� ��������� ��������, ����� ��� ��������.
SELECT geom.STArea() AS ObjectArea
FROM myPackage
WHERE qgs_fid = 3

-- 11.  �������� ���������������� ������ � ���� ����� (1) /����� (2) /�������� (3).
-- �����
DECLARE @pointGeometry GEOMETRY;
SET @pointGeometry = GEOMETRY::STGeomFromText('POINT(28 28)', 4326);

SELECT @pointGeometry AS PointGeometry;

-- �����
DECLARE @lineGeometry GEOMETRY;
SET @lineGeometry = GEOMETRY::STGeomFromText('LINESTRING(5 5, 5 24, 29 29)', 4326);

SELECT @lineGeometry AS LineGeometry;


-- �������
DECLARE @polygonGeometry GEOMETRY;
SET @polygonGeometry = GEOMETRY::STGeomFromText('POLYGON((15 10, 29 29, 5 4, 12 2, 15 10))', 4326);

SELECT @polygonGeometry AS PolygonGeometry;


-- 12.  �������, � ����� ���������������� ������� �������� ��������� ���� �������

-- ����� � �������

DECLARE @point GEOMETRY = GEOMETRY::STGeomFromText('POINT(28 28)', 4326);
SELECT * FROM myPackage WHERE geom.STContains(@point) = 1;

-- ������ � �������
DECLARE @line GEOMETRY = GEOMETRY::STGeomFromText('LINESTRING(25 -15, 25 -10, 26 -10)', 4326);
SELECT * FROM myPackage WHERE geom.STContains(@line) = 1;

DECLARE @polygon GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((25 -15, 25 -14, 26 -10, 25 -15))', 4326);
SELECT * FROM myPackage WHERE geom.STContains(@polygon) = 1;
--13.	����������������� �������������� ���������������� ��������.
CREATE SPATIAL INDEX SpatialIndex_new
ON [dbo].[geometry_columns] ([geom])
USING GEOMETRY_GRID
WITH (GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM), BOUNDING_BOX = (0, 0, 50, 50));

DECLARE @searchPoint GEOMETRY;
SET @searchPoint = GEOMETRY::STGeomFromText('POINT(20 20)', 4326);

SELECT TOP 1 *
FROM [dbo].[geometry_columns] WITH(INDEX(SpatialIndex_new))
WHERE [geom].STIntersects(@searchPoint.STBuffer(5)) = 1;

INSERT INTO [dbo].[geometry_columns]
VALUES
    ('QGIS_LAB2','dbo','myPackage1','geom1',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('POINT(20 20)', 4326)),
    ('QGIS_LAB3','dbo','myPackage2','geom2',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('POLYGON((30 30, 30 40, 40 40, 40 30, 30 30))', 4326)),
    ('QGIS_LAB4','dbo','myPackage3','geom3',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('LINESTRING(10 10, 15 15, 20 20)', 4326));
	UPDATE STATISTICS [dbo].[geometry_columns] WITH FULLSCAN;

--14.	������������ �������� ���������, ������� ��������� ���������� ����� � ���������� ���������������� ������, � ������� ��� ����� ��������.
CREATE OR ALTER PROCEDURE GetGeometryFromPoint
    @latitude FLOAT,
    @longitude FLOAT,
    @resultGeometry GEOMETRY OUTPUT
AS
BEGIN
    DECLARE @point GEOMETRY = GEOMETRY::STGeomFromText('POINT(' + CAST(@longitude AS NVARCHAR(20)) + ' ' + CAST(@latitude AS NVARCHAR(20)) + ')', 4326);
    SET @resultGeometry = (SELECT TOP 1 geom FROM myPackage WHERE geom.STContains(@point) = 1);
END;

DECLARE @latitude FLOAT = 28.0;
DECLARE @longitude FLOAT = 28.0;
DECLARE @result GEOMETRY;

EXEC GetGeometryFromPoint @latitude, @longitude, @result OUTPUT;
select @result; 

-- @result ������ �������� ������ GEOMETRY
SELECT @result AS PointGeometry;










--����
CREATE SPATIAL INDEX [SpatialIndexName]
ON [TableName] ([SpatialColumnName])
USING [SpatialIndexType]
WITH ([IndexOptions])