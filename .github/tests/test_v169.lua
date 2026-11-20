-- Soulbound v116.00.43: delayed Fame EXP then >=2s later actual Fame.
-- Sound markers come before the durable Fame-EXP receipt. No sound on kill/pending/status.
local path=assert(arg[1],'soundpack.lua required')
local chunk,err=loadfile(path)
assert(chunk,err)
local played,spoken={},{};
local normal,technical,alias
mud={
 play=function(file,channel)played[#played+1]={file=file,channel=channel};return true end,
 stop=function()end,
 echo=function(msg)spoken[#spoken+1]=msg end,
 timer=function()end,
 trigger=function(pattern,fn)
  if pattern:find('^SOUND_EVENT',1,true) then technical=fn else normal=fn end
 end,
 alias=function(_,fn) alias=fn end,
 set_channel=function()end
}
chunk()
assert(normal and technical and alias)
local total=0
local function check(ok,msg)assert(ok,'FAIL v169 '..msg);total=total+1;print('PASS v169 '..msg)end
local function count(ch)
 local n=0;for _,x in ipairs(played) do if x.channel==ch then n=n+1 end end
 return n
end
local function last(ch)
 for i=#played,1,-1 do if played[i].channel==ch then return played[i].file end end
end
local function send(s)
 if s:find('^SOUND_EVENT ') then technical(s,{}) else normal(s,{}) end
end
local function cmd(s)alias('sbs '..s,{[1]=s})end
local pending='FAME MOB: EXP zostanie wypłacony po 60–300 sekundach. Fama zostanie przyznana około 2 sekundy po EXP.'
local exp='FAME MOB: zaległy EXP za Strażnik Mgły został rozliczony.'
local fame='FAMA: +1 za Strażnik Mgły (Rozległy Las).'
send(pending);send(exp);send(fame)
check(count('sb_fame')==0 and count('sb_fame_exp_cap')==0,'Fame events do not sound before entering world')
send('Witaj, Tester. Soulbound v116.00.43 World Core.')
send(pending)
send('FAME MOB: EXP zostanie wypłacony po 60–300 sekundach. Fama za tego przeciwnika została już zaliczona.')
send('Fame zaliczone: Strażnik Mgły (EXP oczekuje).')
send('Fame: 43, poziom 20. Następny cel.')
send('FAME MOB: zaległy EXP za Strażnik Mgły nie został rozliczony.')
check(count('sb_fame')==0 and count('sb_fame_exp_cap')==0 and count('sb_cap')==0,'kill/pending/readout/failed EXP stay silent')
send('SOUND_EVENT FULL_CAP cap=1000 kind=character')
check(count('sb_cap')==1 and last('sb_cap')=='sounds/events/cap.ogg','real FULL_CAP marker plays cap OGG')
send(exp)
check(count('sb_cap')==1 and count('sb_fame_exp_cap')==0,'Fame EXP receipt after marker never duplicates CAP')
check(count('sb_fame')==0,'EXP phase does not prematurely play Fame')
send(fame)
check(count('sb_fame')==1 and last('sb_fame')=='sounds/events/fame.ogg','actual credited Fame plays fame OGG')
send('FAMA: +1 za Strażnik Mgły (Rozległy Las). Nagroda oczekuje.')
send('[NEWS] FAMA: +1 za Strażnik Mgły (Rozległy Las).')
send('FAMA: +0 za Strażnik Mgły (Rozległy Las).')
send('FAMA: +1 za Strażnik Mgły (Rozległy Las)')
check(count('sb_fame')==1,'news/status/malformed Fame do not play')
send('FAME MOB: zaległy EXP za Ponowny Strażnik został rozliczony.')
check(count('sb_fame_exp_cap')==1 and last('sb_fame_exp_cap')=='sounds/events/cap.ogg','explicit confirmed Fame EXP is fallback CAP if no marker')
check(count('sb_fame')==1,'repeat Fame kill EXP never mints another Fame')
send('FAME MOB: zaległy EXP za Kolejny Strażnik został rozliczony.')
check(count('sb_fame_exp_cap')==2,'separate delayed EXP payouts can play CAP again')
send('SOUND_EVENT HALF_CAP cap=1000 kind=character')
send('FAME MOB: zaległy EXP za Mały Boss został rozliczony.')
check(count('sb_fame_exp_cap')==2,'partial payout marker must not be falsely upgraded to CAP')
send('SOUND_EVENT FULL_CAP cap=1000 kind=character')
send('FAME MOB: zaległy EXP za Trzeci Boss został rozliczony.')
check(count('sb_fame_exp_cap')==2 and count('sb_cap')==2,'another real FULL_CAP plays once through its marker')
send('FAMA: +1 za Trzeci Boss (Krypta).')
check(count('sb_fame')==2,'another confirmed Fame plays again')
send('Zapisuję postać i wracam do wyboru postaci.')
send(exp);send(fame);send('SOUND_EVENT FULL_CAP cap=1000 kind=character')
check(count('sb_fame_exp_cap')==2 and count('sb_fame')==2 and count('sb_cap')==2,'logout prevents all Fame sounds')
cmd('status')
check(spoken[#spoken]:find('v1.6.9',1,true)~=nil,'version 1.6.9')
cmd('diag')
check(spoken[#spoken]:find('bledy=0',1,true)~=nil,'no runtime errors')
print('V169 TOTAL PASS '..total)
