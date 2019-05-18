AutoItSetOption("MustDeclareVars", 1)
Global $ver = "0.10 15 May 2019 Moving piece"

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=0.0.0.9
#AutoIt3Wrapper_Icon=R:\!Autoit\Ico\chess.ico
#AutoIt3Wrapper_Res_Description=Chess to send to another location
#AutoIt3Wrapper_Res_LegalCopyright=(c) Phillip Forrestal 2019
;#AutoIt3Wrapper_Outfile=Chess19.exe
#AutoIt3Wrapper_Outfile_x64=Chess19.exe
;#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "R:\!Autoit\Blank\_Debug.au3"

Global Static $TESTING = @Compiled = 0
Global Static $MESSAGE = True ;$TESTING

If $MESSAGE Then
	_DebugSetup(@ScriptName, True) ; start
	_DebugOut($ver)
	;Global $DEBUG = @error = 0
EndIf

Func DataOut($sString = "", $sString2 = "")
	If $MESSAGE Then
		_DebugOut($sString & " " & $sString2)
	EndIf
EndFunc   ;==>DataOut
#CS INFO
	9005 V1 5/9/2019 12:49:19 PM
#CE

Func Pause($string = "", $sString2 = "")
	MsgBox(262144, $string, $sString2)
EndFunc   ;==>Pause
#CS INFO
	6847 V1 5/9/2019 12:49:19 PM
#CE

$ver = StringLeft($ver, StringInStr($ver, " ", 0, 4))

#cs ----------------------------------------------------------------------------

	X Y only deals with the display board
	File Rank only deals with the game board
	The 'game board' is never flipped, it the White's perspective

	TO DO
	Flicking
	Start game menu
	Check import game
	Add new user
	Load save or imported game

	Set up game
	Move
	Save game
	Export game for Email or Network location
	Repeat

	Check for right moves.

	Add to Move list, save

	0.10 14 May 2019 Moving piece
	0.09 14 May 2019 Change 'R' to a number

	0.08 17 Apr 2019  My system updates nothing to do with this  program
	0.07 20 Mar 2019 Flip game board. see top note.
	0.06 8 Mar 2019 Display moves
	0.05 8 Mar 2019 Select start to move to
	0.04 7 Mar 2019 Input Pieces
	0.03 6 Mar 2019 Update board
	0.02 6 Mar 2019 Display board
	0.01 5 Mar 2019 Fen to data
	0.00 1 Mar 2019  Start

	Log in  skip if one use
	if no user go to new user
	Check download folder for Chess Package
	Check network folder for Chess Package
	Ask to run game from Save
	New users

	do a move

	Output local file
	Output email and network locations packages.

#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Misc.au3>
#include <Constants.au3>
#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>

;Global
;Display
;Board is 512 x 512
Global Static $g_BoardHor = 700
Global Static $g_BoardVer = 512

;boards
;Controls for display board
Global $g_aCtrlDisplay[8][8] ; pieces
Global $g_aCtrlDisplayBG[8][8] ; White/Red

Global $g_aBackGound[8][8] ; which is white/red
Global $g_aSelected[8][8] ; which is using the select colors  use to kill the flicker

Global $g_board[8][8] ; pieces lasy out
;Global $g_a[8][8] ;unnow

Global $g_sNextColor, $g_sCastling, $g_sEn_passant, $g_iHalfmove, $g_iFullmove

Global $g_BottomColor
; FEN Piece placement (from White's perspective).
Static $g_sFen_Play = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

Static $WHITE = "1"
Static $BLACK = "-1"
Static $EMPTY = 0

Static $wPAWN = 2 ;P
Static $bPAWN = -2 ;p

Static $wROOK = 3 ;R
Static $bROOK = -3 ;r

Static $wKNIGHT = 4 ;N
Static $bKNIGHT = -4 ;n

Static $wBISHOP = 5 ;B
Static $bBISHOP = -5 ;b

Static $wQUEEN = 6 ;Q
Static $bQUEEN = -6 ; q

Static $wKING = 7 ;K
Static $bKING = -7 ;k

#cs

	LATER
	The game Diana chess (or Ladies chess) was suggested by Hopwood in 1870.
	rbnkbr
	pppppp
	-
	-
	PPPPPP
	RBNKBR
	There are no queens on the board and pawns can't promote to queens either.
	Pawns cannot move forward two squares on their initial move.
	Castling is done by switching the positions of the king and rook.
	The same condition as in chess apply for castling
	(e.g., the king should not be under check, neither rook nor king should have moved before etc.)

	Const $Diana_white = "rnbkbr/pppppp/6/6/PPPPPP/RBNKBR w KQkq - 0 1"
#ce

;pieces
Global Const $hWhitePawn = @ScriptDir & "\images\wpawn.bmp"
Global Const $hWhiteBishop = @ScriptDir & "\images\wbishop.bmp"
Global Const $hWhiteKnight = @ScriptDir & "\images\wknight.bmp"
Global Const $hWhiteRook = @ScriptDir & "\images\wrook.bmp"
Global Const $hWhiteQueen = @ScriptDir & "\images\wqueen.bmp"
Global Const $hWhiteKing = @ScriptDir & "\images\wking.bmp"

Global Const $hBlackPawn = @ScriptDir & "\images\bpawn.bmp"
Global Const $hBlackBishop = @ScriptDir & "\images\bbishop.bmp"
Global Const $hBlackKnight = @ScriptDir & "\images\bknight.bmp"
Global Const $hBlackRook = @ScriptDir & "\images\brook.bmp"
Global Const $hBlackQueen = @ScriptDir & "\images\bqueen.bmp"
Global Const $hBlackKing = @ScriptDir & "\images\bking.bmp"

Global Const $hEmpty = @ScriptDir & "\images\empty.bmp"

;Game
; Piece = " & $g_board[$X][$Y] $X = Rank $Y = File.
; White = LL 0,0 1A  UL 7,0 8A  LR 0,7 1H  UR 7,7 8H
; bd
; Black = LL 0,0 8H  UL 7,0 1H  LR 0,7 8A  UR 7,7 1A
; bd         7,7        0,7        7,0        0,0
Global $g_Rank ;~~
Global $g_File
Global $g_Piece
Global $g_Playing

Global $g_RankTo
Global $g_FileTo
Global $g_RankFrom
Global $g_FileFrom
Global $g_X
Global $g_Y

;game
Global $g_FileName

;See bottom for Main Call

Func Main()
	Setup()
	Return

	If $TESTING Then
		$g_FileName = "R:\!Autoit\GitHub\Board-Games\Test.Chess"
	Else
		$g_FileName = PickGame()
	EndIf
EndFunc   ;==>Main
#CS INFO
	12208 V1 5/14/2019 8:14:38 AM
#CE

Func StartMenu()
	Local $Form1, $button1, $Button2, $Button3, $nMsg

	#Region ### START Koda GUI section ### Form=
	$Form1 = GUICreate("Chess", 189, 150, 189, 126)
	$button1 = GUICtrlCreateButton("Last game", 32, 16, 121, 25)
	$Button2 = GUICtrlCreateButton("Pick a game", 32, 56, 121, 25)
	$Button3 = GUICtrlCreateButton("New game", 32, 96, 121, 33)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit

		EndSwitch
	WEnd

EndFunc   ;==>StartMenu
#CS INFO
	36505 V1 5/14/2019 8:14:38 AM
#CE

Func NewGame()
	Local $Form1, $button1, $Button2, $Radio1, $Radio2, $nMsg

	#Region ### START Koda GUI section ### Form=
	$Form1 = GUICreate("New Game", 405, 294, 598, 326)
	$Radio1 = GUICtrlCreateRadio("You White", 32, 16, 161, 33)
	$Radio2 = GUICtrlCreateRadio("You Black", 32, 56, 89, 17)
	GUIStartGroup()
	$button1 = GUICtrlCreateButton("Select Oppant", 8, 104, 113, 41)
	$Button2 = GUICtrlCreateButton("Start", 8, 160, 113, 49)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit

		EndSwitch
	WEnd
EndFunc   ;==>NewGame
#CS INFO
	41817 V1 5/14/2019 8:14:38 AM
#CE

Func PickGame()
	$g_FileName = FileOpenDialog("Load Game", @ScriptDir & "\Games", "(*.chess)", "", $FD_FILEMUSTEXIST)
	If @error <> 0 Then
		Return
	EndIf

EndFunc   ;==>PickGame
#CS INFO
	12711 V1 5/14/2019 8:14:38 AM
#CE

Func Setup()
	Local $l_fExit = False
	Local $l_StartWhite = False

	If False Then
		MainForm()
	Else
		$g_FileName = "test.chess"
		$g_BottomColor = $BLACK
		;$g_BottomColor = $WHITE
	EndIf

	CreateBoard()

	FenBoard($g_sFen_Play)

	$l_fExit = True
	$g_Playing = $g_BottomColor

	DataOut("Start Game Loop")

	Do ;game loop
		UpdateBoard($g_BottomColor)

		GetStartPos() ;~~
		Pause("Change Backgrout for From")
		ShowBG($g_RankFrom, $g_FileFrom, 1)

		;GetInput() ;Return true exit, board location

		; data stored in $g_Rank, $g_File and $g_Piece

		Pause("Temp Exit Game Look")
		Return

		If $l_fExit Then
			ExitLoop
		EndIf
		$g_RankFrom = $g_Rank
		$g_FileFrom = $g_File

		Do
			ShowBG($g_Y, $g_X, 1)

			$l_fExit = GetInput() ;To
			If $l_fExit Then
				ExitLoop
			EndIf
			$g_FileTo = $g_File
			$g_RankTo = $g_Rank

		Until Not ($g_RankFrom = $g_Rank And $g_FileFrom = $g_File) ;Put in Check Valid move here

		DoMove()
		;Store move in file
		;List move in display

	Until $l_fExit

	;	MsgBox(0, "Game done", "Game done")

EndFunc   ;==>Setup
#CS INFO
	74931 V13 5/14/2019 5:47:13 PM V12 5/14/2019 4:54:04 PM V11 5/14/2019 9:00:10 AM V10 5/14/2019 8:14:38 AM
#CE

Func DoMove() ;No check for valid for now
	$g_board[$g_RankTo][$g_FileTo] = $g_board[$g_RankFrom][$g_FileFrom]
	$g_board[$g_RankFrom][$g_FileFrom] = $EMPTY
	;
	;	ShowBG($g_RankFrom, $g_FileFrom)
EndFunc   ;==>DoMove
#CS INFO
	17373 V4 5/14/2019 4:54:04 PM V3 5/14/2019 8:14:38 AM V2 3/20/2019 2:40:29 AM V1 3/8/2019 8:15:47 PM
#CE

;~~
Func GetStartPos() ; Pick up a piece, check to make it your piece
	Do
		Do
			GetInput() ; data stored in $g_Rank, $g_File and $g_Piece
			DataOut($g_Rank, $g_File)
			DataOut("Piece GSP", $g_Piece)
			Local $Flag = False

			If $g_Piece > 0 Then ;check to make sure it the player piece
				If $g_Playing = $WHITE Then
					$Flag = True
				EndIf
			Else
				If $g_Playing = $BLACK Then
					$Flag = True
				EndIf
			EndIf
		Until $Flag

		DataOut("Piece is valid, now check to see it it has a move")

		Pause("Working At~~")
		$g_RankFrom = $g_Rank
		$g_FileFrom = $g_File
		$g_RankTo = -1
		$g_FileTo = -1

	Until ValidMove(0)
EndFunc   ;==>GetStartPos
#CS INFO
	44889 V3 5/14/2019 5:47:13 PM V2 5/14/2019 4:54:04 PM V1 5/14/2019 8:14:38 AM
#CE

Func ValidMove($Type) ; $g_RankFrom, $gFileFrom, $g_Piece  $Type=0:Can move
	Local $Rank, $File, $Direction, $Flag

	$Flag = False ; False = move not valid - True = Can move this way  =
	Switch $g_Piece
		Case $wPAWN, $bPAWN
			$Flag = CheckPawn($Type)
		Case $wROOK, $bROOK
			$Flag = CheckRook($Type)
	EndSwitch
	If $Flag Then
		Return True
	EndIf
	DataOut("ValidMove failed")
	Return False

EndFunc   ;==>ValidMove
#CS INFO
	30329 V3 5/14/2019 4:54:04 PM V2 5/14/2019 9:00:10 AM V1 5/14/2019 8:14:38 AM
#CE

Func CheckPawn($Type) ;
	Local $f, $p, $r, $a

	For $Y = 1 To 4
		DataOut("Direction", $Y)
		$f = $g_FileFrom
		$r = $g_RankFrom
		$a = False

		Switch $Y
			Case 1 ;Right attact
				$f = $g_FileFrom + 1
				$r = $g_RankFrom + 1
				$a = True
			Case 2 ; Left Attact
				$f = $g_FileFrom - 1
				$r = $g_RankFrom + 1
				$a = True
			Case 3 ; Up one
				$r = $g_RankFrom + 1
			Case 4 ; Up two if on start position
				If $g_RankFrom = 1 Then
					$r = $g_RankFrom + 1
					If OnBoard($r, $f) Then
						If $g_board[$r][$f] = $EMPTY Then
							$r = $g_RankFrom + 1
						EndIf
					EndIf
				Else
					$r = -1 ;off board fail
				EndIf
		EndSwitch
		DataOut("Move", $Y)
		DataOut($r, $f)

		If OnBoard($r, $f) Then

			$p = $g_board[$r][$f]

			Pause("Piece at test ", $p)
			Switch $Type
				Case 0 ; looking for free or other player  only need one
					If $a And $p <> $EMPTY Then
						If $g_Playing = $BLACK Then ;+x
							Return True
						EndIf
					Else
						If $g_Playing = $WHITE Then ; -x
							Return True
						EndIf
					EndIf

					If $p = $EMPTY Then
						Return True
					EndIf
					ExitLoop ; Because found a your piece.  start new direction

			EndSwitch
		Else
			ExitLoop ; off edge
		EndIf

		Pause("Dir2")
	Next
	Pause("Dir3")
	Return False

EndFunc   ;==>CheckPawn
#CS INFO
	4807 V2 5/14/2019 9:00:10 AM V1 5/14/2019 8:14:38 AM
#CE

Func CheckRook($Type)
	Local $f, $p, $r

	For $Y = 1 To 4
		DataOut("Direction", $Y)
		$f = $g_FileFrom
		$r = $g_RankFrom

		For $z = 1 To 8
			$f = $g_FileFrom
			$r = $g_RankFrom
			DataOut("Move ", $z)
			Switch $Y
				Case 1 ;Left
					$f = $g_FileFrom + $z
				Case 2 ; Up
					$r = $g_RankFrom + $z
				Case 3 ; Right
					$f = $g_FileFrom - $z
				Case 4 ; Nown
					$r = $g_RankFrom - $z
			EndSwitch
			DataOut($r, $f)

			If OnBoard($r, $f) Then
				$p = $g_board[$r][$f]
				Pause("Piece at test ", $p)
				Switch $Type
					Case 0 ; looking for free or other player  only need one
						If $p = $EMPTY Then
							Return True
						EndIf
						If $p > 0 Then ;if not empty check to see if it the other color  +White
							If $g_Playing = $BLACK Then ;+x
								Return True
							EndIf
						Else
							If $g_Playing = $WHITE Then ; -x
							EndIf
						EndIf
						ExitLoop ; Because found a your piece.  start new direction
				EndSwitch
			Else
				ExitLoop ; off edge
			EndIf

			Pause("Dir1")
		Next
		Pause("Dir2")
	Next
	Pause("Dir3")
	Return False
EndFunc   ;==>CheckRook
#CS INFO
	66322 V5 5/15/2019 10:20:45 AM V4 5/14/2019 5:47:13 PM V3 5/14/2019 4:54:04 PM V2 5/14/2019 9:00:10 AM
#CE

Func OnBoard($Rank, $File)
	If $Rank > 7 Or $Rank < 0 Then
		Return False
	EndIf
	If $File > 7 Or $File < 0 Then
		Return False
	EndIf
	DataOut("On Board")
	Return True
EndFunc   ;==>OnBoard
#CS INFO
	13139 V3 5/15/2019 10:20:45 AM V2 5/14/2019 5:47:13 PM V1 5/14/2019 9:00:10 AM
#CE

Func MainForm()
	Local $MainForm, $Title, $List1, $Label1, $group1, $Label2, $button1, $Label3, $nMsg

	$MainForm = GUICreate("Chess 19 - Version: " & $ver, 615, 438, 535, 331)
	$Title = GUICtrlCreateLabel("Chess 19", 16, 8, 589, 34, $SS_CENTER)
	GUICtrlSetFont(-1, 16, 800, 0, "Arial Black")
	$Label1 = GUICtrlCreateLabel("Users:", 56, 80, 34, 17)
	$group1 = GUICtrlCreateGroup("", 8, 64, 601, 97)

	$Label2 = GUICtrlCreateLabel("Games  - Import - Save  - New", 40, 184, 146, 17)
	$List1 = GUICtrlCreateList("", 32, 208, 105, 136)
	;$Combo1 = GUICtrlCreateCombo("Combo1", 176, 208, 129, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	$button1 = GUICtrlCreateButton("New Game", 360, 208, 89, 33)
	$Label3 = GUICtrlCreateLabel("Current game", 48, 368, 539, 17)
	;$Label4 = GUICtrlCreateLabel($Ver, 312, 408, 287, 17, $SS_RIGHT)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Return

		EndSwitch
	WEnd

EndFunc   ;==>MainForm
#CS INFO
	64133 V3 4/17/2019 2:52:17 AM V2 3/20/2019 2:40:29 AM V1 3/17/2019 7:01:31 PM
#CE

Func GetInput()
	Local $nMsg, $Y, $X

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit
				Return True
		EndSwitch
		If $nMsg > 0 Then
			For $Y = 0 To 7
				For $X = 0 To 7
					If $nMsg = $g_aCtrlDisplayBG[$Y][$X] Then
						$g_Y = $Y
						$g_X = $X
						If $g_BottomColor = $WHITE Then
							$g_File = $X ;X to File-1
							$g_Rank = $Y ;Y to Rank-1
						Else ;b
							$g_File = 7 - $X ;X to File-1
							$g_Rank = 7 - $Y ;Y to Rank-1
						EndIf
						$g_Piece = $g_board[$g_Rank][$g_File]
						DataOut("PieceGI", $g_Piece)
						Return False
					EndIf
				Next
			Next
		EndIf
	WEnd
	;Should never get here
	Return True
EndFunc   ;==>GetInput
#CS INFO
	40215 V6 5/14/2019 5:47:13 PM V5 5/14/2019 4:54:04 PM V4 5/14/2019 8:14:38 AM V3 3/20/2019 2:40:29 AM
#CE

Func ShowBG($Y, $X, $BG = 0) ; 0 = Base, 1= Section
	;Global $g_aSelected[8][8] ; which is using the select colors  use to kill the flicker
	Local $SelColor = 0x92ff24 ; Selected

	Switch $BG
		Case 0
			If $g_aBackGound[$Y][$X] = 0 Then
				$SelColor = $COLOR_WHITE
			Else
				$SelColor = $COLOR_RED
			EndIf
	EndSwitch

	GUICtrlSetBkColor($g_aCtrlDisplayBG[$Y][$X], $SelColor)
	$g_aSelected[$Y][$X] = 1 ; which is using the select colors  use to kill the flicker

EndFunc   ;==>ShowBG
#CS INFO
	35293 V2 3/20/2019 2:40:29 AM V1 3/8/2019 8:15:47 PM
#CE

Global $g_cMoveEdit

Func CreateBoard()
	Local Static $ls_ScreenBoard = -1
	Local $c

	Local $MoveTextLeft = 64 * 8 + 10
	Local $MoveTextSize = $g_BoardHor - $MoveTextLeft - 10

	If $ls_ScreenBoard = -1 Then
		$ls_ScreenBoard = GUICreate("Chess board - " & $ver, $g_BoardHor, $g_BoardVer, -1, -1)
		GUISetState(@SW_SHOW)

		GUICtrlCreateLabel("Moves", $MoveTextLeft, 10, 168, 25, $SS_CENTER)
		GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")

		$g_cMoveEdit = GUICtrlCreateEdit("", $MoveTextLeft, 35, $MoveTextSize, 200, $WS_VSCROLL)
		_GUICtrlEdit_SetReadOnly(-1, True)
		GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")

		$c = False
		For $Y = 0 To 7
			For $X = 0 To 7
				$g_aCtrlDisplayBG[$Y][$X] = GUICtrlCreateGraphic($X * 64, (7 - $Y) * 64, 64, 64) ;Clickable
				$g_aCtrlDisplay[$Y][$X] = GUICtrlCreatePic(@ScriptDir & "\images\empty.bmp", $X * 64, (7 - $Y) * 64, 64, 64)
				If $c Then
					$g_aBackGound[$Y][$X] = 0
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$Y][$X], $COLOR_White)
					$c = False
				Else
					$g_aBackGound[$Y][$X] = 1
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$Y][$X], $COLOR_red)
					$c = True
				EndIf
			Next
			$c = Not $c
		Next
	EndIf
EndFunc   ;==>CreateBoard
#CS INFO
	79287 V9 5/14/2019 4:54:04 PM V8 3/20/2019 2:40:29 AM V7 3/17/2019 7:01:31 PM V6 3/8/2019 8:15:47 PM
#CE

Func CreateMoveText()

EndFunc   ;==>CreateMoveText
#CS INFO
	4243 V1 3/17/2019 7:01:31 PM
#CE

Func UpdateBoard($Bottom)
	Local $Y, $X, $iRank, $iFile

	For $Y = 0 To 7
		For $X = 0 To 7
			If $Bottom = $WHITE Then
				$iRank = $Y
				$iFile = $X
			Else
				$iRank = 7 - $Y
				$iFile = 7 - $X
			EndIf
			Switch $g_board[$iRank][$iFile]
				Case $wROOK
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteRook)
				Case $wKNIGHT
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteKnight)
				Case $wBISHOP
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteBishop)
				Case $wKING
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteKing)
				Case $wQUEEN
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteQueen)
				Case $wPAWN
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhitePawn)
				Case $bPAWN
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackPawn)
				Case $bKING
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackKing)
				Case $bQUEEN
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackQueen)
				Case $bBISHOP
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackBishop)
				Case $bKNIGHT
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackKnight)
				Case $bROOK
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackRook)
				Case Else
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hEmpty)
			EndSwitch
			;			Global $g_aSelected[8][8] ; which is using the select colors  use to kill the flicker
			If $g_aSelected[$Y][$X] = 1 Then
				If $g_aBackGound[$Y][$X] = 0 Then
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$Y][$X], $COLOR_White)
				Else
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$Y][$X], $COLOR_red)
				EndIf
			EndIf
		Next
	Next
EndFunc   ;==>UpdateBoard
#CS INFO
	113988 V6 5/14/2019 4:54:04 PM V5 3/20/2019 2:40:29 AM V4 3/8/2019 8:15:47 PM V3 3/7/2019 9:25:10 PM
#CE

#cs
	A FEN "record" defines a particular game position, all in one text line and using only the ASCII character set. A text file with only FEN data records should have the file extension ".fen".[1]

	A FEN record contains six fields. The separator between fields is a space. The fields are:

	Piece placement (from White's perspective). Each rank is described, starting with rank 8 and ending with rank 1;
	within each rank, the contents of each square are described from file "a" through file "h".
	Following the Standard Algebraic Notation (SAN), each piece is identified by a single letter taken from the standard English names
	(pawn = "P", knight = "N", bishop = "B", rook = "R", queen = "Q" and king = "K").
	[1] White pieces are designated using upper-case letters ("PNBRQK") while black pieces use lowercase ("pnbrqk").
	Empty squares are noted using digits 1 through 8 (the number of empty squares), and "/" separates ranks.

	Active colour. "w" means White moves next, "b" means Black.

	Castling availability. If neither side can castle, this is "-". Otherwise,
	this has one or more letters: "K" (White can castle kingside), "Q" (White can castle queenside),
	"k" (Black can castle kingside), and/or "q" (Black can castle queenside).

	En passant target square in algebraic notation. If there's no en passant target square,
	this is "-". If a pawn has just made a two-square move, this is the position "behind" the pawn.
	This is recorded regardless of whether there is a pawn in position to make an en passant capture.[2]

	Halfmove clock: This is the number of halfmoves since the last capture or pawn advance.
	This is used to determine if a draw can be claimed under the fifty-move rule.

	Fullmove number: The number of the full move. It starts at 1, and is incremented after Black's move.

	starts at 8A

	Rank

#ce

Func FenBoard($o_sFen)
	Local $X, $z, $iRank, $iFile, $who

	$iRank = 7
	$iFile = 0
	$z = 1

	Do
		$who = StringMid($o_sFen, $z, 1)
		Select ; $who
			Case $who = "/"
				$iRank -= 1
				$iFile = 0
			Case Int($who) >= 1
				For $X = 1 To Int($who)
					$g_board[$iRank][$iFile] = $EMPTY
					$iFile += 1
				Next
			Case $who == "R"
				$g_board[$iRank][$iFile] = $wROOK
				$iFile += 1
			Case $who == "N"
				$g_board[$iRank][$iFile] = $wKNIGHT
				$iFile += 1
			Case $who == "B"
				$g_board[$iRank][$iFile] = $wBISHOP
				$iFile += 1
			Case $who == "K"
				$g_board[$iRank][$iFile] = $wKING
				$iFile += 1
			Case $who == "Q"
				$g_board[$iRank][$iFile] = $wQUEEN
				$iFile += 1
			Case $who == "P"
				$g_board[$iRank][$iFile] = $wPAWN
				$iFile += 1
			Case $who == "r"
				$g_board[$iRank][$iFile] = $bROOK
				$iFile += 1
			Case $who == "n"
				$g_board[$iRank][$iFile] = $bKNIGHT
				$iFile += 1
			Case $who == "b"
				$g_board[$iRank][$iFile] = $bBISHOP
				$iFile += 1
			Case $who == "k"
				$g_board[$iRank][$iFile] = $bKING
				$iFile += 1
			Case $who == "q"
				$g_board[$iRank][$iFile] = $bQUEEN
				$iFile += 1
			Case $who == "p"
				$g_board[$iRank][$iFile] = $bPAWN
				$iFile += 1
			Case $who == " "
				;exit
		EndSelect
		$z += 1

	Until $who = " "

	;_ArrayDisplay($g_board)
	If StringMid($o_sFen, $z, 1) = "w" Then ; w or b
		$g_sNextColor = $WHITE
	Else
		$g_sNextColor = $BLACK
	EndIf
	$z += 1
	$g_sCastling = ""
	Do
		$g_sCastling &= StringMid($o_sFen, $z, 1)
		$z += 1
	Until StringMid($o_sFen, $z, 1) = " "
	$z += 1
	$g_sEn_passant = ""
	Do
		$g_sEn_passant &= StringMid($o_sFen, $z, 1)
		$z += 1
	Until StringMid($o_sFen, $z, 1) = " "
	$g_iHalfmove = Int(StringMid($o_sFen, $z)) ;could be more than one digit.  Number between leading and trailing spaces
	Do
		$z += 1
	Until StringMid($o_sFen, $z, 1) = " " ;find next space
	$g_iFullmove = Int(StringMid($o_sFen, $z)) ;could be more than one digit.  Number between leading and endofline

EndFunc   ;==>FenBoard
#CS INFO
	126895 V5 5/14/2019 5:47:13 PM V4 5/14/2019 4:54:04 PM V3 3/20/2019 2:40:29 AM V2 3/6/2019 2:09:26 AM
#CE

;Main
Main()
Exit

#cs
	Board White   Black  PGN  FEN
	6		7		2
	5		6		3
	4		5		4
	3		4		5
	2		3		6
	1		2		7
	0		1		8

	.					0 1 2 3 4 5 6 7 board
	.					A B C D E F G H White
	.					h g f e d c b a Black

	Rank Board to
#ce

;~T ScriptFunc.exe V0.54a 15 May 2019 - 5/15/2019 10:20:45 AM
