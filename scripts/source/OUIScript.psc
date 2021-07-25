ScriptName OUIScript Extends Quest

iWant_Widgets Property iWidgets Auto


;https://www.flaticon.com/packs/basic-ui-3?word=interface&k=1617571564791
;https://www.flaticon.com/packs/human-body-13?word=body
;https://www.flaticon.com/free-icon/gift_726532?term=present&page=1&position=4&page=1&position=4&related_id=726532&origin=search
;https://www.flaticon.com/free-icon/speech-bubble_2462844?term=speech%20bubble&page=1&position=4&page=1&position=4&related_id=2462844&origin=style
;flaticon.com/free-icon/forbidden_2001386?term=cancel&page=1&position=15&page=1&position=15&related_id=2001386&origin=search
;https://www.flaticon.com/free-icon/anger_599507?term=anger%20symbol&page=1&position=1&page=1&position=1&related_id=599507&origin=search
;https://www.flaticon.com/free-icon/rotate_815456?term=loading%20circle&page=1&position=11&page=1&position=11&related_id=815456&origin=search

int SlotCenter
int SlotLeftMiddle
int SlotRightMiddle

int SlotQuarter 
int SlotQuarterSecond
int SlotQuarterThird
int SlotQuarterFourth

int SlotLeftFar
int SlotLeftClose
int SlotRightClose
int SlotRightFar

ORPage PageMain
ORPage PageRomance
ORPage PageInteract
ORPage PageInquire
ORPage PageRelationship
ORPage PageSolicit
ORPage PageSolicitSpecific
ORPage PageTalk
ORPage PageApologize
ORPage PageStartSex

Vector_Form property pages auto

ORPage CurrentPage

ORUIManager manager

int leftKey
int rightKey
int SelectKey
int ExitKey

int[] colorRed
int[] colorLightRed
int[] colorBlue
int[] colorGreen
int[] colorPink
int[] colorYellow
int[] colorWhite

string TextFont = "$EverywhereFont"

actor property playerref auto

actor property npc auto

string name
string gfbf

ReferenceAlias property PlayerFollowerAlias auto
ReferenceAlias property WaitAlias auto

ReferenceAlias property PlayerFollowerLongAlias auto
ReferenceAlias property PlayerFollowerLongAliasTwo auto

;package property FollowerPackage auto 
;package property WaitPackage

ORomanceScript main

bool property UIOpen auto

bool property iconShadows auto

bool followerIsInProstitutionContext 


int prostitutionType
int prostitutionCost

bool isProstitute 
int baseCost
int vaginalCost

bool firstOpen

bool ShownFollowHint


Function EnterDialogueWith(actor act, ORPage page = none)
	main.bridge.ostim.PlayTickBig()
	npc = act 
	firstOpen = true
	uiopen = true
	;playerref.SetDontMove(true)
	game.DisablePlayerControls(false, false, false, false, false, true, abActivate = true,  abJournalTabs = false, aiDisablePOVType = 0)
	SendModEvent("oromance_followthread")
	SendModEvent("oromance_healththread")

	name = OSANative.GetDisplayName(npc)
	if main.bridge.ostim.AppearsFemale(npc)
		gfbf = "girlfriend"
	else 
		gfbf = "boyfriend"
	endif 

	ShowName()

	if CacheRebuild
		CacheRebuild = False
		manager.CallEvent("RebuildPages")
	endif 

	isProstitute = main.isProstitute(npc)
	if isProstitute
		baseCost = main.getPrositutionCost(npc)
		if main.isvirgin(npc)
			vaginalCost = baseCost * 3
		else 
			vaginalCost = baseCost
		endif 
	endif 

	if page != None
		ShowPage(page)
	elseif (act == follower1)
		showpage(PageStartSex)
	elseif main.getdislikeStat(npc) > 19
		ShowPage(PageApologize)
	else 
		if main.bridge.ostim.chanceroll(75)
			main.SayTopic(npc, main.hello)
		endif 
		ShowPage(pagemain)
	endif 
EndFunction

Function BuildPages()
	console("Building pages...")
	main.bridge.ostim.Profile()

	manager.Destroy()
	manager = oruimanager.NewObject()
	pages.DestroyAll()
	pages = Vector_Form.NewObject()
	orpage page


	page = orpage.NewObject(3)

	page.addbutton("ecks", colorlightred, "Exit")
	page.addbutton("heart", colorPink, "Romance")
	page.addbutton("dot", colorBlue, "Interact")

	pages.push_back(page)
	PageMain = page 


	page = orpage.NewObject(3) ;special

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("heart", colorRed, "Try to seduce")
	page.addbutton("lips", colorRed, "Try to kiss")

	pages.push_back(page)
	PageRomance = page


	page = orpage.NewObject(5) 

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("question", colorGreen, "Inquire")
	page.addbutton("ring", colorBlue, "Relationship")
	page.addbutton("gift", colorYellow, "Give gift")
	page.addbutton("speech1", colorPink, "Say")

	pages.push_back(page)
	PageInteract = page


	page = orpage.NewObject(3)

	page.addbutton("ecks", colorlightred, "Exit")
	page.addbutton("heart", colorRed, "Have sex")
	page.addbutton("cancel", colorRed, "Cancel Sex")

	pages.push_back(page)
	PageStartSex = page


	page = orpage.NewObject(4)

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("question", colorPink, "Ask about sexual experience")
	page.addbutton("question", colorYellow, "Ask about current relationships")
	page.addbutton("question", colorBlue, "Ask about sexuality")


	pages.push_back(page)
	PageInquire = page


	page = orpage.NewObject(2) 

	page.addbutton("ecks", colorlightred, "Exit")
	page.addbutton("anger", colorRed, "Apologize")

	pages.push_back(page)
	PageApologize = page


	page = orpage.NewObject(3) ; special

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("speech1", colorGreen, "Compliment ")
	page.addbutton("speech1", colorYellow, "Insult ")


	pages.push_back(page)
	PageTalk = page


	page = orpage.NewObject(3) ;special 

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("heartring", colorRed, "Confess love")
	page.addbutton("marry", colorYellow, "Propose marriage")


	pages.push_back(page)
	PageRelationship = page

	page = orpage.NewObject(2) ;special 

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("coin", colorYellow, "Solicit")


	pages.push_back(page)
	PageSolicit = page



	page = orpage.NewObject(4) ; special

	page.addbutton("arrow", colorlightred, "Back")
	page.addbutton("vagina", colorPink, "Vaginal/anything")
	page.addbutton("hand", colorPink, "Hand job")
	page.addbutton("lips", colorPink, "Blow job")


	pages.push_back(page)
	PageSolicitSpecific = page



	console("Pages built")
	main.bridge.ostim.Profile("Page building")
endfunction

Function ExitDialogue(int waitTime = 2)
	uiopen = false
	

	game.EnablePlayerControls()

	DeleteName()
	ExitUI()

	Utility.Wait(waittime)
	SetAsFollower(npc, false)
	SetAsWaiting(npc, false)

EndFunction


function FireSuccessIncidcator(int type)
	int handle = ModEvent.Create("oromance_success")

	ModEvent.PushInt(handle, type)


	ModEvent.Send(handle)
endfunction 


function SayNo()
	if main.bridge.ostim.chanceroll(65)
		main.SayTopic(npc, main.nah)
	endif 
endfunction


Int nameX = 640
int nameY = 660
Event SuccessIndicatorThread(int type) 

	string icon
	int[] color
	sound soundz

	if type == 0
		icon = "heart"
		color = colorPink
		soundz = main.success
	elseif type == 1
		icon = "anger"
		color = colorLightRed
		soundz = main.fail
	elseif type == 2
		icon = "ecks"
		color = colorRed 
	endif 

	Int Indicator = iWidgets.loadLibraryWidget(icon)
	iWidgets.setRGB(Indicator, color[0], color[1], color[2])
	iWidgets.setSize(Indicator, size/6, size/6)
	iWidgets.setPos(Indicator, nameX, nameY - 10)
	iwidgets.setTransparency(Indicator, 100)
	iWidgets.setVisible(Indicator)
	float time = 0.5

	iwidgets.doTransitionByTime(Indicator,  nameY - 40,  seconds = time,  targetAttribute = "y",  easingClass = "strong",  easingMethod = "out",  delay = 0.0)
	main.bridge.ostim.PlaySound(playerref, soundz)
	Utility.Wait(time)

	Utility.Wait(time/2)

	iwidgets.doTransitionByTime(Indicator,  0,  seconds = time,  targetAttribute = "alpha",  easingClass = "none",  easingMethod = "none",  delay = 0.0)
	Utility.wait(time)

	iwidgets.destroy(Indicator)
EndEvent

Event HealthMonitorThread(String EventName, String zAnimation, Float NumArg, Form Sender)
	;console("Health monitor thread")

	Utility.Wait(5)

	while UIOpen
		if npc.IsDead()
			ExitDialogue(0)
			return
		EndIf

		if playerref.GetDistance(npc) > (384)
			ExitDialogue(0)
			return
		EndIf

		if npc.IsInCombat()
			ExitDialogue(0)
			return
		endif

		Utility.Wait(1)
	EndWhile

EndEvent

Event FollowerSetThread(String EventName, String zAnimation, Float NumArg, Form Sender)
	;console("Follower set thread")

	npc.SetLookAt(playerref, abPathingLookAt = false)
	npc.SetExpressionOverride(5, 100)

	float distance = npc.GetDistance(playerref)
	utility.wait(0.1)
	if npc.GetDistance(playerref) != distance
		SetAsFollower(npc, true)
		
		float lastDistance

		while distance != lastDistance
			lastDistance = distance 
			distance = npc.GetDistance(playerref)

			Utility.Wait(0.5)
		endwhile 
		SetAsFollower(npc, false)
		SetAsWaiting(npc, true)
	else 
		SetAsWaiting(npc, true)
	endif
	
EndEvent

function SetAsFollower(actor act, bool set) ; follower in literal sense, not combat ally
	if set
		PlayerFollowerAlias.ForceRefTo(act)
		console("Setting follower")
	Else
		PlayerFollowerAlias.clear()

		console("Unsetting follower")
	endif

	npc.EvaluatePackage()
EndFunction

function SetAsWaiting(actor act, bool set) ; follower in literal sense, not combat ally
	if set
		WaitAlias.ForceRefTo(act)
		console("Setting waiter")
	Else
		WaitAlias.clear()

		console("Unsetting waiter")
	endif

	npc.EvaluatePackage()
EndFunction

actor follower1
actor follower2

bool function PlayerIsFollowed()
	return (follower1 != none)
endfunction 

function SetAsLongTermFollower(actor act, bool set, int alia = 1) ; follower in literal sense, not combat ally
	if !ShownFollowHint
		ShownFollowHint = true 
		debug.Notification(act.getdisplayname() + " will follow you")
	endif 

	ReferenceAlias al 
	if alia == 1
		al = PlayerFollowerLongAlias
	elseif alia == 2
		al = PlayerFollowerLongAliasTwo
	endif 

	if set
		al.ForceRefTo(act)
		console("Setting long-term follower")
		if alia == 1
			follower1 = act
		elseif alia == 2
			follower2 = act
		endif 
	Else
		al.clear()

		console("Unsetting long-term follower")
		if alia == 1
			follower1 = none
		elseif alia == 2
			follower2 = none
		endif 
	endif

	npc.EvaluatePackage()

EndFunction


function Startup()  
	;debug.messagebox("ui online")

	UIOpen = false

	ShownFollowHint = false 

	iconshadows = true

	iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esl") as iwant_widgets

	if iWidgets == None
		iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esp") as iwant_widgets
		if iWidgets == None
			debug.MessageBox("ORomance: iWant Widgets is not installed, install failed. Please exit now and reread the requirements page")
		endif
	endif 


	main = ((self as quest) as ORomanceScript)

	PlayerFollowerAlias = (self as quest).GetAliasById(0) as ReferenceAlias
	WaitAlias = (self as quest).GetAliasById(1) as ReferenceAlias

	PlayerFollowerLongAlias = (self as quest).GetAliasById(2) as ReferenceAlias
	PlayerFollowerLongAliasTwo = (self as quest).GetAliasById(3) as ReferenceAlias

	if PlayerFollowerAlias == none 
		debug.MessageBox("alias load failure")
	endif
	
	slotCenter = 1
	SlotRightMiddle = 2
	SlotLeftMiddle = 3

	playerref = game.GetPlayer()





	prostitutionType = -1
	prostitutionCost = -1
	
	SlotQuarter = 4
	SlotQuarterSecond = 5
	SlotQuarterThird = 6
	SlotQuarterFourth = 7

	slotleftfar = 8
	slotleftclose = 9
	slotrightclose = 10
	slotrightfar = 11

	
	

	colorRed = new int[3]
	colorRed[0] = 110
	colorRed[1] = 3
	colorRed[2] = 0

	colorWhite = new int[3]
	colorWhite[0] = 255
	colorWhite[1] = 255
	colorWhite[2] = 255

	colorLightRed = new int[3]
	colorLightRed[0] = 128
	colorLightRed[1] = 0
	colorLightRed[2] = 33

	colorPink = new int[3]
	colorPink[0] = 119
	colorPink[1] = 6
	colorPink[2] = 54

	colorGreen = new int[3]
	colorGreen[0] = 62
	colorGreen[1] = 162
	colorGreen[2] = 90

	colorBlue = new int[3]
	colorBlue[0] = 6
	colorBlue[1] = 73
	colorBlue[2] = 128

	colorYellow = new int[3]
	colorYellow[0] = 188
	colorYellow[1] = 143
	colorYellow[2] = 61

	BuildPages()




	;OnLoad()


	;ShowPage(pagemain)
	

EndFunction 

bool CacheRebuild = false
Function OnLoad()
	uiopen = false
	SelectKey = Input.GetMappedKey("Activate")
	ExitKey = Input.GetMappedKey("Tween Menu")
	
	leftKey = main.GetLeftKey()
	rightKey = main.GetRightKey()


	console(ExitKey)

	RegisterForKey(leftkey)
	RegisterForKey(rightkey)
	RegisterForKey(SelectKey)
	RegisterForKey(ExitKey)

	RegisterForModEvent("oromance_followthread", "FollowerSetThread")
	RegisterForModEvent("oromance_healththread", "HealthMonitorThread")

	RegisterForModEvent("oromance_success", "SuccessIndicatorThread")

	if main.DoCacheRebuilds
		CacheRebuild = true
	
		pages.ResetLooping()
		while pages.Loop()
			(pages.i() as ORPage).built = false
		EndWhile
	endif
	
	;RegisterForModEvent("oromance_render", "RenderElementAsync")
	
EndFunction

Function ExitUI()
	currentpage.hide()
	Utility.Wait(0.5)
EndFunction

Event OnKeyDown(Int KeyPress)

	if !uiopen 
		return 
	endif

	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf
	
	if KeyPress == leftKey

			
			CurrentPage.CursorLeft()

			if main.PlayerHasPsychicPerk(npc)
				UpdateColor()
			endif 
 
	elseif KeyPress == rightKey 
		
			
			CurrentPage.CursorRight()

			if main.PlayerHasPsychicPerk(npc)
				UpdateColor()
			endif 
	elseif KeyPress == SelectKey

		main.bridge.ostim.PlayTickBig()
		ProcessEvent()
	elseif KeyPress == ExitKey
		main.bridge.ostim.PlayTickBig()
		if main.bridge.ostim.chanceroll(50)
			main.SayTopic(npc, main.goodbye)
		endif 
		ExitDialogue(1)
	EndIf
EndEvent

function ProcessEvent()
	orpage page = currentpage
	int element = page.selectedButtonID

	if page == PageMain
		if element == 0
			main.SayTopic(npc, main.goodbye)
			ExitDialogue()
		elseif element == 1
			ShowPage(PageRomance)
		elseif element == 2
			ShowPage(PageInteract)
		endif
	elseif page == PageStartSex
		if element == 0
			ExitDialogue(0)
		elseif element == 1
			main.setLastSeduceTime(npc)
			if prostitutionType == -1
				main.bridge.startscene(playerref, npc)
			else 
				if main.GetPlayerGold() >= prostitutionCost
					ExitUI()
					playerref.removeitem(main.gold, prostitutionCost, false, npc)
					if main.bridge.ostim.chanceroll(25)
						main.SayTopic(npc, main.CoinWheels)
					endif 
					main.bridge.startscene(playerref, npc, sextype = prostitutiontype)
				else 
					FireSuccessIncidcator(1)
					main.increasedislikestat(npc, 2)
					debug.Notification("Insufficient gold")
				endif 
			endif
			ExitDialogue()
			SetAsLongTermFollower(npc, false)
		elseif element == 2
			prostitutionType = -1
			SetAsLongTermFollower(npc, false)
			ExitDialogue(1)
		endif
	elseif page == PageRomance
		if element == 0
			ShowPage(PageMain)
		elseif element == 1
			if main.TrySeduce(npc) ;|| true 
				FireSuccessIncidcator(0)
				prostitutionType = -1
				if main.IsMarried(npc)
					if main.IsSpouseNearby(npc) && (main.getSexDesireStat(npc) < 90)
						debug.Notification(npc.GetDisplayName() + " wants to fuck but their spouse is nearby")
						return 
					endif 
				endif 
				if !main.isPlayerPartner(npc)
					if main.bridge.ostim.chanceroll(50)
						main.SayTopic(npc, main.convinced)
					endif 
				else 
					if main.bridge.ostim.chanceroll(50)
						main.SayTopic(npc, main.accept)
					endif 
				endif 

				if PlayerIsFollowed()
					bool canThreesome = True

					if main.isplayerpartner(npc)
						if main.getMonogamyDesireStat(npc) > 15
							canThreesome = false 
							debug.Notification(npc.GetDisplayName() + " does not want to do a threesome")
							FireSuccessIncidcator(1)
						endif 
					endif 
					if main.isplayerpartner(follower1)
						if main.getMonogamyDesireStat(follower1) > 15
							canThreesome = false 
							debug.Notification(follower1.GetDisplayName() + " does not want to do a threesome")
							FireSuccessIncidcator(1)
						endif 
					endif 

					if canThreesome 
						main.bridge.StartScene(playerref, npc, third = follower1)
					endif 

					ExitDialogue()
					SetAsLongTermFollower(follower1, false)
				else 
					SetAsLongTermFollower(npc, true)
				endif 
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 5)
			endif 
			ExitDialogue()
		elseif element == 2
			if main.Trykiss(npc); || true
				FireSuccessIncidcator(0)
				main.kiss(npc)
				ExitDialogue()
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 5)
				ExitDialogue()
			endif 
		elseif element == 3
			ShowPage(PageSolicit)
		EndIf
	elseif page == PageInteract
		if element == 0
			ShowPage(PageMain)
		elseif element == 1
			ShowPage(PageInquire)
		elseif element == 2
			ShowPage(PageRelationship)
		elseif element == 3
			ExitUI()
			int val = main.gift(npc)
			main.ProcessGift(npc, val)
			ExitDialogue()
		elseif element == 4
			showpage(PageTalk)
		EndIf
	elseif page == PageInquire
		if element == 0
			
		elseif element == 1
			if main.TryInquire(npc)
				FireSuccessIncidcator(0)
				main.InquireSexualExperience(npc)
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 2)
			endif
		elseif element == 2
			FireSuccessIncidcator(0)
			main.InquireRelationshipStatus(npc)
		elseif element == 3
			if main.TryInquire(npc)
				FireSuccessIncidcator(0)
				main.InquireSexuality(npc)
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 2)
			endif
		EndIf

		ShowPage(PageInteract)
	elseif page == PageRelationship
		if element == 0
			ShowPage(PageInteract)
		elseif element == 1
			if !main.isPlayerPartner(npc)
				if main.TryAskOut(npc)
					FireSuccessIncidcator(0)
					debug.Notification(name + "is now your " + gfbf)
					main.setPlayerPartner(npc, true)
					if main.bridge.ostim.chanceroll(50)
						main.kiss(npc)
					endif 
				else 
					SayNo()
					FireSuccessIncidcator(1)
					main.increasedislikestat(npc, 3)
				endif
			else 
				main.BreakUpOrDivorce(npc)
			endif 
		elseif element == 2
			if main.TryPropose(npc) ;|| true 
				FireSuccessIncidcator(0)
				main.Marry(npc)
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 3)
			endif
		EndIf

		if element != 0
			ExitDialogue(5)
		endif 

	elseif page == PageSolicit
		if element == 0
			ShowPage(PageRomance)
		elseif element == 1

			ShowPage(PageSolicitSpecific)
			if main.bridge.ostim.chanceroll(60)
				main.SayTopic(npc, main.howmuch)
			endif 
		EndIf
	elseif page == PageSolicitSpecific
		int playerGold = main.GetPlayerGold()
		int cost = main.getPrositutionCost(npc)
		if element == 0
			ShowPage(PageRomance)
		elseif element == 1
			if main.IsVirgin(npc)
				cost *= 3
			endif 
			if playergold >= (cost)
				FireSuccessIncidcator(0)
				prostitutionType = 1
				prostitutionCost = cost
				if main.bridge.ostim.chanceroll(25)
						main.SayTopic(npc, main.price)
				elseif main.bridge.ostim.chanceroll(50)
						main.SayTopic(npc, main.accept)
				endif 
				SetAsLongTermFollower(npc, true)

			else 
				FireSuccessIncidcator(1)
				debug.Notification("Insufficient gold")
			endif
		elseif element == 2
			if playergold >= (cost * 0.25)
				FireSuccessIncidcator(0)
				prostitutionType = 2
				prostitutionCost = (cost * 0.25) as int
				SetAsLongTermFollower(npc, true)
			else 
				FireSuccessIncidcator(1)
				debug.Notification("Insufficient gold")
			endif
		elseif element == 3
			if playergold >= (cost * 0.5)
				FireSuccessIncidcator(0)
				prostitutionType = 3
				prostitutionCost = (cost * 0.5) as int
				SetAsLongTermFollower(npc, true)
			else 
				FireSuccessIncidcator(1)
				debug.Notification("Insufficient gold")
			endif
		EndIf

		if element != 0
			ExitDialogue()
		endif 
	elseif page == PageApologize
		if element == 0
			ExitDialogue()
		elseif element == 1
			main.TryApology(npc)
			page.selectedbutton.click()
		EndIf
	elseif page == PageTalk
		if element == 0
			
		elseif element == 1
			main.compliment(npc)
		elseif element == 2
			main.insult(npc)
		endif 
		showpage(PageInteract)
	endif 



EndFunction



Function ShowPage(ORPage page)
	if CurrentPage.visible
		CurrentPage.Hide()
		Utility.Wait(0.25)
	endif 
	CurrentPage = page 

	if !CurrentPage.built
		ShowLoadingIcon()
		while !CurrentPage.built
			Utility.Wait(0.5)
			if !uiopen
				HideLoadingIcon()
				return 
			endif
		EndWhile
		HideLoadingIcon()
	endif 

	; special logic for certain pages 

	if page == pageromance 
		if main.IsPlayerSpouse(npc)
			page.setbuttontext(1, "Seduce ")
			page.setbuttontext(2, "Kiss ")

		else 
			page.setbuttontext(2, "Try to kiss")

			if PlayerIsFollowed()
				page.setbuttontext(1, "Invite to threesome")
			else 
				page.setbuttontext(1, "Try to seduce")
			endif 
		endif 

		if isprostitute 
			if page.hasbutton("Prostitution")

			else 
				page.addbutton("coin", colorYellow, "Prostitution", load = true)
				page.RecalculateLayout()
			endif 
		else 
			if page.hasbutton("Prostitution")
				page.removebutton("Prostitution")
				page.RecalculateLayout()
			endif 
		endif 
	elseif page == PageRelationship
		if !main.isPlayerPartner(npc)
			page.setbuttonicon(1, "heartring")
			page.setbuttontext(1, "Confess love")
			page.setbuttonsubtext(1, name + " may become your " + gfbf)
		else 
			page.setbuttonsubtext(1, "")
			if main.IsPlayerSpouse(npc)
				page.setbuttontext(1, "Divorce")
			else 
				page.setbuttontext(1, "Break up")
			endif 
			page.setbuttonicon(1, "cancel")
		endif 


		if !main.IsPlayerMarried()
			if page.hasbutton("Propose marriage")

			else 
				page.addbutton("marry", colorYellow, "Propose marriage", load = true)
				page.RecalculateLayout()
			endif 
		else 
			if page.hasbutton("Propose marriage")
				page.removebutton("Propose marriage")
				page.RecalculateLayout()
			endif 
		endif 
	elseif page == PageSolicit
		page.SetButtonSubtext(1, "Price: " + (baseCost * 0.25) as int + " - " + (vaginalCost) + " septims")

	elseif page == PageSolicitSpecific
		page.SetButtonSubtext(1, vaginalCost + " septims")
		page.SetButtonSubtext(2, (basecost * 0.25) as int + " septims")
		page.SetButtonSubtext(3, (basecost * 0.5) as int + " septims")
	endif 




	CurrentPage.CallEvent("Show")

	if firstOpen
		firstopen = false
	endif

	if main.PlayerHasPsychicPerk(npc)
		UpdateColor()
	endif 
EndFunction

int[] Function GetElementLayoutByElementCount(int count)
	int[] ret = PapyrusUtil.IntArray(count)

	if count == 3
		ret[0] = SlotLeftMiddle
		ret[1] = SlotCenter
		ret[2] = SlotRightMiddle
	elseif count == 4
		ret[0] = SlotQuarter
		ret[1] = SlotQuarterSecond
		ret[2] = SlotQuarterThird
		ret[3] = SlotQuarterFourth

	elseif count == 5
		ret[0] = SlotleftFar
		ret[1] = SlotLeftClose
		ret[2] = slotcenter
		ret[3] = SlotRightClose
		ret[4] = SlotRightFar

	elseif count == 2
		ret[0] = SlotLeftMiddle
		ret[1] = SlotRightMiddle

	endif 

	return ret
EndFunction

int nameelement

Function ShowName()
	nameelement = iWidgets.loadText(name, font = textfont, size = 24 )
	iWidgets.setPos(nameelement, namex, namey)

	iwidgets.setTransparency(nameelement, 0)
	iwidgets.setVisible(nameelement, visible = 1)

	iWidgets.doTransitionByTime(nameelement, 100, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndFunction

int[] currNameColor 
Function SetNameColor(int[] color)
	if color == currNameColor
	;	console("Exiting color change")
		return 
	endif 
	;console("Doing color change")

	if !main.GetColorblindMode()
		iWidgets.setRGB(nameelement, color[0], color[1], color[2])
	else 
		if color == colorlightred 
			SetNameDis(npc.GetDisplayName() + " (no chance)")
		elseif color == colorYellow
			SetNameDis(npc.GetDisplayName() + " (some chance)")
		elseif color == colorGreen 
			SetNameDis(npc.GetDisplayName() + " (high chance)")
		elseif color == colorWhite
			SetNameDis(npc.GetDisplayName())
		endif 

	endif 
	currNameColor = color 
endfunction 

Function SetNameDis(string st)
	iWidgets.setText(nameelement, st)
endfunction

Function UpdateColor()
	if currentpage.selectedbuttonid == 0
		SetNameColor(colorWhite)
	endif 

	if CurrentPage == PageRomance
		if (currentpage.selectedbuttonid == 1)
			
			int NPCSV = main.GetSeductionSV(npc)
			CalcColorBasedOnDiff(npcsv)
		elseif (currentpage.selectedbuttonid == 2)
			int NPCSV = main.GetKissSV(npc)

			CalcColorBasedOnDiff(npcsv)
		else 
			SetNameColor(colorwhite)
		endif

	elseif currentpage == PageRelationship

		if currentpage.selectedbuttonid == 1
			if !main.isPlayerPartner(npc) ; ask out button
				int NPCSV = main.getaskoutSV(npc)
				CalcColorBasedOnDiff(npcsv)
			else ;breakup button 
				SetNameColor(colorwhite)
			endif 
		elseif currentpage.selectedbuttonid == 2 ;marry button
			int NPCSV = main.getmarrysv(npc)
			CalcColorBasedOnDiff(npcsv)
			
		EndIf
	elseif currentpage == PageInquire 
		if (currentpage.selectedbuttonid == 1) || (currentpage.selectedbuttonid == 3)
			if main.TryInquire(npc)
				SetNameColor(colorgreen)
			else 
				SetNameColor(colorlightred)
			endif 
		elseif (currentpage.selectedbuttonid == 2)
			setnamecolor(colorgreen)
		else 
			SetNameColor(colorwhite)
		endif 

	else 
		SetNameColor(colorwhite)
	endif 
endfunction

Function CalcColorBasedOnDiff(int npcSV)
		int playerSV = main.GetPlayerSV()
		int diff = npcsv - playersv 

	;	console(diff)

			if (diff > 60)
				SetNameColor(colorlightred)
			elseif (diff < -60)
				setnamecolor(colorGreen)
			else 
				setnamecolor(colorYellow)
			endif
endfunction

Function DeleteName()
	iwidgets.destroy(nameelement)
EndFunction 




int size = 150




int yOffset = 200
int[] function GetElementCordsBySlot(int slot) 
	int[] coords = new int[2]

	
	if slot == slotCenter 
		coords[0] = (1280/2)
	elseif slot == SlotLeftMiddle
		coords[0] = (1280/2) - (1280/6)
	elseif slot == SlotRightMiddle
		coords[0] = (1280/2) + (1280/6)
	elseif slot == SlotQuarter
		coords[0] = (1280/2) - (1280/4)
	elseif slot == SlotQuarterSecond
		coords[0] = (1280/2) - ((1280/4) / 3)
	elseif slot == SlotQuarterThird
		coords[0] = (1280/2) + ((1280/4) / 3)
	elseif slot == SlotQuarterFourth
		coords[0] = (1280/2) + (1280/4)

	elseif slot == SlotLeftFar
		coords[0] = (1280/2) - (1280/4)
	elseif slot == SlotLeftClose 
		coords[0] = (1280/2) - (1280/8)
	elseif slot == SlotRightClose
		coords[0] = (1280/2) + (1280/8)
	elseif slot == slotRightFar
		coords[0] = (1280/2) + (1280/4)
	endif

	coords[1] =  (720/2) + yOffset
	return coords
EndFunction

function console(string in)
	main.console(in)
EndFunction


function ShowInstalled()
	int msg = iWidgets.loadText("ORomance installed", font = "$EverywhereFont"	)
;	iWidgets.setSize(msg, size, size)
	iWidgets.setPos(msg, (1280/2) , (720/2) + yOffset)
	;iwidgets.setRotation(loading, 5)
	iwidgets.setTransparency(msg, 0)
	iwidgets.setVisible(msg)

	iWidgets.doTransitionByTime(msg, 100, 2, "alpha")
	Utility.Wait(2)

	Utility.Wait(3)

	iWidgets.doTransitionByTime(msg, 0, 3, "alpha")

	Utility.Wait(3)
	iwidgets.destroy(msg)
endfunction

int loading
function ShowLoadingIcon()
	loading = iWidgets.loadLibraryWidget("rotate")
	iWidgets.setSize(loading, size/6, size/6)
	iWidgets.setPos(loading, (1280/2) , (720/2) + yOffset)
	;iwidgets.setRotation(loading, 5)
	iwidgets.setRGB(loading, colorgreen[0], colorgreen[1], colorgreen[2])

	iwidgets.setVisible(loading)

	iWidgets.doTransitionByTime(loading, -12000, 20, "rotation")
endfunction

function HideLoadingIcon()
	iwidgets.setVisible(loading, 0)
	iwidgets.destroy(loading)
endfunction
