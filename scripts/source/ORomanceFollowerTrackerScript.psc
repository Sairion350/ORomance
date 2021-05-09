ScriptName ORomanceFollowerTrackerScript Extends ReferenceAlias

ORomanceScript main



Event OnInit()

	main = ((getowningquest()) as ORomanceScript)

	main.console("ORomance Follower Tracker initiated")
	
EndEvent

Event OnLoad()
  main.console("ORomance Follower loaded!")
endEvent

Event OnUnLoad()
  main.console("ORomance Follower unloaded...")
  Clear()
endEvent


;Event OnCellAttach()
;  main.console("Our parent cell has attached")
;endEvent