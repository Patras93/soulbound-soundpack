local script=assert(arg[1], 'path soundpack.lua')
local played, reports={},{}
local on_regular, on_protocol, command
mud = {
 play=function(file,channel,gain,pan,loop)
  played[#played+1]={file=file,channel=channel,gain=gain,loop=loop};return true
 end,
 stop=function(_)end,
 echo=function(msg)reports[#reports+1]=msg end,
 timer=function()end,
 set_channel=function()end,
 trigger=function(pat,fun,opts)
  if pat:find('^SOUND_EVENT',1,true) then on_protocol=fun else on_regular=fun end
 end,
 alias=function(pat,fun)command=fun end
}
assert(loadfile(script))()
assert(on_regular and on_protocol and command)
local n=0
local function check(ok,label)
 assert(ok,'FAIL: '..label); n=n+1;print('PASS soullevel '..label)
end
local function count(channel)
 local k=0;for _,p in ipairs(played) do if p.channel==channel then k=k+1 end end;return k
end
local function last(channel)
 for i=#played,1,-1 do if played[i].channel==channel then return played[i] end end
end
local function send(s)on_regular(s,{})end
local function cmd(x) command('sbs '..x,{[1]=x})end
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
local before=count('sb_soul_level')
send('Broń Duszy otrzymuje 500 Soul XP.')
check(count('sb_soul_level')==before,'soul XP gain silent')
send('Dusza: Soul Level 70/800. Soul XP 0/1200.')
check(count('sb_soul_level')==before,'profile readout silent')
send('Soul Level: 70/800.')
check(count('sb_soul_level')==before,'score readout silent')
send('Osiągnięto próg Tieru 8. Idź do Kapłana Elora.')
check(count('sb_soul_level')==before,'Soul Tier gate silent')
send('Soul Weapon Mastery wzrasta do 38/800.')
check(count('sb_soul_level')==before,'Soul Weapon Mastery silent')
send('Level postaci wzrasta do 75.')
check(count('sb_soul_level')==before,'character level separate')
send('Broń Duszy osiąga Soul Level 71.')
check(count('sb_soul_level')==before+1,'soul level plays')
local p=last('sb_soul_level')
check(p.file=='sounds/events/soul level.ogg','correct user OGG')
check(p.loop==false,'soul level one-shot, no looping')
send('Broń Duszy osiąga Soul Level 72.')
check(count('sb_soul_level')==before+1,'burst multiple soul levels no jingle restart')
send('Broń Duszy ma już Soul Level 72.')
check(count('sb_soul_level')==before+1,'max status silent')
send('Broń Duszy osiąga Soul Level 73. Wypowiedz formułę.')
check(count('sb_soul_level')==before+1,'embedded text ignored')
send('EVENT x2 EXP START!')
check(count('sb_doubleexp')>=1,'double exp remains separately mapped')
check(count('sb_soul_level')==before+1,'double exp never triggers soul level')
cmd('test soullevel')
check(count('sb_test_soullevel')==1,'manual preview works')
check(last('sb_test_soullevel').file=='sounds/events/soul level.ogg','preview file correct')
print('SOUL LEVEL TOTAL PASS '..n)
