CREATE TABLE customer (
    c_number      numeric(3,0) PRIMARY KEY,
    c_first_name  varchar(20),
    c_last_name   varchar(20),
    c_info        varchar(10)
);
INSERT INTO customer (c_number, c_first_name, c_last_name, c_info) VALUES
(1, 'TEST1', 'TEST', 'TEST'),
(2, 'TEST2', 'TEST', 'TEST'),
(3, 'TEST3', 'TEST', 'TEST'),
(4, 'TEST4', 'TEST', 'TEST'),
(5, 'TEST5', 'TEST', 'TEST');
