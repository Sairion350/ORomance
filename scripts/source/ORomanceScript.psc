ScriptName ORomanceScript Extends Quest


OUIScript property OUI auto

actor property playerref auto

AssociationType property Spouse Auto

FavorJarlsMakeFriendsScript FavorJarlsMakeFriends

Faction JarlFaction 

int InteractKey

ovirginityscript ovirgintiy

ORomanceOStimScript property bridge auto

faction FavorJobsBeggarFaction

;marriage 
faction PotientialMarriage
Quest RelationshipMarriage
Topic property MarriageAccept auto ;set by property
Quest RelationshipMarriageBreakUp

ReferenceAlias property PlayerLoveInterest auto

;orc-specific 
race OrcRace
faction OrcFriendFaction

;crimefactions
Faction Property CrimeFactionEastmarch auto ;winterhold
Faction Property CrimeFactionFalkreath auto ;falkreath
Faction Property CrimeFactionHaafingar auto ;solitude
Faction Property CrimeFactionHjaalmarch auto ;morthal
Faction Property CrimeFactionOrcs auto ;orcs
Faction Property CrimeFactionPale auto ;dawnstar
Faction Property CrimeFactionReach auto ;markarth
Faction Property CrimeFactionRift auto ;riften
Faction Property CrimeFactionWhiterun auto ;whiterun
Faction Property CrimeFactionWinterhold auto ;riften

MiscObject  Property Gold Auto

Faction FollowerFaction

;Dialogue 
topic property hello auto
topic property goodbye auto
topic property howmuch Auto
topic property accept auto 
topic property CoinWheels auto 
topic property Convinced auto 
topic property nah auto 
topic property price auto 
topic property whatThe auto

sound property success auto
sound property fail auto

faction property dialogueFaction auto

bool Property DoCacheRebuilds auto

bool debugbuild = false


GlobalVariable property ORDifficulty Auto
GlobalVariable property ORSexuality auto
GlobalVariable property ORKey auto
GlobalVariable property ORColorblind auto 
GlobalVariable property ORUseStationaryMode auto
GlobalVariable property ORLeft auto
GlobalVariable property ORRight auto
GlobalVariable property ORAlwaysAllowNakadashi auto 



int Function GetDifficultyDiff()
	return ORDifficulty.GetValueInt() as int
endfunction

bool Function EnableSexuality()
	return (ORSexuality.GetValueInt() == 1)
endfunction

bool Function GetColorblindMode()
	return (ORColorblind.GetValueInt() == 1)
endfunction

Int Function GetLeftKey()
	return ORLeft.GetValueInt() as int
endfunction

Int Function GetRightKey()
	return ORRight.GetValueInt() as int
endfunction

bool Function AlwaysAllowNakadashi()
	return (ORAlwaysAllowNakadashi.GetValueInt() == 1)
endfunction

Event OnInit()
	oui = (self as quest) as OUIScript
	bridge = (self as quest) as oromanceostimscript
	SetLookupKeys()
	oui.Startup()
	bridge.startup()

	if bridge.ostim.GetAPIVersion() < 12
		debug.MessageBox("Your OStim version is out of date. ORomance requires a newer version.")
		return
	endif 

	Docacherebuilds = true

	oui.ShowLoadingIcon()

	playerref = game.GetPlayer()

	interactkey = 37

	followerfaction = Game.GetFormFromFile(0x05C84E, "Skyrim.esm") as faction
	Gold = Game.GetFormFromFile(0x00000F, "Skyrim.esm") as MiscObject
	Spouse = Game.GetFormFromFile(0x0142CA, "Skyrim.esm") as AssociationType
	JarlFaction = Game.GetFormFromFile(0x050920, "Skyrim.esm") as faction

	favorjarlsmakefriends = Game.GetFormFromFile(0x087E24, "Skyrim.esm") as FavorJarlsMakeFriendsScript

	RelationshipMarriage = Game.GetFormFromFile(0x074793, "Skyrim.esm") as quest
	RelationshipMarriageBreakUp = Game.GetFormFromFile(0x07431B, "Skyrim.esm") as quest
	PotientialMarriage = Game.GetFormFromFile(0x019809, "Skyrim.esm") as faction

	ovirgintiy = game.GetFormFromFile(0x000800, "OVirginity.esp") as ovirginityscript

	FavorJobsBeggarFaction = game.GetFormFromFile(0x060028, "Skyrim.esm") as faction

	PlayerLoveInterest = RelationshipMarriage.GetAliasById(0) as ReferenceAlias
	
	OrcRace = game.GetFormFromFile(0x013747, "Skyrim.esm") as race
	OrcFriendFaction = game.GetFormFromFile(0x024029, "Skyrim.esm") as faction

	success = game.GetFormFromFile(0x004E19, "ORomance.esp") as sound
	fail = game.GetFormFromFile(0x004E1A, "ORomance.esp") as sound

	RegisterForSingleUpdate(1)

	onload()


	oui.HideLoadingIcon()
	if debugbuild
		return 
	endif
	oui.ShowInstalled()
EndEvent

bool function IsPlayerMarried()
	return PlayerLoveInterest.GetActorRef() != none
endfunction

bool Function isOrcFriend(actor npc)
	return (npc.isinfaction(OrcFriendFaction)) || (npc.getrace() == OrcRace)
endfunction

Function Marry(actor npc)
	setPlayerPartner(npc, true)
	RelationshipMarriage.SetStage(10)
	npc.AddToFaction(PotientialMarriage)
	npc.say(marriageaccept)
endfunction

int function GetPlayerGold()
	return playerref.GetItemCount(gold)
endfunction	

int function GetNPCSV(actor npc)
	int npcSV = GetBaseValue(npc)

	npcsv += GetCustomValue(npc)

	int RelationshipRank = npc.GetRelationshipRank(playerref)

	int prude = getPrudishnessStat(npc)

	if prude > 80
		int npcCount = GetNearbyNPCCount()
		if npcCount > 2
			npcsv += (10 + (prude - 80))
		elseif npccount < 1
			npcSV -= 5
		endif 
	endif 


	if IsMarried(npc)
		int monog = getMonogamyDesireStat(npc) ;1- 100

		if monog < 25
			if monog < 6
				npcsv -= 10
			else 
				npcSV += 25
			endif 
		else 
			if monog > 90
				npcSV += 275
			else 
				npcSV += 175
			endif
		endif
		

	EndIf

	if relationshiprank > 0
		npcSV -= 50
	elseif relationshiprank < 0
		npcsv += 100
	endif 

		If (FavorJarlsMakeFriends.WhiterunImpGetOutofJail > 0 || FavorJarlsMakeFriends.WhiterunSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionWhiterun)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.EastmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.EastmarchSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionEastmarch)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.FalkreathImpGetOutofJail > 0 || FavorJarlsMakeFriends.FalkreathSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionFalkreath)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.HaafingarImpGetOutofJail > 0 || FavorJarlsMakeFriends.HaafingarSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionHaafingar)
				npcsv -= 20
			endif
	
		EndIf
		If (FavorJarlsMakeFriends.HjaalmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.HjaalmarchSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionHjaalmarch)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.PaleImpGetOutofJail > 0 || FavorJarlsMakeFriends.PaleSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionPale)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.ReachImpGetOutofJail > 0 || FavorJarlsMakeFriends.ReachSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionReach)
			npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.WinterholdImpGetOutofJail > 0 || FavorJarlsMakeFriends.WinterholdSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionWinterhold)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.RiftImpGetOutofJail > 0 || FavorJarlsMakeFriends.RiftSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionRift)
				npcsv -= 20
			endif
		EndIf

		npcsv -= (getloveStat(npc) * 3) as int
		npcsv += (gethateStat(npc) * 3) as int

		int dislike = getdislikeStat(npc) as Int

		if (dislike >= 1) && (dislike <= 2)
			npcsv -= 15
		else 
			npcsv += (dislike  * 3)
		endif 

		int sexuality = GetSexuality(npc)

		bool femalePlayer = bridge.ostim.AppearsFemale(playerref)

		if bridge.ostim.AppearsFemale(npc)
			if femalePlayer ; female on female
				if sexuality == bi 
					; nothing 
				elseif sexuality == hetero 
					npcsv += 250
				elseif sexuality == gay
					npcsv -= 50
				endif 
			else ; male on female
				if sexuality == bi 
					
				elseif sexuality == hetero 
					
				elseif sexuality == gay
					npcsv += 250
				endif 
			endif 
		else ; male
			if femalePlayer ; male on female
				if sexuality == bi 
					
				elseif sexuality == hetero 
					
				elseif sexuality == gay
					npcsv += 250
				endif 
			else  ; male on male
				if sexuality == bi 
					
				elseif sexuality == hetero 
					npcsv += 250
				elseif sexuality == gay
					npcsv -= 50
				endif 
			endif 
		endif 

	if (npc.GetRace() == orcrace )
		if isOrcFriend(playerref)
			npcsv -= 25
		else 
			npcsv += 75
		endif 
	endif 


	return npcSV

EndFunction

bool function PlayerHasPsychicPerk(actor npc)
	if (GetSpeechStat(playerref) > 49) || isPlayerPartner(npc) 
		return true
	else 
		return false
	endif  
endfunction

bool function TryInquire(actor npc)
	float like = getlikeStat(npc)
	int love = getloveStat(npc) as int 

	if (love >= 1) || (like >= 1) || (npc.GetRelationshipRank(playerref) >= 1)
		return true 
	else 

		return GetPlayerSV() > getPrudishnessStat(npc)
	endif 
	
endfunction 

Function InquireRelationshipStatus(actor npc)
	string name = npc.GetDisplayName()
	string pronoun

	if bridge.ostim.AppearsFemale(npc)
		pronoun = "she"
	else 
		pronoun = "he"
	endif 

	int monog = getMonogamyDesireStat(npc) ;1- 100


	if isPlayerPartner(npc)
		debug.Notification(name + " says " + pronoun + " belongs to you")
	elseif IsMarried(npc)
		if monog < 6
			debug.Notification(name + " says " + pronoun + " is in terrible marriage")
		else 
			debug.Notification(name + " says " + pronoun + " is married")
		endif
	else 
		debug.Notification(name + " says " + pronoun + " is single")
	endif 
endfunction

Function InquireSexuality(actor npc)
	string name = npc.GetDisplayName()
	string pronoun
	if bridge.ostim.AppearsFemale(npc)
		pronoun = "she"
	else 
		pronoun = "he"
	endif 

	int sexuality = GetSexuality(npc)

	if sexuality == bi
		debug.Notification(name + " says " + pronoun + " is attracted to men and women")
	else
		if bridge.ostim.AppearsFemale(npc)
			if Sexuality == hetero
				debug.Notification(name + " says " + pronoun + " is attracted to men")
			elseif sexuality == gay
				debug.Notification(name + " says " + pronoun + " is attracted to women")
			endif
		else 
			if Sexuality == hetero
				debug.Notification(name + " says " + pronoun + " is attracted to women")
			elseif sexuality == gay
				debug.Notification(name + " says " + pronoun + " is attracted to men")
			endif
		endif 
	endif 
endfunction

Function InquireSexualExperience(actor npc)
	string name = npc.GetDisplayName()
	string pronoun
	if bridge.ostim.AppearsFemale(npc)
		pronoun = "she"
	else 
		pronoun = "he"
	endif 

	int sexDesireStat = getSexDesireStat(npc)
	int monog = getMonogamyDesireStat(npc) ;1- 100
	int prude = getPrudishnessStat(npc)

	if monog > 94
		debug.Notification(name + " says " + pronoun + " will not have sex before marriage")
	elseif (prude > 80)
		debug.Notification(name + " says talking about your sexual history is disgusting")
	elseif isvirgin(npc)
		debug.Notification(name + " says " + pronoun + " is a virgin")
	elseif (sexdesirestat > 85) ;&& (prude < 50)
		debug.Notification(name + " says " + pronoun + " lives for sex")
	elseif (sexdesirestat < 16)
		debug.Notification(name + " says " + pronoun + " has little interest in sex")
	elseif (monog - sexDesireStat) > 20
		debug.Notification(name + " says " + pronoun + " is far more interested in love than sex")
	else 
		debug.Notification(name + " says " + pronoun + " has some experience")
	endif 

endfunction

;time of day  | is prostitute | like stat (half effective) | is married | sex desire stat | is virgin
int function GetSeductionSV(actor npc)
	int npcSV = GetNPCSV(npc)

	int timeOfDay = GetTimeOfDay() ; 0 - day | 1 - morning/dusk | 2 - Night

	if timeOfDay == 0
		npcsv += 10
	ElseIf timeOfDay == 2
		npcsv -= 10
	EndIf


	if IsProstitute(npc)
		npcsv += 75
	EndIf

	npcsv -= (getlikeStat(npc) / 2) as int

	if !IsMarried(npc) 
		int monog = getMonogamyDesireStat(npc) ;1- 100

		if monog < 50
			npcsv += (monog - 50)
		elseif monog > 94
			if isPlayerPartner(npc)
				debug.Notification(npc.GetDisplayName() + " will not have sex before marriage")
			endif 
			return 999
		else 
			if !isPlayerPartner(npc)
				npcsv += ((monog - 50) * 2)
			else 
				npcsv += ((monog - 50))
			endif 
		endif 
	EndIf

	int sexDesireStat = getSexDesireStat(npc)

	npcsv -= (sexDesireStat - 50)

	float TimeSinceLastSeductionAttempt = Utility.GetCurrentGameTime() - getLastSeduceTime(npc)

	if sexDesireStat > 95

	elseif TimeSinceLastSeductionAttempt < 0.15
		;console("Adding 130")
		npcsv += 130
	elseif TimeSinceLastSeductionAttempt < 1
		npcsv += ( (100 - sexDesireStat) * ((1 - TimeSinceLastSeductionAttempt) * 3)  ) as int
		;console("Adding " + ( (100 - sexDesireStat) * ((1 - TimeSinceLastSeductionAttempt) * 3)  ) as int)
	endif 


	if IsVirgin(npc)
		npcsv += 35
	endif 

	if IsPlayerSpouse(npc) ;&& !(TimeSinceLastSeductionAttempt < 0.1)
		npcsv = -100
	endif


	console("NPC seduction SV: " + npcsv)
	

	return npcsv

endFunction

bool Function TrySeduce(actor npc)
	int playerSV = GetPlayerSV()
	int npcsv = GetSeductionSV(npc)
	
	console("PlayerSV: " + playersv)


	return (playerSV > npcSV)

EndFunction

int Function GetKissSV(actor npc)
	int npcSV = GetNPCSV(npc)

	float like = getlikeStat(npc)

	int prude = getPrudishnessStat(npc)

	if prude > 30
	    if (like < 1) && (npc.GetRelationshipRank(playerref) < 1)
		    npcsv += 50
	    endif 
    endif


	if IsProstitute(npc)
		npcsv += 75
	EndIf

	npcsv -= (like) as int

	int monog = getMonogamyDesireStat(npc) ;1- 100
	if !IsMarried(npc)

		if monog < 50
			npcSV -= (monog - 50)
		else
			npcSV += (monog - 50)
		endif 

		npcSV -= 20

		
	else 
		 

		 if monog > 50
		 	npcsv += (monog * 2)
		 else 
		 	npcsv += monog
		 endif 
	EndIf

	float TimeSinceKiss = Utility.GetCurrentGameTime() - getLastKissTime(npc)

	if TimeSinceKiss < 0.5
		npcsv += ( (100 - monog) * ((1 - TimeSinceKiss) * 2)  ) as int
	endif 

	if isPlayerPartner(npc)
		npcsv -= 30
	endif 

	if IsPlayerSpouse(npc)
		npcsv = -100
	endif

	console("NPC kiss SV: " + npcsv)
	return npcSV
EndFunction 

bool Function TryKiss(actor npc)
	
	int playerSV = GetPlayerSV()
	int npcSV = GetKissSV(npc)
	console("PlayerSV: " + playersv)
	

	return (playerSV > npcSV)

EndFunction

; is prostitute | like stat | is married
int function GetAskOutSV(actor npc)

	int npcSV = GetNPCSV(npc)
	int prude = getPrudishnessStat(npc)


	if IsProstitute(npc)
		npcsv += 65
	EndIf

	float like = getlikeStat(npc)

	npcsv -= (like) as int


	if prude > 30
		console(like)
		console(npc.GetRelationshipRank(playerref))
	    if (like < 1) && (npc.GetRelationshipRank(playerref) < 1)
		    npcsv += 50
	    endif 
    endif

	if !IsMarried(npc)
		int monog = getMonogamyDesireStat(npc) ;1- 100

		npcSV -= ((monog - 50) * 1.25) as int
	else 
		 int monog = getMonogamyDesireStat(npc) ;1- 100

		 if monog > 50
		 	npcsv += (monog * 2)
		 else 
		 	npcsv += monog
		 endif 
	EndIf

	console("NPC ask out SV: " + npcsv)

	return npcsv
endfunction 

bool Function TryAskOut(actor npc)
	int playerSV = GetPlayerSV()
	int npcsv = GetAskOutSV(npc)

	console("PlayerSV: " + playersv)

	return (playerSV > npcSV)

EndFunction

int Function GetMarrySV(actor npc)
	int npcSV = GetNPCSV(npc)


	int prude = getPrudishnessStat(npc)


	if !isPlayerPartner(npc)
		npcsv += 100
	endif

	int love = getloveStat(npc) as int 

	if love < 16
		npcsv += ((15 - love) * 10)
	endif

	if !IsMarried(npc)
		int monog = getMonogamyDesireStat(npc) ;1- 100

		npcSV -= (monog - 50)

		npcSV -= (monog * 0.3) as int
	else 
		 npcSV += 300
	EndIf

	npcsv += 125

	console("NPC propose SV: " + npcsv)

	return npcsv
endfunction 

bool Function TryPropose(actor npc)
	int playerSV = GetPlayerSV()
	int npcSV = GetMarrySV(npc)


	console("PlayerSV: " + playersv)
	

	return (playerSV > npcSV)

EndFunction

function CatchPlayerCheating(actor npc)
	int monog = getMonogamyDesireStat(npc)
	if monog < 16
		return 
	endif 
	int dislike = getdislikeStat(npc) as int

	if dislike > 18
		return 
	endif 

	oui.FireSuccessIncidcator(1)

	increasedislikestat(npc, utility.randomint(20, 29))
	increasehatestat(npc, utility.randomint(4, 10))

	if bridge.ostim.chanceroll(50)
		if bridge.ostim.chanceroll(50)
			npc.StartCombat(playerref)
		else 
			npc.startcombat(bridge.ostim.getsexpartner(playerref))
		endif 


	endif 
	bridge.ostim.EndAnimation(false)
	Utility.Wait(2)

	int breakupChance = 30 + monog 

	if bridge.ostim.chanceroll(breakupChance)
		BreakUpOrDivorce(npc)
		debug.Notification(npc.GetDisplayName() + " has broken up with you!")
	endif 

	debug.Notification(npc.GetDisplayName() + " has caught you cheating!")

endfunction 

function onload()
	InteractKey = ORKey.GetValueInt() 
	RegisterForKey(InteractKey)
	if debugbuild
		RegisterForKey(184) ;ralt
	endif

	bridge.onload()
	oui.OnLoad()
EndFunction

Event onKeyDown(int keyn)
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console")) || oui.uiopen
		Return
	EndIf

	If keyn == InteractKey
		actor target = game.GetCurrentCrosshairRef() as actor 

		if target 
			if  target.IsInCombat() || bridge.ostim.IsChild(target)
				return 
			endif
			if isPlayerPartner(target) && (getlikeStat(target) < 1) 
				if bridge.ostim.chanceroll(25)
					Debug.Notification(target.GetDisplayName() + " wants a kiss!")
					kiss(target)
					return 
				endif
			endif 
			SeedIfNeeded(target)
			oui.EnterDialogueWith(target)
			if debugbuild
				Displaystats(target)
				console("Player SV: " + GetPlayerSV())
			endif 
		endif 
	elseif keyn == 184
		test()
	EndIf
EndEvent

string property isSeededKey auto

string property BaseStatKey auto 
string property CustomStatKey auto

string property SexDesireKey Auto ; how much the NPC desires sex
string property PrudishnessKey Auto ; How open the NPC is to discussing sex
string property MonogamyDesireKey auto ; how committed the npc is to a single relationship 

string property SexualityKey auto

string property LoveKey Auto
string property LikeKey Auto
string property DislikeKey Auto
string property HateKey Auto

string property LikeLastAccessKey auto
string property DisLikeLastAccessKey auto
string property LastSeduceTimeKey auto
string property LastKissTimeKey auto


string property IsPlayerPartnerKey Auto

string property ProstitutionCostKey Auto




Function SetLookupKeys()
	SexDesireKey = "or_k_sexdesire"
	PrudishnessKey = "or_k_prudishness"
	MonogamyDesireKey = "or_k_monogamy"
	isSeededKey = "or_k_seeded"

	loveKey = "or_k_love"
	likeKey = "or_k_li"
	dislikeKey = "or_k_di"
	hateKey = "or_k_hate"

	LikeLastAccessKey = "or_k_li_last"
	DisLikeLastAccessKey = "or_k_di_last"

	LastSeduceTimeKey = "or_k_last_seduce"
	LastKissTimeKey = "or_k_last_kiss"

	BaseStatKey = "or_k_base"
	CustomStatKey = "or_k_customSV"

	IsPlayerPartnerKey = "or_k_part"

	ProstitutionCostKey = "or_k_cost"

	sexualitykey = "or_k_sexu"

EndFunction

int function GetSpeechStat(actor act)
	return act.GetActorValue("speechcraft") as int
EndFunction

int Function GetPlayerSV()
	;low - 19 (level 5 player with 23 speech)
	;medium - 78 (level 21 player with 45 speech)
	;high - 157 (level 33 player with 85 speech, one thane and one house)
	;Endgame - 220 (level 46 player with 100 speech, 3 houses and 4 thaneships)

	int speech = GetSpeechStat(playerref) - 15
	int playerLevel = playerref.Getlevel()
	int playerThaneCount = 0 
	int slayedAlduinStat = 0 ;todo
	int endedWar = 0 ;todo 
	int propertyOwned = Game.QueryStat("Houses Owned")

	;----- Thanes -----
	If (FavorJarlsMakeFriends.WhiterunImpGetOutofJail > 0 || FavorJarlsMakeFriends.WhiterunSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.EastmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.EastmarchSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.FalkreathImpGetOutofJail > 0 || FavorJarlsMakeFriends.FalkreathSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.HaafingarImpGetOutofJail > 0 || FavorJarlsMakeFriends.HaafingarSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.HjaalmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.HjaalmarchSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.PaleImpGetOutofJail > 0 || FavorJarlsMakeFriends.PaleSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.ReachImpGetOutofJail > 0 || FavorJarlsMakeFriends.ReachSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.WinterholdImpGetOutofJail > 0 || FavorJarlsMakeFriends.WinterholdSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.RiftImpGetOutofJail > 0 || FavorJarlsMakeFriends.RiftSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf

	int charisma = speech
	int attractiveness = playerlevel
	int wealth = propertyOwned
	int fame = playerThaneCount



	;apply multipliers
	charisma = (charisma * 1.2) as int
	attractiveness = (playerlevel) * 2
	fame = fame * 5
	wealth = wealth * 2

	float finalMult = 1

	return (((charisma + attractiveness + fame + wealth) * finalMult) + GetDifficultyDiff()) as int
EndFunction

Function SeedIfNeeded(actor npc)
	if !isSeeded(npc)
		SeedStats(npc)
	EndIf
EndFunction

int hetero = 0
int bi = 1
int gay = 2

Function SeedStats(actor npc)
	StoreNPCDataInt(npc, BaseStatKey, createBaseValue(npc))
	StoreNPCDataInt(npc, CustomStatKey, 0)

	StoreNPCDataInt(npc, SexDesireKey, Utility.RandomInt(1, 100))
	StoreNPCDataInt(npc, PrudishnessKey, Utility.RandomInt(1, 100))
	StoreNPCDataInt(npc, MonogamyDesireKey, Utility.RandomInt(1, 100))

	StoreNPCDataFloat(npc, lovekey, 0.0)
	StoreNPCDataFloat(npc, likekey, 0.0)
	StoreNPCDataFloat(npc, dislikekey, 0.0)
	StoreNPCDataFloat(npc, hatekey, 0.0)

	float time =  Utility.GetCurrentGameTime()

	storenpcdatafloat(npc, LikeLastAccessKey, time)
	storenpcdatafloat(npc, DisLikeLastAccessKey, time)

	storenpcdatafloat(npc, LastSeduceTimeKey, 0)
	storenpcdatafloat(npc, LastKissTimeKey, 0)

	StoreNPCDataBool(npc, IsPlayerPartnerKey, false)

	int num = Utility.RandomInt(1, 100)
	int sexuality ; 0 - straight  / 1 bisexual / 2 - gay
	if bridge.ostim.appearsfemale(npc)
		if num < 91
			sexuality = hetero
		elseif num < 96
			sexuality = bi 
		else 
			sexuality = gay 
		endif
	else 
		if num < 78
			sexuality = hetero
		elseif num < 97
			sexuality = bi 
		else 
			sexuality = gay 
		endif
	endif 

	storenpcdataint(npc, SexualityKey, sexuality)

	int mult = 10
	if npc.IsInFaction(FavorJobsBeggarFaction)
		mult = 1
	endif 
	int cost = GetBaseValue(npc) * mult
	cost -= (getSexDesireStat(npc) - 50) * mult
	if cost < 1
		cost = 1
	endif

	StoreNPCDataInt(npc, ProstitutionCostKey, cost)

	;calculation 
	if !IsMarried(npc)
		int mon = getMonogamyDesireStat(npc)
		if mon < 16
			if getSexDesireStat(npc) > 20
				ovirgintiy.setVirginity(npc, false)
			endif 
		elseif mon > 84
			if getSexDesireStat(npc) < 95
				ovirgintiy.setVirginity(npc, true)
			endif 
		endif 
	endif


	StoreNPCDataBool(npc, isSeededKey, true)
EndFunction

bool function isSeeded(actor npc)
	return getNPCDataBool(npc, isSeededKey)
EndFunction

bool function isPlayerPartner(actor npc)
	return GetNPCDataBool(npc, IsPlayerPartnerKey)
EndFunction

bool function setPlayerPartner(actor npc, bool partner)
	if partner 
		StoreNPCDataBool(npc, IsPlayerPartnerKey, true)
		npc.SetRelationshipRank(playerref, 4)
		playerref.SetRelationshipRank(npc, 4)
		increaselovestat(npc, 3)
	else
		StoreNPCDataBool(npc, IsPlayerPartnerKey, false)
	EndIf
EndFunction

int function GetSexuality(actor npc)
	if !EnableSexuality()
		return bi 
	endif 
	return getnpcdataint(npc, SexualityKey)
endfunction

 function StoreSexuality(actor npc, int val)
	 storenpcdataint(npc, SexualityKey, val)
endfunction

function BreakUpOrDivorce(actor npc)
	if IsPlayerSpouse(npc)
		RelationshipMarriageBreakUp.Start()
		Utility.Wait(0.1)
		relationshipmarriage.Reset()
		increasehatestat(npc, 5)
	elseif isPlayerPartner(npc)
		setplayerpartner(npc, false)
		increasehatestat(npc, 2)
	endif 
	getdislikeStat(npc)
	setdislikestat(npc, 30)
	increaselovestat(npc, -10)
	npc.SetRelationshipRank(playerref, -2)
	playerref.SetRelationshipRank(npc, -2)
	oui.FireSuccessIncidcator(2)

endfunction 

int function getPrositutionCost(actor npc)
	return getnpcdataint(npc, ProstitutionCostKey)
EndFunction

function setProstitutionCost(actor npc, int cost)
	StoreNPCDataInt(npc, ProstitutionCostKey, cost)
EndFunction

int function getSexDesireStat(actor npc)
	return getnpcdataint(npc, sexdesirekey)
EndFunction

int function getPrudishnessStat(actor npc)
	return getnpcdataint(npc, Prudishnesskey)
EndFunction

int function getMonogamyDesireStat(actor npc)
	return getnpcdataint(npc, Monogamydesirekey)
EndFunction

function increaselovestat(actor npc, float val)
	int curr = getloveStat(npc) as int
	if curr >= 30
		return 
	endif 

	setlovestat(npc, val + curr)
EndFunction

function setlovestat(actor npc, float val)
	if val < 0
		val = 0
	endif 
	storenpcdatafloat(npc, lovekey, val)
EndFunction 

function setlikestat(actor npc, float val)
	storenpcdatafloat(npc, likekey, val)
EndFunction 

float function getloveStat(actor npc)
	return getnpcdatafloat(npc, lovekey)
EndFunction

float function getLastSeduceTime(actor npc)
	return getnpcdatafloat(npc, LastSeduceTimeKey)
EndFunction

function setLastSeduceTime(actor npc)
	storenpcdatafloat(npc, LastSeduceTimeKey, Utility.GetCurrentGameTime())
EndFunction

float function getLastKissTime(actor npc)
	return getnpcdatafloat(npc, LastKissTimeKey) 
EndFunction

function setLastKissTime(actor npc)
	storenpcdatafloat(npc, LastKissTimeKey, Utility.GetCurrentGameTime())
EndFunction

float function getlikeStat(actor npc)
	float lastCalcTime = GetNPCDataFloat(npc, LikeLastAccessKey)
	float like = getnpcdatafloat(npc, likekey)
	float currTime = Utility.GetCurrentGameTime()
	float diff = currtime - lastCalcTime

	like -= (diff * 3) ; deteriorate 3/day

	if like < 0
		like = 0
	endif 

	StoreNPCDataFloat(npc, LikeLastAccessKey, currtime)
	StoreNPCDataFloat(npc, likekey, like)
	return like
EndFunction

function increaselikestat(actor npc, float val)
	float curr = getlikeStat(npc)
	if curr >= 30
		return 
	endif 

	setlikestat(npc, val + curr)
EndFunction

float function getdislikeStat(actor npc)
	float lastCalcTime = GetNPCDataFloat(npc, disLikeLastAccessKey)
	float dislike = getnpcdatafloat(npc, dislikekey)
	float currTime = Utility.GetCurrentGameTime()
	float diff = currtime - lastCalcTime

	dislike -= (diff * 3) ; deteriorate 3/day

	if dislike < 0
		dislike = 0
	endif 

	StoreNPCDataFloat(npc, disLikeLastAccessKey, currtime)
	StoreNPCDataFloat(npc, dislikekey, dislike)
	return dislike
EndFunction

function increasedislikestat(actor npc, float val)
	float curr = getdislikeStat(npc)
	if curr >= 30
		return 
	endif 

	setdislikestat(npc, val + curr)
EndFunction

function setdislikestat(actor npc, float val)
	storenpcdatafloat(npc, DislikeKey, val)
EndFunction 

float function gethateStat(actor npc)
	return getnpcdatafloat(npc, hatekey)
EndFunction

function increasehatestat(actor npc, float val)
	int curr = gethateStat(npc) as int
	
	if curr >= 30
		return 
	endif 

	curr = (val + curr) as int

	sethatestat(npc, val + curr)


	if !isPlayerPartner(npc)
		int rel = npc.GetRelationshipRank(playerref)
		if rel > -2
			if curr > 9
				npc.SetRelationshipRank(playerref, -2)
				playerref.SetRelationshipRank(npc, -2)
			endif 
		endif 
	endif 

	if (curr > 19) && isPlayerPartner(npc)
		if bridge.ostim.chanceroll(50)
			BreakUpOrDivorce(npc)
		endif 
	endif 
EndFunction

function sethatestat(actor npc, float val)
	if val < 0
		val = 0
	endif 
	storenpcdatafloat(npc, HateKey, val)
EndFunction 

int function GetBaseValue(actor npc)
	return getnpcdataint(npc, BaseStatKey)
EndFunction

int function GetCustomValue(actor npc)
	return getnpcdataint(npc, CustomStatKey)
EndFunction

function SetCustomValue(actor npc, int value)
	return storenpcdataint(npc, CustomStatKey, value)
EndFunction

bool Function IsMarried(actor npc)
	return npc.HasAssociation(Spouse)
EndFunction

bool Function IsSpouseNearby(actor npc)
		actor[] nearby = MiscUtil.ScanCellNPCs(npc, radius = 0.0)

		int i = 0
		int l = nearby.length 

		while i < l
			if nearby[i].HasAssociation(spouse, npc)
				return True
			endif 

			i += 1
		endwhile

		return false
endfunction

bool function IsNPCSpouse(actor npc, actor otherNPC)
	return npc.HasAssociation(spouse, othernpc)
endfunction 

bool Function IsPlayerSpouse(actor npc)
	return PlayerLoveInterest.GetActorRef() == npc
EndFunction

bool Function IsVirgin(actor npc)
	return ovirgintiy.isVirgin(npc)
EndFunction

bool Function IsProstitute(actor npc)
	return ovirgintiy.isProstitute(npc)
EndFunction

int Function createBaseValue(actor npc)
	int value = 0

	actorbase npcBase = npc.GetActorBase()

	bool unique = npcBase.isunique()
	bool protected = npcBase.IsProtected()
	bool essential = npcBase.IsEssential()

	bool isJarl = npc.IsInFaction(JarlFaction)

	bool isGuard = npc.IsGuard()

	if unique
		value += (100) as int

		if protected
			value += (15) as int
		EndIf

		if essential
			value += (20) as int
		EndIf

		if isJarl
			value += 50
		EndIf

		value += Utility.RandomInt(-15, 15)
	else 
		value += Utility.RandomInt(60, 140)

		if isGuard
			value += 30
		EndIf
	EndIf

	


	return value

EndFunction

function DisplayStats(actor npc)
	console("-------------------------------")
	console("Stats for: " + npc.GetDisplayName())

	console("Base SV: " + GetBaseValue(npc))
	console("Custom SV mod:" + GetCustomValue(npc))

	console("Sex desire: " + getSexDesireStat(npc))
	console("Prudishness: " + getPrudishnessStat(npc))
	console("Monogamy desire: " + getMonogamyDesireStat(npc))
	
	console("Love stat: " + getLoveStat(npc))
	console("Like stat: " + getLikeStat(npc))
	console("Disike stat: " + getDislikeStat(npc))
	console("Hate stat: " + getHateStat(npc))

	console("Last seduce time: " + getLastSeduceTime(npc))
	console("Last kiss time: " + getLastKissTime(npc))

	console("Married: " + IsMarried(npc))
	console("Jarl: " + npc.IsInFaction(JarlFaction))
	string sexu
	int sexint = GetSexuality(npc)
	if sexint == hetero 
		sexu = "Heterosexual"
	elseif sexint == bi 
		sexu = "Bisexual"
	else 
		sexu = "Gay"
	endif 

	console("Sexuality: " + sexu)

	console("Virgin: " + IsVirgin(npc))
	console("Prostitute: " + IsProstitute(npc))
	console("Prostitution price: " + getPrositutionCost(npc))
	console("Player partner: " + isPlayerPartner(npc))

	console("-------------------------------")
EndFunction


function StoreNPCDataFloat(actor npc, string keys, Float num) 
	StorageUtil.SetFloatValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Float function GetNPCDataFloat(actor npc, string keys)
	return StorageUtil.GetFloatValue(npc, keys, -1)
EndFunction

function StoreNPCDataInt(actor npc, string keys, int num) 
	StorageUtil.SetIntValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Int function GetNPCDataInt(actor npc, string keys)
	return StorageUtil.GetIntValue(npc, keys, -1)
EndFunction

function StoreNPCDataBool(actor npc, string keys, bool value)
	int store 
	if value 
		store = 1
	else 
		store = 0
	endif
	StoreNPCDataInt(npc, keys, store)
	;console("Set value " + store + " for key " + keys)
EndFunction

Bool function GetNPCDataBool(actor npc, string keys)
	int value = GetNPCDataInt(npc, keys)
	bool ret = (value == 1)
	;console("got value " + value + " for key " + keys)
	return ret
EndFunction

int Function GetTimeOfDay() global ; 0 - day | 1 - morning/dusk | 2 - Night
	float hour = GetCurrentHourOfDay()

	if (hour < 4) || (hour > 20 ) ; 8:01 to 3:59. night
		return 2
	elseif ((hour >= 18) && (hour <= 20))  || ((hour >= 4) && (hour <= 6)) ; morning/dusk
		return 1
	Else
		return 0
	endif
		
EndFunction

float Function GetCurrentHourOfDay() global
 
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	Return Time
 
EndFunction

function TryApology(actor npc)

	int successChance
	int criticalFailChance

	if getHateStat(npc) < 10
		criticalFailChance = 10
	else 
		criticalFailChance = 100
	endif 

	successChance = 50

	if bridge.ostim.ChanceRoll(successchance)
		oui.FireSuccessIncidcator(0)
		increasedislikestat(npc, -1)
		if getdislikeStat(npc) < 20
			oui.showpage(1)
		endif 
	Else
		
		if bridge.ostim.ChanceRoll(criticalFailChance)
			oui.FireSuccessIncidcator(2)
			oui.exitdialogue(0)
			increasedislikestat(npc, 1)
			
		else 
			oui.FireSuccessIncidcator(1)
		endif  
	endif


endfunction

bool function IsOkToEjaculateInside(actor npc)
	if IsPlayerSpouse(npc)
		return True
	elseif isplayerpartner(npc)
		if (getMonogamyDesireStat(npc) > 15) || (getSexDesireStat(npc) > 75)
			return true 
		endif 
	else 
		if (getMonogamyDesireStat(npc) > 71) || (getSexDesireStat(npc) > 85)
			return true 
		endif 
	endif
	return false
endfunction

int function GetNearbyNPCCount()
	return (miscutil.ScanCellNPCs(playerref, 640)).length - 2
EndFunction

int function gift(actor npc)
	return npc.ShowGiftMenu(true, apFilterList = None,  abShowStolenItems = true, abUseFavorPoints = true)
EndFunction

function compliment(actor npc)
	int like = Utility.RandomInt(1, 3) ; like NPC should gain

	int currLike = getlikestat(npc) as Int ; current like stat

	int targetLike ; like stat cap

	if IsPlayerSpouse(npc)
		targetLike = 15
	elseif isPlayerPartner(npc)
		targetLike = 10
	else 
		targetLike = 5
	endif 

	if (like + currLike) > targetLike ;if adding the like the npc should gain goes over the cap
		like = targetLike - currLike ; shrink the like to go under the cap
	endif 


	if like > 0 ;npc will gain a  like point
		oui.FireSuccessIncidcator(0)
		increaselikestat(npc, like)

	else  ;player will not gain a like point due to reaching limit
		oui.FireSuccessIncidcator(1)
		increasedislikestat(npc, utility.randomint(1,3))
	endif
EndFunction

function insult(actor npc) ; todo make hate stat lower rel rank
	int currDis = getdislikeStat(npc) as int 

	if currDis > 5
		increasehatestat(npc, Utility.RandomInt(1, 2))
	endif

	if bridge.ostim.chanceroll(25)
		SayTopic(npc, whatthe)
	endif 
	increasedislikestat(npc, Utility.RandomInt(1, 3))
	oui.FireSuccessIncidcator(1)
endfunction

Function kiss(actor npc)
	if IsMarried(npc)
		if IsSpouseNearby(npc)
			debug.Notification(npc.GetDisplayName() + " wants to kiss but their spouse is nearby")
			return 
		endif 
	endif 
	bridge.startscene(playerref, npc, true)

	setLastKissTime(npc)

	int like = 15
	int monog = getMonogamyDesireStat(npc)
	like = (((monog as float) / 100) * like) as int
	int currLike = getlikestat(npc) as Int
	int targetLike

	if IsPlayerSpouse(npc)
		targetLike = 20
		increaselovestat(npc, 1)
	elseif isPlayerPartner(npc)
		targetLike = 15
		if bridge.ostim.chanceroll(50)
			increaselovestat(npc, 1)
		endif 
	
	else 
		targetLike = 10
	endif 

	if (like + currLike) > targetLike
		like = targetLike - currLike
	endif 

	increaselikestat(npc, like)

EndFunction

function ProcessGift(actor npc, int value)
	if value == 0
		return 
	endif 
	debug.SendAnimationEvent(npc, "idletake")
	int like = 1 + (value / 10)

	int currLike = getlikestat(npc) as Int

	int targetLike

	if IsPlayerSpouse(npc)
		targetLike = 15
	elseif isPlayerPartner(npc)
		targetLike = 10
	
	else 
		targetLike = 5
	endif 

	if (like + currLike) > targetLike
		like = targetLike - currLike
	endif 

	increaselikestat(npc, like)

	if like > 0
		oui.FireSuccessIncidcator(0)
	endif 

EndFunction

actor[] Function CheckForFollowers()
	actor[] nearby = MiscUtil.ScanCellNPCsByFaction(followerfaction, playerref, radius = 0.0,  minRank = 0,  maxRank = 127,  IgnoreDead = true)
	;console(nearby.length)

	return nearby
EndFunction


Event OnUpdate() ;todo test across saves
	actor[] followers = CheckForFollowers()

	if followers.length > 0
		int i = 0
		int l = followers.length 

		while i < l
			oui.FireSuccessIncidcator(0)
			SeedIfNeeded(followers[i])
			increaselovestat(followers[i], 1)

			i += 1
		endwhile 

	else 
		;console("no followers")
	endif

	;RegisterForSingleUpdate(5)
	RegisterForSingleUpdate(1200) ; 20 minutes
EndEvent

function SayTopic(actor npc, topic ztopic)
	npc.AddToFaction(dialoguefaction)
	npc.say(ztopic)
	Utility.wait(0.1)
	npc.RemoveFromFaction(dialoguefaction)
endfunction

function test()
	console("Running test code")

	actor npc = game.GetCurrentCrosshairRef() as actor
	setPlayerPartner(npc, true)
	;oui.SetAsLongTermFollower(game.GetCurrentCrosshairRef() as actor, true)
	;bridge.StartScene(playerref, game.GetCurrentCrosshairRef() as actor,true)
	;increasedislikestat(npc, 30)
	;oui.FireSuccessIncidcator(0)
	;oui.ShowLoadingIcon()
	;console(((self as quest).GetAliasById(4) as ReferenceAlias).GetActorRef().GetDisplayName())
	;CheckForFollowers()
	;console(IsSpouseNearby(npc))
	;SayTopic(npc, whatthe)
	;console(gift(npc))
	;kiss(npc)
EndFunction

function console(string in)
	if !debugbuild
		return
	endif 
	OsexIntegrationMain.Console(in)
EndFunction