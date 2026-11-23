-- Soulbound v116.00.43: border crossing without LOOK on guided/manual movement.
-- Source: data/rooms.py catalog of 20 081 rooms, 141 zones and 295 cross-zone exits.
local path=assert(arg[1], 'soundpack.lua required')
assert(loadfile(path), 'Lua syntax')
local played,spoken,timers={},{},{}
local normal,technical,alias
mud={
 play=function(file,channel)played[#played+1]={file=file,channel=channel};return true end,
 stop=function()end,
 echo=function(msg)spoken[#spoken+1]=msg end,
 timer=function(delay,fn)timers[#timers+1]=fn end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(_,fn)alias=fn end,
 set_channel=function()end,
}
assert(loadfile(path))()
assert(normal and technical and alias)
local passes=0
local function check(ok,msg)
 assert(ok,'FAIL v168 '..msg);passes=passes+1;print('PASS v168 '..msg)
end
local function count(ch)
 local n=0;for _,a in ipairs(played) do if a.channel==ch then n=n+1 end end
 return n
end
local function last(ch)
 for i=#played,1,-1 do if played[i].channel==ch then return played[i].file end end
end
local function send(line) normal(line,{}) end
local function command(line)alias('sbs '..line,{[1]=line})end

send('Docierasz do: Stary Trakt.')
check(count('sb_area')==0,'no area sound without character login')
send('Witaj, Testowy. Soulbound v116.00.43 World Core.')
send('Lokalizacja: Plac Dusz. Strefa: Miasto Dusz.')
check(count('sb_area')==0,'initial zone identification is silent')
send('Idziesz na wschód. Cel: Stary Trakt.')
send('Wyjścia: Północ do Dzicz. Strefa: Dzicz. Mapy okolic.')
check(count('sb_area')==0,'intent to move, map/exits do not play area sound')
send('Docierasz do: Stary Trakt.')
check(count('sb_area')==1 and last('sb_area')=='sounds/events/change area.ogg','Miasto Dusz -> Dzicz without look')
send('Stary Trakt. Strefa: Dzicz.')
check(count('sb_area')==1,'LOOK after arrival does not double play')
send('Docierasz do: Zapomniana Kapliczka.')
check(count('sb_area')==1,'ordinary step inside Dzicz silent')
send('Docierasz do: Północna Brama.')
check(count('sb_area')==2,'return Dzicz -> Miasto Dusz plays')
send('Docierasz do: Stary Trakt.')
check(count('sb_area')==3,'re-entering original zone plays again')
send('Docierasz do: Łąka Kwiatów.')
check(count('sb_area')==4,'Dzicz -> Łąki border plays')
send('Docierasz do: Srebrzysta równina — Rozległe Łąki (1/12, 12/12).')
check(count('sb_area')==5,'Łąki -> new extended meadow zone plays without look')
send('Srebrzysta równina — Rozległe Łąki (1/12, 12/12). Strefa: Rozległe Łąki.')
check(count('sb_area')==5,'new region LOOK does not double play')
send('Idziesz na północ. Cel: Srebrzysta równina — Rozległe Łąki (1/12, 11/12).')
send('Docierasz do: Srebrzysta równina — Rozległe Łąki (1/12, 11/12).')
check(count('sb_area')==5,'long walks inside 240-room extension silent')
send('Docierasz do: Łąka Kwiatów.')
check(count('sb_area')==6,'extended meadow -> original meadow plays')
send('Łąka Kwiatów. Strefa: Łąki.')
check(count('sb_area')==6,'reverse LOOK does not double play')
send('Lokalizacja: Wąwóz — Bezkresny Przestwór. Strefa: Bezkresny Przestwór.')
check(count('sb_area')==7,'teleport followed by current-zone confirmation plays')
send('Docierasz do: Zewnętrzny Krąg — Bezkresny Przestwór.')
check(count('sb_area')==8,'surface to authored dungeon border without LOOK')
send('Docierasz do: Zawalony Trakt — Bezkresny Przestwór.')
check(count('sb_area')==9,'large dungeon to deep extension via confirmed border')
send('Docierasz do: Zapomniany trakt — Bezkresny Przestwór.')
check(count('sb_area')==10,'large dungeon to further extension')
send('Docierasz do: Kamienny chodnik — Bezkresny Przestwór.')
check(count('sb_area')==10,'internal passage with no border silent')
send('Zapisuję postać i wracam do wyboru postaci.')
send('Docierasz do: Łąka Kwiatów.')
check(count('sb_area')==10,'after logout area cue cannot play')
send('Witaj, Testowy. Soulbound v116.00.43 World Core.')
send('Lokalizacja: Morskie Molo. Strefa: Wybrzeże.')
check(count('sb_area')==10,'new character login baseline silent')
send('Dopływasz do: Skalisty brzeg — Wybrzeże Wysp (1/12, 1/12).')
check(count('sb_area')==11,'sea movement across border plays')
send('Docierasz do: Skalisty brzeg — Wybrzeże Wysp (1/12, 2/12).')
check(count('sb_area')==11,'sea coast walking without border silent')
send('Dopływasz do: Morskie Molo.')
check(count('sb_area')==12,'return by sea across border plays')
send('Lokalizacja: Stary Trakt. Strefa: Dzicz.')
check(count('sb_area')==13,'show_location after actual teleport updates zone')
send('WEJŚCIE: Wejście do Jaskiń Goblinów.')
check(count('sb_area')==14,'dungeon entry confirmed without LOOK plays')
command('status')
check(spoken[#spoken]:find('v1.6.10',1,true)~=nil,'status version 1.6.8')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'diagnostics no runtime error')
print('TOTAL V168 PASS '..passes)
