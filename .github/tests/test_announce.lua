local p=assert(arg[1],'soundpack.lua path required')
assert(loadfile(p),'Lua syntax error')
local plays,stops,alarms,timers,active={}, {}, {}, {}, {}
local ordinary,event,alias
local t=0
local function recording(...)
 plays[#plays+1]={file=select(1,...),channel=select(2,...),gain=select(3,...),loop=select(5,...)}
 active[select(2,...)]=plays[#plays]
 return true
end
mud={
 play=recording,
 stop=function(channel) stops[#stops+1]=channel;active[channel]=nil end,
 echo=function(msg)alarms[#alarms+1]=msg end,
 timer=function(delay,fn)timers[#timers+1]={when=t+delay,fn=fn} end,
 trigger=function(pat,fn,opts) if pat:find('^SOUND_EVENT',1,true) then event=fn else ordinary=fn end end,
 alias=function(pat,fn)alias=fn end,
 set_channel=function()end,
}
assert(loadfile(p))()
assert(ordinary and event and alias,'missing registrations')
local function send(s)
 if s:find('^SOUND_EVENT ') then event(s,{}) else ordinary(s,{}) end
end
local function command(s)alias('sbs '..s,{[1]=s})end
local function advance(seconds)
 local deadline=t+seconds
 while true do
  local ii,min=nil,math.huge
  for j,v in ipairs(timers) do if v.when<min then ii=j;min=v.when end end
  if not ii or min>deadline then break end
  local item=table.remove(timers,ii)
  t=item.when;item.fn()
 end
 t=deadline
end
local function count(ch)
 local n=0;for _,v in ipairs(plays)do if v.channel==ch then n=n+1 end end;return n
end
local function last(ch)
 for i=#plays,1,-1 do if plays[i].channel==ch then return plays[i] end end
end
local checks=0
local function check(test,label)
 if not test then error('FAIL '..label) end
 checks=checks+1;print('PASS '..label)
end
send('Witaj, Testowy. Soulbound v12.00.8 World Core.')
check(count('sb_enter')==1,'login triggers single enter')
send('Walka w czasie rzeczywistym rozpoczeta.')
send('SOUND_EVENT mob_hp id=rat current=100 max=100')
check(count('sb_cond_mob')==1 and last('sb_cond_mob').file=='sounds/mob/excellent.ogg','music excellent from HP 100')
check(last('sb_cond_mob').loop==true and math.abs(last('sb_cond_mob').gain-0.175)<.001,'music loops at quieter gain')
local stopBefore=#stops
send('SOUND_EVENT mob_hp id=rat current=14 max=100')
check(last('sb_cond_mob').file=='sounds/mob/awful.ogg','14 percent mob awful')
check(#stops==stopBefore,'next HP track without pre-stop gap')
send('SOUND_EVENT mob_hp id=rat current=14 max=100')
check(count('sb_cond_mob')==2,'same HP bucket no restart')
send('SOUND_EVENT mob_hp id=rat current=8 max=100')
check(last('sb_cond_mob').file=='sounds/mob/dying.ogg','dying 1-9%')
command('music off')
check(active['sb_cond_mob']==nil,'music OFF stops active loop')
local n=count('sb_cond_mob')
send('SOUND_EVENT mob_hp id=rat current=20 max=100')
check(count('sb_cond_mob')==n,'music OFF ignores new HP without disabling FX')
command('test ep')
check(count('sb_test_ep')==1,'FX remain while music off')
command('music on')
check(count('sb_cond_mob')==n+1 and last('sb_cond_mob').file=='sounds/mob/awful.ogg','music ON resumes current HP bucket')
command('musicvol 10')
check(last('sb_cond_mob').gain<.08 and last('sb_cond_mob').gain>.06,'musicvol changes current track gain')
command('music status')
check(alarms[#alarms]:find('10%%')~=nil,'accessible status of musicvol')
command('musicvol 0')
check(not active['sb_cond_mob'],'musicvol zero mutes music')
command('musicvol 25')
send('Koniec walki: wszyscy przeciwnicy zostali pokonani.')
check(not active['sb_cond_mob'],'end combat stops music')
send('Zadanie ukonczone: Zabij wilki.')
check(count('sb_quest')==1,'quest completion sound')
send('Mira wrecza ci nagrode: 10 zlota.')
check(count('sb_quest_gold')==0,'gold waits for quest fanfare')
advance(2.9)
check(count('sb_quest_gold')==1 and last('sb_quest_gold').file=='sounds/events/receive gold.ogg','gold after quest fanfare')
send('Zadanie ukonczone: Zbierz ziola.')
send('Mira wrecza ci nagrode: 15 srebra.')
send('Wylogowano z konta.')
advance(3.0)
check(count('sb_quest_gold')==1,'logout cancels queued gold')
send('Witaj, Testowy. Soulbound v12.00.8 World Core.')
send('SOUND_EVENT mob_hp id=rat current=80 max=100')
check(count('sb_cond_mob')>=5,'relogin restores music event handling')
send('Walka w czasie rzeczywistym rozpoczeta.')
send('Pokonuje cie szczur.')
check(active['sb_cond_mob']==nil,'death stops music')
n=count('sb_cond_mob')
send('SOUND_EVENT mob_hp id=rat current=20 max=100')
check(count('sb_cond_mob')==n,'postmortem mob HP cannot restart loop')
command('status')
check(alarms[#alarms]:find('v1.6.5')~=nil,'status version')
command('diag')
check(alarms[#alarms]:find('bledy=0')~=nil,'diagnostic errors zero')

-- Podglad OGG nie ingeruje w kanaly walki ani efekty.
command('testmob pretty hurt')
check(last('sb_preview_mob').file=='sounds/mob/pretty hurt.ogg' and not last('sb_preview_mob').loop,'preview mob music one shot')
check(math.abs(last('sb_preview_mob').gain-0.175)<0.001,'preview mob music quieter')
command('testplayer awful')
check(last('sb_preview_player').file=='sounds/player/awful.ogg','preview player voice')
local oldpreview=count('sb_preview_player')
command('testplayer dying')
check(count('sb_preview_player')==oldpreview,'invalid preview player dying rejected')
command('teststop')
check(not active.sb_preview_mob and not active.sb_preview_player,'preview stops without touching FX')
-- Oddanie bez pieniedzy nie moze odtwarzac zlota.
send('Witaj, Testowy. Soulbound v12.00.8 World Core.')
local ng=count('sb_quest_gold')
send('Zadanie ukonczone: Zioła.')
send('Mira wrecza ci nagrode: Kamien Duszy.')
advance(3.2)
check(count('sb_quest_gold')==ng,'item reward is not gold')
send('Zadanie ukonczone: Krypta.')
send('Mira wrecza ci nagrode: 2 mithril, 50 zlota.')
advance(2.9)
check(count('sb_quest_gold')==ng+1,'gold parses combination of currencies')
send('Mira wrecza ci nagrode: 50 zlota.')
check(count('sb_quest_gold')==ng+1,'one money sound per quest reward')
send('Zadanie ukonczone: Wilki.')
send('Mira wrecza ci nagrode: 10 zlota.')
command('off')
advance(3.0)
check(count('sb_quest_gold')==ng+1,'soundpack OFF cancels pending gold')
command('on')
send('Event x2 EXP START!')
local nx=count('sb_doubleexp')
check(nx>=1,'double EXP starts sound')
send('Event x2 EXP aktywny.')
check(count('sb_doubleexp')==nx,'double EXP status does not repeat sound')
send('Event x2 EXP START!')
check(count('sb_doubleexp')==nx,'double EXP repeated start ignored')
send('Event x2 EXP zakonczony.')
send('Event x2 EXP START!')
check(count('sb_doubleexp')==nx+1,'new double EXP start plays')
local ne=count('sb_ep')
send('Wazne odkrycie: +10 EP.')
check(count('sb_ep')==ne+1,'ep single cue')
send('EP: 300. Osiagniecie 5 EP.')
check(count('sb_ep')==ne+1,'ep readout silent')
local nf=count('sb_fame')
send('Fame zaliczone: 1000.')
check(count('sb_fame')==nf+1,'fame single cue')
local na=count('sb_achievement')
send('Osiagniecie: Pierwsze kroki.')
check(count('sb_achievement')==na+1,'achievement cue on award')
local nr=count('sb_recall')
send('Juz jestes w Swiatyni Odrodzenia.')
check(count('sb_recall')==nr,'recall already at shrine silent')
send('Teleportujesz sie do Swiatyni Odrodzenia.')
check(count('sb_recall')==nr+1,'confirmed recall cue')
local nenter=count('sb_other_enter')
send('SOUND_EVENT player_login who=Test2')
check(count('sb_other_enter')==nenter+1,'SOUND_EVENT only one audio cue')
local ngold=count('sb_gold')
send('Otrzymujesz 5 zlota.')
check(count('sb_gold')==ngold+1,'regular gold reward is still audible')

print('TOTAL PASS '..checks)

-- Rozszerzenie: nowe OGG tylko na globalny start eventu, a nie x2 EXP.
local previousX2=count('sb_doubleexp')
local oldAnnouncements=count('sb_announce')
-- W testach zegar kontrolowany przez symulator (w produkcji os.time).
local oldtime=os.time
os.time=function()return math.floor(t+10000) end
send('WYDARZENIE ŚWIATA: Inwazja ognia! Boss: Ognisty Smok. Miejsce: Stara Twierdza. Czas wydarzenia: 3 godziny. Prawdziwy boss, wspólny EXP i łupy.')
check(count('sb_announce')==oldAnnouncements+1,'event boss announcement')
check(last('sb_announce').file=='sounds/events/announce.ogg','announce file mapping')
check(not last('sb_announce').loop,'announce plays once')
send('WYDARZENIE ŚWIATA: Rzadki wróg. Miejsce: Kanion. Wydarzenie jest prawdziwą walką; solo i drużyny mogą wziąć udział.')
check(count('sb_announce')==oldAnnouncements+1,'burst event announcements are deduplicated')
advance(9)
send('WYDARZENIE ŚWIATA: Gracz rozpoczyna Obrona Fortu! Obozowisko: Rynek. Można walczyć solo lub z drużyną.')
check(count('sb_announce')==oldAnnouncements+2,'world crisis starts event sound after cooldown')
advance(9)
send('WYDARZENIE ADMINA: chaos w Arce. Potwory beda dostepne przez maksymalnie 30 minut poza walka.')
check(count('sb_announce')==oldAnnouncements+3,'admin global event')
send('WYDARZENIE ŚWIATA ZAKOŃCZONE: Gracz odparł Inwazja!')
send('WYDARZENIA ŚWIATA — następna rotacja za 200 sekund.')
send('WYDARZENIE ŚWIATA: Inwazja! Boss: Smok. (To lista w menu, bez Miejsce:)')
send('EVENT x2 EXP aktywny.')
check(count('sb_announce')==oldAnnouncements+3,'status history, end event, and double exp excluded')
check(count('sb_doubleexp')==previousX2,'double exp sound unchanged')
command('test announce')
check(count('sb_test_announce')==1,'manual announce audio test')
os.time=oldtime
print('ANNOUNCE TESTS PASS')
