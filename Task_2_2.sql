DROP TABLE IF EXISTS `table`;

CREATE TABLE `table` (
    employee_id INT,
    client_id INT,
    call_date DATE);

INSERT INTO `table` (employee_id, client_id, call_date)
VALUES 
    (1, 1001, '2023-01-10'),
    (1, 1002, '2023-01-12'),
    (1, 1001, '2023-01-12'),
    (1, 1001, '2023-01-12'),
    (1, 1003, '2023-01-15'),
    (1, 1004, '2023-01-15'),
    (1, 1005, '2023-02-18'),
    (1, 1006, '2023-02-25'),
    (1, 1007, '2023-02-25'),
    (1, 1008, '2023-03-30'),
    (1, 1009, '2023-03-30'),
    (1, 1009, '2023-03-30'),
    (1, 1007, '2023-03-31'),
    (2, 1010, '2023-01-05'),
    (2, 1011, '2023-01-05'),
    (2, 1011, '2023-01-12'),
    (2, 1012, '2023-02-15'),
    (2, 1013, '2023-02-15'),
    (2, 1014, '2023-02-20'),
    (2, 1015, '2023-03-25'),
    (2, 1016, '2023-03-28'),
    (2, 1015, '2023-03-28'),
    (3, 1017, '2023-01-09'),
    (3, 1018, '2023-01-19'),
    (3, 1017, '2023-01-19'),
    (3, 1018, '2023-02-10'),
    (3, 1019, '2023-02-15'),
    (3, 1018, '2023-02-15'),
    (3, 1020, '2023-03-20'),
    (3, 1021, '2023-03-20'),
    (3, 1022, '2023-03-22'),
    (3, 1023, '2023-03-22'),
    (3, 1025, '2023-03-22'),
    (4, 1026, '2023-01-05'),
    (4, 1026, '2023-01-20'),
    (4, 1026, '2023-01-20'),
    (4, 1027, '2023-02-03'),
    (4, 1028, '2023-02-28'),
    (4, 1027, '2023-02-28'),
    (4, 1028, '2023-03-12'),
    (5, 1029, '2023-01-10'),
    (5, 1029, '2023-01-22'),
    (5, 1028, '2023-01-22'),
    (5, 1029, '2023-01-22'),
    (5, 1030, '2023-02-14'),
    (5, 1031, '2023-03-01'),
    (5, 1032, '2023-03-01'),
    (5, 1032, '2023-03-20');
SELECT * FROM `table`;

DROP TABLE IF EXISTS monthly_summary, min_day, max_day, total_history;

CREATE TABLE monthly_summary AS
SELECT employee_id,
    DATE_FORMAT(call_date, '%Y-%m') AS report_month,
    COUNT(*) AS total_calls,
    COUNT(DISTINCT client_id) AS unique_clients
FROM `table`
GROUP BY employee_id, report_month;
SELECT * FROM monthly_summary;

CREATE TABLE min_day AS
SELECT employee_id,
       DATE_FORMAT(call_date, '%Y-%m') AS report_month,
       DATE(call_date) AS min_call_date
FROM `table` t1
WHERE DATE(call_date) = (
    SELECT DATE(call_date)
    FROM `table` t2
    WHERE t2.employee_id = t1.employee_id 
      AND DATE_FORMAT(t2.call_date, '%Y-%m') = DATE_FORMAT(t1.call_date, '%Y-%m')
    GROUP BY DATE(call_date)
    ORDER BY COUNT(*) ASC, DATE(call_date) ASC
    LIMIT 1)
GROUP BY employee_id, report_month, min_call_date;
SELECT * FROM min_day;

CREATE TABLE max_day AS
SELECT employee_id,
       DATE_FORMAT(call_date, '%Y-%m') AS report_month,
       DATE(call_date) AS max_call_date
FROM `table` t1
WHERE DATE(call_date) = (
    SELECT DATE(call_date)
    FROM `table` t2
    WHERE t2.employee_id = t1.employee_id 
      AND DATE_FORMAT(t2.call_date, '%Y-%m') = DATE_FORMAT(t1.call_date, '%Y-%m')
    GROUP BY DATE(call_date)
    ORDER BY COUNT(*) DESC, DATE(call_date) ASC
    LIMIT 1)
GROUP BY employee_id, report_month, max_call_date;
SELECT * FROM max_day;

CREATE TABLE total_history AS
SELECT employee_id,
    COUNT(*) AS total_calls_history
FROM `table`
GROUP BY employee_id;
SELECT * FROM total_history;

SELECT 
    ms.employee_id AS 'ID сотрудника',
    ms.report_month AS 'Отчетный месяц',
    ms.total_calls AS 'Кол-во совершенных звонков за отчетный месяц',
    ms.unique_clients AS 'Кол-во уникальных клиентов за отчетный месяц',
    md.min_call_date AS 'День с минимальным кол-вом звонков',
    mx.max_call_date AS 'День с максимальным кол-вом звонков',
    th.total_calls_history AS 'Кол-во звонков за всю историю работы'
FROM monthly_summary ms
LEFT JOIN min_day md ON ms.employee_id = md.employee_id AND ms.report_month = md.report_month
LEFT JOIN max_day mx ON ms.employee_id = mx.employee_id AND ms.report_month = mx.report_month
LEFT JOIN total_history th ON ms.employee_id = th.employee_id
ORDER BY ms.employee_id, ms.report_month;


