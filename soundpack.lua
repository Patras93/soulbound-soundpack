-- SOULBOUND SOUNDPACK v1.5.8 - Native Generic MUD (mud.play)
-- Zrodlo: Soulbound v12.00.8 (SOUND_EVENT + komunikaty tekstowe). Tylko pliki OGG uzytkownika.
-- Regula bezpieczenstwa: brak dzwieku jest lepszy niz falszywy dzwiek.
local active, volume = true, 0.7
local seen, state = {}, {mob=nil,player=nil,area=nil,hp=nil,mana=nil,full=false}
local cap, last_xp = nil,nil
local cap_half_seen, cap_full_seen = false,false
local jammer_active=false
local last_mob_hp=nil
local previous_downed_marker=nil
local counters={lines=0,events=0,played=0,errors=0}
local last_line, last_event, last_error = '', '', ''
local mob_name, look_mob = nil,false
local in_world=false
local self_name=nil -- wlasna postac, aby globalny alarm zgonu nie zagral przy naszej smierci
local in_combat=false
local player_downed=false -- blokada muzyki mobow od zgonu do faktycznego powrotu do zycia
local stopped_music=0
local last_stop_reason='brak'
local debug_mode=false
local xp_event_active=nil
local xp_event_starts=0
local recall_confirms=0
-- v12.00.8: zdarzenia przekazywane przez serwer (odzielne od tekstu do NVDA).
local sound_protocol=false
local sound_protocol_count=0
local sound_kinds={}
local mob_hp_by_id={}
local focused_mob=nil
local mob_sound_bucket=nil
local recent_sound_reward_at=-1000
local recent_social_event_at=-1000
local last_sound_marker='brak'
local function norm(s)
 s=tostring(s or ''):lower()
 for a,b in pairs({['ą']='a',['ć']='c',['ę']='e',['ł']='l',['ń']='n',['ó']='o',['ś']='s',['ź']='z',['ż']='z',['Ą']='a',['Ć']='c',['Ę']='e',['Ł']='l',['Ń']='n',['Ó']='o',['Ś']='s',['Ź']='z',['Ż']='z'}) do s=s:gsub(a,b) end
 s=s:gsub('—','-'):gsub('–','-')
 return (s:gsub('^%s+',''):gsub('%s+$',''))
end
local function has(s,p) return s:find(p,1,true)~=nil end
local function say(s) if mud and mud.echo then pcall(function() mud.echo('[Soulbound OGG] '..s) end) end end
local function now()
 -- Generic MUD Lua pracuje w sandboxie bez os.time. Nie zwracaj zawsze 0,
 -- bo wowczas pojedynczy dzwiek z cooldownem zamilknie do konca sesji.
 if os and os.time then local ok,t=pcall(os.time);if ok and type(t)=='number' then return t end end
 return counters.lines
end
local function play(path,channel,delay,force)
 if not active and not force then return false end
 local t=now(); local key=channel..':'..path
 if not force and (delay or 0)>0 and seen[key] and t-seen[key]<(delay or 0) then return false end
 -- Funkcje API dostarczone przez Pythona/Lupa moga miec typ 'userdata'.
 -- Nie wymagamy type(...)=='function', bo odcinalo WSZYSTKIE dzwieki.
 if not mud or not mud.play then
  counters.errors=counters.errors+1; last_error='Brak mud.play';say(last_error);return false
 end
 local ok,res=pcall(function() return mud.play('sounds/'..path,channel,volume,0,channel=='sb_cond_mob') end)
 if not ok or res==false then
  counters.errors=counters.errors+1
  last_error=not ok and tostring(res) or ('Plik nieodnaleziony lub odrzucony: sounds/'..path)
  say('BLAD dzwieku: '..last_error)
  return false
 end
 seen[key]=t;counters.played=counters.played+1
 return true
end
local fx={
 achievement='events/achievement.ogg', allfull='events/allfull.ogg', cap='events/cap.ogg', area='events/change area.ogg',
 wrong='events/command wrong.ogg', crapexp='events/crapexp.ogg', daygift='events/daygift.ogg', doubleexp='events/double exp.ogg',
 ep='events/ep.ogg', exp='events/exp thwack1.ogg', fame='events/fame.ogg', halfcap='events/halfcap.ogg',
 hpfull='events/hpfull.ogg', leavegame='events/leave game.ogg', mana_alarm='events/mana alarm.ogg',
 manafull='events/manafull.ogg', news='events/news.ogg', overcap='events/overcap.ogg', quest='events/quest complete.ogg',
 level='events/achieve.ogg', buy='events/buy something.ogg', corpse='events/corpse.ogg', enter='events/enter.ogg',
 gossip='events/gossip.ogg', healbeam='events/HealBeam.ogg', learned='events/learned.ogg', leave='events/leave.ogg',
 leaveparty='events/leave party.ogg', mort='events/mort.ogg', frienddies='events/friend dies.ogg', member='events/new partymember.ogg',newbie='events/newbie.ogg',
 outmp='events/out of mp.ogg', revive='events/phoenix down.ogg', recall='events/recall scroll.ogg',
 gold='events/receive gold.ogg',reply='events/reply.ogg',say='events/say.ogg',otherrecall='events/someone recalls.ogg',
 jammer='events/stop.ogg',tell='events/tell.ogg',wear='events/you wear.ogg',soulhit='events/you hit.ogg',
 youdied='events/You died.ogg',vmax='events/vmax.ogg',vmaxoff='events/vmax off.ogg',
 vanish='events/vanish.ogg',jammeroff='events/noactoff.ogg',joblevel='events/job level.ogg',theyhit='events/they hit.ogg'
}
-- Oddzielna, stale uzywana sciezka dla dlugich plikow kondycji mobow.
-- Zatrzymujemy tylko ten kanal. Nie przerywamy nagrod, smierci ani czatu.
local function stop_mob_music(reason)
 if mud and mud.stop then
  local ok,err=pcall(function() mud.stop('sb_cond_mob') end)
  if not ok then
   counters.errors=counters.errors+1
   last_error='mud.stop: '..tostring(err)
   say('BLAD zatrzymywania muzyki: '..last_error)
   return false
  end
 end
 stopped_music=stopped_music+1
 last_stop_reason=reason or 'nieznany'
 return true
end
local function end_combat(reason)
 stop_mob_music(reason)
 mob_hp_by_id={}
 focused_mob=nil
 mob_sound_bucket=nil
 in_combat=false
 state.mob=nil
 last_mob_hp=nil
 mob_name=nil
 look_mob=false
end
local function sound(key,delay,channel,force)
 if fx[key] then
  last_event=key; counters.events=counters.events+1
  return play(fx[key],channel or 'sb_'..key,delay or 0,force)
 end
end
-- Progi lokalnego soundpacku, serwer przekazuje HP liczbowe.
local levels={'excellent','scratches','small wounds','quite a few','pretty hurt','big nasty','awful','dying'}
local function bucket(current,maximum,who)
 current,maximum=tonumber(current),tonumber(maximum)
 if not current or not maximum or maximum<=0 then return nil end
 local pct=math.max(0, math.min(100, 100*current/maximum))
 if pct<=0 then return 'died' end
 if pct>=100 then return 'excellent' end
 if pct>=90 then return 'scratches' end
 if pct>=75 then return 'small wounds' end
 if pct>=60 then return 'quite a few' end
 if pct>=45 then return 'pretty hurt' end
 if pct>=30 then return 'big nasty' end
 -- 14% HP ma byc 'awful' u gracza i u moba.
 -- Mob ma osobne 'dying' tylko dla ostatnich 1-9% HP.
 -- Postac gracza nie ma glosowego 'dying': do samego zgonu uzywa 'awful'.
 if pct>=10 or who=='player' then return 'awful' end
 return 'dying'
end
local function health(current,maximum,who)
 local label=bucket(current,maximum,who)
 if not label then return end
 if state[who]==label then return end
 state[who]=label
 if label=='died' then return end -- smierc obsluguje komunikat pokonania
 if who=='mob' then stop_mob_music('zmiana kondycji');mob_sound_bucket=label end
 play(who..'/'..label..'.ogg','sb_cond_'..who,0)
end
local function condition(txt,who)
 for _,label in ipairs(levels) do
  if has(txt,label) then
   -- Tekstowa kondycja 'dying' postaci tez musi uzyc istniejacego glosu 'awful'.
   if who=='player' and label=='dying' then label='awful' end
   if state[who]~=label then
    state[who]=label
    if who=='mob' then stop_mob_music('zmiana kondycji');mob_sound_bucket=label end
    play(who..'/'..label..'.ogg','sb_cond_'..who,0)
   end
   return
  end
 end
end
-- HP i mana: glos kondycji dziala przy ZMIANIE zdrowia w obie strony.
-- Pelne zasoby laczymy z sasiadujacych linii (np. mikstura: HP i Mana
-- sa wysylane osobno), aby nie odtwarzac hpfull i zaraz allfull.
local pending_full_hp, pending_full_mana, full_cue_waiting = false,false,false
local function flush_full_cues()
 full_cue_waiting=false
 local hp_full=state.hp and state.hp[2]>0 and state.hp[1]>=state.hp[2]
 local mana_full=state.mana and state.mana[2]>0 and state.mana[1]>=state.mana[2]
 if (pending_full_hp or pending_full_mana) and hp_full and mana_full then
  sound('allfull',2)
 elseif pending_full_hp and hp_full then
  sound('hpfull',2)
 elseif pending_full_mana and mana_full then
  sound('manafull',2)
 end
 pending_full_hp=false;pending_full_mana=false
end
local function schedule_full_cue()
 if full_cue_waiting then return end
 full_cue_waiting=true
 if mud and mud.timer then
  local ok=pcall(function() mud.timer(0.15,flush_full_cues) end)
  if ok then return end
 end
 flush_full_cues()
end
local function update_vital(kind,a,b,mode,delta)
 a,b=tonumber(a),tonumber(b)
 if not a or not b or b<=0 then return end
 a=math.max(0,math.min(a,b))
 local previous=state[kind]
 -- Tam gdzie komunikat podaje ile HP przywrocono, odtwarzamy poprzedni
 -- stan nawet gdy to pierwszy odczyt HP w tej sesji.
 local derived=false
 if not previous and mode=='event' and kind=='hp' and tonumber(delta) and tonumber(delta)>0 then
  previous={math.max(0,a-tonumber(delta)),b}
  derived=true
 end
 state[kind]={a,b}
 if kind=='hp' then
  if mode=='event' and previous and (previous[1]~=a or previous[2]~=b) then
   if not state.player then state.player=bucket(previous[1],previous[2],'player') end
   health(a,b,'player')
  elseif mode=='event' and not previous then
   -- Pierwszy jawny komunikat o leczeniu (bez historii): podaj obecna
   -- kondycje, ale nie udawaj, ze zwykly status spowodowal leczenie.
   health(a,b,'player')
  else
   -- Odczyty score, HP: i Mana: aktualizuja stan bez alarmow.
   state.player=bucket(a,b,'player')
  end
 end
 if mode~='event' then
  state.full=state.hp and state.mana and state.hp[1]>=state.hp[2] and state.mana[1]>=state.mana[2] or false
  return
 end
 if kind=='mana' and previous and previous[1]/previous[2]>0.20 and a/b<=0.20 then sound('mana_alarm',2) end
 if previous and previous[1]<previous[2] and a>=b then
  if kind=='hp' then pending_full_hp=true else pending_full_mana=true end
  schedule_full_cue()
 elseif derived and a>=b then
  if kind=='hp' then pending_full_hp=true else pending_full_mana=true end
  schedule_full_cue()
 end
 state.full=state.hp and state.mana and state.hp[1]>=state.hp[2] and state.mana[1]>=state.mana[2] or false
end
-- Po miksturze serwer wypisuje: Uzywasz ... Odzyskujesz ... HP,
-- a nastepnie HP <bieżące> z <maksymalne> i ewentualnie Mana ...
local potion_vitals_until=-100000
local potion_hp_gain=0

local function death()
 if player_downed then end_combat('ponowne potwierdzenie zgonu'); return end
 player_downed=true
 pending_full_hp=false;pending_full_mana=false
 end_combat('smierc postaci')
 sound('mort',2,'sb_death_a');sound('youdied',2,'sb_death_b')
 state.player=nil
 if mud and mud.stop then pcall(function() mud.stop('sb_cond_player') end) end
end
-- v1.5.8: Nagrody questow maja OSOBNE dzwieki: ukonczenie + pieniadze.
-- Serwer 12.00.8 najpierw wypisuje EXP postaci, a dopiero pozniej
-- "Zadanie ukonczone". Wstrzymujemy dzwiek EXP na krotka chwile;
-- jesli przyszlo potwierdzenie questa, nie odtwarzamy nagrody EXP.
-- To nie zmienia ani nie blokuje prawdziwego EXP w grze.
local quest_reward_in_progress=false
local quest_reward_marker_line=-100000
local quest_money_until=-100000
local quest_money_played=false
local quest_gold_generation=0
local quest_gold_pending=false
local quest_gold_ready=false
local pending_xp_sounds={}
local pending_xp_seq=0
local function cancel_pending_xp()
 pending_xp_sounds={}
end
local function queue_xp_sound(key,channel)
 if quest_reward_in_progress and counters.lines-quest_reward_marker_line<=80 then return end
 -- Generic MUD ma timer skryptowy. Nie puszczaj EXP natychmiast,
 -- bo potwierdzenie "Zadanie ukonczone" wystepuje PO linii EXP.
 if not mud or not mud.timer then
  -- Nie ryzykuj falszywego dzwieku questa w kliencie bez timerow.
  return
 end
 pending_xp_seq=pending_xp_seq+1
 local id=pending_xp_seq
 pending_xp_sounds[id]=true
 local ok,err=pcall(function()
  mud.timer(0.85,function()
   if pending_xp_sounds[id] then
    pending_xp_sounds[id]=nil
    sound(key,0,channel)
   end
  end)
 end)
 if not ok then
  pending_xp_sounds[id]=nil
  counters.errors=counters.errors+1
  last_error='timer EXP: '..tostring(err)
  say(last_error)
 end
end
-- Odczekaj do konca fanfary questa (2,6 s), aby krotkie zloto (0,54 s)
-- nie zostalo zagluszone. Timer liczymy od potwierdzenia oddania zadania,
-- a nie od momentu otrzymania komunikatu o monetach.
local function reset_quest_gold()
 quest_gold_generation=quest_gold_generation+1
 quest_gold_pending=false
 quest_gold_ready=false
end
local function play_quest_gold()
 if not quest_gold_pending then return end
 quest_gold_pending=false
 sound('gold',0,'sb_quest_gold')
end
local function prepare_quest_gold()
 reset_quest_gold()
 local token=quest_gold_generation
 if mud and mud.timer then
  local ok=pcall(function()
   mud.timer(2.75,function()
    if token~=quest_gold_generation then return end
    quest_gold_ready=true
    if in_world then play_quest_gold() end
   end)
  end)
  if ok then return end
 end
 -- Zgodnosc wsteczna: brak timera nie moze wyciszyc nagrody.
 quest_gold_ready=true
end
local function is_money_reward_line(s)
 -- Weryfikuj sama kwote po nazwie NPC, nie nazwe przedmiotu z liczba.
 local amount=s:match('^.+ wrecza ci nagrode:%s*(.-)%.$')
 if not amount then
  amount=s:match('^o kurde%s*%-%s*premia za wykonanie:%s*dodatkowo%s+(.-)%.$')
 end
 if not amount then return false end
 local count=0
 for part in (amount..','):gmatch('(.-),') do
  part=part:gsub('^%s+',''):gsub('%s+$','')
  local n,unit=part:match('^(%d+)%s+([a-z]+)$')
  if not n or (unit~='srebra' and unit~='zlota' and unit~='mithril') then return false end
  if tonumber(n)>0 then count=count+1 end
 end
 return count>0
end
-- SOUND_EVENT jest protokolem serwera v12.00.8. Komenda status/score/expbank
-- NIE jest nagroda i nie generuje takiego znacznika. Nie zgadujemy zdarzen.
local function on_sound_event(s)
 local event=s:match('^sound_event%s+([%w_]+)')
 if not event then return false end
 sound_protocol=true
 sound_protocol_count=sound_protocol_count+1
 last_sound_marker=event
 local fields={}
 for k,v in s:gmatch('([%w_]+)=([^%s]+)') do fields[k]=v end
 if event=='exp_bank' then
  local n=tonumber(fields.amount or '') or 0
  if n>0 then recent_sound_reward_at=counters.lines;queue_xp_sound('overcap','sb_bank') end
  return true
 elseif event=='half_cap' or event=='full_cap' then
  local n=tonumber(fields.cap or '') or 0
  if n>0 then
   local key=tostring(n)
   if sound_kinds.last_cap~=key then
    sound_kinds.last_cap=key
    sound_kinds.half=false
    sound_kinds.full=false
   end
   recent_sound_reward_at=counters.lines
   if event=='full_cap' and not sound_kinds.full then
    sound_kinds.full=true
    sound_kinds.half=true
    queue_xp_sound('cap','sb_cap')
   elseif event=='half_cap' and not sound_kinds.half and not sound_kinds.full then
    sound_kinds.half=true
    queue_xp_sound('halfcap','sb_halfcap')
   end
  end
  return true
 elseif event=='player_login' then
  sound('enter',0,'sb_other_enter')
  return true
 elseif event=='player_logout' then
  sound('leave',0,'sb_other_leave')
  return true
 elseif event=='tell_received' then
  recent_social_event_at=counters.lines
  sound('tell',0,'sb_tell')
  return true
 elseif event=='reply_received' then
  recent_social_event_at=counters.lines
  sound('reply',0,'sb_reply')
  return true
 elseif event=='mob_hp' then
  -- Po smierci postaci serwer moze jeszcze wyslac opoznione MOB_HP.
  -- Bez tej blokady dluga muzyka stanu moba wracala po smierci gracza.
  if player_downed or not in_world then return true end
  local id=fields.id
  local current=tonumber(fields.current or '')
  local maximum=tonumber(fields.max or '')
  if not id or not current or not maximum or maximum<=0 then return true end
  local label=bucket(current,maximum,'mob')
  if not label then return true end
  if label=='died' then
   mob_hp_by_id[id]=nil
   if focused_mob==id then
    stop_mob_music('HP aktualnego moba = 0')
    focused_mob=nil
    mob_sound_bucket=nil
    state.mob=nil
   end
  else
   -- Aktualizujemy wszystkie moby, ale muzyka dotyczy JEDNEGO celu.
   -- Nie przeplatamy np. excellent.ogg drugiego szczura z awful.ogg pierwszego.
   local old=mob_hp_by_id[id]
   mob_hp_by_id[id]=label
   local new_focus=(focused_mob==nil)
   if new_focus then focused_mob=id end
   if focused_mob==id and (label~=old or new_focus) then
    if label~=mob_sound_bucket then
     stop_mob_music('zmiana kondycji sledzonego moba')
     if play('mob/'..label..'.ogg','sb_cond_mob',0) then
      mob_sound_bucket=label
     end
    end
    state.mob=label
   end
  end
  return true
 end
 -- Nieznany protokolowy event zostaje zignorowany, bez przypadkowego dzwieku.
 return true
end

local function on_line(line)
 counters.lines=counters.lines+1
 local s=norm(line)
 last_line=s:sub(1,120)
 if debug_mode then say('LINIA # '..counters.lines..': '..last_line) end
 if s=='' then return end
 if s:match('^sound_event%s+') then on_sound_event(s);return end
 -- Serwer v12.00.8 rozglasza REALNY zgon dowolnego gracza wszystkim zalogowanym.
 -- Dzwiek TYLKO dla innej postaci; wlasna smierc ma mort + You died.
 -- Rozpoznawaj wylacznie naglowek globalny, nie wpisy w help/changes/czacie.
 local dead_player=s:match('^swiat:%s*(.-)%s+zginal%.%s+miejsce:')
 if dead_player then
  if in_world and self_name and norm(dead_player)~=self_name then
   sound('frienddies',0,'sb_friend_dies')
  end
  return
 end
 -- Potwierdzone w diagnostic-20261020-172415.log i w kodzie v12.00.7:
 -- Witaj <postac>. Soulbound v12.00.7 World Core. -> wejscie postaci
 -- Zapisuje postac i wracam do wyboru postaci. -> wyjscie postaci
 -- Nie traktuj menu ani dowolnego powitania NPC jako logowania.
 if s:match('^witaj,%s*.+%. soulbound v[%d%.]+ world core%.$') then
  self_name=s:match('^witaj,%s*(.-)%. soulbound v[%d%.]+ world core%.$')
  sound_protocol = s:match('soulbound v12%.00%.8')~=nil or s:match('soulbound v1[3-9]%.')~=nil
  sound_kinds={};mob_hp_by_id={};focused_mob=nil;mob_sound_bucket=nil
   cancel_pending_xp();quest_reward_in_progress=false;quest_money_until=-100000;quest_money_played=false;reset_quest_gold()
  if not in_world then
   end_combat('wejscie do gry')
   in_world=true;player_downed=false;xp_event_active=nil;state.player=nil;state.hp=nil;state.mana=nil;state.full=false
   pending_full_hp=false;pending_full_mana=false;potion_vitals_until=-100000
   state.area=nil;look_mob=false;mob_name=nil
   sound('enter',1)
  end
  return
 end
 if s=='zapisuje postac i wracam do wyboru postaci.' then
  if in_world then sound('leavegame',1) end
  end_combat('wyjscie z gry')
  in_world=false;player_downed=false;self_name=nil;state.player=nil;state.hp=nil;state.mana=nil;state.area=nil
   cancel_pending_xp();quest_reward_in_progress=false;quest_money_until=-100000;reset_quest_gold()
  look_mob=false;mob_name=nil
  return
 end
 if s=='wylogowano z konta.' or s=='do zobaczenia.' then end_combat('rozlaczenie');in_world=false;player_downed=false;self_name=nil;reset_quest_gold();return end
 -- Priorytet: kanaly musza zgadzac sie z naglowkiem, nie trescia wiadomosci.
 if s:match('^%[news%] administracja') then sound('news',1);return end
 if s:match('^daily login:%s*dzien %d+%. nagroda ') then sound('daygift',1);return end
 if s:match('^%[gossip%]') then sound('gossip');return end
 if s:match('^%[newbie%]') then sound('newbie');return end
 if s:match('^%[tell%]') then if not sound_protocol then sound('tell') end;return end
 if s:match('^%[reply%]') then if not sound_protocol then sound('reply') end;return end
 if s:match('^%[gildia%]') or s:match('^%[guild%]') or s:match('^%[druzyna%]') or s:match('^%[party%]') then return end
 if s:match('^%[tell do [^%]]+%]') then return end
 if s:match('^.+ mowi:%s+.+') or s:match('^mowisz:%s+.+') then sound('say');return end
 local newarea=s:match('^.+%. strefa:%s*(.-)%.?$')
 if newarea and newarea~='' then
  newarea=newarea:gsub('%.%s*$','')
  if state.area and state.area~=newarea then
   end_combat('zmiana strefy')
   sound('area',1)
  end
  state.area=newarea
  -- Opis wejscia do pokoju sam w sobie NIE jest zdarzeniem walki.
  return
 end
 -- Serwer oznacza powalonego gracza w 'look' i podgladzie druzyny.
 -- Nie mylic ze zwlokami mobow oraz instrukcja w help.
 if s:match('^.-%(%s*powalony%s*%-+%s*mozna wskrzesic%s*%)') or
    s:match('^.-powalony%s*%-%s*mozna wskrzesic%.') then sound('corpse',1);return end
 -- Look na mobie jest dwuliniowy: osobno nazwa, potem HP z bazowymi obrazeniami.
 local lookname=s:match('^(.+)%. przeciwnik%.$')
 if lookname then look_mob=true;mob_name=lookname;state.mob=nil;return end
 local target=s:match('cel (.-)%.%s') or s:match('^uzywasz .- na (.-)%.%s*zadajesz')
 if target and target~=mob_name then mob_name=target;state.mob=nil end
 -- Dokladne komunikaty serwera 12.00.7: walka (Bron Duszy i skille).
 -- Przeciwnik ma priorytet nad HP gracza, aby nie pomylic celow.
 local mh,mm=s:match('przeciwnik:%s*(%d+)%s+z%s+(%d+)%s+hp')
 if not mh then mh,mm=s:match('przeciwnik:%s*(%d+)%s+z%s+(%d+)%s+zycia') end
 if mh and not sound_protocol then last_mob_hp={tonumber(mh),tonumber(mm)};health(mh,mm,'mob') end
 -- Odczyt look na mobie zawiera tez Bazowe obrazenia, wiec to NIE nasze HP.
 local ah,am=s:match('^hp:%s*(%d+)%s+z%s+(%d+)')
 if ah and (has(s,'bazowe obrazenia:') or look_mob) then look_mob=false;last_mob_hp={tonumber(ah),tonumber(am)};if not sound_protocol then health(ah,am,'mob') end;return end
 if ah then look_mob=false;update_vital('hp',ah,am,'snapshot');return end
 -- Sprawdzone w kodzie Soulbound 12.00.8: kolejne skoki HP podczas
 -- leczenia, Regenu, odpoczynku, mikstur i obrazen. Tylko nasze HP.
 local regen_amount,regen_h,regen_max=s:match('^regen odnawia (%d+) hp%. hp (%d+) z (%d+)')
 if regen_h then update_vital('hp',regen_h,regen_max,'event',regen_amount);return end
 local rest_h,rest_max=s:match('^regeneracja:%s*hp (%d+) z (%d+)')
 if rest_h then
  update_vital('hp',rest_h,rest_max,'event')
  local rest_mana,rest_mmax=s:match('mana%s+(%d+)%s+z%s+(%d+)')
  if rest_mana then update_vital('mana',rest_mana,rest_mmax,'event') end
  return
 end
 -- Potwierdzone zuzycie mikstury. Nastepne dwie linie raportuja aktualne zasoby.
 local potion_gain=s:match('^uzywasz .+%. odzyskujesz (.+)%.$')
 if potion_gain and (has(potion_gain,' hp') or potion_gain:match('^%d+ hp')) then
  potion_hp_gain=tonumber(potion_gain:match('(%d+)%s+hp')) or 0
  potion_vitals_until=counters.lines+4
 end
 local ph,pmax=s:match('^hp%s+(%d+)%s+z%s+(%d+)%.?$')
 if ph then
  if counters.lines<=potion_vitals_until then
   update_vital('hp',ph,pmax,'event',potion_hp_gain)
   potion_hp_gain=0
   potion_vitals_until=counters.lines+1 -- opcjonalna linia Mana bez przestarzalego kontekstu
  else
   update_vital('hp',ph,pmax,'snapshot')
  end
  return
 end
 local potion_mana,potion_mmax=s:match('^mana%s+(%d+)%s+z%s+(%d+)%.?$')
 if potion_mana then
  local mode=counters.lines<=potion_vitals_until and 'event' or 'snapshot'
  update_vital('mana',potion_mana,potion_mmax,mode)
  if mode=='event' then potion_vitals_until=-100000 end
  return
 end
 local hh,hmax=s:match('masz teraz (%d+) z (%d+) hp')
 if not hh then hh,hmax=s:match('masz (%d+) z (%d+) hp') end
 if not hh then hh,hmax=s:match('twoje zycie:%s*(%d+) z (%d+)') end
 if hh then
  local gain=tonumber(s:match('odzyskujesz (%d+) hp'))
  update_vital('hp',hh,hmax,'event',gain)
 end
 -- Inny gracz lub sojusznik leczy nas, ale komunikat pokazuje tylko
 -- RZECZYWISTA liczbe odzyskanych HP. Aktualizujemy znany stan,
 -- bez zgadywania, gdy bazowego HP jeszcze nie znamy.
 if not hh then
  local ally_gain=tonumber(s:match('^.+ leczy cie o (%d+) hp%.$'))
  -- Heal Beam otrzymany od innego gracza nie zawiera koncowego HP.
  if not ally_gain then ally_gain=tonumber(s:match('^.+ uzywa heal beam%. odzyskujesz (%d+) hp%.$')) end
  -- Wlasny Heal Beam zwraca nazwe osoby leczonej, nie procent HP.
  if not ally_gain and self_name then
   local healed_name,n=s:match('^heal beam:%s*(.-)%s+odzyskuje (%d+) hp%.$')
   if healed_name and norm(healed_name)==self_name then ally_gain=tonumber(n) end
  end
  if ally_gain and ally_gain>0 and state.hp and state.hp[2]>0 then
   update_vital('hp',math.min(state.hp[2],state.hp[1]+ally_gain),state.hp[2],'event')
  end
 end
 local mana_inline,mana_max=s:match('mana:%s*(%d+) z (%d+)')
 if mana_inline and not s:match('^mana:') and not s:match('przeciwnik:') then update_vital('mana',mana_inline,mana_max,'event') end
 local ma,mb=s:match('^mana:%s*(%d+)%s+z%s+(%d+)')
 if ma then update_vital('mana',ma,mb,'snapshot');return end
 -- Sygnaly z konkretnego kodu Soulbound 12.00.7 (bez zgadywania po slowie 'walka').
 if s:match('^walka w czasie rzeczywistym rozpoczeta%.') then
  -- Serwer moze dopisac linie walki tuz po powaleniu. Nie wznow muzyki.
  end_combat('nowa walka')
  if not player_downed then in_combat=true end
  return
 end
 if s=='koniec walki: wszyscy przeciwnicy zostali pokonani.' then
  end_combat('koniec walki')
  return
 end
 if s=='wycofujesz sie z walki.' then
  end_combat('ucieczka')
  return
 end
 -- Godzinny event x2 EXP: TYLKO oficjalny START serwera, nigdy zwykla nagroda EXP.
 -- Status eventxp nie jest nowym startem; START jest wysylany raz na przelomie godziny.
 if s:match('^event x2 exp start[%.!]') then
  if xp_event_active~=true then
   xp_event_starts=xp_event_starts+1
   sound('doubleexp',0)
  end
  xp_event_active=true
  return
 end
 if s:match('^event x2 exp zakonczony') or s:match('^event x2 exp:%s*nastepny start') then
  xp_event_active=false
  return
 end
 if s:match('^event x2 exp aktywny%.') then
  xp_event_active=true -- to tylko status, bez dzwieku
  return
 end
 -- Dzwiek recall WYŁĄCZNIE na potwierdzenie serwera po zmianie room_id.
 -- Wpisanie /, pokoj Swiatyni, podsumowanie druzyny i samo pojawienie
 -- sie innego gracza nie sa potwierdzeniem teleportacji NASZEJ postaci.
 if s=='teleportujesz sie do swiatyni odrodzenia.' or
    s:match('^.+ uruchamia teleport druzyny%. zostajesz przeniesiony do swiatyni odrodzenia%.$') then
  end_combat('teleport do swiatyni')
  recall_confirms=recall_confirms+1
  sound('recall',0)
  return
 end
 -- Serwer zwraca 'Juz jestes' i teleportacja NIE zaszla.
 -- Dotyczy tez czlonka druzyny, ktory byl juz w Swiatyni.
 if s=='juz jestes w swiatyni odrodzenia.' or
    s:match('^.+ uruchamia teleport druzyny%. juz jestes w swiatyni odrodzenia%.$') then
  return -- brak dzwieku, brak potwierdzenia i brak ingerencji w kanaly
 end
 if s:match('^.+ znika w swietle swiatyni%.$') then sound('otherrecall',1);return end
 -- Zakaz odpalania efektow z list, historii, opisu czy polecen changes.
 if s:match('^nieznana komenda') then sound('wrong',1);return end
 -- Wlasny zgon oraz stan powalenia: oba musza zatrzymywac kondycje mobow.
 if s:match('^pokonuje cie ') or s:match('^giniesz[!%.]') or s:match('^twoja postac umiera') then death();return end
 if s:match('^jestes powalony[%.!]') then
  if not player_downed then death() end
  end_combat('wlasna postac powalona')
  return
 end
 -- Komunikat do WSKRZESZONEGO, inny niz komunikat osoby wskrzeszajacej.
 if s:match('^.+ wskrzesza cie%. wracasz do walki z %d+ hp i %d+ many%.$') then
  player_downed=false
  end_combat('wskrzeszono nasza postac')
  state.hp=nil;state.mana=nil;state.player=nil;state.full=false
  sound('revive',0,'sb_revival')
  return
 end
 -- Samoodrodzenie i Phoenix Egg przywracaja mozliwosc muzyki, ale
 -- nie odtwarzaja phoenix down.ogg (ten jest na wskrzeszenie przez gracza).
 if s:match('^rezygnujesz z oczekiwania na wskrzeszenie i odradzasz sie') or
    s:match('^nikt nie zdazyl cie wskrzesic') or s:match('^twoja dusza wraca do swiatyni odrodzenia') then
  player_downed=false;end_combat('odrodzenie w swiatyni')
  state.hp=nil;state.mana=nil;state.player=nil;state.full=false
  return
 end
 if s:match('^phoenix egg peka%. re%-raise przywraca cie do walki') then
  player_downed=false;end_combat('phoenix egg')
  state.hp=nil;state.mana=nil;state.player=nil;state.full=false
  return
 end
 if s:match('^pokonujesz: ') or s:match('^druzyna pokonuje: ') then
  stop_mob_music('pokonany mob')
  focused_mob=nil;mob_sound_bucket=nil
  sound('vanish');play('mob/died.ogg','sb_mob_death',0);state.mob=nil;mob_name=nil;look_mob=false;return
 end
 if s:match('^osiagniecie:%s*.+') or s:match('^osiagniecie odblokowane') or s:match('^zdobywasz osiagniecie') then sound('achievement',2);return end
 -- Koniec oddawania questa: anuluj oczekujace dzwieki EXP/CAP/Over CAP.
  -- Sama nagroda EXP nadal zostaje przyznana na serwerze.
  if s:match('^zadanie ukonczone: ') or s:match('^quest ukonczony: ') then
   cancel_pending_xp()
   quest_reward_in_progress=false
   quest_money_until=counters.lines+35
   quest_money_played=false
   prepare_quest_gold()
   sound('quest',1)
   return
  end
 -- Potwierdzone w quest_commands.py: te linie sa czescia oddawania questa
  -- i poprzedzaja EXP postaci. Nie odtwarzaj zadnego dzwieku EXP w questach.
  if s:match('^nagroda questa walki:') or s:match('^nagroda questa:%s*%d+%s+soul xp') then
   quest_reward_in_progress=true
   quest_reward_marker_line=counters.lines
   cancel_pending_xp()
   return
  end
  if quest_reward_in_progress and counters.lines-quest_reward_marker_line>80 then
   quest_reward_in_progress=false
  end
  -- Pieniadze z questa dostajemy po komunikacie "Zadanie ukonczone".
  -- Nie mylic z nagroda PRZEDMIOTOWA od NPC ani z przegladaniem listy.
  if counters.lines<=quest_money_until and not quest_money_played and is_money_reward_line(s) and
     (s:match('^.+ wrecza ci nagrode: ') or s:match('^o kurde%s*%-%s*premia za wykonanie:')) then
   quest_money_played=true
   quest_money_until=-100000
   quest_gold_pending=true
   if quest_gold_ready then play_quest_gold() end
   return
  end
if s:match('^fame zaliczone') then sound('fame',1);return end
 if s:match('^wazne odkrycie: %+%d+ ep') then sound('ep',1);return end
 if s:match('^level postaci wzrasta do %d+') then sound('level',2);return end
 if s:match('^.+:%s*bieglosc rosnie do %d+%.$') or (has(s,'bieglosc') and (has(s,'level') or has(s,'poziom')) and (has(s,'wzrasta do') or has(s,'awansuje na'))) then sound('joblevel',2);return end
 if s:match('^uczysz sie umiejetnosci ') or s:match('^nauczono umiejetnosci ') or s:match('^nauczono%. .+ zaczyna na skill level 1%.$') then sound('learned',1);return end
 if has(s,'za malo many') or has(s,'nie masz wystarczajaco many') then sound('outmp',1);return end
 if has(s,'dolacza do druzyny') or has(s,'dolaczasz do druzyny') then sound('member',1);return end
 if has(s,'opuszcza druzyne') or has(s,'opuszczasz druzyne') then sound('leaveparty',1);return end
 if s:match('^heal beam: .+ odzyskuje %d+ hp') or s:match('^heal beam .+ lacznie %d+ hp') or s:match('^.+ uzywa heal beam%. odzyskujesz %d+ hp') then sound('healbeam',1);return end
 if s:match('^jammer: .+ zostaje jednorazowo wylaczony') then jammer_active=true;sound('jammer',1);return end
 if s:match('^jammer: .+ przestaje') or s:match('^stop .+ wygasa') or has(s,'stop sie konczy.') then jammer_active=false;sound('jammeroff',1);return end
 if has(s,'v-max') then
  if has(s,'wygasa') or has(s,'dezaktywujesz') then sound('vmaxoff',1);return end
  if s:match('^v%-max aktywny przez %d+ s') or has(s,'aktywujesz v-max') then sound('vmax',1);return end
 end
 if s:match('^wskrzeszasz .+%. wraca z 35 procent hp i many%.$') then sound('revive',1);return end
 if s:match('^kupujesz:%s+') or s:match('^kupujesz wlasny statek') then sound('buy');return end
 if s:match('^zakladasz:%s+') then sound('wear');return end
 if s:match('^nagroda walutowa: ') or s:match('^otrzymujesz zloto:%s*%+%d+') or s:match('^otrzymujesz %d+ zlota') or s:match('^otrzymujesz %d+ srebra') or s:match('^otrzymujesz %d+ mithril') then sound('gold');return end
 if s:match('^kondycja przeciwnika:') or s:match('^stan przeciwnika:') then if not sound_protocol then condition(s,'mob') end;return end
 if s:match('^twoja kondycja:') or s:match('^stan twojego zdrowia:') then condition(s,'player');return end
 if s:match('^.+ zadaje ci %d+ obrazen') or s:match('^.+ trafia cie .-%d+ obrazen') or s:match('^otrzymujesz %d+ obrazen') or (s:match(' atakuje%. typ obrazen:') and s:match('otrzymujesz %d+%.')) then sound('theyhit');return end
 if s:match('^uderzenie duszy trafia') or s:match('^bron duszy .-:%s*.-trafi') or s:match('^bron duszy .-:%s*.-%d+ obrazen') then sound('soulhit');return end
 -- Precyzyjna linia z kodu player/character.py; nie odtwarzamy co stat.
 -- CAP dotyczy limitu pojedynczej nagrody, a nie EXP do levelu.
 -- Odczyt capu nie jest nagroda i sam niczego nie odtwarza.
 local current=s:match('^your experience cap is (%d+) exp') or
               s:match('multi cap exp:%s*(%d+)')
 if current then
  current=tonumber(current)
  if cap ~= current then cap_half_seen=false;cap_full_seen=false end
  cap=current
  return
 end
 local xp=s:match('^exp postaci %+(%d+)%. postep %d+ z %d+%.') or
          s:match('^exp postaci %+(%d+)%. osiagnieto maksymalny level')
 if xp then
  local n=tonumber(xp);last_xp=n
  if sound_protocol then
   -- Serwer wysyla osobne CAP/HALF_CAP/EXP_BANK przed nagroda.
   -- Po najblizszej nagrodzie EXP postaci znacznik zostaje zuzyty:
   -- nastepny niezalezny kill nie jest wyciszany przez poprzedni CAP.
   local same_reward=counters.lines-recent_sound_reward_at<=20
   recent_sound_reward_at=-1000
   if not same_reward then
    if n<=10 then queue_xp_sound('crapexp') else queue_xp_sound('exp') end
   end
   return
  end
  if cap and n>=cap and not cap_full_seen then
   cap_full_seen=true;cap_half_seen=true;queue_xp_sound('cap')
  elseif cap and n>=math.floor(cap/2) and not cap_half_seen then
   cap_half_seen=true;queue_xp_sound('halfcap')
  elseif n<=10 then queue_xp_sound('crapexp') else queue_xp_sound('exp') end
  return
 end
 -- Brak informacji o ile EXP zostalo ODLOZONE w banku w chwili jego uzyskania.
 -- Nie uruchamiaj overcap od zwyklego widoku EXP Bank.
 if not sound_protocol and (s:match('^przekroczono multi cap:') or s:match('^exp do banku:%s*%+%d+')) then
  queue_xp_sound('overcap');return
 end
end
-- Nie rejestrujemy aliasu dla '/': genericMud sam wysyla komende do serwera.
-- Zmniejsza to ryzyko blokowania polecenia przez soundpack; nie gra dzwieku na Enter.

mud.alias('sbs *',function(line,captures)
 local arg=''
 if type(captures)=='table' and captures[1] then arg=tostring(captures[1])
 else arg=tostring(line or ''):match('^%S+%s+(.+)$') or '' end
 arg=norm(arg)
 if arg=='on' then active=true;say('ON')
 elseif arg=='off' then active=false;end_combat('soundpack off');say('OFF')
 elseif arg=='status' then say('v1.5.8 '..(active and 'ON' or 'OFF')..'; glosnosc '..math.floor(volume*100)..'%; cap '..tostring(cap or 'nieznany')..'; odebrane linie '..counters.lines..'; dzwieki '..counters.played)
 elseif arg=='diag' then say('DIAG v1.5.8: w_swiecie='..tostring(in_world)..'; linie='..counters.lines..'; rozpoznania='..counters.events..'; odtworzenia='..counters.played..'; bledy='..counters.errors..'; mud.play='..(mud and mud.play and 'dostepny' or 'BRAK')..' (typ '..type(mud.play)..')'..'; ostatnie zdarzenie='..last_event..'; ostatnia linia='..last_line..'; ostatni blad='..last_error..'; walki='..tostring(in_combat)..'; powalony='..tostring(player_downed)..'; stop muzyki='..stopped_music..'; przyczyna='..last_stop_reason..'; slash=przekazywany bezposrednio; recall_odp='..recall_confirms..'; x2_start='..xp_event_starts..'; x2_aktywny='..tostring(xp_event_active)..'; sound_event='..tostring(sound_protocol_count)..'; nowy_protokol='..tostring(sound_protocol)..'; ostatni_marker='..last_sound_marker)
 elseif arg=='watch on' then debug_mode=true;say('Podglad linii WLACZONY; sbs watch off wylacza')
 elseif arg=='watch off' then debug_mode=false;say('Podglad linii WYLACZONY')
 elseif arg=='coverage' then say('Soulbound 12.00.8: SOUND_EVENT EXP_BANK/HALF_CAP/FULL_CAP/MOB_HP/PLAYER_LOGIN/PLAYER_LOGOUT/TELL_RECEIVED/REPLY_RECEIVED obslugiwane. Pozostale zdarzenia na podstawie potwierdzonego tekstu. OGG nie dodaja nowych zdarzen po stronie serwera.')
 elseif arg=='musicstop' then end_combat('reczne zatrzymanie');say('Zatrzymano muzyke kondycji mobow')
 elseif arg=='probe' then on_line('Wazne odkrycie: +10 EP.');say('Symulacja lokalna EP: zdarzenia='..counters.events..', dzwieki='..counters.played..'. Nie jest to test serwera.')
 elseif arg:match('^vol %d+$') then local n=tonumber(arg:match('%d+'));if n<=100 then volume=n/100;say('Glosnosc '..n..'%') end
 elseif arg:match('^test [%w_]+$') then
  local kind=arg:match('^test ([%w_]+)$')
  if kind=='death' or kind=='mort' then sound('mort',0,'sb_death_a',true);sound('youdied',0,'sb_death_b',true)
  elseif fx[kind] then sound(kind,0,'sb_test_'..kind,true)
  else say('Brak przypisania do '..kind) end
 elseif arg=='updater' then say('Aktualizacja: Generic MUD > Soundpacks > Manage installed soundpacks > Update from source. Wymaga pakietu z oficjalnego GitHub Release; po aktualizacji polacz ponownie.')
 elseif arg=='help' then say('sbs on/off/status/updater/diag/coverage/musicstop/probe/watch on/off/vol 0-100/test recall/test doubleexp/test ep/test fame/test cap/test death')
 else say('Wpisz sbs help') end
end)
-- Osobny cichy kanal: znaczniki SOUND_EVENT sa techniczne i nie maja
-- przeszkadzac NVDA. Dotyczy natywnego Generic MUD 0.24.0.
if mud.set_channel then
 pcall(function() mud.set_channel('sb_telemetry', {speak=false,display=false,interrupt=false}) end)
end
mud.trigger([[^SOUND_EVENT[ ]+]],function(line,captures) on_line(line) end,{regex=true,priority=100,channel='sb_telemetry'})
-- Znaczniki SOUND_EVENT sa obslugiwane tylko przez pierwszy wyzwalacz.
-- W przeciwnym razie player_login / tell_received mogly uruchomic efekt dwa razy.
mud.trigger([[^(?!SOUND_EVENT[ ]+).+]],function(line,captures) on_line(line) end,{regex=true})
say('Zaladowano v1.5.8 dla Soulbound v12.00.8 - native Generic MUD, tylko Twoje OGG.')
