DROP TABLE IF EXISTS client_operations;

CREATE TABLE client_operations (
    id_client INT,
    operation_date DATE,
    operation_amount DECIMAL(10, 2));

INSERT INTO client_operations (id_client, operation_date, operation_amount)
SELECT 
    FLOOR(RAND() * 100) + 1,
    DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY),  
    ROUND(RAND() * 10000, 2) 
FROM 
    (SELECT 1 FROM dual UNION ALL SELECT 2 FROM dual UNION ALL SELECT 3 FROM dual UNION ALL SELECT 4 FROM dual UNION ALL 
    SELECT 5 FROM dual UNION ALL SELECT 6 FROM dual UNION ALL SELECT 7 FROM dual UNION ALL SELECT 8 FROM dual UNION ALL 
    SELECT 9 FROM dual UNION ALL SELECT 10 FROM dual) AS temp;

SELECT * FROM client_operations
ORDER BY id_client;

-- 1а
SELECT 
    id_client AS "ID Клиента",
    SUM(IF(MONTH(operation_date) = 1, operation_amount, 0)) AS "Сумма Операций в январе 2020",
    SUM(IF(MONTH(operation_date) = 2, operation_amount, 0)) AS "Сумма Операций в феврале 2020",
    SUM(IF(MONTH(operation_date) = 3, operation_amount, 0)) AS "Сумма Операций в марте 2020",
    SUM(IF(MONTH(operation_date) = 4, operation_amount, 0)) AS "Сумма Операций в апреле 2020",
    SUM(IF(MONTH(operation_date) = 5, operation_amount, 0)) AS "Сумма Операций в мае 2020",
    SUM(IF(MONTH(operation_date) = 6, operation_amount, 0)) AS "Сумма Операций в июне 2020",
    SUM(IF(MONTH(operation_date) = 7, operation_amount, 0)) AS "Сумма Операций в июле 2020",
    SUM(IF(MONTH(operation_date) = 8, operation_amount, 0)) AS "Сумма Операций в августе 2020",
    SUM(IF(MONTH(operation_date) = 9, operation_amount, 0)) AS "Сумма Операций в сентябре 2020",
    SUM(IF(MONTH(operation_date) = 10, operation_amount, 0)) AS "Сумма Операций в октябре 2020",
    SUM(IF(MONTH(operation_date) = 11, operation_amount, 0)) AS "Сумма Операций в ноябре 2020",
    SUM(IF(MONTH(operation_date) = 12, operation_amount, 0)) AS "Сумма Операций в декабре 2020"
FROM client_operations
WHERE YEAR(operation_date) = 2020
GROUP BY id_client
ORDER BY id_client;

-- 1b
INSERT INTO client_operations (id_client, operation_date, operation_amount) VALUES
(1, '2020-04-05', 150000),
(1, '2020-04-10', 120000),
(1, '2020-04-15', 130000),
(1, '2020-05-01', 110000),
(1, '2020-05-10', 140000),
(1, '2020-06-05', 160000),
(2, '2020-04-05', 180000),
(2, '2020-04-10', 190000),
(2, '2020-04-15', 200000),
(2, '2020-05-01', 170000),
(2, '2020-05-10', 150000),
(2, '2020-06-05', 110000),
(3, '2020-04-05', 120000),
(3, '2020-04-15', 130000),
(3, '2020-05-01', 110000),
(3, '2020-05-10', 150000),
(3, '2020-06-01', 160000),
(3, '2020-06-15', 170000);

SELECT id_client
FROM client_operations
WHERE operation_date BETWEEN '2020-04-01' AND '2020-06-30'
AND operation_amount > 100000
GROUP BY id_client
HAVING COUNT(*) > 5
ORDER BY id_client;

-- 1с
SELECT 
    id_client,
    SUM(operation_amount)/COUNT(DISTINCT operation_date) AS "Среднедневной оборот в теч. 2020 года"
FROM client_operations
WHERE YEAR(operation_date) = 2020
GROUP BY id_client
ORDER BY id_client;
