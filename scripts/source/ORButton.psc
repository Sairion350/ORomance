ScriptName ORButton extends BaseObject
iwant_widgets iWidgets
OUIScript oUI
OSexIntegrationMain ostim


string property widgetRoot auto 

int size = 150

int bracket 
int core 
int textwidget
int subtextwidget

string property text auto
string subtext
string icon
int[] coords
int[] color

bool property selected auto



Event Click()
	setSize(bracket, (size * 0.75) as int, (size * 0.75) as int)
	setSize(core, ((size/4) * 0.75) as int, ((size/4) * 0.75) as int)

	Utility.Wait(0.1)

	setSize(bracket, (size) as int, (size ) as int)
	setSize(core, ((size/4)) as int, ((size/4) ) as int)
EndEvent

Event FadeIn()
	doTransitionByTime(bracket, 50, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(core, 50, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(textwidget, 0, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(subtextwidget, 0, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndEvent

Event FadeOut()
	doTransitionByTime(bracket, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(core, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(textwidget, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(subtextwidget, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)

	Utility.Wait(0.25)

	Deselect_size()
EndEvent

Event Deselect()
	selected = false 

	Deselect_size()

	doTransitionByTime(bracket, 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(core, 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(textwidget, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(subtextwidget, 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndEvent

Event Deselect_size()
	setSize(bracket, (size * 0.75) as int, (size * 0.75) as int)
	setSize(core, ((size/4) * 0.75) as int, ((size/4) * 0.75) as int)
EndEvent

Event Select()
	selected = true


	ostim.PlayTickSmall()


	setSize(bracket, size , size)
	setSize(core, (size/4), (size/4))

	doTransitionByTime(bracket, 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(core, 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(textwidget, 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	doTransitionByTime(subtextwidget, 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndEvent

Function SetText(string tex)
	if text == tex 
		return 
	endif 
	text = tex 
	textwidget = iWidgets.loadText(text, size = 24 )

	iwidgets.setTransparency(textwidget, 0)
	iWidgets.setPos(textwidget, coords[0] , coords[1] - 45)
	iWidgets.setVisible(textwidget)
EndFunction

Function SetSubtext(string sub)
	if sub == subtext
		return 
	endif 
	subtext = sub 
	subtextwidget = iWidgets.loadText(subtext, size = 18 )

	iwidgets.setTransparency(subtextwidget, 0)
	iWidgets.setPos(subtextwidget, coords[0] , coords[1] + 30)
	iWidgets.setVisible(subtextwidget)
EndFunction

Function SetIcon(string newIcon)
	if icon == newIcon 
		return 
	endif 
	icon = newicon 
	core = iWidgets.loadLibraryWidget(icon)

	iwidgets.setTransparency(core, 0)
	setSize(core, size/4, size/4)
	iWidgets.setPos(core, coords[0] , coords[1])
	iWidgets.setVisible(core)
EndFunction

Function UpdateLayout(int newSlot)
	coords = oui.GetElementCordsBySlot(newslot)

	iWidgets.setPos(Bracket, coords[0] , coords[1])
	iWidgets.setPos(core, coords[0] , coords[1])
	iWidgets.setPos(textwidget, coords[0] , coords[1] - 45)
	iWidgets.setPos(subtextwidget, coords[0] , coords[1] + 30)
endfunction

ORButton Function NewObject(int slot, string zicon, int[] zcolor, string ztext, string zsubtext = "") Global
	ORButton obj = BaseObject.Construct("ORButton") as ORButton
	
	obj.Setup(slot, zicon, zcolor, ztext, zsubtext)
	return obj
EndFunction 

Function Setup(int slot, string zicon, int[] zcolor, string ztext, string zsubtext)
	iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esl") as iwant_widgets
	if iWidgets == None
		iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esp") as iwant_widgets
		if iWidgets == None
			debug.MessageBox("ORomance: iWant Widgets is not installed, install failed. Please exit now and reread the requirements page")
		endif
	endif 
	oui = game.GetFormFromFile(0x000800, "ORomance.esp") as OUIScript

	ostim = OUtils.GetOStim()

	coords = oui.GetElementCordsBySlot(slot)
	icon = zicon
	color = zcolor
	text = ztext
	subtext = zsubtext
	
	;LoadWidgets()
EndFunction

Event LoadWidgets(string root)
	widgetRoot = root

	bracket = iWidgets.loadLibraryWidget("uibracket")
	setSize(Bracket, size, size)
	iWidgets.setPos(Bracket, coords[0] , coords[1])

	core = iWidgets.loadLibraryWidget(icon)
	setSize(core, size/4, size/4)
	iWidgets.setPos(core, coords[0] , coords[1])
	iWidgets.setRGB(core, color[0], color[1], color[2])

	textwidget = iWidgets.loadText(text, size = 24 )
	iWidgets.setPos(textwidget, coords[0] , coords[1] - 45)

	if subtext != ""
		subtextwidget = iWidgets.loadText(subtext, size = 18 )
		iWidgets.setPos(subtextwidget, coords[0] , coords[1] + 30)
	else 
		subtextwidget = -1
	endif 

	iwidgets.setTransparency(bracket, 0)
	iwidgets.setTransparency(core, 0)
	iwidgets.setTransparency(textwidget, 0)
	iwidgets.setTransparency(subtextwidget, 0)

	iWidgets.setVisible(Bracket)
	iWidgets.setVisible(core)
	iWidgets.setVisible(textwidget)
	iWidgets.setVisible(subtextwidget)

	selected = false

	Deselect_size()	
EndEvent




; Our own versions of iwidget's stuff. For performance.

Function setSize(Int id, Int h, Int w)
	String[] value
	String s

	value = Utility.CreateStringArray(2, "")
	value[0] = id As String

	value[1] = h As String
	s = _serializeArray(value)
	UI.InvokeString("HUD Menu", WidgetRoot + ".setHeight", s)

	value[1] = w As String
	s = _serializeArray(value)
	UI.InvokeString("HUD Menu", WidgetRoot + ".setWidth", s)
EndFunction

String Function _serializeArray(String[] a)
	Int i;
	String s = "";
	
	; Avoid demarc after last value
	While (i < (a.Length - 1))
		s += a[i]+"|"
		i += 1
	EndWhile
	
	s += a[a.Length - 1]
	
	Return (s)
EndFunction

Function doTransitionByTime(Int id, Int targetValue, Float seconds = 2.0, String targetAttribute = "alpha", String easingClass = "none", String easingMethod = "none", Float delay = 0.0)
	String[] value
	String s
	Int i = 0

	value = Utility.CreateStringArray(7, "")
	value[0] = id As String
	value[1] = targetValue As String
	value[2] = seconds As String

	If (targetAttribute == "x" || targetAttribute == "y" || targetAttribute == "xscale" || targetAttribute == "yscale" || targetAttribute == "rotation")
		value[3] = "_"+targetAttribute
	ElseIf targetAttribute == "meterpercent"
		value[3] = "percent"
	Else
		; Default to alpha
		value[3] = "_alpha"
	EndIf
	
	If (easingClass == "regular" || easingClass == "bounce" || easingClass == "back" || easingClass == "elastic" || easingClass == "strong")
		value[4] = easingClass
	Else
		; Default to no easing
		value[4] = "none"
	EndIf
	
	If (easingMethod == "in")
		value[5] = "easeIn"
	ElseIf easingMethod == "out"
		value[5] = "easeOut"
	ElseIf easingMethod == "inout"
		value[5] = "easeInOut"
	Else
		; If a valid easing method is not defined, revert to no easing
		value[4] = "none"
		value[5] = ""
	EndIf
	
	value[6] = delay As String

	s = _serializeArray(value)

	UI.InvokeString("HUD Menu", WidgetRoot + ".doTransition", s)
EndFunction














