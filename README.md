# Database_project

Są to pliki użyte do stworzenia prostego projektu bazy danych, która symuluje prostą bazę danych banku. W projekcie znajdują się:

## Tabele
- klienci
  Zawiera podstawowe dane klientów, w dostarczonej wersji jest 10 przykładowych wpisów
- dane
  Rozszerzenie tabeli klienci o dodatkowe informacje
- konta
  Tabela zawiera numer klienta i zahaszowane hasła
- rachunki
  Tabela zawiera dodatkowo numery rachunków i kwoty znajdujące się na koncie
- transakcje
  Tabela zawierająca wszystkie transakcje między kontami
- card
  Tabela służy do wprowadzania danych, któ®e przewidujemy modelem do detekcji fraudów

## Funkcje SQL
- funkcja zwracająca dane klienta na podstawie id klienta
- funkcja zwracająca kwotę na rachunku na podstawie rachunku
- funkcja rozpoczynająca transakcję pomiedzy kontami
- funkcja potwierdzająca transakcję między kontami
- funkcja zmieniająca hasło

## Funkcje Python
- funkcja wyświetlająca rachunki, które mają saldo niższe od podanej kwoty
- funkcja wyświetlająca rachunek na podstawie imienia i nazwiska
- funkcja modifikująca saldo konta
- funkcja która zczytuje dane ze zbioru treningowego i przewiduje czy transakcje w nim zapisane to oszustwa czy nie
- funkcja która wykonuje tranzakcję pomiędzy kontami oraz przewiduje czy jest ona oszustwem czy nie
