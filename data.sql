-- Tworzenie nowej bazy danych
CREATE DATABASE moja_baza;

-- Utworzenie tabeli i dodanie kilku przykładowych danych
\c moja_baza;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE klienci (
    id SERIAL PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    data_urodzenia DATE
);

INSERT INTO klienci (imie, nazwisko, email, data_urodzenia)
VALUES
    ('Jan', 'Kowalski', 'jan.kowalski@example.com', '1990-01-01'),
    ('Anna', 'Nowak', 'anna.nowak@example.com', '1985-05-15'),
    ('Piotr', 'Wiśniewski', 'piotr.wisniewski@example.com', '1988-11-30'),
    ('Maria', 'Lis', 'maria.lis@example.com', '1992-08-20'),
    ('Grzegorz', 'Kowalczyk', 'grzegorz.kowalczyk@example.com', '1980-04-10'),
    ('Karolina', 'Zając', 'karolina.zajac@example.com', '1995-09-25'),
    ('Tomasz', 'Szymański', 'tomasz.szymanski@example.com', '1983-07-12'),
    ('Monika', 'Wójcik', 'monika.wojcik@example.com', '1998-02-28'),
    ('Robert', 'Dąbrowski', 'robert.dabrowski@example.com', '1987-06-05'),
    ('Agnieszka', 'Kowal', 'agnieszka.kowal@example.com', '1991-12-15');

 CREATE TABLE dane (
    id SERIAL PRIMARY KEY, 
    klient_id INT Unique,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    email VARCHAR(100),
    data_urodzenia DATE,
    telefon VARCHAR(20) UNIQUE,
    pesel VARCHAR(11) UNIQUE,
    adres TEXT ,
    kod_pocztowy VARCHAR(10),
    miasto VARCHAR(100),
    FOREIGN KEY (klient_id) REFERENCES klienci(ID) ON UPDATE CASCADE);

INSERT INTO dane (imie, nazwisko, email, data_urodzenia, pesel, adres, kod_pocztowy, miasto)
VALUES
    ('Anna', 'Nowak', 'anna.nowak@example.com', '1990-01-15', '90011512345', 'ul. Kwiatowa 5', '00-001', 'Warszawa'),
    ('Jan', 'Kowalski', 'jan.kowalski@example.com', '1985-05-20', '85052098765', 'ul. Leśna 10', '12-345', 'Kraków'),
    ('Marta', 'Wiśniewska', 'marta.wisniewska@example.com', '1992-09-08', '92090887654', 'ul. Słoneczna 7', '45-678', 'Wrocław'),
    ('Piotr', 'Lis', 'piotr.lis@example.com', '1980-03-12', '80031223456', 'ul. Polna 15', '90-123', 'Gdańsk'),
    ('Ewa', 'Kwiatkowska', 'ewa.kwiatkowska@example.com', '1987-07-25', '87072565432', 'ul. Ogrodowa 3', '34-567', 'Katowice'),
    ('Krzysztof', 'Nowicki', 'krzysztof.nowicki@example.com', '1995-11-30', '95113087654', 'ul. Miodowa 8', '89-012', 'Łódź'),
    ('Magda', 'Szymańska', 'magda.szymanska@example.com', '1983-04-18', '83041812345', 'ul. Wiejska 12', '67-890', 'Poznań'),
    ('Marcin', 'Jankowski', 'marcin.jankowski@example.com', '1989-06-03', '89060376543', 'ul. Rybacka 4', '23-456', 'Szczecin'),
    ('Karolina', 'Wójcik', 'karolina.wojcik@example.com', '1991-12-09', '91120923456', 'ul. Parkowa 9', '78-901', 'Bydgoszcz'),
    ('Adam', 'Dąbrowski', 'adam.dabrowski@example.com', '1982-08-14', '82081487654', 'ul. Kwietna 6', '56-789', 'Lublin');



CREATE TABLE konta (
    id SERIAL PRIMARY KEY,
    klient_id INT,
    numer_klienta VARCHAR(20) UNIQUE,
    haslo VARCHAR(255), -- Przykładowa długość, dostosuj do swoich potrzeb
    FOREIGN KEY (klient_id) REFERENCES klienci(ID) ON UPDATE CASCADE
);

INSERT INTO konta (klient_id, numer_klienta, haslo)
VALUES
    (1, '12345678', crypt('password_1', gen_salt('bf'))),
    (2, '23456789', crypt('password_2', gen_salt('bf'))),
    (3, '34567890', crypt('password_3', gen_salt('bf'))),
    (4, '45678901', crypt('password_4', gen_salt('bf'))),
    (5, '56789012', crypt('password_5', gen_salt('bf'))),
    (6, '67890123', crypt('password_6', gen_salt('bf'))),
    (7, '78901234', crypt('password_7', gen_salt('bf'))),
    (8, '89012345', crypt('password_8', gen_salt('bf'))),
    (9, '90123456', crypt('password_9', gen_salt('bf'))),
    (10, '01234567', crypt('password_10', gen_salt('bf')));

CREATE TABLE rachunki (
    id SERIAL PRIMARY KEY,
    klient_id INT,
    numer_klienta VARCHAR(20),
    numer_rachunku VARCHAR(22),
    kwota DECIMAL(10,2),
    FOREIGN KEY (klient_id) REFERENCES klienci(ID)
);

INSERT INTO rachunki (klient_id, numer_klienta, numer_rachunku, kwota)
VALUES
    (1, '12345678', '1234567890123456789012', 1000.00),
    (2, '23456789', '2345678901234567890123', 500.50),
    (3, '34567890', '3456789012345678901234', 750.25),
    (4, '45678901', '4567890123456789012345', 1200.75),
    (5, '56789012', '5678901234567890123456', 300.00),
    (6, '67890123', '6789012345678901234567', 1500.50),
    (7, '78901234', '7890123456789012345678', 900.80),
    (8, '89012345', '8901234567890123456789', 600.35),
    (9, '90123456', '9012345678901234567890', 850.45),
    (10, '01234567', '0123456789012345678901', 1100.60);

CREATE TABLE transakcje (
    id SERIAL PRIMARY KEY,
    numer_rachunku_zrodlo VARCHAR(22),
    numer_rachunku_docelowy VARCHAR(22),
    kwota DECIMAL(10,2),
    kod_potwierdzajacy VARCHAR(8),
    status VARCHAR(20)
);

-- Tabela dla danych klientów
CREATE TABLE Card (
    Time FLOAT,
    V1 FLOAT,
    V2 FLOAT,
    V3 FLOAT,
    V4 FLOAT,
    V5 FLOAT,
    V6 FLOAT,
    V7 FLOAT,
    V8 FLOAT,
    V9 FLOAT,
    V10 FLOAT,
    V11 FLOAT,
    V12 FLOAT,
    V13 FLOAT,
    V14 FLOAT,
    V15 FLOAT,
    V16 FLOAT,
    V17 FLOAT,
    V18 FLOAT,
    V19 FLOAT,
    V20 FLOAT,
    V21 FLOAT,
    V22 FLOAT,
    V23 FLOAT,
    V24 FLOAT,
    V25 FLOAT,
    V26 FLOAT,
    V27 FLOAT,
    V28 FLOAT,
    Amount FLOAT,
    Status BOOLEAN  -- True dla fraud, False dla nie-fraud
);




CREATE OR REPLACE FUNCTION DaneK(IN p_klient_id INT)
RETURNS TABLE (
    numer_klienta VARCHAR(20),
    numer_rachunku VARCHAR(22),
    imie VARCHAR(50),
    nazwisko VARCHAR(50)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ko.numer_klienta,
        r.numer_rachunku,
        k.imie,
        k.nazwisko
    FROM
        klienci k
    JOIN
        konta ko ON k.id = ko.klient_id
    JOIN
        rachunki r ON ko.klient_id = r.klient_id
    WHERE
        k.id = p_klient_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Kwota(IN p_numer_rachunku VARCHAR(22))
RETURNS DECIMAL(10,2)
AS $$
DECLARE
    v_kwota DECIMAL(10,2);
BEGIN
    SELECT
        kwota
    INTO
        v_kwota
    FROM
        rachunki
    WHERE
        numer_rachunku = p_numer_rachunku;

    RETURN v_kwota;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION StartT(
    p_numer_rachunku_zrodlo VARCHAR(22),
    p_numer_rachunku_docelowy VARCHAR(22),
    p_kwota DECIMAL(10,2)
)
RETURNS VARCHAR
AS $$
DECLARE
    v_kwota_zrodlo DECIMAL(10,2);
    v_kwota_docelowe DECIMAL(10,2);
    v_kod_potwierdzajacy VARCHAR(8);
BEGIN
    -- Sprawdź, czy rachunki źródłowy i docelowy istnieją
    PERFORM 1 FROM rachunki WHERE numer_rachunku = p_numer_rachunku_zrodlo;
    IF NOT FOUND THEN
        RETURN 'Rachunek źródłowy nie istnieje.';
    END IF;

    PERFORM 1 FROM rachunki WHERE numer_rachunku = p_numer_rachunku_docelowy;
    IF NOT FOUND THEN
        RETURN 'Rachunek docelowy nie istnieje.';
    END IF;

    -- Pobierz kwoty rachunków źródłowego i docelowego
    SELECT kwota INTO v_kwota_zrodlo FROM rachunki WHERE numer_rachunku = p_numer_rachunku_zrodlo;
    SELECT kwota INTO v_kwota_docelowe FROM rachunki WHERE numer_rachunku = p_numer_rachunku_docelowy;

    -- Sprawdź, czy wystarczająca ilość środków na rachunku źródłowym
    IF v_kwota_zrodlo < p_kwota THEN
        RETURN 'Niewystarczająca kwota na rachunku źródłowym.';
    END IF;

    -- Odejmij kwotę od rachunku źródłowego
    UPDATE rachunki
    SET kwota = kwota - p_kwota
    WHERE numer_rachunku = p_numer_rachunku_zrodlo;

    -- Wygeneruj 8-cyfrowy kod potwierdzający transakcję
    v_kod_potwierdzajacy := LPAD(FLOOR(random() * 100000000)::TEXT, 8, '0');

    -- Dodaj transakcję do tabeli
    INSERT INTO transakcje (numer_rachunku_zrodlo, numer_rachunku_docelowy, kwota, kod_potwierdzajacy, status)
    VALUES (p_numer_rachunku_zrodlo, p_numer_rachunku_docelowy, p_kwota, v_kod_potwierdzajacy, 'oczekujaca');

    -- Zwróć kod potwierdzający transakcję
    RETURN v_kod_potwierdzajacy;
EXCEPTION
    WHEN OTHERS THEN
        -- W przypadku błędu, zwróć kod błędu
        RETURN 'Błąd inicjacji transakcji.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION PotwierdzT(
    p_kod_potwierdzajacy VARCHAR(8),
    p_akceptacja INT
)
RETURNS VARCHAR
AS $$
DECLARE
    v_numer_rachunku_zrodlo VARCHAR(22);
    v_numer_rachunku_docelowy VARCHAR(22);
    v_kwota DECIMAL(10,2);
BEGIN
    -- Sprawdź, czy istnieje transakcja o podanym kodzie potwierdzającym
    SELECT numer_rachunku_zrodlo, numer_rachunku_docelowy, kwota
    INTO v_numer_rachunku_zrodlo, v_numer_rachunku_docelowy, v_kwota
    FROM transakcje
    WHERE kod_potwierdzajacy = p_kod_potwierdzajacy
    AND status = 'oczekujaca';

    IF NOT FOUND THEN
        RETURN 'Nieprawidłowy kod potwierdzający transakcję lub transakcja została już zatwierdzona/odrzucona.';
    END IF;

    -- Anuluj transakcję i zwróć środki na konto źródłowe
    IF p_akceptacja = 0 THEN
        UPDATE rachunki
        SET kwota = kwota + v_kwota
        WHERE numer_rachunku = v_numer_rachunku_zrodlo;

        UPDATE transakcje
        SET status = 'anulowana'
        WHERE kod_potwierdzajacy = p_kod_potwierdzajacy;

        RETURN 'Transakcja anulowana. Środki zwrócone na konto źródłowe.';
    END IF;

    -- Zatwierdź transakcję i dodaj kwotę do docelowego konta
    IF p_akceptacja = 1 THEN
        UPDATE rachunki
        SET kwota = kwota + v_kwota
        WHERE numer_rachunku = v_numer_rachunku_docelowy;

        UPDATE transakcje
        SET status = 'zatwierdzona'
        WHERE kod_potwierdzajacy = p_kod_potwierdzajacy;

        RETURN 'Transakcja zatwierdzona. Kwota dodana do docelowego konta.';
    END IF;

    -- Jeśli parametr akceptacji jest inny niż 0 lub 1, zwróć błąd
    RETURN 'Nieprawidłowy parametr akceptacji. Użyj 0 dla odrzucenia lub 1 dla zatwierdzenia transakcji.';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ZmianaH(
    p_numer_klienta VARCHAR(20),
    p_nowe_haslo VARCHAR(255)
)
RETURNS VARCHAR
AS $$
DECLARE
    v_nowe_haslo_hash VARCHAR(255);
BEGIN
    -- Zahaszuj nowe hasło
    SELECT crypt(p_nowe_haslo, gen_salt('bf')) INTO v_nowe_haslo_hash;

    -- Zaktualizuj zahaszowane hasło w tabeli
    UPDATE uzytkownicy
    SET haslo = v_nowe_haslo_hash
    WHERE numer_klienta = p_numer_klienta;

    IF FOUND THEN
        RETURN 'Hasło zostało zmienione pomyślnie.';
    ELSE
        RETURN 'Brak użytkownika o podanym numerze klienta.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Wystąpił błąd podczas zmiany hasła.';
END;
$$ LANGUAGE plpgsql;






