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

; -----------------------------------------------------------------------
; BuildPerksJson — perks the player owns, with current rank.
; Uses vanilla Actor.HasPerk against per-rank Perk forms (each FO4 perk
; rank is a distinct Perk form). Avoids Hydra:Forms:ActorBase.GetPerks(),
; which crashes in Hydra callback contexts (see issue #12 / PR #13).
; -----------------------------------------------------------------------
string Function BuildPerksJson() Global
    Actor player = Game.GetPlayer()
    string[] names = new string[70]
    names[0] = "Iron Fist"
    names[1] = "Big Leagues"
    names[2] = "Armorer"
    names[3] = "Blacksmith"
    names[4] = "Heavy Gunner"
    names[5] = "Strong Back"
    names[6] = "Steady Aim"
    names[7] = "Basher"
    names[8] = "Rooted"
    names[9] = "Pain Train"
    names[10] = "Pickpocket"
    names[11] = "Rifleman"
    names[12] = "Awareness"
    names[13] = "Locksmith"
    names[14] = "Demolition Expert"
    names[15] = "Night Person"
    names[16] = "Refractor"
    names[17] = "Sniper"
    names[18] = "Penetrator"
    names[19] = "Concentrated Fire"
    names[20] = "Toughness"
    names[21] = "Lead Belly"
    names[22] = "Lifegiver"
    names[23] = "Chem Resistant"
    names[24] = "Aquaboy / Aquagirl"
    names[25] = "Rad Resistant"
    names[26] = "Adamantium Skeleton"
    names[27] = "Cannibal"
    names[28] = "Ghoulish"
    names[29] = "Solar Powered"
    names[30] = "Cap Collector"
    names[31] = "Lady Killer / Black Widow"
    names[32] = "Lone Wanderer"
    names[33] = "Attack Dog"
    names[34] = "Animal Friend"
    names[35] = "Local Leader"
    names[36] = "Party Boy / Party Girl"
    names[37] = "Inspirational"
    names[38] = "Wasteland Whisperer"
    names[39] = "Intimidation"
    names[40] = "V.A.N.S."
    names[41] = "Medic"
    names[42] = "Gun Nut"
    names[43] = "Hacker"
    names[44] = "Scrapper"
    names[45] = "Science!"
    names[46] = "Chemist"
    names[47] = "Robotics Expert"
    names[48] = "Nuclear Physicist"
    names[49] = "Nerd Rage!"
    names[50] = "Gunslinger"
    names[51] = "Commando"
    names[52] = "Sneak"
    names[53] = "Mister Sandman"
    names[54] = "Action Boy / Action Girl"
    names[55] = "Moving Target"
    names[56] = "Ninja"
    names[57] = "Quick Hands"
    names[58] = "Blitz"
    names[59] = "Gun Fu"
    names[60] = "Fortune Finder"
    names[61] = "Scrounger"
    names[62] = "Bloody Mess"
    names[63] = "Mysterious Stranger"
    names[64] = "Idiot Savant"
    names[65] = "Better Criticals"
    names[66] = "Critical Banker"
    names[67] = "Grim Reaper's Sprint"
    names[68] = "Four Leaf Clover"
    names[69] = "Ricochet"
    int[] r1 = new int[70]
    r1[0] = 0x0001dafe
    r1[1] = 0x0004a0b5
    r1[2] = 0x0004b254
    r1[3] = 0x0004b253
    r1[4] = 0x0004a0d6
    r1[5] = 0x0004b24e
    r1[6] = 0x001d2487
    r1[7] = 0x00065df9
    r1[8] = 0x001d247f
    r1[9] = 0x0004d89b
    r1[10] = 0x0004d88a
    r1[11] = 0x0004a0b6
    r1[12] = 0x000d2287
    r1[13] = 0x000523ff
    r1[14] = 0x0004c923
    r1[15] = 0x0004c93b
    r1[16] = 0x000ca99d
    r1[17] = 0x0004c92a
    r1[18] = 0x00024aff
    r1[19] = 0x0004d890
    r1[20] = 0x0004a0ab
    r1[21] = 0x0004a0b9
    r1[22] = 0x0004a0cf
    r1[23] = 0x0004a0d5
    r1[24] = 0x001d248d
    r1[25] = 0x001d2479
    r1[26] = 0x0004c92d
    r1[27] = 0x0004b259
    r1[28] = 0x0004d89e
    r1[29] = 0x0004d8a7
    r1[30] = 0x001d2456
    r1[31] = 0x00019aa3
    r1[32] = 0x001d246b
    r1[33] = 0x0004b26d
    r1[34] = 0x0001e67f
    r1[35] = 0x0004d88d
    r1[36] = 0x0004d887
    r1[37] = 0x001d2461
    r1[38] = 0x001d248a
    r1[39] = 0x001d02b5
    r1[40] = 0x000207d1
    r1[41] = 0x0004c926
    r1[42] = 0x0004a0da
    r1[43] = 0x00052403
    r1[44] = 0x00065e65
    r1[45] = 0x000264d9
    r1[46] = 0x000e36ff
    r1[47] = 0x0004d889
    r1[48] = 0x001d246f
    r1[49] = 0x0004d886
    r1[50] = 0x0004a09f
    r1[51] = 0x0004a0c5
    r1[52] = 0x0004c935
    r1[53] = 0x0004b258
    r1[54] = 0x0004d869
    r1[55] = 0x0004ddee
    r1[56] = 0x0004d8a6
    r1[57] = 0x000221fc
    r1[58] = 0x001d2451
    r1[59] = 0x0004d881
    r1[60] = 0x0004c942
    r1[61] = 0x0004a0b0
    r1[62] = 0x0004a0bb
    r1[63] = 0x0004c929
    r1[64] = 0x001d245e
    r1[65] = 0x0004d87a
    r1[66] = 0x0004c91f
    r1[67] = 0x0004d8a2
    r1[68] = 0x0004d895
    r1[69] = 0x001d247c
    int[] r2 = new int[70]
    r2[0] = 0x0001daff
    r2[1] = 0x000e36fc
    r2[2] = 0x0004b255
    r2[3] = 0x0004b26a
    r2[4] = 0x0004a0d7
    r2[5] = 0x00065e5b
    r2[6] = 0x001d2488
    r2[7] = 0x00065dfa
    r2[8] = 0x001d2480
    r2[9] = 0x00065e3c
    r2[10] = 0x000e3702
    r2[11] = 0x0004a0b7
    r2[12] = 0
    r2[13] = 0x00052400
    r2[14] = 0x0004c924
    r2[15] = 0x001d2495
    r2[16] = 0x000ca99e
    r2[17] = 0x0004c92b
    r2[18] = 0x001d2477
    r2[19] = 0x001d2459
    r2[20] = 0x0004a0ae
    r2[21] = 0x00024b00
    r2[22] = 0x00024b00
    r2[23] = 0x00065e0c
    r2[24] = 0
    r2[25] = 0x001d247a
    r2[26] = 0x00024afd
    r2[27] = 0x001d1a62
    r2[28] = 0x00065e22
    r2[29] = 0x001d2484
    r2[30] = 0x000d75e2
    r2[31] = 0x00065e33
    r2[32] = 0x001d246d
    r2[33] = 0x001d244d
    r2[34] = 0x0004a0d9
    r2[35] = 0x001d2468
    r2[36] = 0x001d2473
    r2[37] = 0x001d2462
    r2[38] = 0x001d248b
    r2[39] = 0x001d02b6
    r2[40] = 0
    r2[41] = 0x0006fa1c
    r2[42] = 0x0004a0db
    r2[43] = 0x00052404
    r2[44] = 0x001d2483
    r2[45] = 0x000264da
    r2[46] = 0x000e3700
    r2[47] = 0x00065e64
    r2[48] = 0x001d2470
    r2[49] = 0x00065e37
    r2[50] = 0x0004a0a9
    r2[51] = 0x0004a0c6
    r2[52] = 0x000b9882
    r2[53] = 0x001d2490
    r2[54] = 0x00065df5
    r2[55] = 0x001d2492
    r2[56] = 0x000e3704
    r2[57] = 0x001d2478
    r2[58] = 0x001d2452
    r2[59] = 0x001d244f
    r2[60] = 0x001acf98
    r2[61] = 0x001acf9a
    r2[62] = 0x001d2453
    r2[63] = 0x001d2493
    r2[64] = 0x001d245f
    r2[65] = 0x00065e03
    r2[66] = 0x0004c920
    r2[67] = 0x00065e3e
    r2[68] = 0x00065e20
    r2[69] = 0x001d247d
    int[] r3 = new int[70]
    r3[0] = 0x0001db00
    r3[1] = 0x000e36fd
    r3[2] = 0x0004b256
    r3[3] = 0x000264d8
    r3[4] = 0x0004a0d8
    r3[5] = 0x00065e5c
    r3[6] = 0
    r3[7] = 0x00065dfb
    r3[8] = 0x001d2482
    r3[9] = 0x00065e3d
    r3[10] = 0x000e3703
    r3[11] = 0x0004a0b8
    r3[12] = 0
    r3[13] = 0x00052401
    r3[14] = 0x0004c925
    r3[15] = 0
    r3[16] = 0x000ca99f
    r3[17] = 0x0004c92c
    r3[18] = 0
    r3[19] = 0x001d245a
    r3[20] = 0x0004a0af
    r3[21] = 0x00024b01
    r3[22] = 0x001d2467
    r3[23] = 0
    r3[24] = 0
    r3[25] = 0x001d247b
    r3[26] = 0x00024afe
    r3[27] = 0x001d1a63
    r3[28] = 0x00065e23
    r3[29] = 0x001d2485
    r3[30] = 0x001d2457
    r3[31] = 0x00065e34
    r3[32] = 0x001d246e
    r3[33] = 0x001d244e
    r3[34] = 0x001d2450
    r3[35] = 0
    r3[36] = 0x001d2474
    r3[37] = 0x001d2463
    r3[38] = 0x001d248c
    r3[39] = 0x001d02b7
    r3[40] = 0
    r3[41] = 0x0006fa1d
    r3[42] = 0x0004a0dc
    r3[43] = 0x00052405
    r3[44] = 0
    r3[45] = 0x000264db
    r3[46] = 0x000e3701
    r3[47] = 0x001acf96
    r3[48] = 0x001d2471
    r3[49] = 0x00065e38
    r3[50] = 0x0004a0aa
    r3[51] = 0x0004a0c7
    r3[52] = 0x000b9883
    r3[53] = 0x001d2491
    r3[54] = 0
    r3[55] = 0x001e0791
    r3[56] = 0x000e3705
    r3[57] = 0
    r3[58] = 0
    r3[59] = 0x001d245c
    r3[60] = 0x001acf99
    r3[61] = 0x001acf9b
    r3[62] = 0x001d2454
    r3[63] = 0x001d2494
    r3[64] = 0x001d2460
    r3[65] = 0x00065e04
    r3[66] = 0x0004c921
    r3[67] = 0x00065e3f
    r3[68] = 0x00065e21
    r3[69] = 0x001d247e
    int[] r4 = new int[70]
    r4[0] = 0x00065e42
    r4[1] = 0x000e36fe
    r4[2] = 0x001797ea
    r4[3] = 0
    r4[4] = 0x00065e2a
    r4[5] = 0x001d2489
    r4[6] = 0
    r4[7] = 0x00065dfc
    r4[8] = 0
    r4[9] = 0
    r4[10] = 0x001d248f
    r4[11] = 0x0006fa20
    r4[12] = 0
    r4[13] = 0x001d246a
    r4[14] = 0x00065e13
    r4[15] = 0
    r4[16] = 0x00065e4b
    r4[17] = 0
    r4[18] = 0
    r4[19] = 0
    r4[20] = 0x00065e5d
    r4[21] = 0
    r4[22] = 0
    r4[23] = 0
    r4[24] = 0
    r4[25] = 0
    r4[26] = 0
    r4[27] = 0
    r4[28] = 0
    r4[29] = 0
    r4[30] = 0
    r4[31] = 0
    r4[32] = 0
    r4[33] = 0
    r4[34] = 0
    r4[35] = 0
    r4[36] = 0
    r4[37] = 0
    r4[38] = 0
    r4[39] = 0
    r4[40] = 0
    r4[41] = 0x00065e35
    r4[42] = 0x0016578e
    r4[43] = 0x001d245d
    r4[44] = 0
    r4[45] = 0x0016578f
    r4[46] = 0x001d2458
    r4[47] = 0
    r4[48] = 0
    r4[49] = 0
    r4[50] = 0x0006fa1e
    r4[51] = 0x0006fa24
    r4[52] = 0x000b9884
    r4[53] = 0
    r4[54] = 0
    r4[55] = 0
    r4[56] = 0
    r4[57] = 0
    r4[58] = 0
    r4[59] = 0
    r4[60] = 0x00215cd4
    r4[61] = 0x001eb99c
    r4[62] = 0x001f418e
    r4[63] = 0
    r4[64] = 0
    r4[65] = 0
    r4[66] = 0
    r4[67] = 0
    r4[68] = 0x001d245b
    r4[69] = 0
    int[] r5 = new int[70]
    r5[0] = 0x00065e43
    r5[1] = 0x00065e05
    r5[2] = 0
    r5[3] = 0
    r5[4] = 0x00065e2b
    r5[5] = 0
    r5[6] = 0
    r5[7] = 0
    r5[8] = 0
    r5[9] = 0
    r5[10] = 0
    r5[11] = 0x00065e52
    r5[12] = 0
    r5[13] = 0
    r5[14] = 0
    r5[15] = 0
    r5[16] = 0x00065e4c
    r5[17] = 0
    r5[18] = 0
    r5[19] = 0
    r5[20] = 0x00065e5e
    r5[21] = 0
    r5[22] = 0
    r5[23] = 0
    r5[24] = 0
    r5[25] = 0
    r5[26] = 0
    r5[27] = 0
    r5[28] = 0
    r5[29] = 0
    r5[30] = 0
    r5[31] = 0
    r5[32] = 0
    r5[33] = 0
    r5[34] = 0
    r5[35] = 0
    r5[36] = 0
    r5[37] = 0
    r5[38] = 0
    r5[39] = 0
    r5[40] = 0
    r5[41] = 0
    r5[42] = 0
    r5[43] = 0
    r5[44] = 0
    r5[45] = 0
    r5[46] = 0
    r5[47] = 0
    r5[48] = 0
    r5[49] = 0
    r5[50] = 0x00065e24
    r5[51] = 0x00065e0d
    r5[52] = 0x000b9881
    r5[53] = 0
    r5[54] = 0
    r5[55] = 0
    r5[56] = 0
    r5[57] = 0
    r5[58] = 0
    r5[59] = 0
    r5[60] = 0
    r5[61] = 0
    r5[62] = 0
    r5[63] = 0
    r5[64] = 0
    r5[65] = 0
    r5[66] = 0
    r5[67] = 0
    r5[68] = 0
    r5[69] = 0
    string result = "["
    bool first = true
    int i = 0
    while i < 70
        int rank = 0
        if r5[i] != 0 && player.HasPerk(Game.GetForm(r5[i]) as Perk)
            rank = 5
        elseif r4[i] != 0 && player.HasPerk(Game.GetForm(r4[i]) as Perk)
            rank = 4
        elseif r3[i] != 0 && player.HasPerk(Game.GetForm(r3[i]) as Perk)
            rank = 3
        elseif r2[i] != 0 && player.HasPerk(Game.GetForm(r2[i]) as Perk)
            rank = 2
        elseif r1[i] != 0 && player.HasPerk(Game.GetForm(r1[i]) as Perk)
            rank = 1
        endif
        if rank > 0
            if !first
                result += ","
            endif
            result += "{\"name\":\"" + names[i] + "\",\"rank\":" + rank + "}"
            first = false
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
    string sPerks = BuildPerksJson()
    return "{\"type\":\"" + asType + "\",\"game_date\":\"" + GameDate() + "\",\"game_time\":\"" + GameTime() + "\",\"level\":" + Game.GetPlayerLevel() + ",\"name\":\"" + player.GetDisplayName() + "\"," + special + ",\"bobbleheads\":" + sBob + ",\"ammo\":" + sAmmo + ",\"aid\":" + sAid + ",\"perks\":" + sPerks + "}"
EndFunction

; -----------------------------------------------------------------------
; WriteSessionStart — appends session_start to the event log on load.
; Console: cgf "LudoTrace.WriteSessionStart"
; -----------------------------------------------------------------------
Function WriteSessionStart() Global
    Log(BuildStateJson("session_start"))
    Debug.Notification("[LudoTrace __VERSION__] Loaded")
EndFunction

; -----------------------------------------------------------------------
; OnPostSaveGameEvent — mid-session snapshot on every save.
; -----------------------------------------------------------------------
Function OnPostSaveGameEvent(Hydra:Events:PostSaveGameParams akParams) Global
    Log(BuildStateJson("save"))
    Debug.Notification("[LudoTrace] Saved")
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
    ; GetPerks crashes in Hydra event callbacks — perks omitted until a safe call site is found (see issue #12)
    Log("{\"type\":\"level\",\"to\":" + akParams.iNewLevel + ",\"game_time\":\"" + GameTime() + "\"}")
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
