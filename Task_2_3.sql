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

CREATE TABLE C AS(SELECT 
    clients.client_id AS client_id,
    products.product_id AS product_id
FROM (SELECT DISTINCT client_id FROM A) as clients
CROSS JOIN B AS products
ORDER BY clients.client_id, products.product_id);
SELECT * FROM C;

SELECT 
    C.client_id AS "ID Клиента", 
    C.product_id AS "ID продукта",
    IF(a.product_id IS NOT NULL, 1, 0) AS "Флаг использования продукта"
FROM C
LEFT JOIN A
ON C.client_id=A.client_id AND C.product_id=A.product_id
ORDER BY C.client_id, C.product_id;

