# Навигация по практическим работам по предмету 'Базы данных' 2 курса

1 семестр:

* Практическая 1 - Построение даталогических моделей (ER-диаграмм)
* Практическая 2 - Построение логических моделей (ER-диаграмм)

2 семестр:

* Практическая 1 - [Анализ продаж в магазине](https://github.com/Archive-of-practical-work-for-the-PRUE/Homework-SQL/tree/main)
* Практическая 2 - [Отчет по успеваемости студента](https://github.com/Archive-of-practical-work-for-the-PRUE/Homework-SQL/tree/grade)
* Практическая 3 - [Расписание для группы](https://github.com/Archive-of-practical-work-for-the-PRUE/Homework-SQL/tree/shedule)

# Практическая работа 1 - Анализ продаж в магазине

## Задание
Создать базу данных, заполнить данными, а также:
1.	Посчитать оплаты по каждой кассе. Вывести результат в виде: `Касса`, `Сумма`
2.	Посчитать продукты, приобретенные в магазине. Вывести результат в виде: `Продукт`, `Кол-во`
3.	Найти самый приобретаемый продукт и вывести все чеки по нему. 
Вывести результат в виде: `Чек`, `Касса`, `Покупатель`, `Размер скидки`, `Кол-во`
4.	Рассчитать среднюю скидку по всем чекам. Вывести результат в виде: `День`, `Скидка`
5.	Вывести список продуктов, которые не приобретались. Вывести результат в виде: `День`, `Продукт`

## Описание базы данных
База данных "ShopSQL" содержит информацию о продажах в магазине и включает следующие таблицы:
- `Cash` - информация о кассах
- `DiscountTypes` - виды скидочных карт
- `Buyer` - покупатели
- `Product` - товары
- `Receipt` - чеки
- `Receipt_has_Products` - связь чеков с товарами

## SQL-запросы для анализа

### 1. Оплаты по каждой кассе
```sql
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
```

### 2. Продукты, приобретенные в магазине
```sql
SELECT
    p.ProductName AS Продукт,
    SUM(rp.Quantity) AS Количество
FROM Receipt_has_Products rp
JOIN Product p ON rp.Product_ID = p.ID_Product
GROUP BY p.ProductName;
```

### 3. Чеки по самому продаваемому продукту
```sql
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
    CONCAT(b.FirstName, ' ', b.SecondName, ' ', b.Surname) AS Покупатель,
    d.Discount_percentage AS Размер_скидки,
    rp.Quantity AS Количество
FROM Receipt_has_Products rp
JOIN MostBoughtProduct mbp ON rp.Product_ID = mbp.Product_ID
JOIN Receipt r ON rp.Receipt_ID = r.ID_Receipt
JOIN Cash c ON r.Cash_ID = c.ID_Cash
JOIN Buyer b ON r.Buyer_ID = b.ID_Buyer
JOIN DiscountTypes d ON b.DiscountTypes_ID = d.ID_DiscountTypes;
```

### 4. Средняя скидка по всем чекам
```sql
SELECT
    DATE(r.Purchase_datetime) AS День,
    AVG(d.Discount_percentage) AS Средняя_скидка
FROM Receipt r
JOIN Buyer b ON r.Buyer_ID = b.ID_Buyer
JOIN DiscountTypes d ON b.DiscountTypes_ID = d.ID_DiscountTypes
GROUP BY День;
```

### 5. Продукты, которые не приобретались
```sql
SELECT DISTINCT
    d.purchase_date AS День,
    p.ProductName AS Продукт
FROM (
    SELECT DISTINCT DATE(Purchase_datetime) AS purchase_date 
    FROM Receipt
) d
CROSS JOIN Product p
LEFT JOIN Receipt_has_Products rp
    ON p.ID_Product = rp.Product_ID
    AND rp.Receipt_ID IN (SELECT ID_Receipt FROM Receipt WHERE DATE(Purchase_datetime) = d.purchase_date)
WHERE rp.Product_ID IS NULL
ORDER BY День, Продукт;
```
