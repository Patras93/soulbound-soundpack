-- Soulbound v113.00.17: explicit, essential Jammer-end notice.
-- The old "Stop się kończy" notice is now rewritten by the game server.
local path=assert(arg[1], 'soundpack.lua required')
assert(loadfile(path), 'Lua syntax')
local plays,spoken={},{};
local normal,technical,alias
mud={
 play=function(file,channel) plays[#plays+1]={file=file,channel=channel};return true end,
 stop=function()end,
 echo=function(s)spoken[#spoken+1]=s end,
 timer=function()end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(_,fn)alias=fn end,
 set_channel=function()end,
}
assert(loadfile(path))()
assert(normal and technical and alias, 'missing triggers')
local n=0
local function check(ok,msg)
 assert(ok, 'FAIL v165 '..msg);n=n+1;print('PASS v165 '..msg)
end
local function count(ch)
 local a=0;for _,x in ipairs(plays) do if x.channel==ch then a=a+1 end end
 return a
end
local function last(ch)
 for i=#plays,1,-1 do if plays[i].channel==ch then return plays[i].file end end
end
local function send(s) normal(s,{}) end
local function command(s) alias('sbs '..s,{[1]=s}) end
local ending='Jammer na Upiór Velsal zakończył działanie.'
send(ending)
check(count('sb_jammeroff')==0,'no end sound before entering game')
send('Witaj, Testowy. Soulbound v113.00.17 World Core.')
check(count('sb_jammeroff')==0,'login does not sound Jammer end')
send('Jammer: Upiór Velsal zostaje jednorazowo wyłączony na 3 akcji. Celność 85 procent.')
check(count('sb_jammer')==1 and last('sb_jammer')=='sounds/events/stop.ogg','Jammer start unchanged')
send('Upiór Velsal jest zatrzymany przez Jammer i pomija akcję. Pozostało 2 akcji Stop.')
check(count('sb_jammeroff')==0,'remaining Stop actions cannot end Jammer')
send(ending)
check(count('sb_jammeroff')==1 and last('sb_jammeroff')=='sounds/events/noactoff.ogg','v113.00.17 exact Jammer end plays noactoff')
local baseline=count('sb_jammeroff')
send('Jammer na Upiór Velsal zakończył działanie')
send('Jammer na Upiór Velsal zakończył działanie!')
send('[NEWS] Jammer na Upiór Velsal zakończył działanie.')
send('Jammer na Upiór Velsal zakończył działanie. Pozostało 1 akcji Stop.')
send('Jammer na Upiór Velsal nie zakończył działania.')
send('Stop: nadal działa.')
check(count('sb_jammeroff')==baseline,'no false positive for similar lines, chatter, or status')
send('Zapisuję postać i wracam do wyboru postaci.')
send(ending)
check(count('sb_jammeroff')==baseline,'no Jammer-end sound after character logout')
command('test jammeroff')
check(last('sb_test_jammeroff')=='sounds/events/noactoff.ogg','manual preview uses existing OGG')
command('status')
check(spoken[#spoken]:find('v1.6.5',1,true)~=nil,'status shows v1.6.5')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'no Lua runtime errors')
print('V165 TOTAL PASS '..n)
