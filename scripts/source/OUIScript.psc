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

int PageMain
int PageRomance
int PageInteract
int PageInquire
int PageRelationship
int PageSolicit
int PageSolicitSpecific
int PageTalk
int PageApologize

int PageStartSex

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

bool firstOpen

bool ShownFollowHint


Function EnterDialogueWith(actor act)
	main.bridge.ostim.PlayTickBig()
	npc = act 
	firstOpen = true
	uiopen = true
	;playerref.SetDontMove(true)
	game.DisablePlayerControls(false, false, false, false, false, true, abActivate = true,  abJournalTabs = false, aiDisablePOVType = 0)
	SendModEvent("oromance_followthread")
	SendModEvent("oromance_healththread")

	name = npc.GetDisplayName()
	if main.bridge.ostim.AppearsFemale(npc)
		gfbf = "girlfriend"
	else 
		gfbf = "boyfriend"
	endif 

	ShowName()

	if CacheRebuild
		CacheRebuild = False
		RebuildCache()
	endif 


	if (act == follower1)
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



	PageMain = 1
	PageRomance = 2
	PageInteract = 3
	PageInquire = 4
	PageSolicit = 5
	PageSolicitSpecific = 7
	PageRelationship = 6
	PageStartSex = 8
	PageTalk = 9
	PageApologize = 10

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

	ClearCache()

	ReInitElementStorage()

	;OnLoad()


	;ShowPage(pagemain)
	

EndFunction 

bool CacheRebuild = false
Function OnLoad()
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
	else 
		ClearCache()
	endif
	
	;RegisterForModEvent("oromance_render", "RenderElementAsync")
	
EndFunction

function ClearCache()

	TextWidgetkeys = new String[1]
	TextWidgetkeys[0] = "aaaaaaaaa"
	TextWidgetValues = new Int[1]
	TextWidgetkeys[0] = -1

	CoreWidgetkeys = new String[1]
	CoreWidgetkeys[0] = "aaaaaaaaa"
	CoreWidgetValues = new Int[1]
	CoreWidgetValues[0] = -1

	InitBrackets()

endfunction 

Function ExitUI()
	FadeOutAllElements()
	Utility.Wait(0.5)
	DestroyAllElements()
	ReinitelementStorage()

	currentpage = -1
	selectedelement = -1
EndFunction

Event OnKeyDown(Int KeyPress)

	if !uiopen 
		return 
	endif

	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf
	
	if KeyPress == leftKey
		if selectedElement == 1
			return 
		else 
			main.bridge.ostim.PlayTickSmall()
			DeselectElement(GetElementByID(selectedElement))
			selectedElement -= 1
			SelectElement(GetElementByID(selectedElement))

			if main.PlayerHasPsychicPerk(npc)
				UpdateColor()
			endif 
		endif 
	elseif KeyPress == rightKey 
		if GetElementByID(selectedElement + 1).Length == 1
			return 
		else 
			main.bridge.ostim.PlayTickSmall()
			DeselectElement(GetElementByID(selectedElement))
			selectedElement += 1
			SelectElement(GetElementByID(selectedElement))

			if main.PlayerHasPsychicPerk(npc)
				UpdateColor()
			endif 
		endif 
	elseif KeyPress == SelectKey

		main.bridge.ostim.PlayTickBig()
		ProcessEvent(CurrentPage, selectedElement)
	elseif KeyPress == ExitKey
		if main.bridge.ostim.chanceroll(50)
			main.SayTopic(npc, main.goodbye)
		endif 
		ExitDialogue(1)
	EndIf
EndEvent

function ProcessEvent(int page, int element)
	if page == PageMain
		if element == 1
			main.SayTopic(npc, main.goodbye)
			ExitDialogue()
		elseif element == 2
			ShowPage(PageRomance)
		elseif element == 3
			ShowPage(PageInteract)
		endif
	elseif page == PageStartSex
		if element == 1
			ExitDialogue(0)
		elseif element == 2
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
		elseif element == 3
			prostitutionType = -1
			SetAsLongTermFollower(npc, false)
			ExitDialogue(1)
		endif
	elseif page == PageRomance
		if element == 1
			ShowPage(PageMain)
		elseif element == 2
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
		elseif element == 3
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
		elseif element == 4
			ShowPage(PageSolicit)
		EndIf
	elseif page == PageInteract
		if element == 1
			ShowPage(PageMain)
		elseif element == 2
			ShowPage(PageInquire)
		elseif element == 3
			ShowPage(PageRelationship)
		elseif element == 4
			ExitUI()
			int val = main.gift(npc)
			main.ProcessGift(npc, val)
			ExitDialogue()
		elseif element == 5
			showpage(PageTalk)
		EndIf
	elseif page == PageInquire
		if element == 1
			
		elseif element == 2
			if main.TryInquire(npc)
				FireSuccessIncidcator(0)
				main.InquireSexualExperience(npc)
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 2)
			endif
		elseif element == 3
			FireSuccessIncidcator(0)
			main.InquireRelationshipStatus(npc)
		elseif element == 4
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
		if element == 1
			ShowPage(PageInteract)
		elseif element == 2
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
		elseif element == 3
			if main.TryPropose(npc) ;|| true 
				FireSuccessIncidcator(0)
				main.Marry(npc)
			else 
				SayNo()
				FireSuccessIncidcator(1)
				main.increasedislikestat(npc, 3)
			endif
		EndIf

		if element != 1
			ExitDialogue(5)
		endif 

	elseif page == PageSolicit
		if element == 1
			ShowPage(PageRomance)
		elseif element == 2

			ShowPage(PageSolicitSpecific)
			if main.bridge.ostim.chanceroll(60)
				main.SayTopic(npc, main.howmuch)
			endif 
		EndIf
	elseif page == PageSolicitSpecific
		int playerGold = main.GetPlayerGold()
		int cost = main.getPrositutionCost(npc)
		if element == 1
			ShowPage(PageRomance)
		elseif element == 2
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
		elseif element == 3
			if playergold >= (cost * 0.25)
				FireSuccessIncidcator(0)
				prostitutionType = 2
				prostitutionCost = (cost * 0.25) as int
				SetAsLongTermFollower(npc, true)
			else 
				FireSuccessIncidcator(1)
				debug.Notification("Insufficient gold")
			endif
		elseif element == 4
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

		if element != 1
			ExitDialogue()
		endif 
	elseif page == PageApologize
		if element == 1
			ExitDialogue()
		elseif element == 2
			main.TryApology(npc)
			clickElement(getelementbyid(element))
		EndIf
	elseif page == PageTalk
		if element == 1
			
		elseif element == 2
			main.compliment(npc)
		elseif element == 3
			main.insult(npc)
		endif 
		showpage(PageInteract)
	endif 



EndFunction

int[] Element1
int[] Element2
int[] Element3
int[] Element4
int[] Element5


int[] function GetElementByID(int id)
	if id == 1
		return element1
	elseif id == 2
		return element2
	elseif id == 3
		return element3
	elseif id == 4
		return element4
	elseif id == 5
		return element5
	else 
		return new int[1]
	endif 
EndFunction

int selectedElement
int CurrentPage
Function ShowPage(int pageID)
	bool prostitute = main.IsProstitute(npc) 


	CurrentPage = pageID
	int elementTotal = 6

	int i = 1
	int max = elementTotal

	while i < max
		DestroyElement(GetElementByID(i))

		i += 1
	EndWhile

	ReInitElementStorage()

	int layoutCount = 3

	if pageID == PageMain
		int[] posData = GetElementLayoutByElementCount(layoutCount)

		Element1 = RenderElement(posData[0], "ecks", colorLightRed, "Exit")
		Element2 = RenderElement(posData[1], "heart", colorPink, "Romance")
		Element3 = RenderElement(posData[2], "dot", colorBlue, "Interact")

	elseif pageid == PageStartSex
		int[] posData = GetElementLayoutByElementCount(layoutCount)

		Element1 = RenderElement(posData[0], "ecks", colorLightRed, "Exit")
		Element2 = RenderElement(posData[1], "heart", colorRed, "Have sex")
		Element3 = RenderElement(posData[2], "cancel", colorRed, "Cancel Sex")
	Elseif pageid == PageRomance
		if prostitute
			layoutCount += 1
		endif 

		string seduce
		string kiss
		if main.IsPlayerSpouse(npc)
			kiss = "Kiss "
			seduce = "Seduce "
		else 
			kiss = "Try to kiss"
			if PlayerIsFollowed()
				seduce = "Invite to threesome"
			else 
				seduce = "Try to seduce"
			endif 

		endif 

		int[] posData = GetElementLayoutByElementCount(layoutCount)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "heart", colorred, seduce)
		Element3 = RenderElement(posData[2], "lips", colorred, kiss)
		


		If prostitute
			Element4 = RenderElement(posData[3], "coin", colorYellow, "Prostituion")
		EndIf

	elseif pageid == PageApologize
		int[] posData = GetElementLayoutByElementCount(layoutCount - 1)

		Element1 = RenderElement(posData[0], "ecks", colorLightRed, "Exit")
		Element2 = RenderElement(posData[1], "anger", colorred, "Apologize")
	Elseif pageid == PageInteract
		int[] posData = GetElementLayoutByElementCount(layoutCount + 2)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "question", colorGreen, "Inquire")
		Element3 = RenderElement(posData[2], "ring", colorBlue, "Relationship")
		Element4 = RenderElement(posData[3], "gift", colorYellow, "Give gift")
		Element5 = RenderElement(posData[4], "speech1", colorPink, "say")

	Elseif pageid == PageInquire
		int[] posData = GetElementLayoutByElementCount(layoutCount + 1)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "question", colorPink, "Ask about sexual experience")
		Element3 = RenderElement(posData[2], "question1", colorYellow, "Ask about current relationships")
		Element4 = RenderElement(posData[3], "question2", colorBlue, "Ask about sexuality")
	Elseif pageid == PageRelationship
		int count = layoutCount
		if main.IsPlayerMarried()
			count -= 1
		endif 
		int[] posData = GetElementLayoutByElementCount(count)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		if !main.isPlayerPartner(npc)
			Element2 = RenderElement(posData[1], "heartring", colorRed, "Confess love", subtextstr=name + " may become your " + gfbf)
		else 
			string a ="Break up"
			if main.IsPlayerSpouse(npc)
				a = "Divorce"
			endif 

			Element2 = RenderElement(posData[1], "cancel", colorRed, a)
		endif
		
		if !main.IsPlayerMarried()
			Element3 = RenderElement(posData[2], "marry", colorYellow, "Propose marriage")
		endif
	Elseif pageid == PageSolicit
		int cost = main.getPrositutionCost(npc)
		debug.Notification("You have " + main.GetPlayerGold() + " gold")
		int[] posData = GetElementLayoutByElementCount(layoutCount - 1)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "coin", colorYellow, "Solicit", subtextstr="Price: " + (cost * 0.25) as int + " - " + (cost) + " septims")

	Elseif pageid == PageSolicitSpecific
		int cost = main.getPrositutionCost(npc)

		int[] posData = GetElementLayoutByElementCount(layoutCount + 1)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "vagina", colorPink, "Vaginal/anything", subtextstr=cost + " septims")
		Element3 = RenderElement(posData[2], "hand", colorPink, "Hand job", subtextstr= (cost * 0.25) as int + " septims")
		Element4 = RenderElement(posData[3], "lips", colorPink, "Blow job", subtextstr= (cost * 0.5) as int + " septims")
		
	Elseif pageid == PageTalk
		int[] posData = GetElementLayoutByElementCount(layoutCount)

		Element1 = RenderElement(posData[0], "arrow", colorLightRed, "Back")
		Element2 = RenderElement(posData[1], "speech1", colorGreen, "Compliment ")
		Element3 = RenderElement(posData[2], "speech2", colorYellow, "Insult ")
	EndIf

	selectedElement = 2

	i = 1

	while i < max
		DeselectElement(GetElementByID(i))

		i += 1
	EndWhile


	SelectElement(GetElementByID(selectedElement))

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

Function DestroyElement(int[] element)
	int i = 0
	int l = Element.Length

	while i < l
		if (Element.Length != 1)
			if (i != 2) && (i != 0) && (i != 1)
				iWidgets.Destroy(Element[i])
			elseif (i == 2) || (i == 1)
				iwidgets.setVisible(element[i], 0)
			elseif i == 0
				HideUIBracket(element[i])
			endif 
		EndIf

		i += 1
	EndWhile
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
	if selectedElement == 1
		SetNameColor(colorWhite)
	endif 

	if CurrentPage == PageRomance
		if (selectedElement == 2)
			
			int NPCSV = main.GetSeductionSV(npc)
			CalcColorBasedOnDiff(npcsv)
		elseif (selectedelement == 3)
			int NPCSV = main.GetKissSV(npc)

			CalcColorBasedOnDiff(npcsv)
		else 
			SetNameColor(colorwhite)
		endif

	elseif currentpage == PageRelationship

		if selectedelement == 2
			if !main.isPlayerPartner(npc) ; ask out button
				int NPCSV = main.getaskoutSV(npc)
				CalcColorBasedOnDiff(npcsv)
			else ;breakup button 
				SetNameColor(colorwhite)
			endif 
		elseif selectedelement == 3 ;marry button
			int NPCSV = main.getmarrysv(npc)
			CalcColorBasedOnDiff(npcsv)
			
		EndIf
	elseif currentpage == PageInquire 
		if (selectedelement == 2) || (selectedElement == 4)
			if main.TryInquire(npc)
				SetNameColor(colorgreen)
			else 
				SetNameColor(colorlightred)
			endif 
		elseif (selectedelement == 3)
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

function DeselectElement(int[] element)

	iwidgets.setSize(element[0], (size * 0.75) as int, (size * 0.75) as int)
	iwidgets.setSize(element[1], ((size/4) * 0.75) as int, ((size/4) * 0.75) as int)


	iWidgets.doTransitionByTime(Element[0], 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(Element[1], 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(Element[2], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(Element[3], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndFunction

function SelectElement(int[] element)
	iwidgets.setSize(element[0], size , size)
	iwidgets.setSize(element[1], (size/4), (size/4))

	int i = 0
	int l = Element.Length

	while i < l
		iWidgets.doTransitionByTime(Element[i], 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
		

		i += 1
	EndWhile
EndFunction


int size = 150

int[] Function RenderElement(int slot, string icon, int[] color, string Textstr, string subtextstr = "", bool subtextIsDialogue = false) 
	

	


	;Int Bracket = iWidgets.loadLibraryWidget("uibracket")
	Int Bracket = GetUIBracket()
	iWidgets.setSize(Bracket, size, size)
	int[] coords = GetElementCordsBySlot(slot)
	iWidgets.setPos(Bracket, coords[0] , coords[1])

;	float time = game.GetRealHoursPassed() * 60 * 60
	
	int core = GetCoreWidget(icon)
	iWidgets.setSize(core, size/4, size/4)
	iWidgets.setPos(core, coords[0] , coords[1])
	iWidgets.setRGB(core, color[0], color[1], color[2])

;	OsexIntegrationMain.Console((game.GetRealHoursPassed() * 60 * 60) - time)

	;int text = iWidgets.loadText(Textstr, font = textfont, size = 24 )
	int text = GetTextWidget(textstr, 24)
	iWidgets.setPos(text, coords[0] , coords[1] - 45)

	int subtext
	if subtextstr != ""
		subtext = iWidgets.loadText(subtextstr, font = textfont, size = 18 )
		iWidgets.setPos(subtext, coords[0] , coords[1] + 30)
		if subtextIsDialogue
			iWidgets.setRGB(subtext, 255, 255, 255)
		else 
			iWidgets.setRGB(subtext, 181, 181, 181)
		EndIf
	else 
		subtext = -1
	endif 
	
	
	


	iwidgets.setTransparency(bracket, 0)
	iwidgets.setTransparency(core, 0)
	iwidgets.setTransparency(text, 0)
	iwidgets.setTransparency(subtext, 0)

	iWidgets.setVisible(Bracket)
	iWidgets.setVisible(core)
	iWidgets.setVisible(text)
	iWidgets.setVisible(subtext)


	int[] Element = new int[4]
	Element[0] = Bracket
	Element[1] = core
	Element[2] = text
	Element[3] = subtext

	


	return Element
EndFunction

Function FadeElementIn(int[] Element)
	int i = 0
	int l = Element.Length

	while i < l
		iWidgets.doTransitionByTime(Element[i], 100, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)

		i += 1
	EndWhile
EndFunction

Function FadeElementOut(int[] Element)
	int i = 0
	int l = Element.Length

	while i < l
		iWidgets.doTransitionByTime(Element[i], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)

		i += 1
	EndWhile
EndFunction

Function clickElement(int[] Element)
	iwidgets.setSize(element[0], (size * 0.75) as int, (size * 0.75) as int)
	iwidgets.setSize(element[1], ((size/4) * 0.75) as int, ((size/4) * 0.75) as int)

	Utility.Wait(0.1)

	iwidgets.setSize(element[0], (size) as int, (size ) as int)
	iwidgets.setSize(element[1], ((size/4)) as int, ((size/4) ) as int)
EndFunction

function FadeOutAllElements()
	int i = 0
	int max = 6

	while i < max 
		int[] element = GetElementByID(i)

		If element.length != 1
			FadeElementOut(element)
		EndIf
		i += 1
	EndWhile
EndFunction

function DestroyAllElements()
	int i = 0
	int max = 6

	while i < max 
		int[] element = GetElementByID(i)

		If element.length != 1
			DestroyElement(element)
		EndIf
		i += 1
	EndWhile
EndFunction

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

Function ReInitElementStorage()
	Element1 = new Int[1]
	Element2 = Element1
	Element3 = Element1
	Element4 = Element1
	Element5 = Element1
EndFunction


string[] TextWidgetkeys
int[] TextWidgetValues


int Function GetTextWidget(string widgettxt, int sizes)
	if main.bridge.ostim.StringArrayContainsValue(TextWidgetkeys, widgettxt)
		int z
		Int i = 0
		Int L = TextWidgetkeys.Length
		While (i < L)
			If (TextWidgetkeys[i] == widgettxt)
				z = i
				i = L
			EndIf
			i += 1
		EndWhile

		;console("Cached text found: " + TextWidgetKeys[z])
		iWidgets.setTransparency(TextWidgetValues[z], 0)
		return TextWidgetValues[z]

	else 
		;console("No cache found, making new...")
		int wid = iWidgets.loadText(widgettxt, font = textfont, size = sizes )

		TextWidgetkeys = PapyrusUtil.PushString(TextWidgetkeys, widgettxt)
		TextWidgetValues = PapyrusUtil.Pushint(TextWidgetValues, wid)

		if TextWidgetkeys.length > 60
			console("Warning, widget cache is: " + TextWidgetkeys.length)
			console("memory leak?")
		endif 

		return wid

	EndIf

EndFunction

function console(string in)
	main.console(in)
EndFunction





Function SendAsyncRender(int slot, string icon, int[] color, string Textstr, int elementID, string subtextstr = "", bool subtextIsDialogue = false)
	int handle = ModEvent.Create("oromance_render")

	;ModEvent.PushForm(handle, self)
	ModEvent.PushInt(handle, slot)
	ModEvent.PushString(handle, icon)
	ModEvent.PushInt(handle, 0)
	ModEvent.PushString(handle, textstr)
	ModEvent.PushInt(handle, elementID)
	ModEvent.PushString(handle, subtextstr)
	ModEvent.PushBool(handle, subtextIsDialogue)

	ModEvent.Send(handle)
EndFunction

Event RenderElementAsync(int slot, string icon, int color, string Textstr, int elementID, string subtextstr, bool subtextIsDialogue)
	float time = game.GetRealHoursPassed() * 60 * 60

	


	Int Bracket = iWidgets.loadLibraryWidget("uibracket")
	iWidgets.setSize(Bracket, size, size)
	int[] coords = GetElementCordsBySlot(slot)
	iWidgets.setPos(Bracket, coords[0] , coords[1])


	int core = iWidgets.loadLibraryWidget(icon)
	iWidgets.setSize(core, size/4, size/4)
	iWidgets.setPos(core, coords[0] , coords[1])
	;iWidgets.setRGB(core, color[0], color[1], color[2])

	int text = iWidgets.loadText(Textstr, font = "$EverywhereFont", size = 24 )
	iWidgets.setPos(text, coords[0] , coords[1] - 45)

	int subtext
	if subtextstr != ""
		subtext = iWidgets.loadText(subtextstr, font = "$EverywhereFont", size = 18 )
		iWidgets.setPos(subtext, coords[0] , coords[1] + 30)
		if subtextIsDialogue
			iWidgets.setRGB(subtext, 255, 255, 255)
		else 
			iWidgets.setRGB(subtext, 181, 181, 181)
		EndIf
	else 
		subtext = -1
	endif 
	
	
	;OsexIntegrationMain.Console((game.GetRealHoursPassed() * 60 * 60) - time)


	iwidgets.setTransparency(bracket, 0)
	iwidgets.setTransparency(core, 0)
	iwidgets.setTransparency(text, 0)
	iwidgets.setTransparency(subtext, 0)

	iWidgets.setVisible(Bracket)
	iWidgets.setVisible(core)
	iWidgets.setVisible(text)
	iWidgets.setVisible(subtext)


	int[] Element = new int[4]
	Element[0] = Bracket
	Element[1] = core
	Element[2] = text
	Element[3] = subtext

	if elementID == 1
		element1 = Element
	elseif elementID == 2
		element2 = Element
	elseif elementID == 3
		element3 = Element
	elseif elementID == 4
		element4 = Element
	;elseif elementID == 5
	;	element5 = Element
	EndIf

EndEvent

function WaitForAsyncRender(int elementcount)
	bool done = false 

	while !done 
		int doneCount = 0
		int i = elementcount

		while i != 0
			if GetElementByID(i).Length > 1
				doneCount += 1
			endif 

			i -= 1
		EndWhile

		if doneCount == elementcount
			done = true 
		endif 
		Utility.Wait(0.1)
	EndWhile

EndFunction

int bracket1 
int bracket2 
int bracket3 
int bracket4 
int bracket5 

bool bracket1visible
bool bracket2visible
bool bracket3visible
bool bracket4visible
bool bracket5visible

int function GetUIBracket()
	if !bracket1visible
		bracket1visible = true
		return bracket1
	elseif !bracket2visible
		bracket2visible = true
		return bracket2
	elseif !bracket3visible
		bracket3visible = true
		return bracket3
	elseif !bracket4visible
		bracket4visible = true
		return bracket4
	elseif !bracket5visible
		bracket5visible = true
		return bracket5
	endif

endfunction

function HideUIBracket(int bracket)
	if bracket == bracket1  
		iwidgets.setVisible(bracket, 0)
		bracket1visible = false
	elseif bracket == bracket2 
		iwidgets.setVisible(bracket, 0)
		bracket2visible = false
	elseif bracket == bracket3 
		iwidgets.setVisible(bracket, 0)
		bracket3visible = false
	elseif bracket == bracket4 
		iwidgets.setVisible(bracket, 0)
		bracket4visible = false
	elseif bracket == bracket5 
		iwidgets.setVisible(bracket, 0)
		bracket5visible = false
	endif

endfunction

function InitBrackets()
	bracket1 = iWidgets.loadLibraryWidget("uibracket")
	iwidgets.setVisible(bracket1, 0)
	bracket1visible = false

	bracket2 = iWidgets.loadLibraryWidget("uibracket")
	iwidgets.setVisible(bracket2, 0)
	bracket2visible = false

	bracket3 = iWidgets.loadLibraryWidget("uibracket")
	iwidgets.setVisible(bracket3, 0)
	bracket3visible = false

	bracket4 = iWidgets.loadLibraryWidget("uibracket")
	iwidgets.setVisible(bracket4, 0)
	bracket4visible = false

	bracket5 = iWidgets.loadLibraryWidget("uibracket")
	iwidgets.setVisible(bracket5, 0)
	bracket5visible = false
endfunction


string[] CoreWidgetkeys
int[] CoreWidgetValues


int Function GetCoreWidget(string coreicon)
	if main.bridge.ostim.StringArrayContainsValue(CoreWidgetkeys, coreicon)
		int z
		Int i = 0
		Int L = CoreWidgetkeys.Length
		While (i < L)
			If (CoreWidgetkeys[i] == coreicon)
				z = i
				i = L
			EndIf
			i += 1
		EndWhile

		;console("Cached text found: " + CoreWidgetkeys[z])
		return CoreWidgetValues[z]

	else 
		;console("No cache found, making new...")
		int wid = iWidgets.loadLibraryWidget(coreicon)

		CoreWidgetkeys = PapyrusUtil.PushString(CoreWidgetkeys, coreicon)
		CoreWidgetValues = PapyrusUtil.Pushint(CoreWidgetValues, wid)

		if CoreWidgetkeys.length > 60
			console("Warning, widget cache is: " + CoreWidgetkeys.length)
			console("memory leak?")
		endif 

		return wid

	EndIf

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

function RebuildCache()
	ShowLoadingIcon()

	InitBrackets()
	RebuildCoreCache()
	RebuildTextCache()

	HideLoadingIcon()
endfunction 

Function RebuildCoreCache()
	Int i = 0
	Int L = CoreWidgetkeys.Length
	while i < L
		CoreWidgetValues[i] = iWidgets.loadLibraryWidget(CoreWidgetkeys[i])

		i += 1
	endwhile 

endfunction

Function RebuildTextCache()
	Int i = 0
	Int L = TextWidgetkeys.Length
	while i < L
		TextWidgetValues[i] = iWidgets.loadText(TextWidgetkeys[i], font = textfont)

		i += 1
	endwhile 

endfunction
;iWidgets.loadText(widgettxt, font = textfont, size = sizes )