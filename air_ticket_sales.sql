------------------------
-- СОЗДАНИЕ БАЗЫ ДАННЫХ
------------------------

CREATE DATABASE air_ticket_sales;
USE air_ticket_sales;

------------------------
-- СОЗДАНИЕ ТАБЛИЦ
------------------------

-- 1. Таблица аккаунтов (accounts)
CREATE TABLE accounts (
    id_account INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблица авиакомпаний (airlines)
CREATE TABLE airlines (
    id_airline INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- 3. Таблица аэропортов (airports)
CREATE TABLE airports (
    id_airport INT AUTO_INCREMENT PRIMARY KEY,
    airport_code VARCHAR(3) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- 4. Таблица маршрутов (routes)
CREATE TABLE routes (
    id_route INT AUTO_INCREMENT PRIMARY KEY,
    departure_airport_id INT NOT NULL,
    arrival_airport_id INT NOT NULL,
    distance DECIMAL(6, 2) NOT NULL,
    FOREIGN KEY (departure_airport_id) REFERENCES airports(id_airport)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (arrival_airport_id) REFERENCES airports(id_airport)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 5. Таблица самолётов (airplanes)
CREATE TABLE airplanes (
    id_airplane INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    economy_capacity INT NOT NULL,
    business_capacity INT NOT NULL,
    first_capacity INT NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(id_airline)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. Таблица рейсов (flights)
CREATE TABLE flights (
    id_flight INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    airplane_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    FOREIGN KEY (route_id) REFERENCES routes(id_route)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (airplane_id) REFERENCES airplanes(id_airplane)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. Таблица статусов рейсов (flight_statuses)
CREATE TABLE flight_statuses (
    id_flight_status INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    `status` ENUM('Запланирован', 'Задержан', 'Отменён', 'Вылетел', 'Прибыл') NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id_flight)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. Таблица мест (seats)
CREATE TABLE seats (
    id_seat INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    class ENUM('Эконом', 'Бизнес', 'Первый') NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id_flight)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Таблица пассажиров (passengers)
CREATE TABLE passengers (
    id_passenger INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(id_account)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 10. Таблица билетов (tickets)
CREATE TABLE tickets (
    id_ticket INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_id INT,
    price DECIMAL(7, 2) NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES flights(id_flight)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(id_passenger)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seats(id_seat)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 11. Таблица бронирований (reservations)
CREATE TABLE reservations (
    id_reservation INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    `status` ENUM('Подтвержден', 'Отменён') NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(id_account)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 12. Таблица деталей бронирования (reservation_details)
CREATE TABLE reservation_details (
    id_reservation_details INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    ticket_id INT NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id_reservation)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id_ticket)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 13. Таблица платежей (payments)
CREATE TABLE payments (
    id_payment INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    amount DECIMAL(7, 2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Наличные', 'Карта', 'Онлайн'),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id_reservation)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 14. Таблица счетов (invoices)
CREATE TABLE invoices (
    id_invoice INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    invoice_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(7, 2) NOT NULL,
    FOREIGN KEY (payment_id) REFERENCES payments(id_payment)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 15. Таблица багажа (baggages)
CREATE TABLE baggages (
    id_baggage INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    weight DECIMAL(5, 2) NOT NULL,
    fee DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id_ticket)
        ON DELETE CASCADE ON UPDATE CASCADE
);

------------------------
-- ЗАПОЛНЕНИЕ ТАБЛИЦ
------------------------

-- Таблица аккаунтов
INSERT INTO accounts (first_name, last_name, email, password) VALUES
('Иван', 'Иванов', 'ivanov@example.com', 'pass1234'),
('Анна', 'Петрова', 'petrova@example.com', 'secret987'),
('Сидоров', 'Сидоров', 'sidorov@example.com', 'mypassword'),
('Смит', 'Смит', 'smith@example.com', 'smith2023'),
('Ли', 'Ли', 'lee@example.com', 'leestrong'),
('Гомес', 'Гомес', 'gomez@example.com', 'gomez123');

-- Таблица авиакомпаний
INSERT INTO airlines (name, country) VALUES
('Аэрофлот', 'Россия'),
('Lufthansa', 'Германия'),
('Delta Airlines', 'США'),
('Emirates', 'ОАЭ'),
('Turkish Airlines', 'Турция'),
('Qatar Airways', 'Катар');

-- Таблица аэропортов
INSERT INTO airports (airport_code, name, city, country) VALUES
('SVO', 'Шереметьево', 'Москва', 'Россия'),
('DME', 'Домодедово', 'Москва', 'Россия'),
('JFK', 'John F. Kennedy', 'Нью-Йорк', 'США'),
('FRA', 'Франкфурт', 'Франкфурт', 'Германия'),
('IST', 'Аэропорт Стамбул', 'Стамбул', 'Турция'),
('DXB', 'Дубайский международный', 'Дубай', 'ОАЭ');

-- Таблица маршрутов
INSERT INTO routes (departure_airport_id, arrival_airport_id, distance) VALUES
(1, 3, 7500.5),
(2, 4, 2400.0),
(5, 6, 3000.2),
(3, 1, 7500.5),
(4, 2, 2400.0),
(6, 5, 3000.2);

-- Таблица самолётов
INSERT INTO airplanes (airline_id, model, capacity, economy_capacity, business_capacity, first_capacity) VALUES
(1, 'Boeing 737', 160, 120, 30, 10),
(2, 'Airbus A320', 180, 130, 40, 10),
(3, 'Boeing 777', 396, 300, 80, 16),
(4, 'Airbus A380', 555, 400, 120, 35),
(5, 'Boeing 787', 242, 180, 50, 12),
(6, 'Airbus A350', 315, 250, 50, 15);

-- Таблица рейсов
INSERT INTO flights (route_id, airplane_id, departure_time, arrival_time) VALUES
(1, 1, '2025-04-10 10:00:00', '2025-04-10 18:00:00'),
(2, 1, '2025-04-11 12:00:00', '2025-04-11 14:30:00'),
(3, 3, '2025-04-12 16:00:00', '2025-04-12 20:30:00'),
(4, 4, '2025-04-13 08:00:00', '2025-04-13 16:00:00'),
(5, 5, '2025-04-14 09:30:00', '2025-04-14 12:00:00'),
(6, 6, '2025-04-15 19:00:00', '2025-04-15 23:00:00');

-- Таблица статусов рейсов
INSERT INTO flight_statuses (flight_id, status) VALUES
(1, 'Запланирован'),
(2, 'Вылетел'),
(3, 'Отменён'),
(4, 'Задержан'),
(5, 'Прибыл'),
(6, 'Запланирован');

-- Таблица мест
INSERT INTO seats (flight_id, seat_number, class) VALUES
(1, '1A', 'Эконом'),
(1, '1B', 'Эконом'),
(2, '2A', 'Бизнес'),
(3, '3C', 'Эконом'),
(4, '4D', 'Бизнес'),
(5, '5E', 'Первый');

-- Таблица пассажиров
INSERT INTO passengers (account_id, first_name, last_name, passport_number, date_of_birth) VALUES
(1, 'Иван', 'Иванов', '1234567890', '1990-01-01'),
(2, 'Анна', 'Петрова', '2345678901', '1985-05-05'),
(3, 'Джон', 'Смит', '3456789012', '1992-07-10'),
(4, 'Мария', 'Ли', '4567890123', '1988-03-15'),
(5, 'Луис', 'Гомес', '5678901234', '1995-09-20'),
(6, 'Алекс', 'Сидоров', '6789012345', '1993-12-25');

-- Таблица билетов
INSERT INTO tickets (flight_id, passenger_id, seat_id, price) VALUES
(1, 1, 1, 250.00),
(2, 2, 2, 350.00),
(3, 3, 3, 400.00),
(4, 4, 4, 275.00),
(5, 5, 5, 500.00),
(6, 6, 6, 600.00);

-- Таблица бронирований
INSERT INTO reservations (account_id, status) VALUES
(1, 'Подтвержден'),
(2, 'Подтвержден'),
(3, 'Отменён'),
(4, 'Подтвержден'),
(5, 'Подтвержден'),
(6, 'Отменён');

-- Таблица деталей бронирования
INSERT INTO reservation_details (reservation_id, ticket_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);

-- Таблица платежей
INSERT INTO payments (reservation_id, amount, payment_method) VALUES
(1, 250.00, 'Карта'),
(2, 350.00, 'Онлайн'),
(4, 275.00, 'Наличные'),
(5, 500.00, 'Карта'),
(6, 600.00, 'Онлайн'),
(3, 400.00, 'Карта');

-- Таблица счетов
INSERT INTO invoices (payment_id, amount) VALUES
(1, 250.00),
(2, 350.00),
(3, 275.00),
(4, 500.00),
(5, 600.00),
(6, 400.00);

-- Таблица багажа
INSERT INTO baggages (ticket_id, weight, fee) VALUES
(1, 15.5, 30.00),
(2, 18.0, 35.00),
(3, 10.0, 20.00),
(4, 23.0, 40.00),
(5, 12.5, 25.00),
(6, 20.0, 38.00);

------------------------
-- SELECT запросы и VIEW
------------------------

-- a. Запрос на извлечение данных из нескольких связанных таблиц с использованием соединения по равенству полей таблиц
-- Этот запрос извлекает информацию о пассажирах и рейсах, на которых они летели.
SELECT 
    passengers.first_name AS "Имя", 
    passengers.last_name AS "Фамилия", 
    flights.departure_time AS "Время отправления", 
    flights.arrival_time AS "Время прибытия"
FROM 
    passengers
JOIN tickets ON passengers.id_passenger = tickets.passenger_id
JOIN flights ON tickets.flight_id = flights.id_flight
WHERE flights.departure_time > '2025-04-10';

-- b. Запрос с использованием INNER JOIN
-- Этот запрос использует INNER JOIN для соединения таблиц passengers, tickets и flights.
SELECT 
    passengers.first_name AS "Имя", 
    passengers.last_name AS "Фамилия", 
    flights.departure_time AS "Время отправления", 
    flights.arrival_time AS "Время прибытия"
FROM 
    passengers
INNER JOIN tickets ON passengers.id_passenger = tickets.passenger_id
INNER JOIN flights ON tickets.flight_id = flights.id_flight
WHERE flights.departure_time > '2025-04-10';

-- c. Запрос с использованием CASE
-- Этот запрос использует конструкцию CASE для определения статуса рейса.
SELECT 
    flights.id_flight AS "Номер рейса", 
    CASE
        WHEN flight_statuses.status = 'Задержан' THEN 'Рейс задержали'
        WHEN flight_statuses.status = 'Отменён' THEN 'Рейс отменили'
        ELSE 'Рейс завершился'
    END AS "Статус рейса"
FROM 
    flights
JOIN flight_statuses ON flights.id_flight = flight_statuses.flight_id;

-- d. Запрос с использованием группировок, группировочных функций и условий на группы (HAVING)
-- Этот запрос группирует рейсы по авиакомпаниям и считает количество рейсов для каждой авиакомпании.
-- Выводятся только те авиакомпании, у которых количество рейсов больше одного.
SELECT 
    airlines.name AS "Название авиакомпании", 
    COUNT(flights.id_flight) AS "Количество рейсов"
FROM 
    airlines
JOIN airplanes ON airlines.id_airline = airplanes.airline_id
JOIN flights ON airplanes.id_airplane = flights.airplane_id
GROUP BY airlines.name
HAVING COUNT(flights.id_flight) > 1;

-- e. Запрос с использованием левого соединения (LEFT JOIN)
-- Этот запрос извлекает всех пассажиров с их билетами, включая тех, у кого билет не забронирован.
SELECT 
    passengers.first_name AS "Имя", 
    passengers.last_name AS "Фамилия", 
    tickets.id_ticket AS "Номер билета"
FROM 
    passengers
LEFT JOIN tickets ON passengers.id_passenger = tickets.passenger_id;

-- f. Запрос с использованием вложенного подзапроса (вложенный SELECT)
-- Этот запрос извлекает информацию о пассажирах, которые летели на рейсах, стоимость билета на которые превышает 300.
SELECT 
    first_name AS "Имя", 
    last_name AS "Фамилия"
FROM 
    passengers
WHERE id_passenger IN (
    SELECT passenger_id
    FROM tickets
    WHERE price > 300
);

-- g. Запрос на создание представления (VIEW)
-- Этот запрос создаёт представление, извлекающее информацию о пассажирах и их рейсах.
CREATE VIEW passenger_flight_view AS
SELECT 
    passengers.first_name AS "Имя", 
    passengers.last_name AS "Фамилия", 
    flights.departure_time AS "Время отправления", 
    flights.arrival_time AS "Время прибытия"
FROM 
    passengers
INNER JOIN tickets ON passengers.id_passenger = tickets.passenger_id
INNER JOIN flights ON tickets.flight_id = flights.id_flight
WHERE flights.departure_time > '2025-04-10';

SELECT * FROM passenger_flight_view;

------------------------
-- ТРИГГЕРЫ
------------------------

-- 1. Триггер для автоматического расчёта общей суммы билетов по бронированию
DELIMITER //
CREATE TRIGGER trg_update_payment_sum AFTER INSERT ON reservation_details
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(7,2);
    DECLARE v_count INT;
    
    -- Подсчитываем, сколько уже есть записей о платеже для данного бронирования
    SELECT COUNT(*) INTO v_count 
    FROM payments 
    WHERE reservation_id = NEW.reservation_id;
    
    -- Вычисляем суммарную стоимость билетов по данному бронированию
    SELECT IFNULL(SUM(t.price),0) INTO v_total
    FROM reservation_details rd
    JOIN tickets t ON rd.ticket_id = t.id_ticket
    WHERE rd.reservation_id = NEW.reservation_id;
    
    IF v_count > 0 THEN
        UPDATE payments 
        SET amount = v_total 
        WHERE reservation_id = NEW.reservation_id;
    ELSE
        INSERT INTO payments (reservation_id, amount, payment_method)
        VALUES (NEW.reservation_id, v_total, 'Онлайн');
    END IF;
END //
DELIMITER ;

-- Вставляем новую запись в reservation_details, которая должна вызвать триггер
INSERT INTO reservation_details (reservation_id, ticket_id) VALUES (1, 2);
-- Проверяем, появилась ли запись в таблице payments для бронирования с id = 1
SELECT * FROM payments WHERE reservation_id = 1;
-- Вставляем еще одну запись в reservation_details для бронирования с id = 1
INSERT INTO reservation_details (reservation_id, ticket_id) VALUES (1, 3);
-- Проверяем, обновилась ли запись в таблице payments для бронирования с id = 1
SELECT * FROM payments WHERE reservation_id = 1;

-- 2. Триггер предотвращает дублирование билетов для одного и того же пассажира на один рейс
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_ticket 
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM tickets 
        WHERE flight_id = NEW.flight_id 
          AND passenger_id = NEW.passenger_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ошибка: Пассажир уже имеет билет на этот рейс.';
    END IF;
END //
DELIMITER ;

-- Вставляем первый билет для пассажира 1 на рейс 1.
INSERT INTO tickets (flight_id, passenger_id, seat_id, price)
VALUES (1, 1, 1, 250.00);

------------------------
-- ПРОЦЕДУРЫ
------------------------

-- 1. Обновление статуса рейса
DELIMITER //
CREATE PROCEDURE UpdateFlightStatus (
    IN in_flight_id INT,
    IN in_status ENUM('Запланирован', 'Задержан', 'Отменён', 'Вылетел', 'Прибыл')
)
BEGIN
    -- Проверим, есть ли уже запись статуса для рейса
    IF EXISTS (SELECT 1 FROM flight_statuses WHERE flight_id = in_flight_id) THEN
        -- Обновим существующий статус
        UPDATE flight_statuses
        SET status = in_status
        WHERE flight_id = in_flight_id;
    ELSE
        -- Если нет — создадим новую запись
        INSERT INTO flight_statuses (flight_id, status)
        VALUES (in_flight_id, in_status);
    END IF;
END //
DELIMITER ;

SELECT * FROM flight_statuses WHERE flight_id = 4;
CALL UpdateFlightStatus(4, 'Вылетел');
SELECT * FROM flight_statuses WHERE flight_id = 4;

-- 2. Доход авиакомпании по билетам
DELIMITER //
CREATE PROCEDURE GetRevenueByAirline (
    IN in_airline_id INT
)
BEGIN
    SELECT 
        al.name AS airline_name,
        SUM(t.price) AS total_revenue
    FROM tickets t
    JOIN flights f ON t.flight_id = f.id_flight
    JOIN airplanes ap ON f.airplane_id = ap.id_airplane
    JOIN airlines al ON ap.airline_id = al.id_airline
    WHERE al.id_airline = in_airline_id
    GROUP BY al.id_airline, al.name;
END //
DELIMITER ;

CALL GetRevenueByAirline(1);
