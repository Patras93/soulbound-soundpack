-- Potwierdzone komunikaty Soulbound v107.00.0: Bio Blast, recall, x2 EXP.
local path=assert(arg[1], 'soundpack.lua wymagany')
assert(loadfile(path), 'skladnia Lua')
local played,stopped,spoken,timers={},{},{},{}
local normal,technical,alias
local time=0
mud={
 play=function(file,channel,gain,pan,loop)
  played[#played+1]={file=file,channel=channel,loop=loop};return true
 end,
 stop=function(channel)stopped[#stopped+1]=channel end,
 echo=function(msg)spoken[#spoken+1]=msg end,
 timer=function(delay,fn)timers[#timers+1]={when=time+delay,fn=fn} end,
 trigger=function(pattern,fn,opts)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(pattern,fn) alias=fn end,
 set_channel=function()end
}
assert(loadfile(path))()
assert(normal and technical and alias,'Brak podlaczenia wyzwalaczy')
local n=0
local function check(ok,desc)
 assert(ok,'FAIL: '..desc); n=n+1;print('PASS v162: '..desc)
end
local function count(channel)
 local z=0
 for _,p in ipairs(played) do if p.channel==channel then z=z+1 end end
 return z
end
local function last(channel)
 for i=#played,1,-1 do if played[i].channel==channel then return played[i] end end
end
local function send(line)
 if line:find('^SOUND_EVENT ') then technical(line,{}) else normal(line,{}) end
end
local function command(s)alias('sbs '..s,{[1]=s})end
local function advance(seconds)
 local deadline=time+seconds
 while true do
  local i,minimum=nil,math.huge
  for k,x in ipairs(timers) do if x.when<minimum then i=k;minimum=x.when end end
  if not i or minimum>deadline then break end
  local timer=table.remove(timers,i)
  time=timer.when;timer.fn()
 end
 time=deadline
end
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
check(count('sb_bioblast')==0,'brak BioBlast po samym logowaniu')
send('Bio Blast: Szczur otrzymuje 34 obrażeń. HP 121.')
check(count('sb_bioblast')==1 and last('sb_bioblast').file=='sounds/events/biohit.ogg','Bio Blast trafienie odtwarza biohit.ogg')
check(count('sb_biopoison')==0,'trafienie bez nakladania trucizny nie gra poisoned')
send('Bio Blast: Wilk otrzymuje 35 obrażeń. HP 90.')
check(count('sb_bioblast')==1,'AoE wiele mobow bez nakladania drugiego biohit')
send('Bio Blast: Umiejętność nakłada efekt: trucizna.')
check(count('sb_biopoison')==1 and last('sb_biopoison').file=='sounds/events/poisoned.ogg','rzeczywista trucizna gra poisoned')
send('Bio Blast: Umiejętność nakłada efekt: trucizna.')
check(count('sb_biopoison')==1,'AoE wiele mobow bez dublowania poisoned')
send('Trucizna zabiera 7 HP.')
check(count('sb_biopoison')==1,'obrazenia okresowe trucizny sa ciche')
advance(0.95)
send('Bio Blast: Wilk otrzymuje 14 obrażeń. HP 76.')
check(count('sb_bioblast')==2,'nowy atak po serii znów uruchamia biohit')
send('Bio Blast: Umiejętność nie nakłada efektu: trucizna.')
check(count('sb_biopoison')==1,'nieudane nalozenie nie gra poisoned')
send('Bio Blaster: Mag otrzymuje 10 obrażeń. HP 10.')
check(count('sb_bioblast')==2,'Bio Blaster inzyniera nie jest Bio Blast Magiteka')
local recall=count('sb_otherrecall')
send('Bela znika w świetle Świątyni.')
check(count('sb_otherrecall')==recall,'znikniecie ze starego pokoju bez dzwieku')
send('Ala pojawia się w Świątyni Odrodzenia.')
send('SOUND_EVENT PLAYER_LOGIN name=Ala')
advance(1)
check(count('sb_otherrecall')==recall,'wejscie postaci nie moze symulowac recalla')
send('Bela pojawia się w Świątyni Odrodzenia.')
check(count('sb_otherrecall')==recall,'przybycie oczekuje na mozliwy znacznik logowania')
advance(.75)
check(count('sb_otherrecall')==recall+1 and last('sb_otherrecall').file=='sounds/events/someone recalls.ogg','potwierdzony recall innej postaci')
send('Testowy pojawia się w Świątyni Odrodzenia.')
advance(1)
check(count('sb_otherrecall')==recall+1,'wlasne przybycie bez efektu innych graczy')
send('Nina pojawia się w Świątyni Odrodzenia.')
send('Zapisuję postać i wracam do wyboru postaci.')
advance(1)
check(count('sb_otherrecall')==recall+1,'wylogowanie anuluje oczekujacy recall')
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
local start=count('sb_doubleexp')
local ending=count('sb_doubleexp_end')
send('EVENT x2 EXP START. Przez 15 minut wszystkie główne rodzaje EXP są podwajane.')
check(count('sb_doubleexp')==start+1,'dzwiek START x2 EXP bez zmian')
check(count('sb_doubleexp_end')==ending,'dzwiek konca nie gra na starcie')
send('EVENT x2 EXP AKTYWNY. Pozostało 5 minut. Wszystkie główne rodzaje EXP są podwajane.')
check(count('sb_doubleexp_end')==ending,'status x2 EXP nie oznacza konca')
send('EVENT x2 EXP ZAKOŃCZONY. Następny start na początku kolejnej godziny.')
check(count('sb_doubleexp_end')==ending+1 and last('sb_doubleexp_end').file=='sounds/events/multiplierdown.ogg','dzwiek konca x2 EXP po oficjalnym komunikacie')
send('EVENT x2 EXP ZAKOŃCZONY. Następny start na początku kolejnej godziny.')
check(count('sb_doubleexp_end')==ending+1,'ponowne zakonczenie nie dubluje OGG')
send('EVENT x2 EXP: następny start za 10 minut. Event trwa 15 minut i uruchamia się na początku każdej godziny.')
check(count('sb_doubleexp_end')==ending+1,'eventxp status bez efektu zakonczenia')
send('EVENT x2 EXP START. Przez 15 minut wszystkie główne rodzaje EXP są podwajane.')
send('EVENT x2 EXP ZAKOŃCZONY. Następny start na początku kolejnej godziny.')
check(count('sb_doubleexp_end')==ending+2,'koniec nastepnego eventu ponownie gra')
local before=count('sb_test_multiplierdown')
command('test multiplierdown')
check(count('sb_test_multiplierdown')==before+1,'podglad nowego dzwieku')
command('status')
check(spoken[#spoken]:find('v1.6.2',1,true)~=nil,'status pokazuje v1.6.2')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'diag bez bledow')
print('TOTAL V162 PASS '..n)
