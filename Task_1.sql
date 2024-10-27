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

CREATE TABLE task_1 as
(SELECT * FROM task_r r
UNION SELECT * FROM task_m m
ORDER BY 1 ASC);
SELECT * FROM task_1;