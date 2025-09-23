
MsgBox, , CPL History Aid,
(
	To Use :
	Go to Meditech 3 (colorful) > Main menu or BB menu

	Press Windows Key+Q
	A list of the loaded patients should display.
	If it does not try toggling CAPS LOCK off / on
	and press Win+Q again
	
	Go to Meditech > Result Inquiry (29) > Print Specimens (12)

	Press Windows Key+S to enter next patient name
	Press Windows Key+A to enter previous patient name

	Do CPL history checks as before

	~~Made using AutoHotKey by J. Ochoa, 06/04/2023~~
)

global patients := []
global position := 0

#Q::
patients := []
position := 0
SendInput, 39{Enter}35{Enter}5{Enter}{Enter}{Enter}{F10}R{Enter}{Enter}{Enter}{F10}24{PgDn}{Enter}{Enter}{Enter}{Enter}{Enter}{F10}I{Enter}{Insert}BT{Enter}ABS{Enter}I{F12}
Sleep, 1000
loop(readMeditech())
concat := "Loaded patients:`n" ;output list of loaded patients
For each, element in patients {
	concat .= element . "`n"
}
MsgBox, %concat%
return

loop(line) {
	pos := RegExMatch(line, "[A-Za-z- ]+,[A-Za-z-]+", name) ;look for names in format LAST,FIRST with optional hyphon and space in last name and optional hyphon in first name
	if (!pos) ;not found
		return
	nameLen := StrLen(name)
	;name := SubStr(name, 3) ;trim off end of assc
	;name = %name% ;trim off whitespace
	names := StrSplit(name, ",")
	firstName := SubStr(names[2], 1, 5)
	lastName := SubStr(names[1], 3, 5)
	name := lastName "," firstName 
	patients.push(name)
	loop(SubStr(line, pos + nameLen)) ;recursivly check rest of line in case there are more than one patient name per line
}

*#A::
position -= 1
if (position <= 0) {
	MsgBox, 0,,End of file
	position := 0
	return
}
output := patients[position]
SendInput, {BackSpace 25}%output%
return

*#S::
position += 1
if (position > patients.MaxIndex()) {
	MsgBox, 0,,End of file
	position := patients.MaxIndex()
	return
}
output := patients[position]
SendInput, {BackSpace 25}%output%
return

readMeditech() { ;Copy the contents of meditech to clipboard
	clipboard := "" ;clear clipboard
	trys := 0
	While (clipboard == "")&&(trys < 10) { ;try 10 times and then give up
		sleep, 500
		trys++
		winActivate, LAB.COCCBA
		sysGet, xBorder, 32
		sysGet, yBorder, 33
		sysGet, titleBar, 4
		winGetPos,,, winWidth, winHeight, LAB.COCCBA
		padding := 10
		startX := xBorder + padding
		startY := yBorder + padding + (titleBar * 2)
		endX := winWidth - (xBorder + padding)
		endY := winHeight - (yBorder + padding)
		;sendInput, {Click %startX% %startY% Down}{Click %endX% %endY% Down}!C{Click Up} ;copy contents of meditech to clipboard
		MouseClickDrag, Left, %startX%, %startY%, %endX%, %endY%
		sendInput, !c
	}
	return clipboard
}