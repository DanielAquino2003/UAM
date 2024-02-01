import numpy as np

from typing import Sequence

from reversi import from_dictionary_to_array_board

from game import (
    TwoPlayerGameState,
)

from tournament import (
    StudentHeuristic,
)


class Solution1(StudentHeuristic):
  def get_name(self) -> str:
    return "#LIGAMANCHADA"
  
  def get_max_tokens(self, state:TwoPlayerGameState, token, keys):
    totals = list()
    listx = list()
    listx.append(0)
    listy = list()
    listy.append(0)

    h = state.game.height
    w = state.game.width

    for i in state.board:
      contx =0
      conty =0
      t = tuple(i)

      if t[0] not in listx:
        for j in range(t[1], w):
          taux = (t[0], j)
          if taux in keys and state.board[taux] != token:
            listx.append(t[0])
            contx+=1

      if t[1] not in listy:
        for j in range(t[0], h):
          taux = (j, t[1])
          if taux in keys and state.board[taux] != token:
            listx.append(t[0])
            conty+=1


      totals.append(contx)
      totals.append(conty)
    totals.sort(reverse=True)
    return totals
  
  def evaluation_function(self, state: TwoPlayerGameState) -> float:
    aux = 1
    # player 1 B player 2 W
    if state.is_player_max(state.player1):
      token = 'B'
      nottoken = 'W'
    elif state.is_player_max(state.player2):
      token = 'W'
      nottoken = 'B'
    else:
      raise ValueError('Player MAX not defined')
    


    # number of tokens he can eat - number of tokens we can eat
    keys = state.board.keys()

    t1 = self.get_max_tokens(state, token, keys)
    t2 = self.get_max_tokens(state, nottoken, keys)

    
    res =  t2[0] - t1[0]
    
    
    return res