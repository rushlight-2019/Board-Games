AutoItSetOption("MustDeclareVars", 1)

Global $ver = "0.08 17 Apr 2019  My system updates nothing to do with this program"

Global $DEBUG = True
Global $TESTING = True

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

	0.09 5 May 2019 Start Menu

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
Global Const $g_sFen_Play = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

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
Global $g_Rank
Global $g_File
Global $g_RankTo
Global $g_FileTo
Global $g_iRankFrom
Global $g_iFileFrom
Global $g_X
Global $g_Y

;game
Global $g_FileName

;See bottom for Main Call

Func Main()

	PickGame()




EndFunc   ;==>Main

Func PickGame()
	$g_FileName = FileOpenDialog("Load Game", @ScriptDir & "\Games", "(*.cgm)", "", $FD_FILEMUSTEXIST)
	If @error <> 0 Then
		Return
	EndIf


EndFunc   ;==>PickGame

Func Setup()
	Local $l_fExit = False
	Local $l_StartWhite = False

	If False Then
		MainForm()
	Else ;~~~~~~~~~~~~~~~~~~~~~~~~~
		$g_FileName = "test.chess"
		;$g_BottomColor = "b"
		$g_BottomColor = "w"
	EndIf

	CreateBoard()

	FenBoard($g_sFen_Play)

	$l_fExit = True
	Do ;game loop
		UpdateBoard($g_BottomColor)
		$l_fExit = GetInput() ;Return true exit, board location
		If $l_fExit Then
			ExitLoop
		EndIf
		$g_iRankFrom = $g_Rank
		$g_iFileFrom = $g_File

		Do
			ShowBG($g_Y, $g_X, 1)

			$l_fExit = GetInput() ;To
			If $l_fExit Then
				ExitLoop
			EndIf
			$g_FileTo = $g_File
			$g_RankTo = $g_Rank

		Until Not ($g_iRankFrom = $g_Rank And $g_iFileFrom = $g_File) ;Put in Check Valid move here

		DoMove()
		;Store move in file
		;List move in display

	Until $l_fExit

	;	MsgBox(0, "Game done", "Game done")

EndFunc   ;==>Setup
#CS INFO
	61112 V9 4/17/2019 2:52:17 AM V8 3/20/2019 2:40:29 AM V7 3/17/2019 7:01:31 PM V6 3/8/2019 8:15:47 PM
#CE

Func DoMove() ;No check for valid for now
	$g_board[$g_RankTo][$g_FileTo] = $g_board[$g_iRankFrom][$g_iFileFrom]
	$g_board[$g_iRankFrom][$g_iFileFrom] = 0
	;
	;	ShowBG($g_iRankFrom, $g_iFileFrom)
EndFunc   ;==>DoMove
#CS INFO
	17616 V2 3/20/2019 2:40:29 AM V1 3/8/2019 8:15:47 PM
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
				Return True
		EndSwitch
		If $nMsg > 0 Then
			For $Y = 0 To 7
				For $X = 0 To 7
					If $nMsg = $g_aCtrlDisplayBG[$Y][$X] Then
						$g_Y = $Y
						$g_X = $X
						If $g_BottomColor = "w" Then
							$g_File = $X ;X to File-1
							$g_Rank = $Y ;Y to Rank-1
						Else ;b
							$g_File = 7 - $X ;X to File-1
							$g_Rank = 7 - $Y ;Y to Rank-1

						EndIf
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
	34187 V3 3/20/2019 2:40:29 AM V2 3/8/2019 8:15:47 PM V1 3/7/2019 9:25:10 PM
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

		;pause()

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
			;pause()
		Next
	EndIf
EndFunc   ;==>CreateBoard
#CS INFO
	80651 V8 3/20/2019 2:40:29 AM V7 3/17/2019 7:01:31 PM V6 3/8/2019 8:15:47 PM V5 3/7/2019 9:25:10 PM
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
			If $Bottom = "w" Then
				$iRank = $Y
				$iFile = $X
			Else
				$iRank = 7 - $Y
				$iFile = 7 - $X
			EndIf
			Select
				Case $g_board[$iRank][$iFile] == "R"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteRook)
				Case $g_board[$iRank][$iFile] == "N"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteKnight)
				Case $g_board[$iRank][$iFile] == "B"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteBishop)
				Case $g_board[$iRank][$iFile] == "K"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteKing)
				Case $g_board[$iRank][$iFile] == "Q"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhiteQueen)
				Case $g_board[$iRank][$iFile] == "P"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hWhitePawn)
				Case $g_board[$iRank][$iFile] == "p"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackPawn)
				Case $g_board[$iRank][$iFile] == "k"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackKing)
				Case $g_board[$iRank][$iFile] == "q"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackQueen)
				Case $g_board[$iRank][$iFile] == "b"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackBishop)
				Case $g_board[$iRank][$iFile] == "n"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackKnight)
				Case $g_board[$iRank][$iFile] == "r"
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hBlackRook)
				Case Else
					GUICtrlSetImage($g_aCtrlDisplay[$Y][$X], $hEmpty)
			EndSelect
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
	134984 V5 3/20/2019 2:40:29 AM V4 3/8/2019 8:15:47 PM V3 3/7/2019 9:25:10 PM V2 3/7/2019 12:36:00 PM
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
		Switch $who
			Case "/"
				$iRank -= 1
				$iFile = 0
			Case 1 To 8
				For $X = 1 To $who
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
	73280 V3 3/20/2019 2:40:29 AM V2 3/6/2019 2:09:26 AM V1 3/5/2019 4:52:41 PM
#CE

;Main
Main()
Exit

Func Out($string)
	MsgBox(262144, @ScriptLineNumber, 'Selection:' & @CRLF & '$string' & @CRLF & @CRLF & 'Return:' & @CRLF & $string)
EndFunc   ;==>Out
#CS INFO
	10512 V2 4/17/2019 2:52:17 AM V1 3/2/2019 2:02:06 PM
#CE

Func Pause()
	MsgBox(0, "", "")
EndFunc   ;==>Pause
#CS INFO
	3360 V1 3/6/2019 2:09:26 AM
#CE

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

;~T ScriptFunc.exe V0.53 17 Apr 2019 - 4/17/2019 2:54:42 AM
