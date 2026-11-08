-- Soulbound v108 regression: Over Cap START and Advent Gifts CLAIM; plus v1.6.2.
local path=assert(arg[1], 'soundpack.lua wymagany')
assert(loadfile(path), 'Lua syntax error')
local plays,spoken,timers={},{},{}
local line_trigger,event_trigger,alias_trigger
local clock=0
mud={
 play=function(file,channel,gain,pan,loop) plays[#plays+1]={file=file,channel=channel};return true end,
 stop=function()end,
 echo=function(msg)spoken[#spoken+1]=msg end,
 timer=function(delay,fn)timers[#timers+1]={at=clock+delay,fn=fn} end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then event_trigger=fn else line_trigger=fn end
 end,
 alias=function(pattern,fn)alias_trigger=fn end,
 set_channel=function()end,
}
assert(loadfile(path))()
assert(line_trigger and event_trigger and alias_trigger)
local function send(msg)
 if msg:find('^SOUND_EVENT ') then event_trigger(msg,{}) else line_trigger(msg,{}) end
end
local function count(channel)
 local n=0;for _,e in ipairs(plays) do if e.channel==channel then n=n+1 end end
 return n
end
local function last(channel)
 for i=#plays,1,-1 do if plays[i].channel==channel then return plays[i].file end end
end
local passed=0
local function check(ok,msg) assert(ok,'FAIL '..msg);passed=passed+1;print('PASS: '..msg) end
local function command(s) alias_trigger('sbs '..s,{[1]=s}) end
local function advance(delta)
 local deadline=clock+delta
 while true do
  local ix,soon=nil,math.huge
  for i,e in ipairs(timers) do if e.at<soon then ix=i;soon=e.at end end
  if not ix or soon>deadline then break end
  local e=table.remove(timers,ix);clock=e.at;e.fn()
 end
 clock=deadline
end
local over='EVENT OVER CAP START. Przez 15 minut limit nagrody EXP x2; sam EXP nie jest podwajany.'
local over_end='EVENT OVER CAP ZAKOŃCZONY. Limity EXP wróciły do normy.'
local advent='PREZENT ADWENTOWY odebrany! Dzień 1/32. Nagroda: 15 złota. Następny prezent jutro.'
send(over)
check(count('sb_overcap_event_start')==0,'bez startu przed logowaniem')
send(advent)
check(count('sb_advent_gift')==0,'bez prezentu przed logowaniem')
send('Witaj, Testowy. Soulbound v108.00.0 World Core.')
send('EVENT x2 EXP START. Przez 15 minut wszystkie główne rodzaje EXP są podwajane.')
check(count('sb_doubleexp')==1 and count('sb_overcap_event_start')==0,'zwykly x2 EXP nie uruchamia Over Cap')
send(over)
check(count('sb_overcap_event_start')==1 and last('sb_overcap_event_start')=='sounds/events/double caps.ogg','Over Cap START uruchamia double caps OGG')
send(over)
check(count('sb_overcap_event_start')==1,'zdublowany START bez ponownego dzwieku')
send('EVENT OVER CAP AKTYWNY. Pozostało 5 minut.')
send('Multi Cap EXP: 100000')
send('EXP postaci +1000. Postęp 1234 z 5000.')
check(count('sb_overcap_event_start')==1,'status i nagrody EXP nie uruchamiaja eventu')
send(over_end)
check(count('sb_overcap_event_start')==1,'koniec Over Cap bez dzwieku startu')
send(over)
check(count('sb_overcap_event_start')==2,'nowa godzina pozwala na drugi START')
send('PREZENT ADWENTOWY: Lista dostępnych nagród.')
send('PREZENT ADWENTOWY już odebrany. Następny prezent jutro.')
check(count('sb_advent_gift')==0,'lista i odmowa nie uruchamiaja prezentu')
send(advent)
check(count('sb_advent_gift')==1 and last('sb_advent_gift')=='sounds/events/advent.ogg','odbior prezentu uruchamia advent OGG')
send('PREZENT ADWENTOWY odebrany! Dzień 32/32. Nagroda: 1 mithril. Następny prezent jutro.')
check(count('sb_advent_gift')==2,'kolejny prawdziwy odbior prezentu')
send('Bio Blast: Szczur otrzymuje 34 obrażeń. HP 121.')
check(count('sb_bioblast')==1 and last('sb_bioblast')=='sounds/events/biohit.ogg','Bio Blast zachowany z 1.6.2')
send('Bio Blast: Wilk otrzymuje 35 obrażeń. HP 90.')
check(count('sb_bioblast')==1,'AoE nie dubluje biohit')
send('Bio Blast: Umiejętność nakłada efekt: trucizna.')
check(count('sb_biopoison')==1 and last('sb_biopoison')=='sounds/events/poisoned.ogg','Poisoned z 1.6.2 zachowany')
advance(1)
send('Bio Blast: Wilk otrzymuje 14 obrażeń. HP 76.')
check(count('sb_bioblast')==2,'nastepna seria Bio Blast gra ponownie')
send('EVENT x2 EXP ZAKOŃCZONY. Następny start na początku kolejnej godziny.')
check(count('sb_doubleexp_end')==1 and last('sb_doubleexp_end')=='sounds/events/multiplierdown.ogg','koniec x2 z 1.6.2 zachowany')
send('EVENT x2 EXP ZAKOŃCZONY. Następny start na początku kolejnej godziny.')
check(count('sb_doubleexp_end')==1,'koniec x2 bez duplikatu')
send('Bela pojawia się w Świątyni Odrodzenia.')
send('SOUND_EVENT PLAYER_LOGIN name=Bela')
advance(1)
check(count('sb_otherrecall')==0,'login innego gracza nie symuluje recalla')
send('Ala pojawia się w Świątyni Odrodzenia.')
advance(1)
check(count('sb_otherrecall')==1,'recall innego gracza z 1.6.2 zachowany')
command('test advent')
check(last('sb_test_advent')=='sounds/events/advent.ogg','podglad advent')
command('test doublecaps')
check(last('sb_test_doublecaps')=='sounds/events/double caps.ogg','podglad doublecaps')
command('status')
check(spoken[#spoken]:find('v1.6.4',1,true)~=nil,'wersja 1.6.3 w statusie')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'brak bledow Lua runtime')
print('V163 TOTAL PASS '..passed)
