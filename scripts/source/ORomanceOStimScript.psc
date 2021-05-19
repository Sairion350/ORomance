ScriptName ORomanceOStimScript Extends Quest
OsexIntegrationMain property ostim auto

actor playerref

ORomanceScript main

bool hadOrgasmRelIncrease

Function Startup()

	console("ORomance OStim bridge ready")

	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	playerref = game.GetPlayer()

	prostitutionType = 1

	main = ((self as quest) as ORomanceScript)

	;onload()	
EndFunction

function onload()
	RegisterForModEvent("ostim_end", "OstimEnd")
	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("oromance_sexthread", "ORomanceAsync")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")
endfunction 

Bool bUseAIControl
Bool bAlwaysUndressAtAnimStart
Bool bUseBed
Bool bUseFreeCam
bool bEnableDomBar
bool bEnableSubBar
bool bUseAINonAggressive
bool bAutoUndressIfNeeded

bool isKiss

string kissanim
string startinganim

int prostitutionType

Function StartScene(actor dom, actor sub, bool kiss = false, int sexType = 1, actor third = none)
	if ostim.AnimationRunning()
		ostim.EndAnimation(false)
		Utility.Wait(2) 
	endif 

	prostitutionType = sextype

	startinganim = ""
	if kiss 
		startinganim = "0MF|Sy6!Sy9|Em|St9AdoreKm"
		; 0MF|Sy6!LLy9|Em|LiftedLotusKm jump up on and kiss    0MF|Sy6!LLy9|Em|LiftedLotusEmb
		; 0MF|Sy6!Sy9|Em|CurlicueKm kiss iwth one leg wrapped around 0MF|Sy6!Sy9|Em|CurlicueEmb
		; 0MF|Sy6!Sy9|Em|St9AdoreKm ;standard  0MF|Sy6!Sy9|Em|St9AdoreEmb

		int kissz

		int love = main.getloveStat(sub) as int 

		if love > 20
			if ostim.ChanceRoll(50)
				kissz = 0
			else 
				kissz = 1
			endif
		elseif love > 10
			if ostim.ChanceRoll(50)
				kissz = 2
			else 
				kissz = 1
			endif
		else 
			kissz = 2
		endif

		if kissz == 0
			startinganim = "0MF|Sy6!LLy9|Em|LiftedLotusEmb"
			kissanim = "0MF|Sy6!LLy9|Em|LiftedLotusKm"
		elseif kissz == 1
			startinganim = "0MF|Sy6!Sy9|Em|CurlicueEmb"
			kissanim = "0MF|Sy6!Sy9|Em|CurlicueKm"
		elseif kissz == 2
			startinganim = "0MF|Sy6!Sy9|Em|St9AdoreEmb"
			kissanim = "0MF|Sy6!Sy9|Em|St9AdoreKm"
		endif 
		
		; Disable the controls
		OStim.DisableOSAControls = true

		; Disable auto-control
		bUseAIControl = OStim.UseAIControl
		OStim.UseAIControl = false
		
		bUseAINonAggressive = OStim.UseAINonAggressive
		OStim.UseAINonAggressive = false		
	
		; Don't undress
		bAlwaysUndressAtAnimStart = OStim.AlwaysUndressAtAnimStart
		OStim.AlwaysUndressAtAnimStart = false
	
		; Don't use beds
		bUseBed = OStim.UseBed
		OStim.UseBed = false
		
		; Don't toggle the camera
		bUseFreeCam = OStim.UseFreeCam
		OStim.UseFreeCam = false

		bEnableDomBar = ostim.EnableDomBar
		ostim.EnableDomBar = false

		bEnableSubBar = ostim.EnableSubBar
		ostim.EnableSubBar = false

		iskiss = true

	endif 

	if prostitutionType != 1
		; Disable the controls
		OStim.DisableOSAControls = true

		; Disable auto-control
		bUseAIControl = OStim.UseAIControl
		OStim.UseAIControl = false
		bUseAINonAggressive = OStim.UseAINonAggressive
		OStim.UseAINonAggressive = false

		; Don't undress
		bAlwaysUndressAtAnimStart = OStim.AlwaysUndressAtAnimStart
		OStim.AlwaysUndressAtAnimStart = false

		;enable mid-scene undress
		bAutoUndressIfNeeded = ostim.AutoUndressIfNeeded
		ostim.AutoUndressIfNeeded = true

		string aclass
		if prostitutionType == 2 ; handjob
			if ostim.ChanceRoll(50)
				aclass = "HJ"
			else 
				aclass = "ApHJ"
			endif 
		elseif prostitutionType == 3
			if ostim.ChanceRoll(50)
				aclass = "BJ"
			else 
				aclass = "ApPJ"
			endif
		endif 

		startinganim = GetRandomAnimationByClass(aclass)

	endif 

	ostim.startscene(dom, sub, zStartingAnimation = startinganim, zThirdActor = third)
EndFunction

Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	if !ostim.IsActorActive(playerref)
		return 
	endif 
	
	actor npc = ostim.GetMostRecentOrgasmedActor()
	if (npc != playerref) && !hadOrgasmRelIncrease && ostim.IsActorActive(playerref)
		if ostim.IsSceneAggressiveThemed()
			return 
		endif 
		main.seedifneeded(npc)

		hadOrgasmRelIncrease = true

		main.increaselikestat(npc, 3)

		int targetLike
		int currLove = main.getloveStat(npc) as int
		int love = 1

		if main.IsPlayerSpouse(npc)
			targetLike = 30
		elseif main.isPlayerPartner(npc)
			targetLike = 20
		else 
			targetLike = 10
		endif 

		if (love + currLove) > targetLike
			love = targetLike - currLove
		endif 

		main.increaselovestat(npc, love)

		if love > 0
			main.oui.FireSuccessIncidcator(0)
		endif
	endif 
	if npc == playerref 
		npc = ostim.getsexpartner(playerref)
		if ostim.IsVaginal() && ostim.isFemale(npc) && !ostim.isfemale(playerref)
			main.seedifneeded(npc)
			int monog = main.getMonogamyDesireStat(npc)

			if main.IsPlayerSpouse(npc) || main.AlwaysAllowNakadashi()
				;it's fine do nothing
			else
				if !main.IsOkToEjaculateInside(npc) ;todo test
					if ostim.ChanceRoll(10) ; didn't notice
						debug.Notification(npc.GetDisplayName() + " didn't notice you cumming inside her")
						return
					endif 

					if main.isPlayerPartner(npc)
						playerCameInsidePussy = true
						int dislike = (((monog / 10) - 10) * -1)
						main.increasedislikestat(npc, dislike)
						if ostim.ChanceRoll(50)
							main.increasehatestat(npc, 2)
						endif 
						main.oui.FireSuccessIncidcator(1)
					else 
						playerCameInsidePussy = true
						int dislike = (((monog / 10) - 10) * -1) + 15
						main.increasedislikestat(npc, dislike)
						main.increasehatestat(npc, 2)
						main.oui.FireSuccessIncidcator(1)
					endif
				endif

			endif 

		endif 
	endif 
EndEvent

bool playerCameInsidePussy
Event OstimStart(string eventName, string strArg, float numArg, Form sender)
	SendModEvent("oromance_sexthread")
	hadOrgasmRelIncrease = false
	playerCameInsidePussy = false
	if iskiss 

		Utility.Wait(1.5)
		
		; Disable the Nav menu
		OStim.HideAllSkyUIWidgets()
	
		ostim.WarpToAnimation(startinganim + "+01Km")

		Utility.Wait(Utility.RandomInt(6, 9))

		ostim.WarpToAnimation(kissanim + "+01Kx")

		Utility.Wait(1)

		ostim.endanimation()

		ostim.ShowAllSkyUIWidgets()
	elseif prostitutionType != 1
		ostim.HideNavMenu()
	endif 

	if ostim.IsSceneAggressiveThemed()
		actor ag = ostim.GetAggressiveActor()
		if ag == playerref 
			actor vic = ostim.GetSexPartner(playerref)

			main.increasedislikestat(vic, 30)
			main.increasehatestat(vic, utility.randomint(1, 30))

			main.oui.FireSuccessIncidcator(1)
		endif 
	else 
		if ostim.IsActorActive(playerref)
			actor partner = ostim.GetSexPartner(playerref)

			if partner.GetRelationshipRank(playerref) == 0
				partner.SetRelationshipRank(playerref, 1)
				Utility.Wait(2)
				main.oui.FireSuccessIncidcator(0)
			endif 
		endif 
	endif 
EndEvent

Event ORomanceAsync(string eventName, string strArg, float numArg, Form sender)

	console("ORomance async thread running")
	Utility.Wait(2)

	
	while ostim.AnimationRunning()
		if ostim.IsActorActive(playerref)
			CheckForPlayerPartners()
			if main.ismarried(ostim.GetSexPartner(playerref))
				CheckForNPCSpouses(ostim.GetSexPartner(playerref))
			endif 
		endif 

		Utility.wait(5)
	endwhile
EndEvent

function CheckForPlayerPartners()
	actor[] acts
	int i = 0
	int l 
	acts = MiscUtil.ScanCellNPCs(playerref, 1280)

		;console("Nearby actors: " + acts.length)

		l = acts.length 
		i = 0

		actor npc
		while i < acts.Length
			npc = acts[i]
			if main.isPlayerPartner(npc)
				if playerref.IsDetectedBy(npc) && !ostim.isactoractive(npc) && ostim.AnimationRunning()
				;console("Player is detected by npc: " + npc.getdisplayname())
				
						;uh-oh
						if ostim.IsSceneAggressiveThemed() && (ostim.getsexpartner(ostim.GetAggressiveActor()) == playerref)
							if ostim.AnimationRunning()
								npc.StartCombat(ostim.GetAggressiveActor())
							endif
						else 
							if ostim.AnimationRunning()
								main.catchplayercheating(npc)
							endif 
						endif
				endif 
			endif

			i += 1 
		endwhile
EndFunction

function CheckForNPCSpouses(actor mainNPC)
	actor[] acts
	int i = 0
	int l 
	acts = MiscUtil.ScanCellNPCs(playerref, 1280)

		;console("Nearby actors: " + acts.length)

		l = acts.length 
		i = 0

		actor npc
		while i < acts.Length
			npc = acts[i]
			if main.IsNPCSpouse(mainNPC, npc)
				;console("is sposu")
				if playerref.IsDetectedBy(npc)
					;console("Starting combat")
					main.oui.FireSuccessIncidcator(1)
					actor a = ostim.GetSexPartner(mainnpc)
					npc.StartCombat(a)
					main.increasedislikestat(a, 10)
					main.increasehatestat(a, 10)
				endif 
			endif

			i += 1 
		endwhile

endfunction 

Event OstimEnd(string eventName, string strArg, float numArg, Form sender)
	if isKiss
		; Enable the controls
		OStim.DisableOSAControls = false
	
		; Restore the previous settings
		OStim.UseAIControl = bUseAIControl
		ostim.UseAINonAggressive = bUseAIControl
		OStim.AlwaysUndressAtAnimStart = bAlwaysUndressAtAnimStart
		OStim.UseBed = bUseBed
		OStim.UseFreeCam = bUseFreeCam
		ostim.EnableDomBar = bEnableDomBar
		ostim.EnableSubBar = bEnableSubBar


	endif 

	if prostitutionType != 1
		; Enable the controls
		OStim.DisableOSAControls = false

		OStim.UseAIControl = bUseAIControl
		ostim.UseAINonAggressive = bUseAIControl
		OStim.AlwaysUndressAtAnimStart = bAlwaysUndressAtAnimStart
		ostim.AutoUndressIfNeeded = bAutoUndressIfNeeded

	endif 
	if playerCameInsidePussy && !ostim.IsSceneAggressiveThemed()
		actor a = ostim.GetSexPartner(playerref)
		Utility.Wait(2)
		string adjective
		if main.getdislikeStat(a) as int > 19
			adjective = "angry"
		else 
			adjective = "displeased"
		endif
		debug.Notification(a.GetDisplayName() + " is " + adjective + " because you came inside her")
	endif 

	isKiss = false
	prostitutionType = 1
EndEvent 


string function GetRandomAnimationByClass(string cclass)
	ODatabaseScript odatabase = ostim.GetODatabase()

	Int Animations = ODatabase.GetAnimationsWithActorCount(ODatabase.GetDatabaseOArray(), 2)
	Animations = ODatabase.GetHubAnimations(Animations, False)
	Animations = ODatabase.GetTransitoryAnimations(Animations, False)

	animations = odatabase.GetAnimationsWithAnimationClass(animations, cclass)

	int l = odatabase.GetLengthOArray(animations)

	int ret = odatabase.GetObjectOArray(animations, utility.randomint(0, l - 1))

	Return odatabase.GetSceneID(ret)
endfunction

function console(string in)
	main.console(in)
EndFunction