SOULBOUND SOUNDPACK v1.6.5 — INSTRUKCJA (PL)

Projekt: https://github.com/Patras93/soulbound-soundpack
Wydania: https://github.com/Patras93/soulbound-soundpack/releases
GRA: Soulbound v107–v113.00.17, Generic MUD v0.24.0+.
Zachowano 87 plików dźwiękowych OGG.

AKTUALIZACJA W GENERIC MUD
1. Otwórz Soundpacks > Manage installed soundpacks.
2. Wybierz Soulbound Soundpack i Update from source.
3. Po zainstalowaniu nowego wydania połącz się ponownie z grą.

JAMMER
- Gdy Jammer przestaje działać na przeciwniku, dźwięk
  events/noactoff.ogg odtwarza się po komunikacie
  "Jammer na NAZWA zakończył działanie."
- Nie uruchamia się, kiedy Jammer jeszcze trwa ani po samym
  użyciu umiejętności. Start Jammera ma własny events/stop.ogg.
- Zgodność ze starszymi komunikatami Jammer/Stop jest zachowana.
- Odsłuch testowy: sbs test jammeroff.
- Sprawdzenie stanu: sbs diag.

POZOSTAŁE EFEKTY
- daygift.ogg: codzienny prezent automatyczny v109 i nowszych.
- advent.ogg: prezent adwentowy.
- double caps.ogg: START wydarzenia Over Cap EXP.
- Bio Blast, zatrucie, recall, x2 EXP, kroki, Soul Level, muzyka walki.
- Odsłuch: sbs test daygift / advent / doublecaps / biohit / poisoned /
  multiplierdown / otherrecall / jammeroff.

PUBLIKACJA
Po przesłaniu zmian kodu i pack.toml do repozytorium GitHub Actions
automatycznie wykonuje testy i publikuje ZIP jako nowe wydanie.
Nie trzeba uruchamiać skryptów CMD, BAT ani ręcznie tworzyć Release.

Przy publicznym udostępnianiu nagrań należy mieć prawa do redystrybucji.
