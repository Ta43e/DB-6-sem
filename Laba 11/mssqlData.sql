-- Вставка данных в таблицу USERS
INSERT INTO USERS (USERNAME, PASSWORD, EMAIL, DEVICE, ROLE) 
VALUES
('user1', 'password1', 'user1@example.com', 'device1', 'role1'),
('user2', 'password2', 'user2@example.com', 'device2', 'role2'),
('user3', 'password3', 'user3@example.com', 'device3', 'role3'),
('user4', 'password4', 'user4@example.com', 'device4', 'role4'),
('user5', 'password5', 'user5@example.com', 'device5', 'role5'),
('user6', 'password6', 'user6@example.com', 'device6', 'role6'),
('user7', 'password7', 'user7@example.com', 'device7', 'role7'),
('user8', 'password8', 'user8@example.com', 'device8', 'role8'),
('user9', 'password9', 'user9@example.com', 'device9', 'role9'),
('user10', 'password10', 'user10@example.com', 'device10', 'role10');

-- Вставка данных в таблицу SOFTWARE
INSERT INTO SOFTWARE (NAME, VERSION, VENDOR, LICENSE_TYPE) 
VALUES
('Software1', '1.0', 'Vendor1', 'Type1'),
('Software2', '2.0', 'Vendor2', 'Type2'),
('Software3', '3.0', 'Vendor3', 'Type3'),
('Software4', '4.0', 'Vendor4', 'Type4'),
('Software5', '5.0', 'Vendor5', 'Type5'),
('Software6', '6.0', 'Vendor6', 'Type6'),
('Software7', '7.0', 'Vendor7', 'Type7'),
('Software8', '8.0', 'Vendor8', 'Type8'),
('Software9', '9.0', 'Vendor9', 'Type9'),
('Software10', '10.0', 'Vendor10', 'Type10');

-- Вставка данных в таблицу LICENSES
INSERT INTO LICENSES (SOFTWARE_ID, USER_ID, START_DATE, END_DATE, LICENSE_COST) 
VALUES
(1, 1, '2024-01-01', '2024-12-31', 100.00),
(2, 2, '2024-01-01', '2024-12-31', 120.00),
(3, 3, '2024-01-01', '2024-12-31', 130.00),
(4, 4, '2024-01-01', '2024-12-31', 140.00),
(5, 5, '2024-01-01', '2024-12-31', 150.00),
(6, 6, '2024-01-01', '2024-12-31', 160.00),
(7, 7, '2024-01-01', '2024-12-31', 170.00),
(8, 8, '2024-01-01', '2024-12-31', 180.00),
(9, 9, '2024-01-01', '2024-12-31', 190.00),
(10, 10, '2024-01-01', '2024-12-31', 200.00);

-- Вставка данных в таблицу ROOM_CLASSES
INSERT INTO ROOM_CLASSES (CLASS_NAME, USER_ID) 
VALUES
('Class1', 1),
('Class2', 2),
('Class3', 3),
('Class4', 4),
('Class5', 5),
('Class6', 6),
('Class7', 7),
('Class8', 8),
('Class9', 9),
('Class10', 10);

-- Вставка данных в таблицу CLASS_HISTORY
INSERT INTO CLASS_HISTORY (CLASS_ID, NEW_CLASS_NAME, CHANGE_DATE) 
VALUES
(1, 'NewClass1', '2024-01-01'),
(2, 'NewClass2', '2024-01-01'),
(3, 'NewClass3', '2024-01-01'),
(4, 'NewClass4', '2024-01-01'),
(5, 'NewClass5', '2024-01-01'),
(6, 'NewClass6', '2024-01-01'),
(7, 'NewClass7', '2024-01-01'),
(8, 'NewClass8', '2024-01-01'),
(9, 'NewClass9', '2024-01-01'),
(10, 'NewClass10', '2024-01-01');
