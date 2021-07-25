ScriptName ORUIManager extends BaseObject
import outils 
OUIScript oUI



Event RebuildPages()
	GetOStim().Profile()

	console("Rebuilding pages...")
	Vector_Form pages = oui.pages
	pages.ResetLooping()
	while pages.Loop()
		(pages.i() as orpage).Load()
	endwhile
	console("All pages rebuilt")
	
	GetOStim().Profile("Build")
EndEvent

ORUIManager Function NewObject() Global
	ORUIManager obj = BaseObject.Construct("ORUIManager") as ORUIManager
	
	obj.Setup()
	return obj
EndFunction 

Function Setup()
	
	oui = game.GetFormFromFile(0x000800, "ORomance.esp") as OUIScript

	
EndFunction
