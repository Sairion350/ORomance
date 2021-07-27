ScriptName ORPage extends BaseObject
iwant_widgets iWidgets
OUIScript oUI

Vector_Form property buttons auto
int[] property layout auto

bool property built auto

bool property visible auto

ORButton property selectedButton auto 
int Property selectedButtonID
	int Function Get()
		return buttons.find(selectedButton)
	EndFunction
EndProperty

Event Show()
	visible = true
	selectedButton = buttons.get(1) as ORButton

	buttons.ResetLooping()
	while buttons.Loop()
		if buttons.LoopPos() == 1 
			(buttons.get(1) as ORButton).CallEvent("Select")
		else 
			(buttons.i() as ORButton).CallEvent("FadeIn")
		endif 
		
	endwhile
EndEvent

Event Hide()
	visible = false 

	buttons.ResetLooping()
	while buttons.Loop()
		(buttons.i() as ORButton).CallEvent("FadeOut")
	endwhile
EndEvent

Function CursorRight()
	if selectedButton == (buttons.Back() as ORButton)
		return 
	else 
		selectedButton.CallEvent("Deselect")
		selectedButton = buttons.get( buttons.find(selectedButton) + 1) as ORButton
		selectedButton.CallEvent("Select")
	endif 
EndFunction

Function CursorLeft()
	if selectedButton == (buttons.Front() as ORButton)
		return 
	else 
		selectedButton.CallEvent("Deselect")
		selectedButton = buttons.get( buttons.find(selectedButton) - 1) as ORButton
		selectedButton.CallEvent("Select")
	endif 
EndFunction

Function Load()
	string root = iwidgets.WidgetRoot
	buttons.ResetLooping()
	while buttons.Loop()
		(buttons.i() as ORButton).LoadWidgets(root)
	endwhile

	built = true
EndFunction

Function SetButtonText(int button, string newText)
	(buttons.get(button) as ORButton).SetText(newText)
EndFunction

Function SetButtonSubtext(int button, string newText)
	(buttons.get(button) as ORButton).SetSubText(newText)
EndFunction

Function SetButtonIcon(int button, string newIcon)
	(buttons.get(button) as ORButton).SetIcon(newIcon)
EndFunction

Function AddButton(string zicon, int[] zcolor, string ztext, string zsubtext = "", bool load = false)
	int id = buttons.Size()

	ORButton button = ORButton.NewObject(layout[id],  zicon, zcolor, ztext, zsubtext)

	if load 
		button.LoadWidgets(iwidgets.WidgetRoot)
	endif 
	buttons.Push_back(button)
EndFunction

Function RecalculateLayout()
	layout = oui.GetElementLayoutByElementCount(buttons.size())

	buttons.ResetLooping()
	while buttons.Loop()
		(buttons.i() as ORButton).UpdateLayout(layout[buttons.LoopPos()])
	endwhile
endfunction

Function RemoveButton(string buttonText)
	buttons.ResetLooping()
	while buttons.Loop()
		if (buttons.i() as ORButton).text == buttonText
			RemoveButtonByID(buttons.LoopPos())
		endif 
	endwhile
EndFunction

Function RemoveButtonByID(int id)
	ORButton button = buttons.Get(id) as orbutton

	buttons.Remove(button)
	button.Destroy()
EndFunction

bool Function HasButton(string buttonText)
	buttons.ResetLooping()
	while buttons.Loop()
		if (buttons.i() as ORButton).text == buttonText
			return true 
		endif 
	endwhile

	return false
EndFunction

ORPage Function NewObject(int buttonCount) Global
	ORPage obj = BaseObject.Construct("ORPage") as ORPage
	
	obj.Setup(buttoncount)
	return obj
EndFunction 

Function Setup(int buttoncount)
	iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esl") as iwant_widgets
	if iWidgets == None
		iWidgets = game.GetFormFromFile(0x000800, "iWant Widgets.esp") as iwant_widgets
		if iWidgets == None
			debug.MessageBox("ORomance: iWant Widgets is not installed, install failed. Please exit now and reread the requirements page")
		endif
	endif 
	oui = game.GetFormFromFile(0x000800, "ORomance.esp") as OUIScript

	buttons = Vector_Form.NewObject()

	visible = false
	
	layout = oui.GetElementLayoutByElementCount(buttoncount)

	built = true
EndFunction

Event Destroy()
	buttons.DestroyAll()
	Parent.Destroy()
EndEvent
