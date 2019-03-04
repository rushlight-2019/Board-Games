AutoItSetOption("MustDeclareVars", 1)

Global $ver = "0.01 2 Mar 2019 Create board."

#include <Debug.au3>
_DebugSetup(@ScriptName & " " & $ver, True) ; start

_DebugOut($ver)
Global $_debug = @error = 0
Global $TESTING = True

Func Out($string)
	_DebugOut($string)
EndFunc   ;==>Out
#CS INFO
	4392 V1 3/2/2019 2:02:06 PM
#CE


#cs ----------------------------------------------------------------------------
	to do

	0.01 2 Mar 2019 Create board.
	0.00 1 Mar 2019  Start


#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Misc.au3>
#include <Constants.au3>


Static $UserLoction = EnvGet("USERPROFILE")
Static $Temp = EnvGet("TEMP")

AutoItSetOption("SendKeyDelay", 15)
AutoItSetOption("SendKeyDownDelay", 15)





;Main
Main()


Func Main()
	Out($ver & " " & $_debug)
	MsgBox(0, $ver, $ver & " " & $_debug)
EndFunc   ;==>Main
#CS INFO
	6070 V1 3/2/2019 2:02:06 PM
#CE
Exit
;~T ScriptMine.exe 0.98 26 Feb 2019 Backup 3/2/2019 2:02:06 PM
