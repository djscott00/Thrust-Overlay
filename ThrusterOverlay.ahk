#SingleInstance force
SetTitleMatchMode 1
#MaxThreadsPerHotkey 3
SetFormat, float, 03  ; Omit decimal point from axis position percentages.

#Include <Gdip_All>
#Include <GdipHelper>

;-----------------Device and Key Mapping. Use an empty/blank value if you don't have particular mappings
;Thrust Keys
mappedVerticalDownKey := "j"
mappedVertialUpKey := "k"
mappedLateralLeftKey := 
mappedLateralRightKey := 
mappedForwardKey := 
mappedBackKey := 

;Rotation Keys
mappedYawLeftKey := 
mappedYawRightKey := 
mappedRollLeftKey := 
mappedRollRightKey := 
mappedPitchUpKey := 
mappedPitchDownKey := 

;Joystick/Gamepad Mappings
JoystickNum_thrust := 2
JoystickNum_lateral := 2
JoystickNum_vertical := 2

JoystickNum_pitch := 3
JoystickNum_yaw := 3
JoystickNum_roll := 3

mappedLateralAxis := "JoyX"
mappedThrustAxis := "JoyY"
mappedVertialAxis := "JoyZ"

mappedYawAxis := "JoyX"
mappedPitchAxis := "JoyY"
mappedRollAxis := "JoyZ"

;-------------------Set your desired colors and transparency
global transparency := "CC" ;00 for fully transparent / ff for fully opaque
global transparencyMarkers := "af"
global colorPrimary := "03b2e1"
global colorSecondary := "002f3b"
global colorBackground := "000000"
global colorMarkers := "fffdad"


;-------------------Position/Size Variables for the 2D overlays
global overlayRadius := 60
global overlayDiameter := 2*overlayRadius

global overlayThruster2DX := 40
global overlayThruster2DY := A_ScreenHeight - overlayDiameter - 40

global overlayRotation2DX := A_ScreenWidth - overlayDiameter - 40
global overlayRotation2DY := overlayThruster2DY

global overlayTextYOffset := 50 ;***Increase this value if the rotated text isn't low enough (lame workaround for now)


;--------------------Position/Size Variables for the 1D overlays
global overlay1DShort := 20				 ; used for the width on vertical running overlay, and used for the height on horizontal running overlay
global overlay1DLong := overlayDiameter  ; used for the width on horizontal running overlay, and used for the height on vertical running overlay

global overlayThruster1DX := overlayThruster2DX
global overlayThruster1DY := overlayThruster2DY - overlay1DLong - 60

global overlayRotation1DX := overlayRotation2DX
global overlayRotation1DY := overlayRotation2DY - overlay1DShort - 60


;--------------------Size Variables for the value markers
global dotRadius := 8
global dotDiameter := dotRadius * 2


;--------------------Styling variables for the axis labels
global textFont = "Orbitron"
global textSize := 17


;---------------------- END OF CONFIG SECTION. Do not make changes below this point unless
; you wish to alter the basic functionality of the script.

global pPenPrimary
global pPenSecondary

global pBrushPrimary
global pBrushBackground
global pBrushMarker


Initialize()

GetKeyState, joy_info, %JoystickNumber%JoyInfo

SetTimer, mainLoop,16
MainLoop:
	
	;****Get the thruster axis values
	GetKeyState, lateralVal, %JoystickNum_lateral%%mappedLateralAxis%
	lateralVal := Round(2*(lateralVal/100 - 0.5), 2)
	
	GetKeyState, thrustVal, %JoystickNum_thrust%%mappedThrustAxis%
	thrustVal := Round(2*(thrustVal/100 - 0.5), 2)
	
	axisZ := 0.0
	IfInString, joy_info, Z
	{
		GetKeyState, verticalVal, %JoystickNum_vertical%%mappedVertialAxis%
		verticalVal := Round(-2*(verticalVal/100 - 0.5), 2)
	}
	
	;***Get the thruster key values
	DownKey := GetKeyState(mappedVerticalDownKey)
	UpKey := GetKeyState(mappedVertialUpKey)
	LeftKey := GetKeyState(mappedLateralLeftKey)
	RightKey := GetKeyState(mappedLateralRightKey)
	ForwardKey := GetKeyState(mappedForwardKey)
	BackKey := GetKeyState(mappedBackKey)
	
	
	If (DownKey and !UpKey) {
		verticalVal := 1.0
	}
	else if(UpKey and !DownKey) {
		verticalVal := -1.0
	}
	
	if(LeftKey and !RightKey) {
		lateralVal := -1.0
	}
	else if(RightKey and !LeftKey) {
		lateralVal := 1.0
	}
	
	if(ForwardKey and !BackKey) {
		thrustVal := -1.0
	}
	else if(BackKey and !ForwardKey) {
		thrustVal := 1.0
	}	
	
	;***Get the rotation axis values
	pitchVal := 0
	yawVal := 0
	rollVal := 0
	
	GetKeyState, pitchVal, %JoystickNum_pitch%%mappedPitchAxis%
	pitchVal := Round(2*(pitchVal/100 - 0.5), 2)
	
	GetKeyState, yawVal, %JoystickNum_yaw%%mappedYawAxis%
	yawVal := Round(2*(yawVal/100 - 0.5), 2)

	GetKeyState, rollVal, %JoystickNum_roll%%mappedRollAxis%
	rollVal := Round(2*(rollVal/100 - 0.5), 2)
	
	
	;Get the rotation key values
	RollLeftKey := GetKeyState(mappedRollLeftKey)
	RollRightKey := GetKeyState(mappedRollRightKey)
	YawLeftKey := GetKeyState(mappedYawLeftKey)
	YawRightKey := GetKeyState(mappedYawRightKey)
	PitchUpKey := GetKeyState(mappedPitchUpKey)
	PitchDownKey := GetKeyState(mappedPitchDownKey)	
	
	If (RollLeftKey and !RollRightKey) {
		rollVal := -1.0
	}
	else if(RollRightKey and !RollLeftKey) {
		rollVal := 1.0
	}
	
	if(YawLeftKey and !YawRightKey) {
		yawVal := -1.0
	}
	else if(YawRightKey and !YawLeftKey) {
		yawVal := 1.0
	}
	
	if(PitchUpKey and !PitchDownKey) {
		pitchVal := -1.0
	}
	else if(PitchDownKey and !PitchUpKey) {
		pitchVal := 1.0
	}	
	
	

	DrawAllGraphics(lateralVal, thrustVal, verticalVal, yawVal, pitchVal, rollVal)
	

return

Initialize()
{
	global
	
	SetUpGDIP()
	Gdip_SetSmoothingMode(G, 4)	
	
	;Setup Brush/Pen objects
	pPenPrimary := Gdip_CreatePen("0x" transparency colorPrimary, 1)
	pPenSecondary := Gdip_CreatePen("0x" transparency colorSecondary, 2)
	
	pBrushPrimary := Gdip_BrushCreateSolid("0x" transparency colorPrimary)
	pBrushBackground := Gdip_BrushCreateSolid("0x" transparency colorBackground)
	pBrushMarker := Gdip_BrushCreateSolid("0x" transparencyMarkers colorMarkers )
	
	pPenShadow := Gdip_CreatePen("0x" transparency colorBackground, 4)

}

DrawAllGraphics(lateralVal, thrustVal, verticalVal, yawVal, pitchVal, rollVal)
{
	StartDrawGDIP()
	ClearDrawGDIP()

	
	Draw2DOverlay(lateralVal, thrustVal, overlayThruster2DX, overlayThruster2DY, "LATERAL", "THRUST")
	Draw1DOverlayVertical(verticalVal, overlayThruster1DX, overlayThruster1DY, "VERTICAL")
	
	Draw2DOverlay(yawVal, pitchVal, overlayRotation2DX, overlayRotation2DY, "YAW", "PITCH")
	Draw1DOverlayHorizontal(rollVal, overlayRotation1DX, overlayRotation1DY, "ROLL")
	
	
	EndDrawGDIP()
}



Draw1DOverlayHorizontal(value, xPosition, yPosition, AxisLabel)
{
	global
	
	dotX := xPosition + overlay1DLong /2 + value*overlay1DLong/2 - dotRadius
	dotY := yPosition + overlay1DShort/2 - dotRadius
	
	HorLineX := xPosition + overlay1DLong/2 + 1
	HorLineYTop := yPosition + 4
	HorLineYBot := yPosition + overlay1DShort - 4



	;Then draw the background color
	Gdip_FillRoundedRectangle(G, pBrushBackground, xPosition, yPosition, overlay1DLong, overlay1DShort, 3)

	;First draw the primary color
	Gdip_DrawRoundedRectangle(G, pPenPrimary, xPosition,yPosition ,overlay1DLong, overlay1DShort, 3)
	
	;Then draw the secondary color line
	Gdip_DrawLine(G, pPenSecondary, HorLineX, HorLineYTop, HorLineX, HorLineYBot)
	
	;Then draw the axis value marker
	Gdip_FillEllipse(G, pBrushMarker, dotX, dotY, dotDiameter, dotDiameter)
	
	;Draw the axis labels
	Gdip_DrawOrientedString(G, AxisLabel, textFont, textSize, 0, xPosition, yPosition - 30
		, overlay1DLong, 0, 0, pBrushPrimary,0,1,1)

}


Draw1DOverlayVertical(value, xPosition, yPosition, AxisLabel)
{
	global
	
	dotX := xPosition + overlay1DShort /2 - dotRadius
	dotY := yPosition + overlay1DLong /2 + value*overlay1DLong/2 - dotRadius
	
	HorLineXLeft := xPosition + 4
	HorLineXRight := xPosition + overlay1DShort - 4
	HorLineY := yPosition + overlay1DLong/2 + 1

	;draw the background color
	Gdip_FillRoundedRectangle(G, pBrushBackground, xPosition, yPosition, overlay1DShort, overlay1DLong, 3)

	;draw the primary color
	Gdip_DrawRoundedRectangle(G, pPenPrimary, xPosition,yPosition , overlay1DShort ,overlay1DLong, 3)

	
	;Then draw the secondary color line
	Gdip_DrawLine(G, pPenSecondary, HorLineXLeft, HorLineY, HorLineXRight, HorLineY)
	
	;Then draw the axis value marker
	Gdip_FillEllipse(G, pBrushMarker, dotX, dotY, dotDiameter, dotDiameter)
	
	;Draw the axis labels
	Gdip_DrawOrientedString(G, AxisLabel, textFont, textSize, 0, xPosition + overlay1DShort + 15, yPosition + overlayTextYOffset
		, 0, overlay1DLong, 270, pBrushPrimary,0,1,1)

}



Draw2DOverlay(xVal, yVal, xPosition, yPosition, xAxisLabel, yAxisLabel)
{
	global
	
	;Calculate dot position values
	xRadialLengthFactor := Round(xVal * Sqrt( 1 - 0.5*yVal**2), 2)
	yRadialLengthFactor := Round(yVal * Sqrt( 1 - 0.5*xVal**2), 2)
	dotXFinal := xPosition + overlayRadius + xRadialLengthFactor*overlayRadius - dotRadius
	dotYFinal := yPosition + overlayRadius + yRadialLengthFactor*overlayRadius - dotRadius
	
	;Calculate vertical and horizontal line position values
	VertLineX := xPosition + overlayRadius + 1
	VertLineYTop := yPosition + 8
	VertLineYBot := yPosition + overlayDiameter - 8
	HorLineXLeft := xPosition + 8
	HorLineXRight := xPosition + overlayDiameter - 8
	HorLineY := yPosition + overlayRadius + 1	


	;draw the background color
	Gdip_FillEllipse(G, pBrushBackground, xPosition, yPosition, overlayDiameter, overlayDiameter)

	;draw the primary color
	Gdip_DrawEllipse(G, pPenPrimary, xPosition, yPosition, overlayDiameter, overlayDiameter)


	;draw the secondary color lines
	Gdip_DrawLine(G, pPenSecondary, VertLineX, VertLineYTop, VertLineX, VertLineYBot)
	Gdip_DrawLine(G, pPenSecondary, HorLineXLeft, HorLineY, HorLineXRight, HorLineY)
	
	;draw the axis value markers
	Gdip_FillEllipse(G, pBrushMarker, dotXFinal, dotYFinal, dotDiameter, dotDiameter)
	
	
	
	
	;Draw the axis labels
	Gdip_DrawOrientedString(G, xAxisLabel, textFont, textSize, 0, xPosition-1, yPosition - 30
		, overlayDiameter, 0, 0, pBrushBackground, 0, 1, 1)
	Gdip_DrawOrientedString(G, xAxisLabel, textFont, textSize, 0, xPosition+1, yPosition - 30
		, overlayDiameter, 0, 0, pBrushBackground, 0, 1, 1)			
	
	
	Gdip_DrawOrientedString(G, xAxisLabel, textFont, textSize, 0, xPosition, yPosition - 30
		, overlayDiameter, 0, 0, pBrushPrimary, 0, 1, 1)
	Gdip_DrawOrientedString(G, yAxisLabel, textFont, textSize, 0, xPosition + overlayDiameter + 15, yPosition + overlayTextYOffset
		, 0, overlayDiameter, 270, pBrushPrimary, 0, 1, 1)
}
