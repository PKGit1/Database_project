import psycopg2
import pandas as pd
import joblib
from sklearn.preprocessing import StandardScaler

def connect_to_database():
    return psycopg2.connect(
        dbname="moja_baza",
        user="user2",
        password="haslo",
        host="localhost",
        port="5432"
    )

def display_accounts_below_threshold(threshold):
    conn = connect_to_database()
    cur = conn.cursor()

    query = f"SELECT k.imie, k.nazwisko FROM klienci k " \
            f"JOIN rachunki r ON k.id = r.klient_id " \
            f"WHERE r.kwota < {threshold}"

    cur.execute(query)
    rows = cur.fetchall()

    if rows:
        print("Konta poniżej podanej kwoty:")
        for row in rows:
            print(f"{row[0]} {row[1]}")
    else:
        print("Brak kont poniżej podanej kwoty.")

    cur.close()
    conn.close()

def display_account_number_by_name(first_name, last_name):
    conn = connect_to_database()
    cur = conn.cursor()

    query = f"SELECT r.numer_klienta FROM klienci k " \
            f"JOIN konta ko ON k.id = ko.klient_id " \
            f"JOIN rachunki r ON ko.klient_id = r.klient_id " \
            f"WHERE k.imie = '{first_name}' AND k.nazwisko = '{last_name}'"

    cur.execute(query)
    row = cur.fetchone()

    if row:
        print(f"Numer konta dla {first_name} {last_name}: {row[0]}")
    else:
        print(f"Nie znaleziono konta dla {first_name} {last_name}.")

    cur.close()
    conn.close()

def modify_account_balance(account_number, amount, operation):
    conn = connect_to_database()
    cur = conn.cursor()

    if operation.lower() == 'add':
        query = f"UPDATE rachunki SET kwota = kwota + {amount} WHERE numer_klienta = '{account_number}'"
    elif operation.lower() == 'subtract':
        query = f"UPDATE rachunki SET kwota = kwota - {amount} WHERE numer_klienta = '{account_number}'"
    else:
        print("Nieprawidłowa operacja (dozwolone: 'add' lub 'subtract')")
        return

    cur.execute(query)
    conn.commit()

    print(f"Zmieniono kwotę na koncie {account_number} o {amount}. Operacja: {operation}")

    cur.close()
    conn.close()


def process_and_insert_data(client_data_file, model_file, train_data_file, table_name):
    # Wczytaj dane klientów
    df_clients = pd.read_csv(client_data_file)

    # Wczytaj wcześniej wytrenowany model
    loaded_model = joblib.load(model_file)

    # Wczytaj dane treningowe
    df_train = pd.read_csv(train_data_file)

    # Przeskaluj dane klientów
    scaler = StandardScaler()

    # Dopasuj scaler do danych treningowych
    scaler.fit(df_train.drop("Class", axis=1))

    # Przeskaluj dane klientów
    X_clients_scaled = scaler.transform(df_clients.drop("Class", axis=1))

    # Przeprowadź predykcję na nowych danych
    predictions = loaded_model.predict(X_clients_scaled)

    # Zamień wyniki na wartości boolean
    status_column = predictions.astype(bool)

    # Dodaj kolumnę Status do ramki danych klientów
    df_clients["Status"] = status_column

    # Przygotuj dane do wstawienia do tabeli SQL
    data_to_insert = df_clients[
        ["Time", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V15", "V16",
         "V17", "V18", "V19", "V20", "V21", "V22", "V23", "V24", "V25", "V26", "V27", "V28", "Amount", "Status"]]

    conn = psycopg2.connect(
            dbname="moja_baza",
            user="user2",
            password="haslo",
            host="localhost",
            port="5432"
        )

    # Utwórz kursor
    cur = conn.cursor()

    # Sprawdź i wprowadź dane do tabeli SQL
    for index, row in data_to_insert.iterrows():
        # Dodaj warunek, aby dane oszustwa nie były wprowadzane do tabeli
        if not row["Status"]:
            cur.execute("""
                INSERT INTO {} (Time, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, Amount, Status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """.format(table_name), tuple(row))

    # Zatwierdź zmiany i zamknij połączenie
    conn.commit()
    conn.close()

import pandas as pd
import numpy as np
import psycopg2
from sklearn.preprocessing import StandardScaler
import joblib

def make_transaction(source_account, target_account, amount, model, scaler):
    conn = psycopg2.connect(
        dbname="moja_baza",
        user="user2",
        password="haslo",
        host="localhost",
        port="5432"
    )

    cur = conn.cursor()

    # Sprawdź stan konta źródłowego
    cur.execute(f"SELECT kwota FROM rachunki WHERE numer_klienta = '{source_account}'")
    source_balance = cur.fetchone()

    if not source_balance:
        print(f"Konto źródłowe o numerze {source_account} nie istnieje.")
        cur.close()
        conn.close()
        return

    source_balance = source_balance[0]

    # Sprawdź, czy na koncie źródłowym jest wystarczająco środków
    if source_balance < amount:
        print("Brak wystarczających środków na koncie źródłowym.")
        cur.close()
        conn.close()
        return

    # Odczytaj dane transakcyjne z pliku "creditcard.csv"
    df_creditcard = pd.read_csv("creditcard.csv")

    # Wybierz losowy wiersz jako dane transakcyjne
    transaction_data = df_creditcard.sample(n=1, random_state=42).iloc[0]

    # Ustaw wartość Amount na zadaną kwotę
    transaction_data["Amount"] = amount

    # Przeskaluj dane transakcji
    transaction_data_scaled = scaler.transform(np.array(transaction_data.drop("Class")).reshape(1, -1))

    # Przeprowadź predykcję na danych transakcji
    prediction = model.predict(transaction_data_scaled)

    # Zamień wynik na wartość boolean
    status = prediction.astype(bool)

    if not status:
        print("Transakcja uznana za podejrzaną przez model. Anulowano transakcję.")
        # Dodaj transakcję do tabeli transakcje z oznaczeniem "anulowana"
        cur.execute("""
            INSERT INTO transakcje (numer_rachunku_zrodlo, numer_rachunku_docelowy, kwota, kod_potwierdzajacy, status)
            VALUES (%s, %s, %s, %s, %s)
        """, (source_account, target_account, amount, "000000", "anulowana"))
        conn.commit()
        cur.close()
        conn.close()
        return

    # Aktualizuj saldo na koncie źródłowym
    cur.execute(f"UPDATE rachunki SET kwota = kwota - {amount} WHERE numer_klienta = '{source_account}'")

    # Sprawdź, czy konto docelowe istnieje
    cur.execute(f"SELECT kwota FROM rachunki WHERE numer_klienta = '{target_account}'")
    target_balance = cur.fetchone()

    if not target_balance:
        print(f"Konto docelowe o numerze {target_account} nie istnieje. Anulowano transakcję.")
        # Dodaj transakcję do tabeli transakcje z oznaczeniem "anulowana"
        cur.execute("""
            INSERT INTO transakcje (numer_rachunku_zrodlo, numer_rachunku_docelowy, kwota, kod_potwierdzajacy, status)
            VALUES (%s, %s, %s, %s, %s)
        """, (source_account, target_account, amount, "000000", "zablokowana"))
        conn.rollback()
        cur.close()
        conn.close()
        return

    # Aktualizuj saldo na koncie docelowym
    cur.execute(f"UPDATE rachunki SET kwota = kwota + {amount} WHERE numer_klienta = '{target_account}'")

    # Dodaj transakcję do tabeli transakcje z oznaczeniem "zatwierdzona"
    cur.execute("""
        INSERT INTO transakcje (numer_rachunku_zrodlo, numer_rachunku_docelowy, kwota, kod_potwierdzajacy, status)
        VALUES (%s, %s, %s, %s, %s)
    """, (source_account, target_account, amount, "000000", "zatwierdzona"))

    # Zatwierdź zmiany i zamknij połączenie
    conn.commit()
    cur.close()
    conn.close()

    print(f"Transakcja pomiędzy kontami {source_account} i {target_account} zakończona.")

# Przykład użycia funkcji

# 1. Wyświetlanie imion i nazwisk osób, których kwota na koncie jest mniejsza niż podana w inpucie.
#threshold_input = float(input("Podaj kwotę progową: "))
#display_accounts_below_threshold(threshold_input)

# 2. Wyświetlanie numeru konta na podstawie imienia i nazwiska podanych w inpucie.
#first_name_input = input("Podaj imię: ")
#last_name_input = input("Podaj nazwisko: ")
#display_account_number_by_name(first_name_input, last_name_input)

# 3. Dodawanie lub odejmowanie kwoty z konta, numer konta oraz kwota pobrane z inpucie.
# account_number_input = input("Podaj numer konta: ")
# amount_input = float(input("Podaj kwotę do dodania/odjęcia: "))
# operation_input = input("Podaj operację (add/subtract): ")
# modify_account_balance(account_number_input, amount_input, operation_input)

# Przykładowe użycie funkcji
# process_and_insert_data(
   # client_data_file="test_data.csv",
   # model_file="final_logreg_model.pkl",
   # train_data_file="train_data.csv",
   # table_name="Card"
# )

# Wczytaj dane treningowe
df_train = pd.read_csv("train_data.csv")

# Wczytaj wcześniej wytrenowany model
model = joblib.load("final_logreg_model.pkl")

# Przygotuj dane treningowe dla skalera (usuwamy kolumnę 'Class')
X_train = df_train.drop("Class", axis=1)

# Stwórz i dopasuj skalera
scaler = StandardScaler()
scaler.fit(X_train)

# Przykładowe numery rachunków
source_account = "12345678"
target_account = "45678901"

# Kwota transakcji
amount = 100.0

# Wywołaj funkcję make_transaction
 make_transaction(source_account, target_account, amount, model, scaler)



