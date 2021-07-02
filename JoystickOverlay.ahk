#SingleInstance force


#Include Lib\Webapp.ahk
__Webapp_AppStart:

;Get our HTML DOM object
iWebCtrl := getDOM()

;Change App name on run-time
setAppName("Joystick Overlay")


;---------------------- START OF CONFIG SECTION



;Joystick/Gamepad Mappings. Stick nums should be integer values, and the axis should be strings in the form of "JoyX", "JoyY", etc
JoystickNum_pitch := 5
JoystickNum_yaw := 5
JoystickNum_roll := 5

mappedLateralAxis := "JoyX"
mappedThrustAxis := "JoyY"
mappedVertialAxis := "JoyZ"

mappedYawAxis := "JoyX"
mappedPitchAxis := "JoyY"
mappedRollAxis := "JoyZ"

;Thrust Keys. Should be string values
mappedBoostKey := "Space"
mappedDriftKey := "LShift"



;---------------------- END OF CONFIG SECTION

global gpitchVal = 0.0
global gyawVal = 0.0
global grollVal = 0.0

global lastBoostDown := A_TickCount
global lastDriftDown := A_TickCount

SetTimer, mainLoop, 33 ;16 for 60 Hz, 33 for 30 Hz
MainLoop:
	
	
	;***Get the rotation axis values
	if(JoystickNum_pitch and mappedPitchAxis) {
		GetKeyState, pitchVal, %JoystickNum_pitch%%mappedPitchAxis%
		gpitchVal := Round(2*(pitchVal/100 - 0.5), 2)
	}
	
	if(JoystickNum_yaw and mappedYawAxis) {
		GetKeyState, yawVal, %JoystickNum_yaw%%mappedYawAxis%
		gyawVal := Round(2*(yawVal/100 - 0.5), 2)
	}

	if(JoystickNum_roll and mappedRollAxis) {
		GetKeyState, rollVal, %JoystickNum_roll%%mappedRollAxis%
		grollVal := Round(2*(rollVal/100 - 0.5), 2)
	}	
	
	curTime := A_TickCount
	timeSinceBoost := curTime - lastBoostDown
	
	if(timeSinceBoost < 200) {
		BoostKey := 1
	}
	else {
		BoostKey := 0
	}

	DriftKey := GetKeyState(mappedDriftKey)	
	
	JS_UpdatePositions(gpitchVal, gyawVal, grollVal, BoostKey, DriftKey)

Return

; Our custom protocol's url event handler
app_call(args) {
	
}

app_page(NewURL) {
	wb := getDOM()
	
	setZoomLevel(100)
}


JS_UpdatePositions(pitchVal, yawVal, rollVal, boostActive, driftActive) {
	window := getWindow()
	window.UpdatePositions(pitchVal, yawVal, rollVal, boostActive, driftActive)
}


~Space::
	lastBoostDown := A_TickCount
return

