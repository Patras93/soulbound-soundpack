SOULBOUND SOUNDPACK v1.6.3 — INSTRUKCJA (PL)

REPO: https://github.com/Patras93/soulbound-soundpack
GRA: Soulbound v108.00.0, Generic MUD v0.24.0+.

INSTALACJA DLA GRACZY
1. W GitHub Releases pobierz Soulbound-Soundpack.zip.
2. Wypakuj folder z pack.toml, soundpack.lua i katalogiem sounds.
3. W Generic MUD: Soundpacks > Set up a soundpack from a folder.
4. Włącz soundpack dla Soulbound i połącz się ponownie.
5. Aktualizacje: Soundpacks > Manage installed soundpacks > Update from source.

NOWE DZWIEKI
- events/double caps.ogg: START wydarzenia Over Cap EXP (zwiększony limit nagrody).
- events/advent.ogg: faktyczne odebranie prezentu adwentowego.
- Zachowano wszystkie wcześniejsze OGG, w tym zakończenie x2 EXP.

KOMENDY
sbs test doublecaps   — test dźwięku rozpoczęcia Over Cap
sbs test advent       — test dźwięku odebrania prezentu
sbs test biohit       — Bio Blast: potwierdzone trafienie
sbs test poisoned     — Bio Blast: potwierdzone nałożenie trucizny
sbs test multiplierdown — potwierdzony koniec x2 EXP
sbs test otherrecall  — recall innego gracza
sbs steps on/off/status/test
sbs caves on/off/status/test
sbs music status
sbs musicvol 25
sbs diag
sbs updater

AUTOMATYCZNA PUBLIKACJA NA GITHUB
1. Rozpakuj ZIP ŹRÓDŁOWY (z .github i PUBLIKUJ_NA_GITHUB.cmd).
2. Uruchom PUBLIKUJ_NA_GITHUB.cmd. Wymagane Git for Windows i GitHub CLI.
3. Skrypt na Twoim komputerze kopiuje źródła do świeżego klonu i wykonuje
   commit/push na main po potwierdzeniu zalogowania konta.
4. GitHub Actions po zmianie pack.toml przeprowadzi testy, utworzy wydanie
   v1.6.3 i dołączy Soulbound-Soundpack.zip. Sprawdzaj zakładkę Actions.
5. Automatyczna publikacja na GitHub nie aktualizuje zainstalowanej gry
   użytkowników bez użycia opcji Update from source.

Przy publicznym udostępnianiu nagrań należy mieć prawa do redystrybucji.
