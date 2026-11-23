-- Soulbound v116.00.68: Over Cap scheduled announcement still broadcasts,
-- but server v116.64 has no live CAP and no OVER_CAP_START sound marker.
-- Preserve text-only hourly start while retaining older technical markers.
local path=assert(arg[1],'soundpack.lua required')
local chunk,parse_error=loadfile(path)
assert(chunk,parse_error)
local plays,spoken,timers={},{},{}
local normal,technical,alias
mud={
 play=function(file,channel)
  plays[#plays+1]={file=file,channel=channel};return true
 end,
 stop=function()end,
 echo=function(s)spoken[#spoken+1]=s end,
 timer=function(delay,fn)timers[#timers+1]=fn end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(pattern,fn)alias=fn end,
 set_channel=function()end
}
chunk()
assert(normal and technical and alias,'missing Generic MUD trigger')
local n=0
local function check(ok,msg)
 assert(ok,'FAIL v1610 '..msg);n=n+1;print('PASS v1610 '..msg)
end
local function count(ch)
 local total=0;for _,p in ipairs(plays) do if p.channel==ch then total=total+1 end end
 return total
end
local function last(ch)
 for i=#plays,1,-1 do if plays[i].channel==ch then return plays[i].file end end
end
local function send(s)
 if s:find('^SOUND_EVENT ') then technical(s,{}) else normal(s,{}) end
end
local function command(s)alias('sbs '..s,{[1]=s})end
local start='EVENT OVER CAP START. Przez 15 minut limit nagrody EXP x2; sam EXP nie jest podwajany.'
local finish='EVENT OVER CAP ZAKOŃCZONY. Limity EXP wróciły do normy.'
local marker='SOUND_EVENT OVER_CAP_START'
send(start)
check(count('sb_overcap_event_start')==0,'start before character login silent')
send('Witaj, Tester. Soulbound v116.00.68 World Core.')
send('EVENT OVER CAP: następny start za 10 minut.')
send('EVENT OVER CAP AKTYWNY. Pozostało 4 minuty.')
send('EVENT x2 EXP START. Przez 15 minut wszystkie główne rodzaje EXP są podwajane.')
check(count('sb_overcap_event_start')==0,'status, countdown and x2 EXP not Over Cap start')
send(start)
check(count('sb_overcap_event_start')==1 and last('sb_overcap_event_start')=='sounds/events/double caps.ogg','v116.68 text start plays double caps')
send(start)
check(count('sb_overcap_event_start')==1,'same event start text repeated silent')
send('SOUND_EVENT FULL_CAP cap=100 kind=character')
send('EXP postaci +100. Postęp 100 z 10000.')
check(count('sb_overcap_event_start')==1,'legacy reward cannot trigger hourly event jingle')
send(finish)
check(count('sb_overcap_event_start')==1,'event end no start jingle')
send(start)
check(count('sb_overcap_event_start')==2,'new scheduled window plays again')
send(marker)
check(count('sb_overcap_event_start')==2,'marker after text does not duplicate jingle')
send(marker)
check(count('sb_overcap_event_start')==3,'next marker still works for another window without end')
send(start)
check(count('sb_overcap_event_start')==3,'text after marker never duplicates')
send(finish)
send(marker)
check(count('sb_overcap_event_start')==4,'older marker-first protocol works')
send(start)
check(count('sb_overcap_event_start')==4,'legacy text after marker does not double')
send(finish)
send('Zapisuję postać i wracam do wyboru postaci.')
send(start);send(marker)
check(count('sb_overcap_event_start')==4,'logout blocks all Over Cap start sounds')
send('Witaj, Tester. Soulbound v113.00.28 World Core.')
send(start)
check(count('sb_overcap_event_start')==5,'older text-only protocol still works')
send(finish)
send(start)
check(count('sb_overcap_event_start')==6,'older new window still works')
send('SOUND_EVENT OVER_CAP_REWARD cap=100 kind=character')
check(count('sb_overcap_reward')==1 and last('sb_overcap_reward')=='sounds/events/overcap.ogg','overcap reward remains separate sound')
check(count('sb_overcap_event_start')==6,'reward cannot sound scheduled start')
command('test doublecaps')
check(last('sb_test_doublecaps')=='sounds/events/double caps.ogg','manual start jingle preview works')
command('status')
check(spoken[#spoken]:find('v1.6.10',1,true)~=nil,'version 1.6.10 displayed')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'zero runtime errors')
print('V1610 TOTAL PASS '..n)
