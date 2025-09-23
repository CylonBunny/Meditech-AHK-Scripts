MsgBox, , Chem Bench Aid,
(
	
		~~Heme Comp Aid!~~

To Use :
	With Meditech tech menu open
	Press Win+Q : Answer prompts and wait

	Tech ID should be what you use to recieve batches in MobiLab
	IE somthing like L.FQU6670, L.BXI65711 or L.LAB.NMH
To Close :
	Locate green box with H icon in system tray -> right-click -> Exit

	~~Made using AutoHotKey by J. Ochoa, 12/25/19~~
)

#Q::
;Quary for techID and days to search
InputBox, 34id, 34ID, Please enter your Meditech ID`n(L.34ID or L.LAB.initials), , 300, 150
askdays:
     InputBox, days, Days back?, How many days back should this search look?`n(#), , 300, 150, , , , , 1
if days is not integer
     goto, askdays
	
;Change format to T-days, wait is 800 milliseconds per day searched
tdays := "T-" . days
wait := days * 800

;Calculate total time in mins and output
totalmins := Ceil((wait * 20) / 60000)
MsgBox, 1, Continue?,This will take about %totalmins% minutes to run`nContinue?
IfMsgBox, Cancel
	Return

;Bring focus to Meditech and run each search
winActivate, LAB.COCCBA
send, 27{Enter}
LRA(34id, "WBC", tdays, wait)
LRA(34id, "ESR", tdays, wait)
LRA(34id, "PREGS", tdays, wait)
LRA(34id, "PREGU", tdays, wait)
LRA(34id, "MONO", tdays, wait)
LRA(34id, "FFN", tdays, wait)
LRA(34id, "EOSU", tdays, wait)
LRA(34id, "APT", tdays, wait)
MRA(34id, "WET", tdays, wait)
LRA(34id, "TEGANGLECIT", tdays, wait)
LRA(34id, "FAC8", tdays, wait)
LRA(34id, "AT3", tdays, wait)
LRA(34id, "AXa", tdays, wait)
LRA(34id, "PT,PAT,IMMED", tdays, wait)
LRA(34id, "UBLD", tdays, wait)
LRA(34id, "UWBC", tdays, wait)
LRA(34id, "BFRBC", tdays, wait)
LRA(34id, "SYNFLDFIB", tdays, wait)
LRA(34id, "NEUTM#", tdays, wait)
LRA(34id, "MASM", tdays, wait)

MsgBox, , Done!, Done!
return

LRA(techid, test, days, wait) {
;assuming in 27... launch LRA open first output in preview and then return to 27
send, LRA{Enter}{F10}%days%{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}%test%{Enter}%test%{Enter}{Enter}{Enter}{Enter}%techid%{Enter}I{Enter}{F12}
;sleep, 1000
;winActivate, LAB.COCCBA 
send, {RControl}I{Enter}{F10}PREVIEW{Enter}
sleep, %wait%
winActivate, LAB.COCCBA 
;Doing some keymagic to return even if preview failed (IE no tests found)
send, {Enter}{F11}Y{Enter}{F11}{Enter}27{Enter}
;sleep, 1000
return
}

MRA(techid, test, days, wait) {
;assuming in 27... launch MRA open first output in preview and then return to 27
send, MRA{Enter}{F10}%days%{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}{Enter}%test%{Enter}%test%{Enter}{Enter}{Enter}{Enter}{Enter}%techid%{Enter}I{Enter}{F12}
;sleep, 1000
;winActivate, LAB.COCCBA 
send, {RControl}I{Enter}{F10}PREVIEW{Enter}
sleep, %wait%
winActivate, LAB.COCCBA 
;Doing some keymagic to return even if preview failed (IE no tests found)
send, {Enter}{F11}Y{Enter}{F11}{Enter}27{Enter}
;sleep, 1000
return
}
