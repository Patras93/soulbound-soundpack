SOULBOUND SOUNDPACK v1.6.8 — INSTRUKCJA (PL)

Repozytorium: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases
Zgodność: Soulbound v116.00.43 i wcześniejsze komunikaty;
Generic MUD v0.24.0+. Łącznie 87 OGG.

NAPRAWA ZMIANY STREFY
- events/change area.ogg — wejście do INNEJ strefy świata.
- Działa po prawdziwym dotarciu do granicy, także przy
  prowadzeniu, gdy serwer nie robi automatycznego LOOK.
- Rozpoznaje potwierdzenia "Docierasz do", "Dopływasz do"
  oraz "WEJŚCIE" z katalogiem granic v116.00.43.
- Nie gra przy każdym pokoju w rozległym terenie, samym
  wydaniu polecenia ruchu ani przy oglądaniu mapy.
- Po dotarciu nie gra ponownie podczas LOOK tej samej strefy.
- Zachowano starsze wykrywanie stref przy opisie lokacji.
- Zmiana terenu nie wymaga nowego pliku OGG.

AKTUALIZACJA W GENERIC MUD
1. Otwórz Soundpacks > Manage installed soundpacks.
2. Wybierz Soulbound Soundpack i Update from source.
3. Po aktualizacji połącz się ponownie z grą.
Sprawdzenie wersji: sbs status.
Diagnostyka: sbs diag.
Test pojedynczego nagrania: sbs test area.

POZOSTAŁE DŹWIĘKI
Wszystkie dotychczasowe efekty zachowano, w tym:
CAP, HALF CAP, Over CAP, Jammer, prezenty, awanse skilli
i Duszy, Bio Blast, leczenie, muzykę walki i kroki.

PUBLIKACJA
GitHub Actions automatycznie sprawdza Lua i dźwięki, buduje
pełny ZIP i publikuje Release po zmianie pack.toml.
Bez uruchamiania jakichkolwiek skryptów CMD/BAT.

Nagrania udostępniaj tylko przy posiadaniu praw do ich rozpowszechniania.
