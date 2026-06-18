Scriptname LudoTrace

; -----------------------------------------------------------------------
; ZeroPad — zero-pad a single-digit int to two digits
; -----------------------------------------------------------------------
string Function ZeroPad(int n) Global
    if n < 10
        return "0" + n
    endif
    return n as string
EndFunction

; -----------------------------------------------------------------------
; GameDate — in-game date as "YYYY-MM-DD"
; -----------------------------------------------------------------------
string Function GameDate() Global
    return Hydra:Time.GetGameYear() + "-" + ZeroPad(Hydra:Time.GetGameMonth()) + "-" + ZeroPad(Hydra:Time.GetGameDay())
EndFunction

; -----------------------------------------------------------------------
; GameTime — in-game clock as "HH:MM"
; -----------------------------------------------------------------------
string Function GameTime() Global
    return ZeroPad(Hydra:Time.GetGameHour() as int) + ":" + ZeroPad(Hydra:Time.GetGameMinute() as int)
EndFunction

; -----------------------------------------------------------------------
; Log — append one event line to the session log
; -----------------------------------------------------------------------
Function Log(string asLine) Global
    Hydra:IO:File.AppendLine("lt_fo4_events.jsonl", asLine)
EndFunction

; -----------------------------------------------------------------------
; BuildStateJson — current character state as a JSON string.
; Shared by WriteSessionStart and OnPostSaveGameEvent.
; -----------------------------------------------------------------------
string Function BuildPerksJson() Global
    ActorBase playerBase = Hydra:Forms:Actor.GetActorBase(Game.GetPlayer())
    Hydra:Forms:ActorBase:PerkRank[] perks = Hydra:Forms:ActorBase.GetPerks(playerBase)
    string result = "["
    bool first = true
    int i = 0
    while i < perks.Length
        if perks[i].kPerk != None && perks[i].iRank > 0
            if !first
                result += ","
            endif
            result += "{\"name\":\"" + perks[i].kPerk.GetName() + "\",\"rank\":" + perks[i].iRank + "}"
            first = false
        endif
        i += 1
    endwhile
    return result + "]"
EndFunction

string Function BuildAmmoJson() Global
    Actor player = Game.GetPlayer()
    string[] names = new string[19]
    names[0]  = ".308 Round"
    names[1]  = ".38 Round"
    names[2]  = ".44 Round"
    names[3]  = ".45 Round"
    names[4]  = ".50 Caliber Round"
    names[5]  = "10mm Round"
    names[6]  = "5.56 Round"
    names[7]  = "5mm Round"
    names[8]  = "2mm EC"
    names[9]  = "Fusion Cell"
    names[10] = "Fusion Core"
    names[11] = "Plasma Cartridge"
    names[12] = "Shotgun Shell"
    names[13] = "Mini Nuke"
    names[14] = "Missile"
    names[15] = "Railway Spike"
    names[16] = "Cryo Cell"
    names[17] = "Gamma Round"
    names[18] = "Flamer Fuel"
    string[] formIds = new string[19]
    formIds[0]  = "0x0001F66B"
    formIds[1]  = "0x0004CE87"
    formIds[2]  = "0x0009221C"
    formIds[3]  = "0x0001F66A"
    formIds[4]  = "0x0001F279"
    formIds[5]  = "0x0001F276"
    formIds[6]  = "0x0001F278"
    formIds[7]  = "0x0001F66C"
    formIds[8]  = "0x0018ABDF"
    formIds[9]  = "0x000C1897"
    formIds[10] = "0x00075FE4"
    formIds[11] = "0x0001DBB7"
    formIds[12] = "0x0001F673"
    formIds[13] = "0x000E6B2E"
    formIds[14] = "0x000CABA3"
    formIds[15] = "0x000FE269"
    formIds[16] = "0x0018ABE2"
    formIds[17] = "0x000DF279"
    formIds[18] = "0x000CAC78"
    int[] intIds = new int[19]
    intIds[0]  = 0x0001f66b
    intIds[1]  = 0x0004ce87
    intIds[2]  = 0x0009221c
    intIds[3]  = 0x0001f66a
    intIds[4]  = 0x0001f279
    intIds[5]  = 0x0001f276
    intIds[6]  = 0x0001f278
    intIds[7]  = 0x0001f66c
    intIds[8]  = 0x0018abdf
    intIds[9]  = 0x000c1897
    intIds[10] = 0x00075fe4
    intIds[11] = 0x0001dbb7
    intIds[12] = 0x0001f673
    intIds[13] = 0x000e6b2e
    intIds[14] = 0x000caba3
    intIds[15] = 0x000fe269
    intIds[16] = 0x0018abe2
    intIds[17] = 0x000df279
    intIds[18] = 0x000cac78
    string result = "["
    bool first = true
    int i = 0
    while i < 19
        Form f = Game.GetForm(intIds[i])
        if f != None
            int count = player.GetItemCount(f)
            if count > 0
                if !first
                    result += ","
                endif
                result += "{\"name\":\"" + names[i] + "\",\"form_id\":\"" + formIds[i] + "\",\"count\":" + count + "}"
                first = false
            endif
        endif
        i += 1
    endwhile
    return result + "]"
EndFunction

string Function BuildAidJson() Global
    Actor player = Game.GetPlayer()
    string[] names = new string[13]
    names[0]  = "Stimpak"
    names[1]  = "RadAway"
    names[2]  = "Rad-X"
    names[3]  = "Med-X"
    names[4]  = "Jet"
    names[5]  = "Mentats"
    names[6]  = "Buffout"
    names[7]  = "Psycho"
    names[8]  = "Calmex"
    names[9]  = "Overdrive"
    names[10] = "X-Cell"
    names[11] = "Stealth Boy"
    names[12] = "Addictol"
    string[] formIds = new string[13]
    formIds[0]  = "0x00023736"
    formIds[1]  = "0x00023742"
    formIds[2]  = "0x00024057"
    formIds[3]  = "0x00033779"
    formIds[4]  = "0x000366C5"
    formIds[5]  = "0x0003377B"
    formIds[6]  = "0x00033778"
    formIds[7]  = "0x0003377D"
    formIds[8]  = "0x00058AA7"
    formIds[9]  = "0x00058AAD"
    formIds[10] = "0x001506F4"
    formIds[11] = "0x0004F4A6"
    formIds[12] = "0x000459C5"
    int[] intIds = new int[13]
    intIds[0]  = 0x00023736
    intIds[1]  = 0x00023742
    intIds[2]  = 0x00024057
    intIds[3]  = 0x00033779
    intIds[4]  = 0x000366c5
    intIds[5]  = 0x0003377b
    intIds[6]  = 0x00033778
    intIds[7]  = 0x0003377d
    intIds[8]  = 0x00058aa7
    intIds[9]  = 0x00058aad
    intIds[10] = 0x001506f4
    intIds[11] = 0x0004f4a6
    intIds[12] = 0x000459c5
    string result = "["
    bool first = true
    int i = 0
    while i < 13
        Form f = Game.GetForm(intIds[i])
        if f != None
            int count = player.GetItemCount(f)
            if count > 0
                if !first
                    result += ","
                endif
                result += "{\"name\":\"" + names[i] + "\",\"form_id\":\"" + formIds[i] + "\",\"count\":" + count + "}"
                first = false
            endif
        endif
        i += 1
    endwhile
    return result + "]"
EndFunction

string Function BuildStateJson(string asType) Global
    Actor player = Game.GetPlayer()

    int str  = player.GetValue(Game.GetStrengthAV())     as int
    int per  = player.GetValue(Game.GetPerceptionAV())   as int
    int endu = player.GetValue(Game.GetEnduranceAV())    as int
    int cha  = player.GetValue(Game.GetCharismaAV())     as int
    int inte = player.GetValue(Game.GetIntelligenceAV()) as int
    int agi  = player.GetValue(Game.GetAgilityAV())      as int
    int luc  = player.GetValue(Game.GetLuckAV())         as int

    string special = "\"special\":{\"S\":" + str + ",\"P\":" + per + ",\"E\":" + endu + ",\"C\":" + cha + ",\"I\":" + inte + ",\"A\":" + agi + ",\"L\":" + luc + "}"
    string sBob = BuildBobbleheadsJson()
    string sAmmo = BuildAmmoJson()
    string sAid = BuildAidJson()
    return "{\"type\":\"" + asType + "\",\"date\":\"" + GameDate() + "\",\"game_time\":\"" + GameTime() + "\",\"level\":" + Game.GetPlayerLevel() + ",\"name\":\"" + player.GetDisplayName() + "\"," + special + ",\"bobbleheads\":" + sBob + ",\"ammo\":" + sAmmo + ",\"aid\":" + sAid + "}"
EndFunction

; -----------------------------------------------------------------------
; WriteSessionStart — appends session_start to the event log on load.
; Console: cgf "LudoTrace.WriteSessionStart"
; -----------------------------------------------------------------------
Function WriteSessionStart() Global
    Log(BuildStateJson("session_start"))
    Debug.Notification("[LudoTrace] Loaded")
EndFunction

; -----------------------------------------------------------------------
; OnPostSaveGameEvent — captures end-of-session state on save.
; -----------------------------------------------------------------------
Function OnPostSaveGameEvent(Hydra:Events:PostSaveGameParams akParams) Global
    Log(BuildStateJson("session_end"))
    Debug.Notification("[LudoTrace] Session saved")
EndFunction

; -----------------------------------------------------------------------
; OnPostLoadGameEvent — registers all session event listeners
; -----------------------------------------------------------------------
; DebugAVIds — logs form IDs for all 7 SPECIAL AVs so we can check
; if they're contiguous and build an efficient range filter.
; Console: cgf "LudoTrace.DebugAVIds"
; -----------------------------------------------------------------------
Function DebugAVIds() Global
    string[] lines = new string[7]
    lines[0] = "Strength    = " + Game.GetStrengthAV().GetFormID()
    lines[1] = "Perception  = " + Game.GetPerceptionAV().GetFormID()
    lines[2] = "Endurance   = " + Game.GetEnduranceAV().GetFormID()
    lines[3] = "Charisma    = " + Game.GetCharismaAV().GetFormID()
    lines[4] = "Intelligence= " + Game.GetIntelligenceAV().GetFormID()
    lines[5] = "Agility     = " + Game.GetAgilityAV().GetFormID()
    lines[6] = "Luck        = " + Game.GetLuckAV().GetFormID()
    Hydra:IO:File.WriteAllLines("LudoTrace_AVIds.txt", lines)
    Debug.Notification("[LudoTrace] AV IDs written")
EndFunction

; -----------------------------------------------------------------------
Function OnPostLoadGameEvent(Hydra:Events:PostLoadGameParams akParams) Global
    ; LocationEnterExit fires for all actors (NPC home locations) — replaced by CellEnterExit filtered to player
    ; Hydra:Events.RegisterForLocationEnterExit(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLocationEnterExitEvent"))
    ; Hydra:Events.RegisterForLocationLoad(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLocationLoadEvent"))
    Hydra:Events.RegisterForLevelIncrease(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLevelIncreaseEvent"))
    Hydra:Events.RegisterForQuestStageChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnQuestStageChangeEvent"))
    Hydra:Events.RegisterForQuestStartStop(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnQuestStartStopEvent"))
    Hydra:Events.RegisterForQuestObjectiveChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnQuestObjectiveChangeEvent"))
    Hydra:Events.RegisterForActorDeath(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnActorDeathEvent"))
    Hydra:Events.RegisterForMiscStatChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnMiscStatChangeEvent"))
    Hydra:Events.RegisterForBookRead(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnBookReadEvent"))
    Hydra:Events.RegisterForLockPick(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLockPickEvent"))
    Hydra:Events.RegisterForTerminalHack(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnTerminalHackEvent"))
    ; equip: fires for NPCs too (enemy attacks, etc.) — not reliable for player gear
    ; Hydra:Events.RegisterForItemEquipUnequip(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnItemEquipUnequipEvent"))
    Hydra:Events.RegisterForItemAddRemove(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnItemAddRemoveEvent"))
    Hydra:Events.RegisterForCombatStateChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnCombatStateChangeEvent"))
    Hydra:Events.RegisterForPerkPointIncrease(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnPerkPointIncreaseEvent"))
    ; perk_run: fires for passive perk effects every calculation — not perk selection, useless
    ; Hydra:Events.RegisterForPerkEntryRun(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnPerkEntryRunEvent"))
    Hydra:Events.RegisterForSleepStartStop(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnSleepStartStopEvent"))
    Hydra:Events.RegisterForWaitStartStop(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnWaitStartStopEvent"))
    Hydra:Events.RegisterForObjectSell(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnObjectSellEvent"))
    Hydra:Events.RegisterForObjectHarvest(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnObjectHarvestEvent"))
    Hydra:Events.RegisterForMenuModeEnterExit(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnMenuModeEnterExitEvent"))
    ; MenuOpenClose fires for every engine UI element (FaderMenu, CursorMenu, VignetteMenu, etc.)
    ; causing concurrent AppendLine calls that corrupt the JSONL. MenuModeEnterExit covers
    ; the player-facing modes (Pipboy, Workshop, Barter) without the noise.
    ; Hydra:Events.RegisterForMenuOpenClose(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnMenuOpenCloseCB"))
    Hydra:Events.RegisterForDifficultyChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnDifficultyChangeEvent"))
    ; life_state: actors loading into world in dead state — not session kills
    ; Hydra:Events.RegisterForLifeStateChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLifeStateChangeEvent"))
    Hydra:Events.RegisterForLimbCripple(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnLimbCrippleEvent"))
    ; furniture: NPC chairs/couches fire constantly, no player signal
    ; Hydra:Events.RegisterForFurnitureEnterExit(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnFurnitureEnterExitEvent"))
    Hydra:Events.RegisterForObjectActivate(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnObjectActivateEvent"))
    Hydra:Events.RegisterForSpellCast(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnSpellCastEvent"))
    ; trigger: invisible volumes, pure noise
    ; Hydra:Events.RegisterForTriggerEnterLeave(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnTriggerEnterLeaveEvent"))
    Hydra:Events.RegisterForObjectOpenClose(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnObjectOpenCloseEvent"))
    Hydra:Events.RegisterForObjectGrabRelease(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnObjectGrabReleaseEvent"))
    Hydra:Events.RegisterForDestructionStageChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnDestructionStageChangeEvent"))
    Hydra:Events.RegisterForCellEnterExit(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnCellEnterExitEvent"))
    ; effect: applied/removed fires for NPCs constantly — turrets, companions, enemies
    ; Hydra:Events.RegisterForActiveEffectApplyRemove(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnActiveEffectApplyRemoveEvent"))
    ; SPECIAL range 706-712 confirmed contiguous — catches bobbleheads, You're SPECIAL!, Intense Training
    Hydra:Events.RegisterForActorValueChange(Hydra:FunctionRefs.CreateGlobalRef("LudoTrace", "OnActorValueChangeEvent"))

    WriteSessionStart()
EndFunction

; -----------------------------------------------------------------------
; Event callbacks — all append one JSON line to lt_fo4_events.jsonl
; -----------------------------------------------------------------------

int Function BobbleheadFormId(string asName) Global
    if asName == "Agility"
        return 0x178B51
    elseif asName == "Barter"
        return 0x178B52
    elseif asName == "Big Guns"
        return 0x178B53
    elseif asName == "Charisma"
        return 0x178B54
    elseif asName == "Endurance"
        return 0x178B55
    elseif asName == "Energy Weapons"
        return 0x178B56
    elseif asName == "Explosives"
        return 0x178B57
    elseif asName == "Intelligence"
        return 0x178B58
    elseif asName == "Lock Picking"
        return 0x178B59
    elseif asName == "Luck"
        return 0x178B5A
    elseif asName == "Medicine"
        return 0x178B5B
    elseif asName == "Melee"
        return 0x178B5C
    elseif asName == "Perception"
        return 0x178B5D
    elseif asName == "Repair"
        return 0x178B5E
    elseif asName == "Science"
        return 0x178B5F
    elseif asName == "Small Guns"
        return 0x178B60
    elseif asName == "Sneak"
        return 0x178B61
    elseif asName == "Speech"
        return 0x178B62
    elseif asName == "Strength"
        return 0x178B63
    elseif asName == "Unarmed"
        return 0x178B64
    endif
    return 0
EndFunction

bool Function PlayerHasBobblehead(string asName) Global
    int formId = BobbleheadFormId(asName)
    if formId == 0
        return false
    endif
    Form bobblehead = Game.GetForm(formId)
    if bobblehead == None
        return false
    endif
    return Game.GetPlayer().GetItemCount(bobblehead) > 0
EndFunction

string Function BuildBobbleheadsJson() Global
    Actor player = Game.GetPlayer()
    string[] names = new string[20]
    names[0]  = "Agility"
    names[1]  = "Barter"
    names[2]  = "Big Guns"
    names[3]  = "Charisma"
    names[4]  = "Endurance"
    names[5]  = "Energy Weapons"
    names[6]  = "Explosives"
    names[7]  = "Intelligence"
    names[8]  = "Lock Picking"
    names[9]  = "Luck"
    names[10] = "Medicine"
    names[11] = "Melee"
    names[12] = "Perception"
    names[13] = "Repair"
    names[14] = "Science"
    names[15] = "Small Guns"
    names[16] = "Sneak"
    names[17] = "Speech"
    names[18] = "Strength"
    names[19] = "Unarmed"
    string result = "["
    bool first = true
    int i = 0
    while i < 20
        Form bobblehead = Game.GetForm(BobbleheadFormId(names[i]))
        if bobblehead != None && player.GetItemCount(bobblehead) > 0
            if !first
                result += ","
            endif
            result += "\"" + names[i] + "\""
            first = false
        endif
        i += 1
    endwhile
    return result + "]"
EndFunction

string Function BobbleheadAtLocation(string asLocation) Global
    if asLocation == "Mass Fusion Building"
        return "Strength"
    elseif asLocation == "Museum of Freedom"
        return "Perception"
    elseif asLocation == "Poseidon Energy"
        return "Endurance"
    elseif asLocation == "Parsons State Insane Asylum"
        return "Charisma"
    elseif asLocation == "Boston Public Library"
        return "Intelligence"
    elseif asLocation == "Wreck of the FMS Northern Star"
        return "Agility"
    elseif asLocation == "Spectacle Island"
        return "Luck"
    elseif asLocation == "Longneck Lukowski's Cannery"
        return "Barter"
    elseif asLocation == "Vault 95"
        return "Big Guns"
    elseif asLocation == "Fort Hagen"
        return "Energy Weapons"
    elseif asLocation == "Saugus Ironworks"
        return "Explosives"
    elseif asLocation == "Pickman Gallery"
        return "Lock Picking"
    elseif asLocation == "Vault 81"
        return "Medicine"
    elseif asLocation == "Trinity Tower"
        return "Melee"
    elseif asLocation == "Corvega Assembly Plant"
        return "Repair"
    elseif asLocation == "Vault 75"
        return "Science"
    elseif asLocation == "Gunners Plaza"
        return "Small Guns"
    elseif asLocation == "Dunwich Borers"
        return "Sneak"
    elseif asLocation == "Park Street Station"
        return "Speech"
    elseif asLocation == "Atom Cats Garage"
        return "Unarmed"
    endif
    return ""
EndFunction

Function OnLocationEnterExitEvent(Hydra:Events:LocationEnterExitParams akParams) Global
    if akParams.kNewLocation == None
        return
    endif
    string name = akParams.kNewLocation.GetName()
    if name == ""
        return
    endif
    if Hydra:TempSet.ContainsKey("sc_locations", name)
        return
    endif
    Hydra:TempSet.Add("sc_locations", name)
    string bobblehead = BobbleheadAtLocation(name)
    if bobblehead != "" && !PlayerHasBobblehead(bobblehead)
        Log("{\"type\":\"near_collectible\",\"category\":\"bobblehead\",\"name\":\"" + bobblehead + "\",\"location\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
        Debug.Notification("[LudoTrace] Bobblehead nearby: " + bobblehead)
    endif
    Log("{\"type\":\"location\",\"name\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLocationLoadEvent(Hydra:Events:LocationLoadParams akParams) Global
    Log("{\"type\":\"location_load\",\"name\":\"" + akParams.kSourceLocation.GetName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLevelIncreaseEvent(Hydra:Events:LevelIncreaseParams akParams) Global
    Log("{\"type\":\"level\",\"to\":" + akParams.iNewLevel + ",\"perks\":" + BuildPerksJson() + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnQuestStageChangeEvent(Hydra:Events:QuestStageChangeParams akParams) Global
    Log("{\"type\":\"quest_stage\",\"quest\":\"" + akParams.kSourceQuest.GetName() + "\",\"stage\":" + akParams.iNewStageId + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnQuestStartStopEvent(Hydra:Events:QuestStartStopParams akParams) Global
    string sState
    if akParams.bStarted
        sState = "started"
    elseif akParams.bFailed
        sState = "failed"
    else
        sState = "completed"
    endif
    Log("{\"type\":\"quest\",\"name\":\"" + akParams.kSourceQuest.GetName() + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnQuestObjectiveChangeEvent(Hydra:Events:QuestObjectiveChangeParams akParams) Global
    Log("{\"type\":\"objective\",\"quest\":\"" + akParams.kSourceQuest.GetName() + "\",\"id\":" + akParams.iNewObjectiveId + ",\"state\":" + akParams.iNewObjectiveState + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnActorDeathEvent(Hydra:Events:ActorDeathParams akParams) Global
    Log("{\"type\":\"kill\",\"target\":\"" + akParams.kTargetActor.GetDisplayName() + "\",\"killer\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMiscStatChangeEvent(Hydra:Events:MiscStatChangeParams akParams) Global
    Log("{\"type\":\"stat\",\"stat\":\"" + akParams.sStatId + "\",\"value\":" + akParams.iNewValue + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnBookReadEvent(Hydra:Events:BookReadParams akParams) Global
    Log("{\"type\":\"found\",\"category\":\"magazine\",\"name\":\"" + akParams.kBook.GetName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnActorValueChangeEvent(Hydra:Events:ActorValueChangeParams akParams) Global
    int id = akParams.kSourceValue.GetFormID()
    if id < 706 || id > 712
        return
    endif
    Log("{\"type\":\"av_change\",\"av\":\"" + akParams.kSourceValue.GetName() + "\",\"from\":" + (akParams.fOldValue as int) + ",\"to\":" + (akParams.fNewValue as int) + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLockPickEvent(Hydra:Events:LockPickParams akParams) Global
    Log("{\"type\":\"lockpick\",\"level\":" + akParams.iLockLevel + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnTerminalHackEvent(Hydra:Events:TerminalHackParams akParams) Global
    Log("{\"type\":\"terminal\",\"level\":" + akParams.iLockLevel + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnItemEquipUnequipEvent(Hydra:Events:ItemEquipUnequipParams akParams) Global
    string sAction
    if akParams.bEquipped
        sAction = "equipped"
    else
        sAction = "unequipped"
    endif
    Log("{\"type\":\"equip\",\"item\":\"" + akParams.kItem.GetName() + "\",\"action\":\"" + sAction + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

string Function AidItemCategory(string asName) Global
    if Hydra:Strings.Contains(asName, "Stimpak")
        return "healing"
    elseif Hydra:Strings.Contains(asName, "RadAway")
        return "radiation"
    elseif Hydra:Strings.Contains(asName, "Rad-X")
        return "radiation"
    elseif Hydra:Strings.Contains(asName, "Jet")
        return "chem"
    elseif Hydra:Strings.Contains(asName, "Mentats")
        return "chem"
    elseif Hydra:Strings.Contains(asName, "Psycho")
        return "chem"
    elseif Hydra:Strings.Contains(asName, "Buffout")
        return "chem"
    elseif asName == "Med-X"
        return "chem"
    elseif asName == "Daddy-O"
        return "chem"
    elseif asName == "Day Tripper"
        return "chem"
    elseif asName == "X-Cell"
        return "chem"
    elseif asName == "Overdrive"
        return "chem"
    elseif asName == "Fury"
        return "chem"
    endif
    return ""
EndFunction

Function OnItemAddRemoveEvent(Hydra:Events:ItemAddRemoveParams akParams) Global
    string name = akParams.kItem.GetName()
    if akParams.iItemCount > 0
        if Hydra:Strings.Contains(name, "Bobblehead")
            Log("{\"type\":\"found\",\"category\":\"bobblehead\",\"name\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
        endif
    elseif akParams.iItemCount < 0
        string category = AidItemCategory(name)
        if category != ""
            Log("{\"type\":\"used\",\"category\":\"" + category + "\",\"item\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
        endif
    endif
EndFunction

Function OnCombatStateChangeEvent(Hydra:Events:CombatStateChangeParams akParams) Global
    ; iNewState: 0=none 1=in combat 2=searching
    Log("{\"type\":\"combat\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"state\":" + akParams.iNewState + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnPerkPointIncreaseEvent(Hydra:Events:PerkPointIncreaseParams akParams) Global
    Log("{\"type\":\"perk_point\",\"total\":" + akParams.iNewCount + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnPerkEntryRunEvent(Hydra:Events:PerkEntryRunParams akParams) Global
    Log("{\"type\":\"perk_run\",\"perk\":\"" + akParams.kPerk.GetName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnSleepStartStopEvent(Hydra:Events:SleepStartStopParams akParams) Global
    string sState
    if akParams.bStarted
        sState = "started"
    else
        sState = "ended"
    endif
    Log("{\"type\":\"sleep\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnWaitStartStopEvent(Hydra:Events:WaitStartStopParams akParams) Global
    string sState
    if akParams.bStarted
        sState = "started"
    else
        sState = "ended"
    endif
    Log("{\"type\":\"wait\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectSellEvent(Hydra:Events:ObjectSellParams akParams) Global
    Log("{\"type\":\"sell\",\"item\":\"" + akParams.kItemRef.GetDisplayName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectHarvestEvent(Hydra:Events:ObjectHarvestParams akParams) Global
    Log("{\"type\":\"harvest\",\"item\":\"" + akParams.kItem.GetName() + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMenuModeEnterExitEvent(Hydra:Events:MenuModeEnterExitParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "exited"
    endif
    Log("{\"type\":\"menu_mode\",\"menu\":\"" + akParams.sMenuName + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMenuOpenCloseCB(Hydra:Events:MenuOpenCloseParams akParams) Global
    string menu = akParams.sMenuName
    ; engine/system menus that fire during saves and transitions — no coaching value and race with save writes
    if menu == "FaderMenu" || menu == "CursorMenu" || menu == "PauseMenu" || menu == "LoadingMenu" || menu == "HUDMenu"
        return
    endif
    string sState
    if akParams.bOpened
        sState = "opened"
    else
        sState = "closed"
    endif
    Log("{\"type\":\"menu\",\"menu\":\"" + menu + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnDifficultyChangeEvent(Hydra:Events:DifficultyChangeParams akParams) Global
    Log("{\"type\":\"difficulty\",\"from\":" + akParams.iOldDifficulty + ",\"to\":" + akParams.iNewDifficulty + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLifeStateChangeEvent(Hydra:Events:LifeStateChangeParams akParams) Global
    Log("{\"type\":\"life_state\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"from\":" + akParams.iOldState + ",\"to\":" + akParams.iNewState + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLimbCrippleEvent(Hydra:Events:LimbCrippleParams akParams) Global
    string sState
    if akParams.bCrippled
        sState = "crippled"
    else
        sState = "healed"
    endif
    Log("{\"type\":\"limb\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnFurnitureEnterExitEvent(Hydra:Events:FurnitureEnterExitParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "exited"
    endif
    Log("{\"type\":\"furniture\",\"name\":\"" + akParams.kTargetRef.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectActivateEvent(Hydra:Events:ObjectActivateParams akParams) Global
    string name = akParams.kTargetRef.GetDisplayName()
    if name == ""
        return
    endif
    Log("{\"type\":\"activate\",\"target\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnSpellCastEvent(Hydra:Events:SpellCastParams akParams) Global
    Log("{\"type\":\"spell\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnTriggerEnterLeaveEvent(Hydra:Events:TriggerEnterLeaveParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "left"
    endif
    Log("{\"type\":\"trigger\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectOpenCloseEvent(Hydra:Events:ObjectOpenCloseParams akParams) Global
    string sState
    if akParams.bOpened
        sState = "opened"
    else
        sState = "closed"
    endif
    Log("{\"type\":\"container\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectGrabReleaseEvent(Hydra:Events:ObjectGrabReleaseParams akParams) Global
    string sState
    if akParams.bGrabbed
        sState = "grabbed"
    else
        sState = "released"
    endif
    Log("{\"type\":\"grab\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnDestructionStageChangeEvent(Hydra:Events:DestructionStageChangeParams akParams) Global
    Log("{\"type\":\"destruction\",\"from\":" + akParams.iOldStage + ",\"to\":" + akParams.iNewStage + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnCellEnterExitEvent(Hydra:Events:CellEnterExitParams akParams) Global
    if !akParams.bEntered
        return
    endif
    if akParams.kSourceActor != Game.GetPlayer()
        return
    endif
    Location loc = Hydra:Forms:Cell.GetLocation(akParams.kTargetCell)
    if loc == None
        return
    endif
    string name = loc.GetName()
    if name == ""
        return
    endif
    if Hydra:TempSet.ContainsKey("sc_locations", name)
        return
    endif
    Hydra:TempSet.Add("sc_locations", name)
    string bobblehead = BobbleheadAtLocation(name)
    if bobblehead != "" && !PlayerHasBobblehead(bobblehead)
        Log("{\"type\":\"near_collectible\",\"category\":\"bobblehead\",\"name\":\"" + bobblehead + "\",\"location\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
        Debug.Notification("[LudoTrace] Bobblehead nearby: " + bobblehead)
    endif
    Log("{\"type\":\"location\",\"name\":\"" + name + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction

Function OnActiveEffectApplyRemoveEvent(Hydra:Events:ActiveEffectApplyRemoveParams akParams) Global
    string sState
    if akParams.bApplied
        sState = "applied"
    else
        sState = "removed"
    endif
    Log("{\"type\":\"effect\",\"target\":\"" + akParams.kTargetActor.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"game_time\":\"" + GameTime() + "\"}")
EndFunction
