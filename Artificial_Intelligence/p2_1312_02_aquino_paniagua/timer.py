import timeit

setup = '''
import numpy as np

from game import Player, TwoPlayerGameState, TwoPlayerMatch
from heuristic import simple_evaluation_function
from reversi import (
    Reversi,
    from_array_to_dictionary_board,
    from_dictionary_to_array_board,
)
from tournament import StudentHeuristic, Tournament


class Heuristic1(StudentHeuristic):

    def get_name(self) -> str:
        return "dummy"

    def evaluation_function(self, state: TwoPlayerGameState) -> float:
        # Use an auxiliary function.
        return self.dummy(123)

    def dummy(self, n: int) -> int:
        return n + 4

class Heuristic2(StudentHeuristic):

    def get_name(self) -> str:
        return "random"

    def evaluation_function(self, state: TwoPlayerGameState) -> float:
        return float(np.random.rand())


class Heuristic3(StudentHeuristic):

    def get_name(self) -> str:
        return "heuristic"

    def evaluation_function(self, state: TwoPlayerGameState) -> float:
        return simple_evaluation_function(state)
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


def create_match(player1: Player, player2: Player) -> TwoPlayerMatch:

    initial_board = None#np.zeros((dim_board, dim_board))
    initial_player = player1

    """game = TicTacToe(
        player1=player1,
        player2=player2,
        dim_board=dim_board,
    )"""

    initial_board = (
        ['..B.B..',
        '.WBBW..',
        'WBWBB..',
        '.W.WWW.',
        '.BBWBWB']
    )

    if initial_board is None:
        height, width = 8, 8
    else:
        height = len(initial_board)
        width = len(initial_board[0])
        try:
            initial_board = from_array_to_dictionary_board(initial_board)
        except ValueError:
            raise ValueError('Wrong configuration of the board')
        else:
            print("Successfully initialised board from array")

    game = Reversi(
        player1=player1,
        player2=player2,
        height=8,
        width=8
    )

    game_state = TwoPlayerGameState(
        game=game,
        board=initial_board,
        initial_player=initial_player,
    )

    return TwoPlayerMatch(game_state, max_seconds_per_move=1000, gui=False)


tour = Tournament(max_depth=4, init_match=create_match)
# if the strategies are copy-pasted here:
strats = {'opt1': [Heuristic1]}#, 'opt2': [Heuristic2], 'opt3': [Heuristic3], 'opt4': [Solution1]}
# if the strategies should be loaded from files in a specific folder:
# folder_name = "folder_strat" # name of the folder where the strategy files are located
# strats = tour.load_strategies_from_folder(folder=folder_name, max_strat=3)

n = 2
'''

stmt = '''
scores, totals, names = tour.run(
    student_strategies=strats,
    increasing_depth=False,
    n_pairs=n,
    allow_selfmatch=False,
)

print(
    'Results for tournament where each game is repeated '
    + '%d=%dx2 times, alternating colors for each player' % (2 * n, n),
)

# print(totals)
# print(scores)

print('\ttotal:', end='')
for name1 in names:
    print('\t%s' % (name1), end='')
print()
for name1 in names:
    print('%s\t%d:' % (name1, totals[name1]), end='')
    for name2 in names:
        if name1 == name2 or name2 not in scores[name1]:
            print('\t---', end='')
        else:
            print('\t%d' % (scores[name1][name2]), end='')
    print()
'''

print(timeit.timeit(setup=setup,
                    stmt=stmt,
                    number=1))