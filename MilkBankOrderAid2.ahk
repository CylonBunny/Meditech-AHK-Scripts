
MsgBox, , Milk Bank Order Aid,
(
	
		~~Milkbank Order Aid 2!~~

To Use :
	1. Make a copy of Orders.txt in this directory
	    Give it a name like Orders-Date.txt or such
	
	2. Set Order Date: DD/MM/YY (year must be two digits!)
	    Set Order Time: HHMM
	    Set Pre or Post?: Pre/Post
	
	3. Remove old orders and
	    Add each order name to a new line in the document

	4. Go to Meditech Enter/Edit Outreach Requisition and
	    Press Windows Key+Q - select your order file

	    After the orders have been entered
	5. To go Meditech Mic Specimen Labels and
	    use the displayed orders (only in Meditech 3)
	    to print the whole run of labels at once

To Close :
	Select H icon in system tray -> right-click -> Exit

	~~Made using AutoHotKey by J. Ochoa, 8/2/22~~
		~~Most recent update 3/12/25~~
)

global prepost, date, time, orderNum, firstOrder, lastOrder, prevOrder := ""
global dates := []
SetkeyDelay, 1

SetPrePost(pp) { ;set pre/post variable
	prepost := pp
	prevOrder := ""
}
SetDate(d) { ;set date variable
	date := d
	prevOrder := ""
}
SetTime(t) { ;set time variable
	time := t
	prevOrder := ""
}

#Q::
FileSelectFile, selectedFile, 3, , Open a file, Text Documents (*.txt)
if (SelectedFile = "") {
	MsgBox, 0,,Nothing selected
	return
}
orderNum := 0
Loop, read, %selectedFile% ;Count orders
{
	If loop(A_LoopReadLine)
		continue
	orderNum++
}
If (!prepost)||(!date)||(!time) {
	MsgBox, 0,,
	(LTrim
		Your order file must exist and have
		at least one set of the following:

		Order Date: mm/dd/yy
		Order Time: hhmm
		Pre or Post?: Pre/Post
	)
	return
}
orderMins := Round((orderNum * 3) / 60, 1)
orderDates := ""
for k, d in dates
	orderDates .= d . "`n"
year := subStr(A_YYYY, 3)
MsgBox, 4,,
(LTrim
	%orderNum% orders found.	

	Current date is:
	%A_MM%/%A_DD%/%year%

	And your orders are for:
	%orderDates%
	Would you like to contine?
	(This will take about %orderMins% minutes.)
) 
IfMsgBox No
    return
MsgBox, 0,, Make sure you are in Enter/Edit Outreach Requisition
winActivate, LAB.COCCBA
count := 1
Loop, read, %selectedFile%
{
	If loop(A_LoopReadLine)
		continue
	order(A_LoopReadLine, count)
	count++
}
MsgBox, 0,,
(LTrim
	Complete!

	%orderNum% orders ordered.
	I think the first order was: %firstOrder%,
	and the last was: %lastOrder%

	Use this information to print the labels.

	(Note: If no orders are displayed here you can find the orders using
	MIC Outstanding Procedure Report - EC)
)
return

loop(line) { ;Initial checks in loop before ordering - returns true if line is empty, comment, or variable declaration
	If line = ;empty
		return true
	If InStr(line, "--") ;comment
		return true
	
	;check for variable declaration lines
	If InStr(line, "Order Date: ") {
		SetDate(SubStr(line, 13))
		dates.Push(SubStr(line, 13))
		return true
	} Else If InStr(line, "Order Time: ") {
		SetTime(SubStr(line, 13))
		return true
	} Else If InStr(line, "Pre or Post?: ") {
		SetPrePost(SubStr(line, 15))
		return true
	}
}

order(patient, count) { ;Enter keys to order patient and return
	If (!prepost)||(!date)||(!time)
		return
	order := patient
	If InStr(prepost, "Post", false) {
		If strLen(prevOrder) > strLen(order)
			order := SubStr(prevOrder, 1, strLen(prevOrder) - strLen(order)) . order
		prevOrder := order
		order = POST %order%
	}
	order = MB,%order%
	shortorder := SubStr(order, 1, 30)
	winActivate, LAB.COCCBA
	sendInput, N{Enter}C{Enter}MMB{Enter}MMB{Enter}{Enter}%shortorder%{Enter}{Enter}U{Enter}U{Enter}
	sleep, 500
	winActivate, LAB.COCCBA
	sendInput,  {F11}
	sleep, 500
	winActivate, LAB.COCCBA
	sendInput,  {Enter}{Enter}{Enter}{F10}%date%{Enter}%time%{Enter}{Enter}{F10}{Enter}EC{Enter}M{Enter}
	winActivate, LAB.COCCBA
	If StrLen(order) > 29
		sendInput, {Enter}{Enter}{Enter}{F10}Y{Enter}%patient%
	winActivate, LAB.COCCBA
	sendInput,  {F12}{F12}
	sleep, 500
	winActivate, LAB.COCCBA
	sendInput,  {Enter}
	if (count == 1)
		firstOrder := readOrder()
	if (count == orderNum)
		lastOrder := readOrder()
	winActivate, LAB.COCCBA
	sendInput,  {Enter}
	return
}

readOrder() { ;Read order off of meditech window and return it
	FoundPos := 0
	clipboard := "" ;clear clipboard
	trys := 0
	While (FoundPos == 0)&&(trys < 10) { ;try 10 times and then give up
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
		FoundPos := InStr(clipboard, "-  MIC  ")
	}
	return subStr(clipboard, FoundPos + 8, FoundPos + 24)
}