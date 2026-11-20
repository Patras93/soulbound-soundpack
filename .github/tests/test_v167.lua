-- Soulbound v113.00.29: one authenticated server marker per successful EXP payout.
-- Every separate reward at the same cap must play again; bank/status must not.
local path=assert(arg[1], 'soundpack.lua required')
assert(loadfile(path), 'Lua syntax error')
local played,spoken,timers={},{},{}
local normal,technical,alias
local clock=0
mud={
 play=function(file,channel,gain,pan,loop)
  played[#played+1]={file=file,channel=channel};return true
 end,
 stop=function()end,
 echo=function(msg)spoken[#spoken+1]=msg end,
 timer=function(delay,fn)timers[#timers+1]={at=clock+delay,fn=fn} end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(pattern,fn)alias=fn end,
 set_channel=function()end
}
assert(loadfile(path))()
assert(normal and technical and alias)
local checks=0
local function check(ok,msg)
 assert(ok,'FAIL v167 '..msg)
 checks=checks+1;print('PASS v167 '..msg)
end
local function count(channel)
 local n=0
 for _,p in ipairs(played) do if p.channel==channel then n=n+1 end end
 return n
end
local function last(channel)
 for i=#played,1,-1 do if played[i].channel==channel then return played[i].file end end
end
local function send(line)
 if line:find('^SOUND_EVENT ') then technical(line,{}) else normal(line,{}) end
end
local function command(s)alias('sbs '..s,{[1]=s})end
local function advance(d)
 local deadline=clock+d
 while true do
  local idx,min=nil,math.huge
  for i,v in ipairs(timers) do if v.at<min then idx=i;min=v.at end end
  if not idx or min>deadline then break end
  local t=table.remove(timers,idx);clock=t.at;t.fn()
 end
 clock=deadline
end
local half='SOUND_EVENT HALF_CAP cap=100 kind=character'
local full='SOUND_EVENT FULL_CAP cap=100 kind=character'
local over='SOUND_EVENT OVER_CAP_REWARD cap=100 kind=character'
local start='SOUND_EVENT OVER_CAP_START'
send(half);send(full);send(over);send(start)
check(count('sb_halfcap')==0 and count('sb_cap')==0 and count('sb_overcap_reward')==0 and count('sb_overcap_event_start')==0,'no reward sounds before login')
send('Witaj, Tester. Soulbound v113.00.29 World Core.')
send('Your experience cap is 100 EXP.')
check(count('sb_halfcap')==0 and count('sb_cap')==0,'reading the limit stays silent')
send(half)
check(count('sb_halfcap')==1 and last('sb_halfcap')=='sounds/events/halfcap.ogg','first HALF_CAP uses halfcap.ogg')
send('EXP postaci +50. Postęp 150 z 900.')
advance(1)
check(count('sb_exp')==0,'paid text does not add ordinary EXP sound after marker')
send(half)
check(count('sb_halfcap')==2,'second HALF_CAP at same cap is audible')
send(full)
check(count('sb_cap')==1 and last('sb_cap')=='sounds/events/cap.ogg','FULL_CAP uses cap.ogg')
send(full)
check(count('sb_cap')==2,'second FULL_CAP at same cap is audible')
send(half)
check(count('sb_halfcap')==3,'HALF_CAP can occur after FULL_CAP in a later reward')
send(over)
check(count('sb_overcap_reward')==1 and last('sb_overcap_reward')=='sounds/events/overcap.ogg','OVER_CAP_REWARD uses overcap.ogg')
send(over)
check(count('sb_overcap_reward')==2,'second real overcap reward also plays')
send('SOUND_EVENT OVER_CAP_REWARD cap=100 kind=soul')
check(count('sb_overcap_reward')==3,'independent kind of real payout still plays')
send('SOUND_EVENT HALF_CAP cap=0 kind=character')
send('SOUND_EVENT HALF_CAP cap=invalid kind=character')
send('SOUND_EVENT FULL_CAP cap=0 kind=character')
send('SOUND_EVENT OVER_CAP_REWARD cap=0 kind=character')
check(count('sb_halfcap')==3 and count('sb_cap')==2 and count('sb_overcap_reward')==3,'malformed or zero cap events stay silent')
send('SOUND_EVENT EXP_BANK amount=70 kind=character')
send('EXP Bank: 70 EXP oczekuje na ręczny odbiór.')
advance(1)
check(count('sb_overcap_reward')==3 and count('sb_bank')==0,'bank deposit is not an OVER_CAP_REWARD on v113.29')
send(start)
check(count('sb_overcap_event_start')==1 and last('sb_overcap_event_start')=='sounds/events/double caps.ogg','hourly start uses double caps.ogg')
send('EVENT OVER CAP START. Przez 15 minut limit nagrody EXP x2; sam EXP nie jest podwajany.')
check(count('sb_overcap_event_start')==1,'hourly text and marker do not duplicate sound')
send(start)
check(count('sb_overcap_event_start')==2,'another real hourly marker works, even without end text')
send(over)
check(count('sb_overcap_reward')==4 and count('sb_overcap_event_start')==2,'overcap payout never triggers hourly event jingle')
send('EXP postaci +101. Postęp 550 z 900.')
advance(1)
check(count('sb_exp')==0,'no generic EXP after overcap payout marker')
send('Zapisuję postać i wracam do wyboru postaci.')
send(full);send(over);send(start)
check(count('sb_cap')==2 and count('sb_overcap_reward')==4 and count('sb_overcap_event_start')==2,'no sounds after logout')
send('Witaj, Tester. Soulbound v113.00.28 World Core.')
send('EVENT OVER CAP START. Przez 15 minut limit nagrody EXP x2; sam EXP nie jest podwajany.')
check(count('sb_overcap_event_start')==3,'old v113.28 textual event start still supported')
send('SOUND_EVENT EXP_BANK amount=40 kind=character')
advance(1)
check(count('sb_bank')==1 and last('sb_bank')=='sounds/events/overcap.ogg','legacy EXP_BANK remains compatible for older servers only')
command('test cap')
check(last('sb_test_cap')=='sounds/events/cap.ogg','CAP preview')
command('test halfcap')
check(last('sb_test_halfcap')=='sounds/events/halfcap.ogg','HALF_CAP preview')
command('test overcap')
check(last('sb_test_overcap')=='sounds/events/overcap.ogg','OVER_CAP preview')
command('status')
check(spoken[#spoken]:find('v1.6.8',1,true)~=nil,'version reported')
command('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'no Lua runtime errors')
print('V167 TOTAL PASS '..checks)
