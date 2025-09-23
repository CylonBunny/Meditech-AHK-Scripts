MsgBox, , Meditech Bench Aid 2.0,
(
	
		~~Meditech Bench Aid 2.0!~~

To Use :
	From Meditech login screen :
	Press Win+Q : to quickly login to Meditech main menu

	From Meditech main menu (or any specimen tracking screen) :
	Press Win+C : to launch chem specimen tracking
	Press Win+H : to launch heme specimen tracking
	Press Win+N : to launch night shift specimen tracking
	Press Win+E : to launch ordered ER specimen tracking
	Press Win+B : to launch blood bank specimen tracking
	Press Win+O : to launch ortho specimen tracking
	Press Win+V : to launch COVID19 specimen tracking

	Press Win+P : to print pending lists (chem, heme, BB, or micro)

	Press Win+A : to close/open batches (chem, heme, or BB)

To Close :
	Locate green box with H icon in system tray -> right-click -> Exit

	~~Made using AutoHotKey by J. Ochoa, 03/31/2020~~
	Last updated on 06/15/25
)

#Q:: ;Login Meditech
SendInput, {Enter}
Sleep, 100
SendInput, 1{Enter}
Sleep, 250
;SendInput, 2{Enter}COCCBA{Enter}{Enter}
SendInput, {Enter}
return

;PRINTERS
::CHEML::SDMCA1CLBB02 ;CHEM LABEL PRINTER
::HEMEL::SDMCA1CLBB04 ;HEME LABEL PRINTER
::BBL::CBALABP15 ;BB LABEL PRINTER
::BBC::CBALABP05 ;BB CARD PRINTER
::CHEMP::CBALABP07 ;CHEM LASER PRINTER
::HEMEP::CBALABCP01 ;HEME LASER PRINTER
;::BBP::CBALABBP01 ;BB LASER PRINTER

;MANAGEMENT REPORTS
#C::
LabManagementReport("SDMC CHEM")
return
#N::
LabManagementReport("SDMC NS")
return
#H::
LabManagementReport("SDMC HEMA")
return
#O::
LabManagementReport("SDMC ORTHO")
return
#E::
LabManagementReportER()
return
#B::
report:=MsgBox_SelectString("Open BB Specimen Tracking","Which specimen tracking to open?","BB|SDBB|Received BB|BBNSY|CPL")
If !report ;nothing selected
	return
If (report = "CPL") {
	BBCPLManagementReport()	
} Else If (report = "Received BB") {
	BBRcvdManagementReport()
} Else {
	BBManagementReport(report)
}
return
#V::
report:=MsgBox_SelectString("Open COVID Specimen Tracking","In-house or send-out?","In-house|Send-out CPL/Methodist|Send-out SAMC/NAMC")
If !report ;nothing selected
	return
rcvd:=MsgBox_SelectString("Open COVID Specimen Tracking","Received or ordered?","Received|Ordered")
If !rcvd ;nothing selected
	return
If (report = "In-house") {
	LabManagementReportCOVIDIH(rcvd)
} Else If (report = "Send-out CPL/Methodist") {
	LabManagementReportCOVIDX(rcvd)
} Else If (report = "Send-out SAMC/NAMC") {
	LabManagementReportCOVIDD(rcvd)
}
return

LabManagementReport(report) { ;Open specified lab management report from main screen or management report
	ManagementReportReturn()
	SendInput, 31{Enter}5{Enter}{Enter}{Enter}{F10}R{PgDn}{F6}{F10}%report%{F12}
	return
}
LabManagementReportER() { ;Open ER lab management report
	ManagementReportReturn()
	SendInput, 31{Enter}5{Enter}{Backspace}{Backspace}MI{F12}
	return
}

LabManagementReportCOVIDIH(rcvd) { ;Open rcvd status in-house COVID lab management report
	ManagementReportCovidCommon(rcvd)
	ManagementReportTest("COVID19")
	ManagementReportTest("COVID19IH")
	;ManagementReportTest("COVID19IHBED")
	;ManagementReportTest("COVID19IHD")
	ManagementReportTest("COVNONPUI")
	ManagementReportTest("COVNONPUIS")
	ManagementReportTest("COVID19IHAG")
	ManagementReportTest("COVID19IHLI")
	SendInput, {F12}
}
LabManagementReportCOVIDX(rcvd) { ;Open rcvd status sendout CPL COVID lab management report
	ManagementReportCovidCommon(rcvd)
	ManagementReportTest("COVID19X")
	ManagementReportTest("COVNONPUIX")
	SendInput, {F12}
}
LabManagementReportCOVIDD(rcvd) { ;Open rcvd status sendout sister hospital COVID lab management report
	ManagementReportCovidCommon(rcvd)
	ManagementReportTest("COVNONPUID")
	ManagementReportTest("COVID19IHD")
	SendInput, {F12}
}
ManagementReportCovidCommon(rcvd) { ;common inital keystrokes in all three covid functions
	ManagementReportReturn()
	SendInput, 31{Enter}5{Enter}{F10}MI,S
	If (rcvd = "Received") {
		SendInput, {Enter}{Enter}{F10}R
	}
	SendInput, {PgDn}{F10}{Enter}{F10}{Enter}{F10}{Enter}{F10}{Enter}{F10}{Enter}{F10}{Enter}{PgUp}FAC{Enter}COCHHA{Enter}E{Enter}
	If (rcvd = "Ordered") {
		SendInput, LSS{Enter}RECD{Enter}E{Enter}
	}
}
ManagementReportTest(test) { ;send keystrokes to add test to management report
	SendInput, LT{Enter}%test%{Enter}I{Enter}
}

BBManagementReport(report) { ;Open specified BB management report from main screen or management report
	ManagementReportReturn()
	SendInput, 39{Enter}35{Enter}5{Enter}{PgDn}{F6}{F10}%report%{F12}
	return
}
BBRcvdManagementReport() { ;Open BB rcvd management report from main screen or management report
	ManagementReportReturn()
	SendInput, 39{Enter}35{Enter}5{Enter}{Enter}{Enter}{F10}R{PgDn}{F6}{F10}SDBB{F12}
	return
}
BBCPLManagementReport() { ;Open BB CPL management report from main screen or management report
	ManagementReportReturn()
	SendInput, 39{Enter}35{Enter}5{Enter}{Enter}{Enter}{F10}R{PgDn}{Enter}{Enter}{Enter}{Enter}{Enter}{F10}I{F12}
	return
}
ManagementReportReturn() { ;Return to main screen from any management report (allow quick switching)
	SendInput, {F11}Y{Enter}{Enter}0{Enter}2{Enter}
	Sleep, 100
	SendInput, {Enter}
	return
}

#P:: ;PRINT SPECIFIED PENDING
pending:=MsgBox_SelectString("Print a pending","Which pending to print?","BB|CHEM|HEME|MICRO")
If !pending ;nothing selected
	return
If (pending != "BB") {
	rcvd:=MsgBox_SelectString("Print a pending","Received?","ALL|RECEIVED|UNRECEIVED")
	If !rcvd ;nothing selected
		return
}
InputBox, printer, Print a pending, Which printer to use?, , 300, 150, , , , , PREVIEW
If ErrorLevel ;cancel pressed
	return
If (pending = "BB") {
	PrintBBOSReport(printer)
} Else If (pending = "CHEM") {
	;PrintOSReport("UA", rcvd, printer)
	PrintOSReport("UR", rcvd, printer)
	PrintOSReport("CHEM", rcvd, printer)
	PrintOSReport("SER", rcvd, printer)
	PrintOSReport("TOX", rcvd, printer)
	PrintOSReport("BF", rcvd, printer)
	PrintOSHeartReport(rcvd, printer)
	PrintOTReport("GHOST1", "GHOST2", rcvd, printer)
} Else If (pending = "HEME") {
	PrintOSReport("UA", rcvd, printer)
	PrintOSReport("COAG", rcvd, printer)
	PrintOSReport("HEMA", rcvd, printer)
	PrintOSReport("BF", rcvd, printer)
	PrintOSHeartReport(rcvd, printer)
	PrintOTReport("PREGS", "PREGU", rcvd, printer)
	PrintOTReport("MONO", "MONO", rcvd, printer)
	PrintOTReport("UEOS", "UEOS", rcvd, printer)
	PrintMicroOPReport("WET", "WET", rcvd, printer)
} Else If (pending = "MICRO") {
	PrintMicroOSReport(rcvd, printer)
}
winActivate, LAB.COCCBA ;Exit back to main screen
SendInput, {F11}{Enter}{Enter}
reload
return

PrintBBOSReport(printer) { ;From main screen print BB pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}39{Enter}27{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}
PrintOSReport(site, rcvd, printer) { ;From main screen print specific rcvd status site pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}32{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{F10}%site%{Enter}{F10}%site%{Enter}{Enter}{Enter}
	If (rcvd != "ALL") {
		SendInput, SD{Enter}
		If (rcvd = "RECEIVED") {
			SendInput, I
		} Else {
			SendInput, E
		}
		SendInput, {Enter}
	}
	SendInput, {Enter}{Enter}COCHHA{Enter}E{Enter}{Enter}PRE CLI{Enter}E{Enter}PRE ER{Enter}E{Enter}PRE IN{Enter}E{Enter}PRE SDC{Enter}E{Enter}PROF SET{Enter}E{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}
PrintOSHeartReport(rcvd, printer) { ;From main screen print specific rcvd status heart pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}32{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}HEART{Enter}I{Enter}SD{Enter}I{Enter}{Enter}
	If (rcvd != "ALL") {
		SendInput, SD{Enter}
		If (rcvd = "RECEIVED") {
			SendInput, I
		} Else {
			SendInput, E
		}
		SendInput, {Enter}
	}
	SendInput, {Enter}{Enter}{Enter}{Enter}PRE CLI{Enter}E{Enter}PRE ER{Enter}E{Enter}PRE IN{Enter}E{Enter}PRE SDC{Enter}E{Enter}PROF SET{Enter}E{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}
PrintOTReport(test1, test2, rcvd, printer) { ;From main screen print specific test1 to test2 rcvd status pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}33{Enter}TEST{Enter}%test1%{Enter}%test2%{Enter}{Enter}{Enter}{Enter}{Enter}COCHHA{Enter}E{Enter}
	If (rcvd != "ALL") {
		SendInput, {Enter}{Enter}{Enter}
		If (rcvd = "RECEIVED") {
			SendInput, RECD{Enter}I{Enter}UNV{Enter}I{Enter}RES{Enter}I{Enter}
		} Else {
			SendInput, ORD{Enter}I{Enter}COLB{Enter}I{Enter}
		}
	}
	SendInput, {Enter}{Enter}PRE CLI{Enter}E{Enter}PRE ER{Enter}E{Enter}PRE IN{Enter}E{Enter}PRE SDC{Enter}E{Enter}PROF SET{Enter}E{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}
PrintMicroOSReport(rcvd, printer) { ;From main screen print micro rcvd status pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}40{Enter}26{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}
	If (rcvd != "ALL") {
		SendInput, SD{Enter}
		If (rcvd = "RECEIVED") {
			SendInput, I{Enter}{Enter}
		} Else {
			SendInput, E{Enter}
		}
	}
	SendInput, {Enter}{Enter}{Enter}COCCBA{Enter}I{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}
PrintMicroOPReport(test1, test2, rcvd, printer) { ;From main screen print specific test1 to test2 micro rcvd status pending to specified printer and wait 3 seconds
	winActivate, LAB.COCCBA 
	SendInput, {Enter}40{Enter}27{Enter}{F10}PROC{Enter}%test1%{Enter}%test2%{Enter}{Enter}{Enter}
	If (rcvd != "ALL") {
		SendInput, SD{Enter}
		If (rcvd = "RECEIVED") {
			SendInput, I
		} Else {
			SendInput, E
		}
		SendInput, {Enter}
	}
	SendInput, {Enter}COCHHA{Enter}E{Enter}{F12}{F10}%printer%{Enter}
	sleep, 5000
	return
}

;#I:: ;OPEN INSTRUMENT QUEUE
;queue:=MsgBox_SelectString("Open Queue","Instrument Queue?","VIT1|VIT2|DXU|XN|CELLA|TOP1|TOP2")
;If !queue ;nothing selected
;	return
;SendInput, {F11}Y{Enter}{Enter}23{Enter}%queue%{Enter}T{Enter}1{Enter}{Enter}
;return

; ** INSTRUMENT QUEUES **
#1::
OPENQUEUE("ATELLICA")
return
#2::
OPENQUEUE("ATELLICA")
return
#3::
OPENQUEUE("XN")
return
#4::
OPENQUEUE("CELLA")
return
#5::
OPENQUEUE("DXU")
return
#6::
OPENQUEUE("TOP1")
return
#7::
OPENQUEUE("TOP2")
return
;#T::
;OPENQUEUE("ATL")
;return

OPENQUEUE(queue) {
	SendInput, {F11}Y{Enter}{Enter}23{Enter}%queue%{Enter}T{Enter}1{Enter}{Enter}
	return
}

#A:: ;CLOSE/OPEN BATCHES
bench:=MsgBox_SelectString("Close/Open batches","Which batches to close/open?`nONLY RUN ONCE A DAY AFTER MIDNIGHT","CHEM|HEME|BB")
If !bench ;nothing selected
	return
If (bench = "CHEM") {
	OPENBATCH("ATELLICA")
} Else If (bench = "HEME") {
	OPENBATCH("DXU")
	OPENBATCH("TOP1")
	OPENBATCH("TOP2")
	OPENBATCH("XN")
	OPENBATCH("CELLA")
} Else If (bench = "BB") {
	OPENBBBATCH("LUM1")
	OPENBBBATCH("LUM2")
}
reload
return

OPENBATCH(batchid) {
	SendInput, 23{Enter}%batchid%{Enter}N{Enter}1{Enter}ON{Enter}{Enter}Y{Enter}{Enter}{Enter}ON{Enter}{Enter}
	sleep, 500
	SendInput, ARO{Enter}{F11}Y{Enter}{Enter}
	sleep, 500
	return
}
OPENBBBATCH(batchid) {
	SendInput, 39{Enter}98{Enter}11{Enter}%batchid%{Enter}N{Enter}1{Enter}ON{Enter}{Enter}{Enter}Y{Enter}{Enter}{Enter}{F11}Y{Enter}{Enter}
	sleep, 500
	return
}

MsgBox_SelectString(Title,Message,Strings)
{
	Gui,55:Add,Text,,%Message%
	Gui,55:Add,ListBox,%Size%,%Strings%
	GuiControlGet,Box,55:Pos,ListBox1
	Gui,55:Add,Button,% "Default g55OK w75 y+10 xp+" (BoxW / 2) - 38,OK
	
	Gui,55:-MinimizeBox
	Gui,55:-MaximizeBox
	
	Gui,55:Show,,%Title%
	Gui,55:+LastFound
	WinWaitClose
	Gui,55:Destroy
	return Result
	
	55OK:
	GuiControlGet,Selected,55:,ListBox1
	Result:=Selected
	Gui,55:Destroy
	return ;This won't end the function, just the g55OK thread.
}

#Z::
SendInput, N{Enter}C{Enter}CPL{Enter}CPL{Enter}
return