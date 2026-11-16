SOULBOUND SOUNDPACK v1.6.7 — INSTRUKCJA (PL)

Repozytorium: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases
Gra: Soulbound v113.00.29, zgodność wsteczna ze starszymi.
Klient: Generic MUD v0.24.0+
Zestaw: 87 niezmienionych nagrań OGG.

DŹWIĘKI EXP
- HALF_CAP: events/halfcap.ogg — nagroda >= połowy limitu, < pełny.
- FULL_CAP: events/cap.ogg — nagroda równa pełnemu limitowi.
- OVER_CAP_REWARD: events/overcap.ogg — rzeczywista nagroda > limitu.
- OVER_CAP_START: events/double caps.ogg — początek godzinnego
  wydarzenia, NIE przekroczenie limitu nagrody.
- Każda następna faktyczna wypłata może uruchomić ponownie
  dźwięk, nawet przy niezmienionym limicie.
- Sprawdzanie statusu, look, score, expbank nie gra dźwięków.

SPRAWDZENIE W GENERIC MUD
sbs test halfcap
sbs test cap
sbs test overcap
sbs test doublecaps
sbs status
sbs diag

AKTUALIZACJA
Generic MUD > Soundpacks > Manage installed soundpacks >
Update from source; następnie połącz się ponownie z grą.
Soundpack opublikuje się automatycznie przez GitHub Actions.
Nie trzeba uruchamiać CMD ani ręcznie otwierać GitHuba.

POZOSTAŁE EFEKTY
Zachowano wszystkie 87 OGG, w tym koniec Jammera, dźwięk nauki
i awansu skilla, prezenty, Bio Blast, zatrucie, recall, x2 EXP,
kroki, muzykę walki, Soul Level.

Publicznie udostępniaj nagrania tylko z prawem do redystrybucji.
