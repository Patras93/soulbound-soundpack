SOULBOUND SOUNDPACK v1.5.7 — GITHUB I GENERIC MUD

REPOZYTORIUM: https://github.com/Patras93/soulbound-soundpack

WERSJA I ZAWARTOSC
- Soundpack Lua, pack.toml, wszystkie 66 OGG, polski changelog.
- Wbudowany w pack.toml adres origin kieruje do stalego pliku
  Soulbound-Soundpack.zip w najnowszym zwyklym wydaniu GitHub.
- Polecenie "sbs updater" wyswietla pomoc.

PIERWSZA PUBLIKACJA — SKRYPT WINDOWS
1. Rozpakuj caly ZIP zrodlowy do oddzielnego folderu.
2. Zainstaluj Git for Windows i GitHub CLI, jesli ich nie masz:
   winget install --id Git.Git -e
   winget install --id GitHub.cli -e
3. Otworz nowy PowerShell w katalogu rozpakowanej paczki.
4. Uruchom: powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\PUBLIKUJ_NA_GITHUB.ps1
   Albo uruchom PUBLIKUJ_NA_GITHUB.cmd.
5. Zaloguj sie w GitHub CLI, jesli zostaniesz o to poproszony.
6. Skrypt skopiuje pliki do repozytorium i utworzy wydanie v1.5.7.
7. Sprawdz GitHub Actions. Po zakonczeniu procesu plik
   Soulbound-Soundpack.zip powinien byc w Assets wydania:
   https://github.com/Patras93/soulbound-soundpack/releases/tag/v1.5.7
8. Jesli Actions zglosi brak uprawnien do zapisu Releases, w repozytorium
   wejdź w Settings > Actions > General > Workflow permissions i ustaw
   Read and write permissions, jesli opcja jest dostepna.

DLA ZNAJOMYCH
1. Pobierz Soulbound-Soundpack.zip z GitHub Releases > Assets.
2. Rozpakuj do folderu z pack.toml, soundpack.lua i sounds.
3. W Generic MUD wybierz Soundpacks > Set up a soundpack from a folder.
4. Wybierz rozpakowany folder, wlacz pakiet w swiecie Soulbound i polacz sie.
5. Przy kolejnych wydaniach wybierz Soundpacks > Manage installed soundpacks >
   Update from source i ponownie polacz sie z gra.

WAŻNE OGRANICZENIE GENERIC MUD v0.23.1
Automatyczne sprawdzanie aktualizacji i komenda /update dzialaja tylko
z repozytoriami rozpoznawanymi przez kod klienta. Nasze nowe repozytorium
ma aktualizacje przez Update from source, ale bez automatycznego alertu.

KOLEJNE WYDANIA
Zmien kod i/lub nagrania, podnies wersje w pack.toml, wypchnij pliki
na GitHub i utworz nowe zwykle wydanie, np. v1.5.8. Workflow zbuduje
zaktualizowany plik Soulbound-Soundpack.zip. Nie zmieniaj stalej nazwy assetu.

BEZPIECZENSTWO
Nie wrzucaj haseł ani tokenow. Nie publikuj nagran bez uprawnien
redystrybucyjnych. Zachowaj kopie lokalnego soundpacku przed instalacja.
