-- 1. Создание отдельного табличного пространства для хранения LOB.
CREATE TABLESPACE my_lob_tablespace
DATAFILE 'my_lab_lob_tablespace.dbf' SIZE 100M
AUTOEXTEND ON
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

DROP TABLESPACE my_lob_tablespace INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE my_lob_tablespace INCLUDING CONTENTS AND DATAFILES;

CREATE or replace DIRECTORY lob_directory AS '/home/oracle/WORD';

CREATE USER lobUser IDENTIFIED BY password;
GRANT CONNECT, RESOURCE TO lobUser;
GRANT CREATE SESSION TO lobUser;
GRANT CREATE ANY DIRECTORY TO lobUser;
GRANT CREATE TABLE TO lobUser;
GRANT UNLIMITED TABLESPACE TO lobUser;
ALTER USER lobUser QUOTA UNLIMITED ON my_lob_tablespace;

-- 4. Добавление квоты на данное табличное пространство пользователю lob_user.
ALTER USER lobUser QUOTA UNLIMITED ON my_lob_tablespace;

-- 5. Добавление в какую-либо таблицу следующих столбцов:
--    – FOTO BLOB: для хранения фотографии;
--    – DOC (или PDF) BFILE: для хранения внешних WORD (или PDF) документов.
CREATE TABLE my_lob_table (
  ID NUMBER PRIMARY KEY,
  FOTO BLOB,
  DOC BFILE
);

drop  table  my_lob_table;

-- 6. Добавление (INSERT) фотографий и документов в таблицу.
-- Пример вставки:
GRANT READ, WRITE ON DIRECTORY lob_directory TO public;

CREATE or replace DIRECTORY lob_directory AS '/home/oracle/WORD';
grant read,write on DIRECTORY lob_directory to lobUser;



COMMIT;




////////////////
CREATE TABLE LOBLOB
    (
    IDLOB NUMBER(5) PRIMARY KEY,
    ccc cLOB,
    BEB BLOB,
    FFF BFILE
);

DROP  TABLE LOBLOB;

CREATE OR REPLACE DIRECTORY LOB_DIR AS '/home/oracle/WORD';

INSERT INTO LOBLOB VALUES( 1, 'HELLO CLOB',NULL, NULL);

INSERT INTO LOBLOB VALUES (2, NULL, NULL, BFILENAME('LOB_DIR', 'S.png'));

DECLARE
    SRC_FILE BFILE;
    DST_FILE BLOB;
    LGH_FILE BINARY_INTEGER;
BEGIN
    SRC_FILE := BFILENAME('LOB_DIR', 'S.png');
    INSERT INTO LOBLOB (IDLOB, CCC, BEB, FFF) VALUES (3, NULL, EMPTY_BLOB(), NULL) RETURNING BEB INTO DST_FILE;
    SELECT BEB INTO DST_FILE FROM LOBLOB WHERE IDLOB = 3 FOR UPDATE;
    DBMS_LOB.FILEOPEN(SRC_FILE, DBMS_LOB.FILE_READONLY);
    LGH_FILE := DBMS_LOB.GETLENGTH(SRC_FILE);
    DBMS_LOB.LOADFROMFILE (DST_FILE, SRC_FILE, LGH_FILE);
    UPDATE LOBLOB SET BEB = DST_FILE WHERE IDLOB = 3;
    COMMIT;
    DBMS_LOB.FILECLOSE(SRC_FILE);
END;
/


SELECT * FROM LOBLOB;
 ////////////