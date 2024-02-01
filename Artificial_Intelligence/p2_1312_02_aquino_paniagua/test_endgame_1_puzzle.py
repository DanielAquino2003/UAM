"""Test case for an heuristic.

Authors:
    Alejandro Bellogin <alejandro.bellogin@uam.es>
    Daniel Fernandez <daniel.fernandezs@uam.es>

"""

from __future__ import annotations

from typing import Sequence
import numpy as np
from game import Player, TwoPlayerGameState
from heuristic import Heuristic
from reversi import (
    Reversi,
    from_array_to_dictionary_board,
)
from strategy import (
    MinimaxStrategy,
)

def subtraction_heuristic(state: TwoPlayerGameState) -> float:
    
    if state.end_of_game:
        # Si el juego ha terminado, usa la puntuación actual.
        return state.scores[state.player1.label] - state.scores[state.player2.label]
    
    # Obtén el número de monedas de cada jugador.
    player1_coins = state.game._player_coins(state.board, state.player1.label)
    player2_coins = state.game._player_coins(state.board, state.player2.label)
    
    # Calcula la diferencia de puntuación de monedas entre los jugadores.
    score_difference = player1_coins - player2_coins
    
    # Peso de las esquinas en la puntuación.
    corner_weight = 20
    
    # Inicializa contadores para contar las esquinas ocupadas por cada jugador.
    player1_corners = 0
    player2_corners = 0
    
    # Coordenadas de las esquinas.
    corners = [(1, 1), (1, state.game.height), (state.game.width, 1), (state.game.width, state.game.height)]
    
    # Calcula las esquinas ocupadas por cada jugador.
    for corner in corners:
        cell_value = state.board.get(corner)
        if cell_value == state.player1.label:
            player1_corners += 1
        elif cell_value == state.player2.label:
            player2_corners += 1
    
    # Calcula la puntuación de las esquinas.
    corner_score = corner_weight * (player1_corners - player2_corners)
    
    # Penalización por esquinas adyacentes ocupadas por el oponente.
    adjacent_corner_penalty = -10
    
    # Comprueba si las esquinas tienen celdas adyacentes ocupadas por el oponente.
    for corner in corners:
        adjacent_cells = [(corner[0] + 1, corner[1]), (corner[0], corner[1] + 1),
                          (corner[0] - 1, corner[1]), (corner[0], corner[1] - 1)]
        for cell in adjacent_cells:
            cell_value = state.board.get(cell)
            if cell_value == state.game.opponent(state.next_player).label:
                corner_score += adjacent_corner_penalty
    
    # Calcula la puntuación total sumando la diferencia de monedas y la puntuación de las esquinas.
    state_value = score_difference + corner_score
    
    # Retorna la puntuación considerando al jugador máximo (player1) como positivo y al otro como negativo.
    return state_value if state.is_player_max(state.player1) else -state_value


def heuristic_1(state: TwoPlayerGameState) -> float:
    return subtraction_heuristic(state)

player_minimax_1 = Player(
    name='Black',
    strategy=MinimaxStrategy(
        heuristic=Heuristic(name='heuristic_1_B', evaluation_function=heuristic_1),
        max_depth_minimax=3,
        verbose=0,
    ),
)

player_minimax_2 = Player(
    name='White',
    strategy=MinimaxStrategy(
        heuristic=Heuristic(name='heuristic_1_W', evaluation_function=heuristic_1),
        max_depth_minimax=3,
        verbose=0,
    ),
)


# minimax vs minimax player
player_a, player_b = player_minimax_1, player_minimax_2

"""
End game test
"""
initial_board = (
        ['WWWWWWWW', # 1
         'WWWBBBBB', # 2
         'WWWWBWBB', # 3
         'WBWBWBWB', # 4
         'WBBWBWWB', # 5
         '.BBBBBWB', # 6
         '.BBBWWBB', # 7
         '..BBBBBB'] # 8
    )

a7_board = (
        ['WWWWWWWW', # 1
         'WWWBBWBB', # 2
         'WWWWWWBB', # 3
         'WBWWWBWB', # 4
         'WBWWBWWB', # 5
         '.WBBBBWB', # 6
         'WWWWWWBB', # 7
         '..BBBBBB'] # 8
    )

a6_board = (
        ['WWWWWWWW', # 1
         'WWWBBBBB', # 2
         'WWWWBWBB', # 3
         'WBWBWBWB', # 4
         'WWBWBWWB', # 5
         'WWWWWWWB', # 6
         '.BBBWWBB', # 7
         '..BBBBBB'] # 8
    )

a8_board = (
        ['WWWWWWWW', # 1
         'WWWBBBBB', # 2
         'WWWWBWBB', # 3
         'WBWBWBWB', # 4
         'WBBWBWWB', # 5
         '.BWBBBWB', # 6
         '.WBBWWBB', # 7
         'W.BBBBBB'] # 8
    )

b8_board = (
        ['WWWWWWWW', # 1
         'WWWBBBBB', # 2
         'WWWWBWBB', # 3
         'WWWBWBWB', # 4
         'WWBWBWWB', # 5
         '.WBBBBWB', # 6
         '.WBBWWBB', # 7
         '.WBBBBBB'] # 8
    )


height = len(initial_board)
width = len(initial_board[0])
try:
    initial_board = from_array_to_dictionary_board(initial_board)
    a7_board = from_array_to_dictionary_board(a7_board)
    a6_board = from_array_to_dictionary_board(a6_board)
    a8_board = from_array_to_dictionary_board(a8_board)
    b8_board = from_array_to_dictionary_board(b8_board)
except ValueError:
    raise ValueError('Wrong configuration of the board')
else:
    print("Successfully initialised board from array")


# Initialize a reversi game.
game = Reversi(
    player1=player_a,
    player2=player_b,
    height=height,
    width=width,
)

# Initialize a game state.
game_state_a7 = TwoPlayerGameState(
    game=game,
    board=a7_board,
    initial_player=player_a,
    player_max=player_b,
)

# Initialize a game state.
game_state_a6 = TwoPlayerGameState(
    game=game,
    board=a6_board,
    initial_player=player_a,
    player_max=player_b,
)

# Initialize a game state.
game_state_a8 = TwoPlayerGameState(
    game=game,
    board=a8_board,
    initial_player=player_a,
    player_max=player_b,
)

# Initialize a game state.
game_state_b8 = TwoPlayerGameState(
    game=game,
    board=b8_board,
    initial_player=player_a,
    player_max=player_b,
)

print("Given this initial state:")
print(  ' WWWWWW..\n', # 1
         'BBBBBBBW\n', # 2
         'BBWBBBBW\n', # 3
         'BBBWBWB.\n', # 4
         'BBWBWWBW\n', # 5
         'BWWWWWBW\n', # 6
         'B.WWWWW.\n', # 7
         'BWWWW..W\n'  # 8
    )
print("This is the ranking of the possible movements: A7, A6, A8, B8")
print("1- A7  -- your score for this movement:", heuristic_1(game_state_a7), " <- This is the best board (so, your strategy should prefer it).")
print("2- A6  -- your score for this movement:", heuristic_1(game_state_a6), " <- Same score as A8.")
print("2- A8  -- your score for this movement:", heuristic_1(game_state_a8), " <- Same score as A6.")
print("4- B8  -- your score for this movement:", heuristic_1(game_state_b8), " <- This is the worst board (so, your strategy should not prefer it).")
