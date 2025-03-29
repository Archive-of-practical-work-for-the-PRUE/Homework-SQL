CREATE DATABASE IF NOT EXISTS ShopSQL;
USE ShopSQL;

CREATE TABLE Cash (
    ID_Cash INT AUTO_INCREMENT PRIMARY KEY,
    INN VARCHAR(12) NOT NULL,
    Address VARCHAR(255) NOT NULL
);

CREATE TABLE DiscountTypes (
    ID_DiscountTypes INT AUTO_INCREMENT PRIMARY KEY,
    Discount_percentage DECIMAL(5,2) NOT NULL CHECK (Discount_percentage BETWEEN 5 AND 15)
);

CREATE TABLE Buyer (
    ID_Buyer INT AUTO_INCREMENT PRIMARY KEY,
    Firstname VARCHAR(255) NOT NULL,
    Secondname VARCHAR(255) NOT NULL,
    Surname VARCHAR(255) NOT NULL,
    DiscountTypes_ID INT NOT NULL,
    FOREIGN KEY (DiscountTypes_ID) REFERENCES DiscountTypes(ID_DiscountTypes)
);

CREATE TABLE Product (
 ID_Product INT AUTO_INCREMENT PRIMARY KEY,
 ProductName VARCHAR(225),
 Price DECIMAL(10, 2)
);

CREATE TABLE Receipt (
    ID_Receipt INT AUTO_INCREMENT PRIMARY KEY,
    Cash_ID INT NOT NULL,
    Buyer_ID INT NOT NULL,
    Purchase_datetime DATETIME NOT NULL,
    FOREIGN KEY (Cash_ID) REFERENCES Cash(ID_Cash),
    FOREIGN KEY (Buyer_ID) REFERENCES Buyer(ID_Buyer)
);

CREATE TABLE Receipt_has_Products (
	ID_Receipt_has_Products INT AUTO_INCREMENT PRIMARY KEY,
	Receipt_ID INT NOT NULL,
    Product_ID INT NOT NULL,
	Quantity INT,
	FOREIGN KEY (Receipt_ID) REFERENCES Receipt(ID_Receipt),
    FOREIGN KEY (Product_ID) REFERENCES Product(ID_Product)
);

INSERT INTO Cash (INN, Address) VALUES 
('123456789012', 'Москва, ул. Ленина, 1'),
('234362390123', 'Красногорск, Чайковского, 10'),
('345672401234', 'Химки, ул. Романова, 5');

INSERT INTO DiscountTypes (Discount_percentage) VALUES
(5.00),
(8.00),
(10.00),
(12.00),
(15.00);

INSERT INTO Buyer (Firstname, Secondname, Surname, DiscountTypes_ID) VALUES
('Александр', 'Андреевич', 'Себежко', 1),
('Илья', 'Витальевич', 'Безридный', 2),
('Павел', 'Антонович', 'Билашенко', 3),
('Анастасия', 'Константиновна', 'Некрасова', 4),
('Даниил', 'Андреевич', 'Смирнов', 5);

INSERT INTO Product (ProductName, Price) VALUES
('Молоко 1л', 139.19),
('Хлеб черный', 60.01),
('Бананы кг', 120.99),
('Картофель кг', 58.15),
('Мясо свинина 1кг', 82.00),
('Рыба скумбрия 1кг', 425.00),
('Кофе 100г', 45.99),
('Чай зеленый 200г', 42.99),
('Сыр 200г', 302.01),
('Колбаса докторская 500г', 236.99);

INSERT INTO Receipt (Cash_ID, Buyer_ID, Purchase_datetime) VALUES
(1, 1, '2025-03-22 10:10:00'),
(2, 2, '2025-03-22 11:10:00'),
(3, 3, '2025-03-22 12:10:00'),
(1, 4, '2025-03-22 13:10:00'),
(2, 5, '2025-03-22 14:25:00');

INSERT INTO Receipt_has_Products (Receipt_ID, Product_ID, Quantity) VALUES
(1, 1, 2), (1, 3, 1), (1, 5, 3),
(2, 1, 1), (2, 3, 2), (2, 6, 1),
(3, 3, 3), (3, 3, 1), (3, 9, 2),
(4, 5, 2), (4, 3, 1), (4, 10, 3),
(5, 1, 1), (5, 3, 2), (5, 10, 1);


-- 1. Сумма покупок по кассам
SELECT
    c.Address AS Касса,
    SUM(p.Price * rp.Quantity * (1 - (d.Discount_percentage / 100))) AS Сумма
FROM Receipt r
JOIN Receipt_has_Products rp ON r.ID_Receipt = rp.Receipt_ID
JOIN Product p ON rp.Product_ID = p.ID_Product
JOIN Cash c ON r.Cash_ID = c.ID_Cash
JOIN Buyer b ON r.Buyer_ID = b.ID_Buyer
JOIN DiscountTypes d ON b.DiscountTypes_ID = d.ID_DiscountTypes
GROUP BY c.Address;


-- 2. Количество проданных единиц каждого продукта
SELECT
    p.ProductName AS Продукт,
    SUM(rp.Quantity) AS Количество
FROM Receipt_has_Products rp
JOIN Product p ON rp.Product_ID = p.ID_Product
GROUP BY p.ProductName;


-- 3. Чеки, содержащие самый продаваемый продукт
WITH MostBoughtProduct AS (
    SELECT Product_ID, SUM(Quantity) AS total_quantity
    FROM Receipt_has_Products
    GROUP BY Product_ID
    ORDER BY total_quantity DESC
    LIMIT 1
)
SELECT
    r.ID_Receipt AS Чек,
    c.Address AS Касса,
    CONCAT(b.FirstName, ' ', b.SecondName, ' ', b.Surname) AS Покупатель,  -- Собираем ФИО
    d.Discount_percentage AS Размер_скидки,
    rp.Quantity AS Количество
FROM Receipt_has_Products rp
JOIN MostBoughtProduct mbp ON rp.Product_ID = mbp.Product_ID
JOIN Receipt r ON rp.Receipt_ID = r.ID_Receipt
JOIN Cash c ON r.Cash_ID = c.ID_Cash
JOIN Buyer b ON r.Buyer_ID = b.ID_Buyer
JOIN DiscountTypes d ON b.DiscountTypes_ID = d.ID_DiscountTypes;


-- 4. Средняя скидка за каждый день
SELECT
    DATE(r.Purchase_datetime) AS День,
    AVG(d.Discount_percentage) AS Средняя_скидка
FROM Receipt r
JOIN Buyer b ON r.Buyer_ID = b.ID_Buyer
JOIN DiscountTypes d ON b.DiscountTypes_ID = d.ID_DiscountTypes
GROUP BY День;

-- 5. Продукты, которые не были куплены в определенные дни
SELECT DISTINCT
    d.purchase_date AS День,
    p.ProductName AS Продукт
FROM (
SELECT DISTINCT
DATE(Purchase_datetime)
AS purchase_date 
FROM Receipt
) d
CROSS JOIN Product p
LEFT JOIN Receipt_has_Products rp
    ON p.ID_Product = rp.Product_ID
    AND rp.Receipt_ID IN (SELECT ID_Receipt FROM Receipt WHERE DATE(Purchase_datetime) = d.purchase_date)
WHERE rp.Product_ID IS NULL
ORDER BY День, Продукт;