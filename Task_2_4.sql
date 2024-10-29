DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;

CREATE TABLE A (
    RepDate DATE,
    BalDate DECIMAL(15,2));
INSERT INTO A (RepDate, BalDate) VALUES
('2020-12-31', 100000),
('2021-01-31', 100000),
('2021-02-28', 120000),
('2021-03-31', 105000);
SELECT * FROM A;

CREATE TABLE B (
    OperDate DATE,
    OperSum DECIMAL(15,2));
INSERT INTO B (OperDate, OperSum) VALUES
('2021-01-15', -20000),
('2021-01-25', 20000),
('2021-02-11', 30000),
('2021-02-20', -10000),
('2021-03-18', -15000); -- опечатка....
SELECT * FROM B;

DROP TABLE IF EXISTS Calendar;
CREATE TABLE Calendar (
    Date DATE);
INSERT INTO Calendar (Date)
SELECT DATE_ADD('2021-01-01', INTERVAL n DAY) AS Date
FROM (
    SELECT a.n + b.n * 10 AS n
    FROM (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
         (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
) AS numbers
WHERE n < 90;
SELECT * FROM Calendar ORDER BY Date;

DROP TABLE IF EXISTS Calendar_B;
CREATE TABLE Calendar_B AS
SELECT 
    c.Date,
    b.OperDate,
    IFNULL(b.OperSum, 0) AS OperSum
FROM Calendar c
LEFT JOIN B b ON c.Date = b.OperDate
ORDER BY c.Date;
SELECT * FROM Calendar_B ORDER BY Date;

SELECT BalDate 
FROM A 
WHERE RepDate = (SELECT MAX(RepDate) FROM A WHERE RepDate <= '2021-01-01');

SELECT SUM(OperSum) FROM B WHERE OperDate < '2021-01-01';

DROP TABLE IF EXISTS InitialBalance;
CREATE TABLE InitialBalance AS SELECT 
    (SELECT BalDate 
     FROM A 
     WHERE RepDate = (SELECT MAX(RepDate) FROM A WHERE RepDate <= '2021-01-01'))
    +
    IFNULL((SELECT SUM(OperSum) FROM B WHERE OperDate < '2021-01-01'), 0) AS Balance;
SELECT * FROM InitialBalance;

DROP TABLE IF EXISTS DailyBalances;
CREATE TABLE DailyBalances AS
SELECT 
    c.Date,
    IFNULL(b.OperSum, 0) AS OperSum,
    (SELECT * FROM InitialBalance) + SUM(IFNULL(b.OperSum, 0)) OVER (ORDER BY c.Date) AS DailyBalance
FROM Calendar c
LEFT JOIN B b ON c.Date = b.OperDate
ORDER BY c.Date;
SELECT * FROM DailyBalances ORDER BY Date;

ALTER TABLE DailyBalances
DROP COLUMN OperSum;
SELECT * FROM DailyBalances ORDER BY Date;






