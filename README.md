# test_1

## Задание 1
Создать таблицу для анализа выполнения плана сотрудниками банка, включив в нее следующие поля:
- Код сотрудника.
- ФИО сотрудника.
- Должность.
- Подразделение.
- Факт доходности (сумма дохода по клиентам для менеджеров или подотчетных клиентов для руководителей).
- План доходности.
- Процент выполнения плана.

Условия
- Менеджеры: факт доходности равен сумме дохода по курируемым клиентам.
- Руководители: факт доходности равен сумме дохода по курируемым клиентам и клиентам всех менеджеров, подотчетных данному руководителю.

Этапы выполнения
<details> 
  <summary>1. Создаем таблицы и заполняем их значениями</summary>
  
```mysql
DROP TABLE IF EXISTS clients_fact;
DROP TABLE IF EXISTS managers_plan;
DROP TABLE IF EXISTS managers;
DROP TABLE IF EXISTS task_m;
DROP TABLE IF EXISTS department_income;
DROP TABLE IF EXISTS task_r;
DROP TABLE IF EXISTS task_1;

CREATE TABLE managers (
    id_manager INT PRIMARY KEY AUTO_INCREMENT,
    fio VARCHAR(30),
    position VARCHAR(30),
    department VARCHAR(50));

CREATE TABLE clients_fact (
    id_client INT,
    id_manager INT,
    fact DECIMAL(8,2),
    FOREIGN KEY (id_manager) REFERENCES managers (id_manager) ON DELETE SET NULL);

CREATE TABLE managers_plan (
    id_manager INT,
    plan DECIMAL(8,2),
    FOREIGN KEY (id_manager) REFERENCES managers (id_manager) ON DELETE SET NULL);


INSERT INTO managers (fio, position, department) VALUES 
('Иванов И.Ю.', 'Менеджер', 'Малый бизнес'),
('Петров П.П.', 'Менеджер', 'Средний бизнес'),
('Сидоров С.С.', 'Менеджер', 'Крупный бизнес'),
('Кузнецов К.А.', 'Руководитель', 'Малый бизнес'),
('Лебедев Л.М.', 'Руководитель', 'Средний бизнес'),
('Федоров Ф.Д.', 'Менеджер', 'Крупный бизнес'),
('Михайлов М.Н.', 'Руководитель', 'Крупный бизнес');
SELECT * FROM managers;

INSERT INTO clients_fact (id_client, id_manager, fact) VALUES 
(1001, 1, 150000.00),
(1002, 2, 200000.00),
(1003, 3, 250000.00),
(1004, 4, 120000.00),
(1005, 5, 175000.00),
(1006, 6, 300000.00),
(1007, 7, 225000.00),
(1008, 6, 150000.00),
(1009, 2, 200000.00),
(1010, 3, 250000.00),
(1011, 1, 120000.00),
(1012, 2, 175000.00),
(1013, 6, 300000.00),
(1015, 3, 225000.00);
SELECT * FROM clients_fact;

INSERT INTO managers_plan (id_manager, plan) VALUES 
(1, 200000.00),
(2, 180000.00),
(3, 220000.00),
(4, 150000.00),
(5, 190000.00),
(6, 280000.00),
(7, 240000.00);
SELECT * FROM managers_plan;
```
</details>

<details> 
  <summary>2. Создаем таблицу `task_m` с информацией о сотрудниках-менеджерах, включая их код, ФИО, должность, подразделение, фактический доход, план и процент выполнения плана, рассчитанный на основе данных о доходности клиентов и планов сотрудников.</summary>
    
```mysql
CREATE TABLE task_m as (
SELECT 
    m.id_manager 'код сотрудника',
    m.fio 'фио сотрудника',
    m.position 'должность',
    m.department 'подразделение',
    SUM(cf.fact) 'факт',
    mp.plan 'план',
    ROUND(SUM(cf.fact)/mp.plan*100,2) '% выполнения плана'
FROM managers m
LEFT JOIN clients_fact cf 
ON m.id_manager = cf.id_manager
LEFT JOIN managers_plan mp 
ON m.id_manager = mp.id_manager
WHERE m.position = 'Менеджер'
GROUP BY m.id_manager, m.fio, m.position, m.department, mp.plan);
SELECT * FROM task_m;
```
</details>

<details> 
  <summary>3. Создаем вспомогательную таблицу `department_income`, содержащую уникальные подразделения и суммарный доход по каждому подразделению.</summary>
    
```mysql
SELECT DISTINCT(department) FROM managers;
CREATE TABLE department_income AS (
SELECT 
    m.department AS department,
    SUM(cf.fact) AS sum_fact
FROM managers m
LEFT JOIN clients_fact cf 
    ON m.id_manager = cf.id_manager
GROUP BY m.department);
SELECT * FROM department_income;
```
</details>

<details> 
  <summary>4. Создаем таблицу `task_r`, содержащую информацию о руководителях: их код, ФИО, должность, подразделение, фактический доход подразделения, план дохода и процент выполнения плана. </summary>
    
```mysql
CREATE TABLE task_r as (
SELECT 
    m.id_manager 'код сотрудника',
    m.fio 'фио сотрудника',
    m.position 'должность',
    m.department 'подразделение',
    di.sum_fact 'факт',
    mp.plan 'план',
    ROUND(di.sum_fact/mp.plan*100,2) '% выполнения плана'
FROM managers m
LEFT JOIN department_income di 
ON m.department = di.department
LEFT JOIN managers_plan mp 
ON m.id_manager = mp.id_manager
WHERE m.position = 'Руководитель'
GROUP BY m.id_manager, m.fio, m.position, m.department, di.sum_fact, mp.plan);
SELECT * FROM task_r;
```
</details>
<details> 
  <summary>5. Создаем объединенную таблицу `task_1`, которая включает в себя все записи из таблиц `task_r` и `task_m` (данные по руководителям и менеджерам соответственно) и сортируем результат по первому столбцу (код сотрудника) в порядке возрастания. </summary>
    
```mysql
CREATE TABLE task_1 as
(SELECT * FROM task_r r
UNION SELECT * FROM task_m m
ORDER BY 1 ASC);
SELECT * FROM task_1;
```
</details>

## Задание 2
### Задание 2.1
<details> <summary>1. Создаем таблицу `client_operations`, чтобы хранить информацию о финансовых операциях клиентов, включая ID клиента, дату операции и сумму операции.</summary>
    
```mysql
DROP TABLE IF EXISTS client_operations;

CREATE TABLE client_operations (
    id_client INT,
    operation_date DATE,
    operation_amount DECIMAL(10, 2));
```
</details> 
<details> <summary>2. Заполняем таблицу `client_operations` случайными данными, включая ID клиента, дату операции и сумму операции, для десяти клиентов с датами операций в течение года.</summary>
    
```mysql
INSERT INTO client_operations (id_client, operation_date, operation_amount)
SELECT 
    FLOOR(RAND() * 100) + 1,
    DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY),  
    ROUND(RAND() * 10000, 2) 
FROM 
    (SELECT 1 FROM dual UNION ALL SELECT 2 FROM dual UNION ALL SELECT 3 FROM dual UNION ALL SELECT 4 FROM dual UNION ALL 
    SELECT 5 FROM dual UNION ALL SELECT 6 FROM dual UNION ALL SELECT 7 FROM dual UNION ALL SELECT 8 FROM dual UNION ALL 
    SELECT 9 FROM dual UNION ALL SELECT 10 FROM dual) AS temp;
```
</details> <details> <summary>3. Выводим все данные из таблицы `client_operations`, отсортированные по ID клиента.</summary>
    
```mysql
SELECT * FROM client_operations
ORDER BY id_client;
```
</details> <details> <summary>4а. Получаем сумму операций для каждого клиента по месяцам за 2020 год, с выделением каждого месяца в отдельную колонку.</summary>
    
```mysql
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
```
</details> <details> <summary>4b. Добавляем конкретные данные о крупных операциях для клиентов для дальнейшего анализа в 2020 году.</summary>
    
```mysql
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
</details>
<details> <summary>Получаем ID клиентов с более чем пятью крупными операциями в период с апреля по июнь 2020 года, сумма каждой операции превышает 100000.</summary>
    
```mysql
SELECT id_client
FROM client_operations
WHERE operation_date BETWEEN '2020-04-01' AND '2020-06-30'
AND operation_amount > 100000
GROUP BY id_client
HAVING COUNT(*) > 5
ORDER BY id_client;
```
</details>
<details> <summary>4c. Рассчитываем среднедневной оборот операций для каждого клиента за 2020 год.</summary>
    
```mysql
SELECT 
    id_client,
    SUM(operation_amount)/COUNT(DISTINCT operation_date) AS "Среднедневной оборот в теч. 2020 года"
FROM client_operations
WHERE YEAR(operation_date) = 2020
GROUP BY id_client
ORDER BY id_client;
```
</details>

### Задание 2.2

<details> <summary>1. Создаем таблицу `table` для хранения данных о звонках сотрудников (ID сотрудника, ID клиента, дата звонка) и заполняем её тестовыми данными.</summary>
    
```mysql
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
```
</details> 
<details> <summary>2. Создаем таблицу `monthly_summary`, которая суммирует общее количество звонков и уникальных клиентов для каждого сотрудника по месяцам.</summary>
    
```mysql
DROP TABLE IF EXISTS monthly_summary;

CREATE TABLE monthly_summary AS
SELECT employee_id,
    DATE_FORMAT(call_date, '%Y-%m') AS report_month,
    COUNT(*) AS total_calls,
    COUNT(DISTINCT client_id) AS unique_clients
FROM `table`
GROUP BY employee_id, report_month;
SELECT * FROM monthly_summary;
```
</details> 
<details> <summary>3. Создаем таблицу `min_day` для нахождения дня с минимальным количеством звонков для каждого сотрудника в месяце.</summary>
    
```mysql
DROP TABLE IF EXISTS min_day;

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
```
</details> 
<details> <summary>4. Создаем таблицу `max_day` для нахождения дня с максимальным количеством звонков для каждого сотрудника в месяце.</summary>
    
```mysql
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
```
</details> 
<details> <summary>5. Создаем таблицу с общим количеством звонков для каждого сотрудника.</summary>
    
```mysql

CREATE TABLE total_history AS
SELECT employee_id,
    COUNT(*) AS total_calls_history
FROM `table`
GROUP BY employee_id;
SELECT * FROM total_history;
```
</details> 
<details> <summary>6. Создаем результирующую таблицу.</summary>
    
```mysql

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
```
</details> 

### Задание 2.3
</details>
<details> 
  <summary>1. Создаем таблицы A, B. Таблица A содержит идентификаторы клиентов и идентификаторы продуктов. Таблица B содержит только идентификаторы продуктов. </summary>
  
```mysql

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;

CREATE TABLE A(
    client_id VARCHAR(20),
    product_id VARCHAR(20));
INSERT INTO A (client_id, product_id) VALUES
    ('Клиент 1', 'Продукт 1'),
    ('Клиент 1', 'Продукт 2'),
    ('Клиент 2', 'Продукт 3'),
    ('Клиент 3', 'Продукт 1');
SELECT * FROM A;

CREATE TABLE B(product_id VARCHAR(20));
INSERT INTO B (product_id) VALUES
    ('Продукт 1'),
    ('Продукт 2'),
    ('Продукт 3');
SELECT * FROM B;
```

</details>

<details> 
  <summary>2. Создаем таблицу C, она содержит уникальные комбинации клиентов и продуктов с использованием CROSS JOIN. </summary>
  
```mysql

CREATE TABLE C AS(SELECT 
    clients.client_id AS client_id,
    products.product_id AS product_id
FROM (SELECT DISTINCT client_id FROM A) as clients
CROSS JOIN B AS products
ORDER BY clients.client_id, products.product_id);
```
</details>

<details> 
  <summary>3. Преобразуем таблицу C с добавлением флага использования продукта из таблицы A.</summary>
  
```mysql
SELECT 
    C.client_id AS "ID Клиента", 
    C.product_id AS "ID продукта",
    IF(A.product_id IS NOT NULL, 1, 0) AS "Флаг использования продукта"
FROM C
LEFT JOIN A
ON C.client_id=A.client_id AND C.product_id=A.product_id
ORDER BY C.client_id, C.product_id;
```
</details>
