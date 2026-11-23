# Soulbound Soundpack v1.6.10

Natywny soundpack Lua dla Generic MUD v0.24.0+ i Soulbound v116.00.68 (zgodnosc wsteczna). Zachowano **87 OGG**.

**Over Cap event fix:** Soulbound v116.64+ nie nadaje juz markera \`SOUND_EVENT OVER_CAP_START\`, poniewaz usunieto limity EXP, ale nadal rozglasza \`EVENT OVER CAP START\` o XX:30. Soundpack odtwarza \`sounds/events/double caps.ogg\` na ten rzeczywisty komunikat, raz na start, z ochrona przed duplikacja starszego znacznika. \`overcap.ogg\` pozostaje osobnym dzwiekiem ponadlimitowej nagrody, ktora nie wystepuje w obecnym nielimitowanym EXP.

**Aktualizacja:** Generic MUD > Soundpacks > Manage installed soundpacks > Update from source, potem ponowne polaczenie.

**Publikacja:** GitHub Actions testuje i publikuje ZIP automatycznie po aktualizacji \`pack.toml\`, bez CMD/BAT.

[Releases](https://github.com/Patras93/soulbound-soundpack/releases/latest) | README_PL.txt | CHANGELOG_PL.txt

Nagrania wolno rozpowszechniac zgodnie z posiadanymi prawami.
