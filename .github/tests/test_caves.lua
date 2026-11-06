local p=assert(arg[1])
local plays,alarms={},{}
local ordinary,event,alias
mud={
 play=function(file,channel,gain,pan,loop)
  plays[#plays+1]={file=file,channel=channel,gain=gain,loop=loop}
  return true
 end,
 stop=function() end,
 echo=function(s) alarms[#alarms+1]=s end,
 timer=function() end,
 trigger=function(pat,fn,opts)
  if pat:find('^SOUND_EVENT',1,true) then event=fn else ordinary=fn end
 end,
 alias=function(pat,fn) alias=fn end,
 set_channel=function() end,
}
assert(loadfile(p))()
assert(ordinary and event and alias)
local checks=0
local function check(cond,desc)
 if not cond then error('FAIL CAVES: '..desc) end
 checks=checks+1
 print('PASS CAVES: '..desc)
end
local function send(line) ordinary(line,{}) end
local function cmd(x) alias('sbs '..x,{[1]=x}) end
local function count(channel)
 local n=0
 for _,v in ipairs(plays) do if v.channel==channel then n=n+1 end end
 return n
end
local function last(channel)
 for i=#plays,1,-1 do if plays[i].channel==channel then return plays[i] end end
end
local function move(room,zone)
 send('Idziesz na północ. Cel: '..room..'.')
 send('Docierasz do: '..room..'.')
 if zone then send('Lokalizacja: '..room..'. Strefa: '..zone..'.') end
end
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
local n=count('sb_cave_steps')
send('Wejście do Jaskiń Goblinów. Strefa: Jaskinie Goblinów.')
check(count('sb_cave_steps')==n,'look alone silent')
send('Idziesz na północ. Cel: Galeria Grzybów.')
check(count('sb_cave_steps')==n,'movement start silent')
send('Docierasz do: Galeria Grzybów.')
check(count('sb_cave_steps')==n+1 and last('sb_cave_steps').file=='sounds/steps/caves/1.ogg','first cave step after arrival')
send('Lokalizacja: Galeria Grzybów. Strefa: Jaskinie Goblinów.')
check(count('sb_cave_steps')==n+1,'no double from look')
move('Tunele Złomu','Jaskinie Goblinów')
check(count('sb_cave_steps')==n+2 and last('sb_cave_steps').file=='sounds/steps/caves/2.ogg','second cave step')
move('Przedsionek Krypty','Podziemia')
check(count('sb_cave_steps')==n+3 and last('sb_cave_steps').file=='sounds/steps/caves/3.ogg','crypt room from v107')
move('Sala Krypty','Podziemia')
check(count('sb_cave_steps')==n+4 and last('sb_cave_steps').file=='sounds/steps/caves/4.ogg','fourth crypt step')
move('Głębia Krypty','Podziemia')
check(count('sb_cave_steps')==n+5 and last('sb_cave_steps').file=='sounds/steps/caves/1.ogg','rotation wraps')
move('Krypta, piętro 3: Krypta Bezimiennych','')
check(count('sb_cave_steps')==n+6 and last('sb_cave_steps').file=='sounds/steps/caves/2.ogg','dynamic crypt floor in guided mode')
move('Piętro 3: Galeria Umarłych Nar','')
check(count('sb_cave_steps')==n+7,'dynamic crypt subroom in guided mode')
move('Izba Mroku','Mityczna Krypta')
check(count('sb_cave_steps')==n+8,'zone after arrival triggers in previously unknown crypt')
move('Komnata Echa','Jaskinia Trolli')
check(count('sb_cave_steps')==n+9,'troll cave zone detection')
move('Rynek Elor','Miasto Elor')
check(count('sb_cave_steps')==n+9,'city movement does not trigger cave')
check(count('sb_city_steps')==1,'city movement still uses city footsteps')
move('Stary Trakt','Dzicz')
check(count('sb_cave_steps')==n+9,'wilderness silent')
move('Piekielne Pole','Pustkowia')
check(count('sb_cave_steps')==n+9,'unknown non-cave silent')
send('Nie możesz iść w tym kierunku.')
check(count('sb_cave_steps')==n+9,'blocked move silent')
send('Teleportujesz się do Świątyni Odrodzenia.')
check(count('sb_cave_steps')==n+9,'teleport silent')
send('Płyniesz na północ. Cel: Sala Krypty.')
send('Dopływasz do: Sala Krypty.')
check(count('sb_cave_steps')==n+9,'sailing silent')
cmd('caves off')
move('Sala Krypty','Podziemia')
check(count('sb_cave_steps')==n+9,'cave OFF silent')
cmd('caves on')
move('Sala Krypty','Podziemia')
check(count('sb_cave_steps')==n+10,'cave ON restored')
cmd('caves status')
check(alarms[#alarms]:find('odegrane 10')~=nil,'NVDA-friendly cave status')
local old=#plays
cmd('caves test')
check(#plays==old+1 and plays[#plays].channel=='sb_cave_preview','separate preview channel')
check(count('sb_cave_steps')==n+10,'preview not counted as walking')
move('Sala Krypty','Podziemia')
check(last('sb_cave_steps').file=='sounds/steps/caves/3.ogg','preview does not advance rotation')
local exp=count('sb_doubleexp')
send('Event x2 EXP START!')
check(count('sb_doubleexp')==exp+1,'existing EXP event remains working')
check(count('sb_cave_steps')==n+11,'EXP event does not trigger cave footsteps')
send('Zapisuję postać i wracam do wyboru postaci.')
move('Sala Krypty','Podziemia')
check(count('sb_cave_steps')==n+11,'logged out movement silent')
print('CAVE TOTAL PASS '..checks)
