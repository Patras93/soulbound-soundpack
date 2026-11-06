-- Test chodzenia w miastach z Soulbound v107, niezalezny od innych testow.
local p=assert(arg[1])
local plays,alarms={},{}
local ordinary,event,alias
mud={
 play=function(file,channel,gain,pan,loop)
  plays[#plays+1]={file=file,channel=channel,gain=gain,loop=loop};return true
 end,
 stop=function()end,
 echo=function(s)alarms[#alarms+1]=s end,
 timer=function()end,
 trigger=function(pat,fn,opts)
  if pat:find('^SOUND_EVENT',1,true) then event=fn else ordinary=fn end
 end,
 alias=function(pat,fn)alias=fn end,
 set_channel=function()end,
}
assert(loadfile(p))()
assert(ordinary and alias,'missing callback registrations')
local total=0
local function expect(v,name)
 if not v then error('FAIL: '..name) end
 total=total+1
 print('PASS CITY: '..name)
end
local function send(s) ordinary(s,{}) end
local function cmd(s) alias('sbs '..s,{[1]=s}) end
local function stepcount()
 local n=0
 for _,a in ipairs(plays) do if a.channel=='sb_city_steps' then n=n+1 end end
 return n
end
local function stepnum()
 local out
 for _,a in ipairs(plays) do if a.channel=='sb_city_steps' then out=a.file end end
 return out
end
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
local n=stepcount()
send('Plac Dusz. Strefa: Miasto Dusz.')
expect(stepcount()==n,'look alone silent')
send('Idziesz na północ. Cel: Ulica Północna.')
expect(stepcount()==n,'walking start alone silent until arrival')
send('Docierasz do: Ulica Północna.')
expect(stepcount()==n+1 and stepnum()=='sounds/steps/1.ogg','completed city walk first variant')
send('Ulica Północna. Strefa: Miasto Dusz.')
expect(stepcount()==n+1,'look after arrival does not double')
send('Idziesz na południe. Cel: Plac Dusz.')
send('Docierasz do: Plac Dusz.')
expect(stepcount()==n+2 and stepnum()=='sounds/steps/2.ogg','second city step next variant')
send('Idziesz na zachód. Cel: Rynek Elor.')
send('Docierasz do: Rynek Elor.')
expect(stepcount()==n+2,'unknown room not played before zone confirmed')
send('Rynek Elor. Strefa: Miasto Elor.')
expect(stepcount()==n+3 and stepnum()=='sounds/steps/3.ogg','another city via zone confirmation')
send('Idziesz na północ. Cel: Stary Trakt.')
send('Docierasz do: Stary Trakt.')
send('Stary Trakt. Strefa: Dzicz.')
expect(stepcount()==n+3,'wilderness silent')
send('Nie możesz iść w tym kierunku.')
expect(stepcount()==n+3,'blocked move silent')
send('Teleportujesz się do Świątyni Odrodzenia.')
expect(stepcount()==n+3,'teleport silent')
send('Płyniesz na wschód. Cel: Port Dusz.')
send('Dopływasz do: Port Dusz.')
send('Port Dusz. Strefa: Miasto Dusz.')
expect(stepcount()==n+3,'sailing silent')
cmd('steps off')
send('Idziesz na północ. Cel: Ulica Północna.')
send('Docierasz do: Ulica Północna.')
expect(stepcount()==n+3,'steps OFF silent')
cmd('steps on')
send('Idziesz na północ. Cel: Ulica Północna.')
send('Docierasz do: Ulica Północna.')
expect(stepcount()==n+4 and stepnum()=='sounds/steps/4.ogg','steps ON restores ordered variants')
cmd('steps status')
expect(alarms[#alarms]:find('odegrane 4')~=nil,'accessible step status')
local testn=#plays
cmd('steps test')
expect(#plays==testn+1 and plays[#plays].channel=='sb_city_preview','manual preview independent of movement')
send('Idziesz na południe. Cel: Plac Dusz.')
send('Docierasz do: Plac Dusz.')
expect(stepcount()==n+5 and stepnum()=='sounds/steps/5.ogg','step rotation continues after preview')
send('Zapisuję postać i wracam do wyboru postaci.')
send('Plac Dusz. Strefa: Miasto Dusz.')
expect(stepcount()==n+5,'logout silent')
send('Witaj, Testowy. Soulbound v107.00.0 World Core.')
send('Idziesz na północ. Cel: Ulica Północna.')
send('Docierasz do: Ulica Północna.')
expect(stepcount()==n+6 and stepnum()=='sounds/steps/6.ogg','relogin steps working')
print('CITY TOTAL PASS '..total)
