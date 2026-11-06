# Soulbound Soundpack dla Generic MUD

Natywny soundpack Lua do gry Soulbound. Wersja **1.5.7**, 66 nagrań OGG.

## Pobieranie i aktualizacje

Po opublikowaniu wydania pobierz **Soulbound-Soundpack.zip** z [Releases](https://github.com/Patras93/soulbound-soundpack/releases/latest), rozpakuj i w Generic MUD wybierz **Soundpacks → Set up a soundpack from a folder**.

Przy następnych wydaniach: **Soundpacks → Manage installed soundpacks → Update from source**, następnie połącz się ponownie z grą. Nie pobieraj „Code → Download ZIP” jako instalatora: ZIP źródeł nie jest tym samym co asset wydania.

**Uwaga:** Generic MUD v0.23.1 nie sprawdza automatycznie nowo dodanych repozytoriów; ten soundpack aktualizuje się ręcznie przez „Update from source”.

## Publikacja

Katalog `.github/workflows/release.yml` po opublikowaniu zwykłego wydania (tag zgodny z `pack.toml`, np. `v1.5.7`) buduje i dołącza plik `Soulbound-Soundpack.zip`. Plik zawiera `origin`, czyli stały adres aktualizacji.

Pełna instrukcja po polsku: `README_PL.txt`. Changelog: `CHANGELOG_PL.txt`.

Repozytorium zawiera pliki OGG dostarczone przez autora soundpacku. Publikuj i udostępniaj tylko te nagrania, na których redystrybucję masz odpowiednie prawa.
