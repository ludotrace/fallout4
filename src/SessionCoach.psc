Scriptname SessionCoach

; -----------------------------------------------------------------------
; GameTime — in-game clock as "H:MM" string
; -----------------------------------------------------------------------
string Function GameTime() Global
    int h  = Hydra:Time.GetGameHour() as int
    int m  = Hydra:Time.GetGameMinute() as int
    string ms = m as string
    if m < 10
        ms = "0" + ms
    endif
    return h + ":" + ms
EndFunction

; -----------------------------------------------------------------------
; Log — append one event line to the session log
; -----------------------------------------------------------------------
Function Log(string asLine) Global
    Hydra:IO:File.AppendLine("SessionCoach_Events.jsonl", asLine)
EndFunction

; -----------------------------------------------------------------------
; WriteSnapshot — callable from console: cgf "SessionCoach.WriteSnapshot"
; -----------------------------------------------------------------------
Function WriteSnapshot() Global
    Actor player = Game.GetPlayer()
    int   lvl    = Game.GetPlayerLevel()

    int str  = player.GetValue(Game.GetStrengthAV())     as int
    int per  = player.GetValue(Game.GetPerceptionAV())   as int
    int endu = player.GetValue(Game.GetEnduranceAV())    as int
    int cha  = player.GetValue(Game.GetCharismaAV())     as int
    int inte = player.GetValue(Game.GetIntelligenceAV()) as int
    int agi  = player.GetValue(Game.GetAgilityAV())      as int
    int luc  = player.GetValue(Game.GetLuckAV())         as int

    int year  = Hydra:Time.GetGameYear()
    int month = Hydra:Time.GetGameMonth()
    int day   = Hydra:Time.GetGameDay()

    string playerName   = player.GetDisplayName()
    string locationName = "(location not available)"

    string header1  = "=== FO4 SESSION COACH - SNAPSHOT ==="
    string header2  = "Generated: " + year + "-" + month + "-" + day
    string header3  = "Character: " + playerName + " | Level: " + lvl + " | Location: " + locationName
    string blank    = ""
    string special1 = "=== S.P.E.C.I.A.L. ==="
    string special2 = "S " + str + "  P " + per + "  E " + endu + "  C " + cha + "  I " + inte + "  A " + agi + "  L " + luc

    string[] lines = new string[6]
    lines[0] = header1
    lines[1] = header2
    lines[2] = header3
    lines[3] = blank
    lines[4] = special1
    lines[5] = special2

    Hydra:IO:File.WriteAllLines("SessionCoach_Snapshot.txt", lines)
    Debug.Notification("[Session Coach] Snapshot written!")
EndFunction

; -----------------------------------------------------------------------
; OnPostLoadGameEvent — registers all session event listeners
; -----------------------------------------------------------------------
Function OnPostLoadGameEvent(Hydra:Events:PostLoadGameParams akParams) Global
    Hydra:Events.RegisterForLocationEnterExit(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLocationEnterExitEvent"))
    Hydra:Events.RegisterForLocationLoad(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLocationLoadEvent"))
    Hydra:Events.RegisterForLevelIncrease(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLevelIncreaseEvent"))
    Hydra:Events.RegisterForQuestStageChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnQuestStageChangeEvent"))
    Hydra:Events.RegisterForQuestStartStop(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnQuestStartStopEvent"))
    Hydra:Events.RegisterForQuestObjectiveChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnQuestObjectiveChangeEvent"))
    Hydra:Events.RegisterForActorDeath(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnActorDeathEvent"))
    Hydra:Events.RegisterForMiscStatChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnMiscStatChangeEvent"))
    Hydra:Events.RegisterForBookRead(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnBookReadEvent"))
    Hydra:Events.RegisterForLockPick(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLockPickEvent"))
    Hydra:Events.RegisterForTerminalHack(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnTerminalHackEvent"))
    Hydra:Events.RegisterForItemEquipUnequip(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnItemEquipUnequipEvent"))
    Hydra:Events.RegisterForItemAddRemove(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnItemAddRemoveEvent"))
    Hydra:Events.RegisterForCombatStateChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnCombatStateChangeEvent"))
    Hydra:Events.RegisterForPerkPointIncrease(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnPerkPointIncreaseEvent"))
    Hydra:Events.RegisterForPerkEntryRun(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnPerkEntryRunEvent"))
    Hydra:Events.RegisterForSleepStartStop(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnSleepStartStopEvent"))
    Hydra:Events.RegisterForWaitStartStop(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnWaitStartStopEvent"))
    Hydra:Events.RegisterForObjectSell(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnObjectSellEvent"))
    Hydra:Events.RegisterForObjectHarvest(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnObjectHarvestEvent"))
    Hydra:Events.RegisterForMenuModeEnterExit(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnMenuModeEnterExitEvent"))
    Hydra:Events.RegisterForMenuOpenClose(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnMenuOpenCloseCB"))
    Hydra:Events.RegisterForDifficultyChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnDifficultyChangeEvent"))
    Hydra:Events.RegisterForLifeStateChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLifeStateChangeEvent"))
    Hydra:Events.RegisterForLimbCripple(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnLimbCrippleEvent"))
    Hydra:Events.RegisterForFurnitureEnterExit(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnFurnitureEnterExitEvent"))
    Hydra:Events.RegisterForObjectActivate(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnObjectActivateEvent"))
    Hydra:Events.RegisterForSpellCast(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnSpellCastEvent"))
    Hydra:Events.RegisterForTriggerEnterLeave(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnTriggerEnterLeaveEvent"))
    Hydra:Events.RegisterForObjectOpenClose(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnObjectOpenCloseEvent"))
    Hydra:Events.RegisterForObjectGrabRelease(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnObjectGrabReleaseEvent"))
    Hydra:Events.RegisterForDestructionStageChange(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnDestructionStageChangeEvent"))
    Hydra:Events.RegisterForCellEnterExit(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnCellEnterExitEvent"))
    Hydra:Events.RegisterForActiveEffectApplyRemove(Hydra:FunctionRefs.CreateGlobalRef("SessionCoach", "OnActiveEffectApplyRemoveEvent"))

    Debug.Notification("[Session Coach] Loaded")
    WriteSnapshot()
EndFunction

; -----------------------------------------------------------------------
; Event callbacks — all append one JSON line to SessionCoach_Events.jsonl
; -----------------------------------------------------------------------

Function OnLocationEnterExitEvent(Hydra:Events:LocationEnterExitParams akParams) Global
    if akParams.kNewLocation == None
        return
    endif
    Log("{\"type\":\"location\",\"name\":\"" + akParams.kNewLocation.GetName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLocationLoadEvent(Hydra:Events:LocationLoadParams akParams) Global
    Log("{\"type\":\"location_load\",\"name\":\"" + akParams.kSourceLocation.GetName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnLevelIncreaseEvent(Hydra:Events:LevelIncreaseParams akParams) Global
    Log("{\"type\":\"level\",\"to\":" + akParams.iNewLevel + ",\"time\":\"" + GameTime() + "\"}")
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
    Log("{\"type\":\"quest\",\"name\":\"" + akParams.kSourceQuest.GetName() + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnQuestObjectiveChangeEvent(Hydra:Events:QuestObjectiveChangeParams akParams) Global
    Log("{\"type\":\"objective\",\"quest\":\"" + akParams.kSourceQuest.GetName() + "\",\"id\":" + akParams.iNewObjectiveId + ",\"state\":" + akParams.iNewObjectiveState + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnActorDeathEvent(Hydra:Events:ActorDeathParams akParams) Global
    Log("{\"type\":\"kill\",\"target\":\"" + akParams.kTargetActor.GetDisplayName() + "\",\"killer\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMiscStatChangeEvent(Hydra:Events:MiscStatChangeParams akParams) Global
    Log("{\"type\":\"stat\",\"stat\":\"" + akParams.sStatId + "\",\"value\":" + akParams.iNewValue + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnBookReadEvent(Hydra:Events:BookReadParams akParams) Global
    Log("{\"type\":\"book\",\"name\":\"" + akParams.kBook.GetName() + "\",\"time\":\"" + GameTime() + "\"}")
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
    Log("{\"type\":\"equip\",\"item\":\"" + akParams.kItem.GetName() + "\",\"action\":\"" + sAction + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnItemAddRemoveEvent(Hydra:Events:ItemAddRemoveParams akParams) Global
    Log("{\"type\":\"item\",\"name\":\"" + akParams.kItem.GetName() + "\",\"count\":" + akParams.iItemCount + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnCombatStateChangeEvent(Hydra:Events:CombatStateChangeParams akParams) Global
    ; iNewState: 0=none 1=in combat 2=searching
    Log("{\"type\":\"combat\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"state\":" + akParams.iNewState + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnPerkPointIncreaseEvent(Hydra:Events:PerkPointIncreaseParams akParams) Global
    Log("{\"type\":\"perk_point\",\"total\":" + akParams.iNewCount + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnPerkEntryRunEvent(Hydra:Events:PerkEntryRunParams akParams) Global
    Log("{\"type\":\"perk_run\",\"perk\":\"" + akParams.kPerk.GetName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnSleepStartStopEvent(Hydra:Events:SleepStartStopParams akParams) Global
    string sState
    if akParams.bStarted
        sState = "started"
    else
        sState = "ended"
    endif
    Log("{\"type\":\"sleep\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnWaitStartStopEvent(Hydra:Events:WaitStartStopParams akParams) Global
    string sState
    if akParams.bStarted
        sState = "started"
    else
        sState = "ended"
    endif
    Log("{\"type\":\"wait\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectSellEvent(Hydra:Events:ObjectSellParams akParams) Global
    Log("{\"type\":\"sell\",\"item\":\"" + akParams.kItemRef.GetDisplayName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectHarvestEvent(Hydra:Events:ObjectHarvestParams akParams) Global
    Log("{\"type\":\"harvest\",\"item\":\"" + akParams.kItem.GetName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMenuModeEnterExitEvent(Hydra:Events:MenuModeEnterExitParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "exited"
    endif
    Log("{\"type\":\"menu_mode\",\"menu\":\"" + akParams.sMenuName + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnMenuOpenCloseCB(Hydra:Events:MenuOpenCloseParams akParams) Global
    string sState
    if akParams.bOpened
        sState = "opened"
    else
        sState = "closed"
    endif
    Log("{\"type\":\"menu\",\"menu\":\"" + akParams.sMenuName + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
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
    Log("{\"type\":\"limb\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnFurnitureEnterExitEvent(Hydra:Events:FurnitureEnterExitParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "exited"
    endif
    Log("{\"type\":\"furniture\",\"name\":\"" + akParams.kTargetRef.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectActivateEvent(Hydra:Events:ObjectActivateParams akParams) Global
    Log("{\"type\":\"activate\",\"target\":\"" + akParams.kTargetRef.GetDisplayName() + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnSpellCastEvent(Hydra:Events:SpellCastParams akParams) Global
    Log("{\"type\":\"spell\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnTriggerEnterLeaveEvent(Hydra:Events:TriggerEnterLeaveParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "left"
    endif
    Log("{\"type\":\"trigger\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectOpenCloseEvent(Hydra:Events:ObjectOpenCloseParams akParams) Global
    string sState
    if akParams.bOpened
        sState = "opened"
    else
        sState = "closed"
    endif
    Log("{\"type\":\"container\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnObjectGrabReleaseEvent(Hydra:Events:ObjectGrabReleaseParams akParams) Global
    string sState
    if akParams.bGrabbed
        sState = "grabbed"
    else
        sState = "released"
    endif
    Log("{\"type\":\"grab\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnDestructionStageChangeEvent(Hydra:Events:DestructionStageChangeParams akParams) Global
    Log("{\"type\":\"destruction\",\"from\":" + akParams.iOldStage + ",\"to\":" + akParams.iNewStage + ",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnCellEnterExitEvent(Hydra:Events:CellEnterExitParams akParams) Global
    string sState
    if akParams.bEntered
        sState = "entered"
    else
        sState = "exited"
    endif
    Log("{\"type\":\"cell\",\"actor\":\"" + akParams.kSourceActor.GetDisplayName() + "\",\"cell\":\"" + akParams.kTargetCell.GetName() + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction

Function OnActiveEffectApplyRemoveEvent(Hydra:Events:ActiveEffectApplyRemoveParams akParams) Global
    string sState
    if akParams.bApplied
        sState = "applied"
    else
        sState = "removed"
    endif
    Log("{\"type\":\"effect\",\"target\":\"" + akParams.kTargetActor.GetDisplayName() + "\",\"state\":\"" + sState + "\",\"time\":\"" + GameTime() + "\"}")
EndFunction
