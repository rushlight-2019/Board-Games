AutoItSetOption("MustDeclareVars", 1)

Global $ver = "0.03 6 Mar 2019 Update board"

#include <Debug.au3>
_DebugSetup(@ScriptName & " " & $ver, True) ; start

_DebugOut($ver)
Global $DEBUG = @error = 0
Global $TESTING = True

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


#cs ----------------------------------------------------------------------------
	to do

	0.03 6 Mar 2019 Update board
	0.02 6 Mar 2019 Display board
	0.01 5 Mar 2019 Fen to data
	0.00 1 Mar 2019  Start

	Going to start with the way I know how to do graphic
	then replace with GUIplus.

#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Misc.au3>
#include <Constants.au3>
;#include <GDIPlus.au3>
#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>


Static $UserLoction = EnvGet("USERPROFILE")
Static $Temp = EnvGet("TEMP")

AutoItSetOption("SendKeyDelay", 15)
AutoItSetOption("SendKeyDownDelay", 15)

;Global
Global $g_aDisplay[8][8]
Global $g_aDisplayK[8][8]
Global $g_board[8][8]
Global $g_old_board[8][8]
Global $g_sNextColor, $g_sCastling, $g_sEn_passant, $g_iHalfmove, $g_iFullmove

Global $Player_color
Const $fen_play_white = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
Const $fen_play_black = "RNBKQBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbkqbnr w KQkq - 0 1"

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

;Main
Main()
Exit



Func Main()
	CreateBoard()
	FenBoard($fen_play_white)
	updateBoard()



EndFunc   ;==>Main
#CS INFO
	5710 V3 3/6/2019 2:09:26 AM V2 3/5/2019 4:52:41 PM V1 3/2/2019 2:02:06 PM
#CE

Func updateBoard()
	Local $iRank, $iFile, $c

	For $iRank = 0 To 7
		For $iFile = 0 To 7
switch $c = $g_aDisplay[$iRank][$iFile]
	case "R"
			GUICtrlSetImage($c, $hWhiteRook)
case "N"
			GUICtrlSetImage($c, $hWhiteKnight)
case "B"
			GUICtrlSetImage($c, $hWhiteBishop)
case "K"
			GUICtrlSetImage($c, $hWhiteKing)
case "Q"
			GUICtrlSetImage($c, $hWhiteQueen)
case "P"
			GUICtrlSetImage($c, $hWhitePawn)
case "p"
			GUICtrlSetImage($c, $hBlackPawn)
case "k"
			GUICtrlSetImage($c, $hBlackKing)
case "q"
			GUICtrlSetImage($c, $hBlackQueen)
case "b"
			GUICtrlSetImage($c, $hBlackBishop)
case "n"
			GUICtrlSetImage($c, $hBlackKnight)
case "r"
			GUICtrlSetImage($c, $hBlackRook)
case else
			GUICtrlSetImage($c, $hEmpty)
			EndSwitch
		Next
	Next
EndFunc   ;==>updateBoard

Func CreateBoard()
	Local $iRank, $iFile, $c
	Local Static $ls_ScreenBoard = -1

	If $ls_ScreenBoard = -1 Then
		$ls_ScreenBoard = GUICreate("Board", 615, 615, -1, -1)
		GUISetState(@SW_SHOW)

		;$g_board[$irank][$iFile]

		$c = False
		For $iRank = 0 To 7
			For $iFile = 0 To 7


				$g_aDisplayK[$iRank][$iFile] = GUICtrlCreateGraphic($iFile * 64, $iRank * 64, 64, 64)
				$g_aDisplay[$iRank][$iFile] = GUICtrlCreatePic(@ScriptDir & "\images\empty.bmp", $iFile * 64, $iRank * 64, 64, 64)
				If $c Then
					GUICtrlSetBkColor($g_aDisplayK[$iRank][$iFile], $COLOR_RED)
					$c = False
				Else
					GUICtrlSetBkColor($g_aDisplayK[$iRank][$iFile], $COLOR_WHITE)
					$c = True
				EndIf

				;test
				If $iRank = 5 Then GUICtrlSetImage($g_aDisplay[$iRank][$iFile], @ScriptDir & "\images\brook.bmp")
				If $iRank = 6 Then GUICtrlSetImage($g_aDisplay[$iRank][$iFile], @ScriptDir & "\images\wKing.bmp")


			Next
			$c = Not $c
			Pause()
		Next



	EndIf

EndFunc   ;==>CreateBoard
#CS INFO
	69529 V2 3/6/2019 2:09:26 AM V1 3/5/2019 4:52:41 PM
#CE

#cs
	for $y = 7 to 0 step -1
	for $x = 0 to 7
	$z = $y * 8 + $x

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


;~T ScriptMine.exe 0.98 26 Feb 2019 Backup 3/6/2019 2:09:26 AM


