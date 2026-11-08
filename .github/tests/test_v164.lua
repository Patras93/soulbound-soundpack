-- Soulbound v109: automatic gifts after 120 seconds, no false triggers.
local path=assert(arg[1], 'soundpack.lua required')
assert(loadfile(path), 'Lua syntax')
local plays,spoken={},{}
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
 set_channel=function()end
}
assert(loadfile(path))()
assert(normal and technical and alias)
local total=0
local function check(ok,msg)assert(ok,'FAIL v164 '..msg);total=total+1;print('PASS v164 '..msg)end
local function count(ch)
 local n=0;for _,v in ipairs(plays) do if v.channel==ch then n=n+1 end end
 return n
end
local function last(ch)
 for i=#plays,1,-1 do if plays[i].channel==ch then return plays[i].file end end
end
local function send(s)normal(s,{})end
local daily='DZIENNY PREZENT: automatyczna nagroda: 15 złota, 30 srebra, EXP postaci +250.'
local advent='ADWENT: automatyczna nagroda: 2 mithril, 3 złota, EXP postaci +1200.'
send(daily);send(advent)
check(count('sb_daily_gift')==0 and count('sb_advent_gift')==0,'no gift before login')
send('Witaj, Testowy. Soulbound v109.00.0 World Core.')
check(count('sb_daily_gift')==0 and count('sb_advent_gift')==0,'login alone silent')
send('ADWENT: dzień 3/31. Prezent wpadnie automatycznie po 2 minutach od logowania.')
send('ADWENT: dzień 3/31. Prezent odebrany.')
send('ADWENT: prezenty automatyczne 1–31 grudnia. Od 1 stycznia Daily Gifts.')
send('DZIENNY PREZENT: automatyczna nagroda:')
send('DZIENNY PREZENT: automatyczna nagroda: 10 złota, EXP postaci +xx.')
send('EXP postaci +250. Postęp 600 z 1500.')
check(count('sb_daily_gift')==0 and count('sb_advent_gift')==0,'status and EXP silent')
send(daily)
check(count('sb_daily_gift')==1 and last('sb_daily_gift')=='sounds/events/daygift.ogg','v109 daily gift')
check(count('sb_advent_gift')==0,'daily not advent')
send(advent)
check(count('sb_advent_gift')==1 and last('sb_advent_gift')=='sounds/events/advent.ogg','v109 advent gift')
check(count('sb_daily_gift')==1,'advent not daily')
send('PREZENT ADWENTOWY odebrany! Dzień 5/32. Nagroda: 15 złota. Następny prezent jutro.')
check(count('sb_advent_gift')==2,'v108 manual advent retained')
send('Zapisuję postać i wracam do wyboru postaci.')
send(daily);send(advent)
check(count('sb_daily_gift')==1 and count('sb_advent_gift')==2,'logout cancels gift playback')
alias('sbs test daygift',{[1]='test daygift'})
check(last('sb_test_daygift')=='sounds/events/daygift.ogg','preview daygift')
alias('sbs test advent',{[1]='test advent'})
check(last('sb_test_advent')=='sounds/events/advent.ogg','preview advent')
alias('sbs status',{[1]='status'})
check(spoken[#spoken]:find('v1.6.4',1,true)~=nil,'status v164')
alias('sbs diag',{[1]='diag'})
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'no runtime error')
print('V164 TOTAL PASS '..total)
