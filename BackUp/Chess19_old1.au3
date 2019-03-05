AutoItSetOption("MustDeclareVars", 1)

Global $ver = "0.01 2 Mar 2019 Create board."

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



#cs ----------------------------------------------------------------------------
	to do

	0.01 3 Mar 2019 Create board.
	0.00 1 Mar 2019  Start


#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Misc.au3>
#include <Constants.au3>
#include <GDIPlus.au3>



Static $UserLoction = EnvGet("USERPROFILE")
Static $Temp = EnvGet("TEMP")

AutoItSetOption("SendKeyDelay", 15)
AutoItSetOption("SendKeyDownDelay", 15)

;Global
Global $g_board[8][8]
Global $g_old_board[8][8]

Global $Player_color
Const $fen_play_white = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
Const $fen_play_black = "RNBKQBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbkqbnr w KQkq - 0 1"


;Main
Main()
Exit



Func Main()

FenBoard($fen_play_white)




EndFunc   ;==>Main
#CS INFO
	6070 V1 3/2/2019 2:02:06 PM
#CE

Func CreateBoard()
	local $x, $y
	local static $ls_ScreenBoard=-1

	if $ls_ScreenBoard= -1 Then



$ls_ScreenBoard = GUICreate("Board", 615, 438, 497, 7)
GUISetState(@SW_SHOW)


endif

EndFunc

#cs
for $y = 7 to 0 step -1
		for $x = 0 to 7
			$z = $y * 8 + $x

			A FEN "record" defines a particular game position, all in one text line and using only the ASCII character set. A text file with only FEN data records should have the file extension ".fen".[1]

A FEN record contains six fields. The separator between fields is a space. The fields are:

    Piece placement (from White's perspective). Each rank is described, starting with rank 8 and ending with rank 1; within each rank, the contents of each square are described from file "a" through file "h". Following the Standard Algebraic Notation (SAN), each piece is identified by a single letter taken from the standard English names (pawn = "P", knight = "N", bishop = "B", rook = "R", queen = "Q" and king = "K").[1] White pieces are designated using upper-case letters ("PNBRQK") while black pieces use lowercase ("pnbrqk"). Empty squares are noted using digits 1 through 8 (the number of empty squares), and "/" separates ranks.
    Active colour. "w" means White moves next, "b" means Black.
    Castling availability. If neither side can castle, this is "-". Otherwise, this has one or more letters: "K" (White can castle kingside), "Q" (White can castle queenside), "k" (Black can castle kingside), and/or "q" (Black can castle queenside).
    En passant target square in algebraic notation. If there's no en passant target square, this is "-". If a pawn has just made a two-square move, this is the position "behind" the pawn. This is recorded regardless of whether there is a pawn in position to make an en passant capture.[2]
    Halfmove clock: This is the number of halfmoves since the last capture or pawn advance. This is used to determine if a draw can be claimed under the fifty-move rule.
    Fullmove number: The number of the full move. It starts at 1, and is incremented after Black's move.

	Start at 8A
	#ce

Func FenBoard($Fen)
	Local $ifen, $ifenboard, $z,$y,$x, $char

$y=7
$x=0
	$z = 1

	do
		Switch 	$who = StringMid($Fen, $z, 1)
			Case "/"
				$y -= 1
				$x=0
			Case 1 To 8
				For $i = 1 To $who
					$g_board[$x][y] = "0"
					$x+=1
				Next
			Case "R", "N", "B", "K", "Q", "P", "r", "n", "b", "k", "q", "p"
				$g_board[$x][y] = $who
				$x+=1
			Case " "
				;exit
		EndSwitch
		$z += 1
	Until $who = " "

_ArrayDisplay($g_board)


	$ifen += 1
	$movenext = StringMid($fen2board, $ifen, 1)
	$ifen += 1
	$Castling = ""
	Do
		$Castling = $Castling & StringMid($fen2board, $ifen, 1)
		$ifen += 1
	Until StringMid($fen2board, $ifen, 1) == " "
	$ifen += 1
	$En_passant = ""
	Do
		$En_passant = $En_passant & StringMid($fen2board, $ifen, 1)
		$ifen += 1
	Until StringMid($fen2board, $ifen, 1) == " "
	$ifen += 2
	$Halfmove_clock = StringMid($fen2board, $ifen, 1)
	$ifen += 2
	$Fullmove_number = StringMid($fen2board, $ifen, 1)
EndFunc   ;==>fen2board



;~T ScriptMine.exe 0.98 26 Feb 2019 Backup 3/2/2019 2:02:06 PM
