-- Для таблицы USERS
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE)
VALUES
('user1', 'password1', 'user1@example.com', 'Device1', 'Admin');

INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE)
VALUES
('user2', 'password2', 'user2@example.com', 'Device2', 'User');

INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE)
VALUES
('user3', 'password3', 'user3@example.com', 'Device3', 'User');


-- Для таблицы SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE)
VALUES
('Software A', '1.0', 'Vendor A', 'Type A');



INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE)
VALUES
('Software B', '1.0', 'Vendor B', 'Type B');

INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE)
VALUES
('Software C', '1.0', 'Vendor C', 'Type C');

select *
from USERS;
-- Для таблицы LICENSES
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
VALUES
(1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2024-06-01', 'YYYY-MM-DD'), 100.00);

INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
VALUES
(1, 1, TO_DATE('2023-7-01', 'YYYY-MM-DD'), TO_DATE('2024-12-11', 'YYYY-MM-DD'), 145.00);


INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
VALUES
(2, 2, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2024-09-01', 'YYYY-MM-DD'), 120.00);

INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
VALUES
(2, 3, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), 150.00);

INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST)
VALUES
(3, 3, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), 150.00);


SELECT * FROM  LICENSES;

-- Для таблицы ROOM_CLASSES
INSERT INTO ROOM_CLASSES (CLASS_NAME, USER_ID)
VALUES
('Classroom 1', 1);

INSERT INTO ROOM_CLASSES (CLASS_NAME, USER_ID)
VALUES
('Classroom 2', 2);

INSERT INTO ROOM_CLASSES (CLASS_NAME, USER_ID)
VALUES
('Meeting Room 1', 3);


-- Для таблицы CLASS_HISTORY
INSERT INTO CLASS_HISTORY (CLASS_ID, NEW_CLASS_NAME, CHANGE_DATE)
VALUES
(1, 'New Classroom 1', TO_DATE('2023-06-01', 'YYYY-MM-DD'));

INSERT INTO CLASS_HISTORY (CLASS_ID, NEW_CLASS_NAME, CHANGE_DATE)
VALUES
(2, 'New Classroom 2', TO_DATE('2023-06-01', 'YYYY-MM-DD'));


select  * from  ROOM_CLASSES