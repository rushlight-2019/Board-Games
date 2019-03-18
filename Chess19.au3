AutoItSetOption("MustDeclareVars", 1)

Global $ver = "0.07 17 Mar 2019"

#include <Debug.au3>
_DebugSetup(@ScriptName & " " & $ver, True) ; start

_DebugOut($ver)
Global $DEBUG = @error = 0
Global $TESTING = True

#cs ----------------------------------------------------------------------------
	to do
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

0.07 17 Mar 2019 Start game
	0.06 8 Mar 2019 Display moves
	0.05 8 Mar 2019 Select start to move to
	0.04 7 Mar 2019 Input Pieces
	0.03 6 Mar 2019 Update board
	0.02 6 Mar 2019 Display board
	0.01 5 Mar 2019 Fen to data
	0.00 1 Mar 2019  Start

	Going to start with the way I know how to do graphic
	then replace with GUIplus, maybe.

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

Static $UserLoction = EnvGet("USERPROFILE")
Static $Temp = EnvGet("TEMP")

AutoItSetOption("SendKeyDelay", 15)
AutoItSetOption("SendKeyDownDelay", 15)

;Global
;Display
;Board is 512 x 512
Global Static $g_BoardHor = 700
Global Static $g_BoardVer = 512

;boards
Global $g_aCtrlDisplay[8][8]
Global $g_aCtrlDisplayBG[8][8]
Global $g_aBackGound[8][8]
Global $g_board[8][8]
Global $g_old_board[8][8]
Global $g_sNextColor, $g_sCastling, $g_sEn_passant, $g_iHalfmove, $g_iFullmove

Global $Player_color
Const $fen_play_white = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
Const $fen_play_black = "RNBKQBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbkqbnr w KQkq - 0 1"

#cs
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
#ce

Const $Diana_white = "rnbkbr/pppppp/6/6/PPPPPP/RBNKBR w KQkq - 0 1"
Const $Diana_black = "RBKNBR/PPPPPP/6/6/pppppp/rbknbr w KQkq - 0 1"

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
Global $g_Rank
Global $g_File
; Piece = " & $g_board[$iRank][$iFile]
Global $g_iRankFrom
Global $g_iFileFrom

;See bottom for Main Call

Func Main()
	Local $l_fExit = False

MainForm()

	CreateBoard()
	FenBoard($fen_play_white)
	$l_fExit = True
	Do ;game loop
		UpdateBoard()
		$l_fExit = GetInput()
		If $l_fExit Then
			ExitLoop
		EndIf
		$g_iRankFrom = $g_Rank
		$g_iFileFrom = $g_File

		Do
			ShowBG($g_Rank, $g_File, 1)

			$l_fExit = GetInput() ;To
			If $l_fExit Then
				ExitLoop
			EndIf
		Until Not ($g_iRankFrom = $g_Rank And $g_iFileFrom = $g_File) ;Put in Check Valid move here

		DoMove()
		;Store move in file
		;List move in display

	Until $l_fExit

	;	MsgBox(0, "Game done", "Game done")

EndFunc   ;==>Main
#CS INFO
	41905 V7 3/17/2019 7:01:31 PM V6 3/8/2019 8:15:47 PM V5 3/7/2019 9:25:10 PM V4 3/7/2019 12:11:06 AM
#CE

Func MainForm()
local $MainForm, $Title, $List1, $Label1, $group1, $Label2, $button1, $Label3, $Label4, $nMsg

$MainForm = GUICreate("Chess 19 - Version: " & $Ver, 615, 438, 535, 331)
$Title = GUICtrlCreateLabel("Chess 19", 16, 8, 589, 34, $SS_CENTER)
GUICtrlSetFont(-1, 16, 800, 0, "Arial Black")
$Label1 = GUICtrlCreateLabel("Users:", 56, 80, 34, 17)
$Group1 = GUICtrlCreateGroup("", 8, 64, 601, 97)

$Label2 = GUICtrlCreateLabel("Games  - Import - Save  - New", 40, 184, 146, 17)
$List1 = GUICtrlCreateList("", 32, 208, 105, 136)
;$Combo1 = GUICtrlCreateCombo("Combo1", 176, 208, 129, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$Button1 = GUICtrlCreateButton("New Game", 360, 208, 89, 33)
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

EndFunc
#CS INFO
	63645 V1 3/17/2019 7:01:31 PM
#CE

	$g_board[$g_Rank][$g_File] = $g_board[$g_iRankFrom][$g_iFileFrom]
	$g_board[$g_iRankFrom][$g_iFileFrom] = 0
	ShowBG($g_iRankFrom, $g_iFileFrom)

EndFunc   ;==>DoMove
#CS INFO
#CS INFO
	63645 V1 3/17/2019 7:01:31 PM
#CE

#CE

Func GetInput()
	Local $nMsg, $Rank, $File

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Return True
		EndSwitch
		If $nMsg > 0 Then
			For $Rank = 0 To 7
				For $File = 0 To 7
					If $nMsg = $g_aCtrlDisplayBG[$Rank][$File] Then
						$g_Rank = $Rank
						$g_File = $File
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
	27130 V2 3/8/2019 8:15:47 PM V1 3/7/2019 9:25:10 PM
#CE

Func ShowBG($iRank, $iFile, $BG = 0) ; 0 = Base, 1= Section
	Local $SelColor = 0x92ff24 ; Selected

	Switch $BG
		Case 0
			If $g_aBackGound[$iRank][$iFile] = 0 Then
				$SelColor = $COLOR_WHITE
			Else
				$SelColor = $COLOR_RED
			EndIf
	EndSwitch

	GUICtrlSetBkColor($g_aCtrlDisplayBG[$iRank][$iFile], $SelColor)

EndFunc   ;==>ShowBG
#CS INFO
	23545 V1 3/8/2019 8:15:47 PM
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

		;pause()

		$c = False
		For $iRank = 0 To 7
			For $iFile = 0 To 7
				$g_aCtrlDisplayBG[$iRank][$iFile] = GUICtrlCreateGraphic($iFile * 64, (7 - $iRank) * 64, 64, 64) ;Clickable
				$g_aCtrlDisplay[$iRank][$iFile] = GUICtrlCreatePic(@ScriptDir & "\images\empty.bmp", $iFile * 64, (7 - $iRank) * 64, 64, 64)
				If $c Then
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$iRank][$iFile], $COLOR_White)
					$g_aBackGound[$iRank][$iFile] = 0
					$c = False
				Else
					GUICtrlSetBkColor($g_aCtrlDisplayBG[$iRank][$iFile], $COLOR_red)
					$g_aBackGound[$iRank][$iFile] = 1
					$c = True
				EndIf
			Next
			$c = Not $c
			;pause()
		Next
	EndIf
EndFunc   ;==>CreateBoard
#CS INFO
	87968 V7 3/17/2019 7:01:31 PM V6 3/8/2019 8:15:47 PM V5 3/7/2019 9:25:10 PM V4 3/7/2019 12:36:00 PM
#CE

Func CreateMoveText()

EndFunc   ;==>CreateMoveText
#CS INFO
	4243 V1 3/17/2019 7:01:31 PM
#CE

Func UpdateBoard()
	Local $iRank, $iFile

	For $iRank = 0 To 7
		For $iFile = 0 To 7
			Select
				Case $g_board[$iRank][$iFile] == "R"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhiteRook)
				Case $g_board[$iRank][$iFile] == "N"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhiteKnight)
				Case $g_board[$iRank][$iFile] == "B"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhiteBishop)
				Case $g_board[$iRank][$iFile] == "K"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhiteKing)
				Case $g_board[$iRank][$iFile] == "Q"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhiteQueen)
				Case $g_board[$iRank][$iFile] == "P"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hWhitePawn)
				Case $g_board[$iRank][$iFile] == "p"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackPawn)
				Case $g_board[$iRank][$iFile] == "k"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackKing)
				Case $g_board[$iRank][$iFile] == "q"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackQueen)
				Case $g_board[$iRank][$iFile] == "b"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackBishop)
				Case $g_board[$iRank][$iFile] == "n"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackKnight)
				Case $g_board[$iRank][$iFile] == "r"
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hBlackRook)
				Case Else
					GUICtrlSetImage($g_aCtrlDisplay[$iRank][$iFile], $hEmpty)
			EndSelect
		Next
		;pause()
	Next
EndFunc   ;==>UpdateBoard
#CS INFO
	117325 V4 3/8/2019 8:15:47 PM V3 3/7/2019 9:25:10 PM V2 3/7/2019 12:36:00 PM V1 3/7/2019 12:11:06 AM
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
	Local $x, $z, $iRank, $iFile, $who

	$iRank = 7
	$iFile = 0
	$z = 1

	Do
		$who = StringMid($o_sFen, $z, 1)
		Switch $who
			Case "/"
				$iRank -= 1
				$iFile = 0
			Case 1 To 8
				For $x = 1 To $who
					$g_board[$iRank][$iFile] = "0"
					$iFile += 1
				Next
			Case "R", "N", "B", "K", "Q", "P", "r", "n", "b", "k", "q", "p"
				$g_board[$iRank][$iFile] = $who
				$iFile += 1
			Case " "
				;exit
		EndSwitch
		$z += 1

	Until $who = " "

	;_ArrayDisplay($g_board)

	$g_sNextColor = StringMid($o_sFen, $z, 1) ; w or b
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
	73344 V2 3/6/2019 2:09:26 AM V1 3/5/2019 4:52:41 PM
#CE

;Main
Main()
Exit

Func Out($string)
	_DebugOut($string)
EndFunc   ;==>Out
#CS INFO
	4392 V1 3/2/2019 2:02:06 PM
#CE

Func Pause()
	MsgBox(0, "", "")
EndFunc   ;==>Pause
#CS INFO
	3360 V1 3/6/2019 2:09:26 AM
#CE

;~T !!ScriptMine.exe V0.32 14 Mar 2019 - 3/17/2019 7:01:31 PM
