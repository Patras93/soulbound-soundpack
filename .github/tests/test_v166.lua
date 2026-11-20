-- Soulbound v113.00.24: skill level-up uses the same learned.ogg
-- as learning a previously unknown skill; no sound on Skill XP/status.
local path=assert(arg[1], 'soundpack.lua required')
assert(loadfile(path), 'Lua syntax')
local played,spoken={},{}
local line_trigger,event_trigger,alias_trigger
local clock=1000
if os and os.time then os.time=function() return clock end end
mud={
 play=function(file,channel,gain,pan,loop)
  played[#played+1]={file=file,channel=channel};return true
 end,
 stop=function()end,
 echo=function(s)spoken[#spoken+1]=s end,
 timer=function()end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then event_trigger=fn else line_trigger=fn end
 end,
 alias=function(_,fn)alias_trigger=fn end,
 set_channel=function()end
}
assert(loadfile(path))()
assert(line_trigger and event_trigger and alias_trigger, 'missing triggers')
local tests=0
local function check(ok,msg)
 assert(ok, 'FAIL v166 '..msg)
 tests=tests+1;print('PASS v166 '..msg)
end
local function count(ch)
 local n=0
 for _,x in ipairs(played) do if x.channel==ch then n=n+1 end end
 return n
end
local function last(ch)
 for i=#played,1,-1 do
  if played[i].channel==ch then return played[i].file end
 end
end
local function send(s) line_trigger(s,{}) end
local function command(s) alias_trigger('sbs '..s,{[1]=s}) end
local function advance() clock=clock+2 end

send('Wicher awansuje na Skill Level 2.')
check(count('sb_learned')==0,'skill level before character login is silent')
send('Witaj, Testowy. Soulbound v113.00.24 World Core.')
check(count('sb_learned')==0,'logging in does not play skill level')
send('Nauczono. Wicher zaczyna na Skill Level 1.')
check(count('sb_learned')==1 and last('sb_learned')=='sounds/events/learned.ogg',
      'first learning continues to play learned.ogg')
advance()
send('Wicher awansuje na Skill Level 2.')
check(count('sb_learned')==2 and last('sb_learned')=='sounds/events/learned.ogg',
      'skill level-up plays the exact same learned.ogg')
advance()
send('Bio Blast awansuje na Skill Level 105.')
check(count('sb_learned')==3,'higher levels and skill names with spaces')
advance()
send('Wicher: Skill XP +28. Level 2, XP 50 z 100.')
send('Używasz Wicher na Skill Level 2.')
send('Wicher: Skill Level 800. Maksymalny poziom.')
send('[NEWS] Wicher awansuje na Skill Level 3.')
send('Wicher awansuje na Skill Level 3. Nowy próg XP.')
send('Wicher awansuje na Skill Level 1.')
check(count('sb_learned')==3,'skill use, XP, status, news and invalid level silent')
advance()
send('Uczysz się umiejętności Wicher.')
check(count('sb_learned')==4 and last('sb_learned')=='sounds/events/learned.ogg',
      'older skill learning announcement remains supported')
send('Zapisuję postać i wracam do wyboru postaci.')
advance()
send('Wicher awansuje na Skill Level 3.')
check(count('sb_learned')==4,'after logout no skill level sound')
command('test learned')
check(last('sb_test_learned')=='sounds/events/learned.ogg','sound preview unchanged')
command('status')
check(spoken[#spoken]:find('v1.6.9',1,true)~=nil,'status version v1.6.9')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'no Lua runtime errors')
print('V166 TOTAL PASS '..tests)
