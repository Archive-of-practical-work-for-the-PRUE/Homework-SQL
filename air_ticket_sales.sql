-- Создание базы данных
CREATE DATABASE air_ticket_sales;
USE air_ticket_sales;

-- 1. Таблица аккаунтов (accounts)
CREATE TABLE accounts (
    id_account INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
	`password` VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
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
    distance DECIMAL(10, 2) NOT NULL,
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
    FOREIGN KEY (airline_id) REFERENCES airlines(id_airline)
        ON DELETE CASCADE ON UPDATE CASCADE
);

--------------------------------------------------
-- 6. Таблица рейсов (flights)
--------------------------------------------------
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
    class VARCHAR(20) NOT NULL,
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
    price DECIMAL(20, 2) NOT NULL,
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

--------------------------------------------------
-- 12. Таблица деталей бронирования (reservation_details)
--------------------------------------------------
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
    amount DECIMAL(20, 2) NOT NULL,
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
    total_amount DECIMAL(20, 2) NOT NULL,
    FOREIGN KEY (payment_id) REFERENCES payments(id_payment)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 15. Таблица багажа (baggages)
CREATE TABLE baggages (
    id_baggage INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    weight DECIMAL(5, 2) NOT NULL,
    fee DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id_ticket)
        ON DELETE CASCADE ON UPDATE CASCADE
);