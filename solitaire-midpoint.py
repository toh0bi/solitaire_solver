#!/usr/bin/env python3
# coding: utf-8
import numpy as np
import time
import sys
from math import pow

#globale Variablen:
board_allowed = np.ones((7,7))
board_allowed[0,0]=0
board_allowed[0,1]=0
board_allowed[1,0]=0
board_allowed[1,1]=0
#
board_allowed[5,5]=0
board_allowed[5,6]=0
board_allowed[6,5]=0
board_allowed[6,6]=0
#
board_allowed[5,0]=0
board_allowed[5,1]=0
board_allowed[6,0]=0
board_allowed[6,1]=0
#
board_allowed[0,5]=0
board_allowed[0,6]=0
board_allowed[1,5]=0
board_allowed[1,6]=0

solutions = [] # Log wie viele Loesungen mit welcher anzahl an Zuegen gefunden wurden
attempsG=0
skipped=0
saved=0
board_hist = set()


def create_board():
    # Pins setzen
    board = np.zeros((7,7))
    board[:] = board_allowed
    # Pin im Mittelpunkt entnehmen
    board[3,3]=0
    return board

def move_pin(board,pin=None,moves=0,recursive_move=False):
    board_new = np.zeros((7,7))
    global attempsG
    attempsG+=1
    lokal_attempts = 0 if attempsG == 1 else 2
    moves += 1
    if (attempsG % 1000000 == 0):
        print("DEBUG: " ,attempsG," Durchläufe \t" + time.ctime())

    global board_hist
    global skipped
    global saved

    # calculate specific id of board to check if it is already solved
    for i in range(4): #4
        board_id=0
        k=1
        for i in range(7):
            for j in range(7):
                if board_allowed[i,j] == 1:
                    board_id += int((pow(2,k)) * board[i,j])
                    k+=1
        if board_id in board_hist:
            skipped+=1
            if skipped % 1000000 == 0 : print("DEBUG: skipped:\t" + str(skipped))
            return 0
        # brett drehen, da symmetrisch und nocheinmal prüfen ob schon gelöst
        board = np.rot90(board)

    # solution found?
    if np.sum(board) <= 1 : # and board[3,3] == 1:
        print("Solution found!")
        print("--> moves made:",moves)
        solutions.append((board,moves))
        return 0

    # nur "gute" Lösungen
    if moves > 8:
        return 0

    for i in range(7):
        for j in range(7):
            if (board[i,j]==0): #skip when its not a pin
                continue

            # check if valid move is possible

            # falls der gleiche pin, wie im vorherigen zug, "zählt" der Zug nicht
            if pin == (i,j):
                moves -= 1
            # -i
            if (i-2 >= 0):
                if (board[i-2,j]==0) and (board[i-1,j]==1) and (board_allowed[i-2,j]==1):
                    if not recursive_move: print("first move to the left")
                    board_new[:]=board    # Brett kopieren
                    board_new[i,j]  =0    # Zug durchführen
                    board_new[i-1,j]=0    #
                    board_new[i-2,j]=1    #
                    pin_new = i-2,j       # Position des gezogenen Pins
                    move_pin(board_new,pin_new,moves,True)
            # +i
            if (i+2 <= 6):
                if (board[i+2,j]==0) and (board[i+1,j]==1) and (board_allowed[i+2,j]==1):
                    if not recursive_move: print("first move to the right")
                    board_new[:]=board
                    board_new[i,j]  =0
                    board_new[i+1,j]=0
                    board_new[i+2,j]=1
                    pin_new = i+2,j
                    move_pin(board_new,pin_new,moves,True)
            # -j
            if (j-2 >= 0):
                if (board[i,j-2]==0) and (board[i,j-1]==1) and (board_allowed[i,j-2]==1):
                    if not recursive_move: print("first move to the bottom")
                    board_new[:]=board
                    board_new[i,j]  =0
                    board_new[i,j-1]=0
                    board_new[i,j-2]=1
                    pin_new = i,j-2
                    move_pin(board_new,pin_new,moves,True)
            # +j
            if (j+2 <= 6):
                if (board[i,j+2]==0) and (board[i,j+1]==1) and (board_allowed[i,j+2]==1):
                    if not recursive_move: print("first move to the top")
                    board_new[:]=board
                    board_new[i,j]  =0
                    board_new[i,j+1]=0
                    board_new[i,j+2]=1
                    pin_new = i,j+2
                    move_pin(board_new,pin_new,moves,True)
    # kein gültiger Zug mehr gefunden
    # safe board to history as specific int
    board_hist.add(board_id)
    saved+=1
    if saved % 1000000 == 0 :
        print("DEBUG: saved:  \t" + str(saved) )


def main(args):
    print("Start:",time.ctime())
    move_pin(create_board())
    print("\nDone...")
    print(solutions)
    print("Anzahl Lösungen:",len(solutions))
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
