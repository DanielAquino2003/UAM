"""Strategies for two player games.

   Authors:
        Fabiano Baroni <fabiano.baroni@uam.es>,
        Alejandro Bellogin Kouki <alejandro.bellogin@uam.es>
        Alberto Suárez <alberto.suarez@uam.es>
"""

from __future__ import annotations  # For Python 3.7

from abc import ABC, abstractmethod
from typing import List

import numpy as np

from game import TwoPlayerGame, TwoPlayerGameState
from heuristic import Heuristic


class Strategy(ABC):
    """Abstract base class for player's strategy."""

    def __init__(self, verbose: int = 0) -> None:
        """Initialize common attributes for all derived classes."""
        self.verbose = verbose 

    @abstractmethod
    def next_move(
        self,
        state: TwoPlayerGameState,
        gui: bool = False,
    ) -> TwoPlayerGameState:
        """Compute next move."""

    def generate_successors(
        self,
        state: TwoPlayerGameState,
    ) -> List[TwoPlayerGameState]:
        """Generate state successors."""
        assert isinstance(state.game, TwoPlayerGame)
        successors = state.game.generate_successors(state)
        assert successors  # Error if list is empty
        return successors


class RandomStrategy(Strategy):
    """Strategy in which moves are selected uniformly at random."""

    def next_move(
        self,
        state: TwoPlayerGameState,
        gui: bool = False,
    ) -> TwoPlayerGameState:
        """Compute next move."""
        successors = self.generate_successors(state)
        return np.random.choice(successors)


class ManualStrategy(Strategy):
    """Strategy in which the player inputs a move."""

    def next_move(
        self,
        state: TwoPlayerGameState,
        gui: bool = False,
    ) -> TwoPlayerGameState:
        """Compute next move"""
        successors = self.generate_successors(state)

        assert isinstance(state.game, TwoPlayerGame)
        if gui:
            index_successor = state.game.graphical_input(state, successors)
        else:
            index_successor = state.game.manual_input(successors)

        next_state = successors[index_successor]

        if self.verbose > 0:
            print('My move is: {:s}'.format(str(next_state.move_code)))

        return next_state


class MinimaxStrategy(Strategy):
    """Minimax strategy."""

    def __init__(
        self,
        heuristic: Heuristic,
        max_depth_minimax: int,
        verbose: int = 0,
    ) -> None:
        super().__init__(verbose)
        self.heuristic = heuristic
        self.max_depth_minimax = max_depth_minimax

    def next_move(
        self,
        state: TwoPlayerGameState,
        gui: bool = False,
    ) -> TwoPlayerGameState:
        """Compute the next state in the game."""

        minimax_value, minimax_successor = self._max_value(
            state,
            self.max_depth_minimax,
        )

        if self.verbose > 0:
            if self.verbose > 1:
                print('\nGame state before move:\n')
                print(state.board)
                print()
            print('Minimax value = {:.2g}'.format(minimax_value))

        return minimax_successor

    def _min_value(
        self,
        state: TwoPlayerGameState,
        depth: int,
    ) -> float:
        """Min step of the minimax algorithm."""

        if state.end_of_game or depth == 0:
            minimax_value = self.heuristic.evaluate(state)
            minimax_successor = None
        else:
            minimax_value = np.inf

            for successor in self.generate_successors(state):
                if self.verbose > 1:
                    print('{}: {}'.format(state.board, minimax_value))

                successor_minimax_value, _ = self._max_value(
                    successor,
                    depth - 1,
                )

                if (successor_minimax_value < minimax_value):
                    minimax_value = successor_minimax_value
                    minimax_successor = successor

        if self.verbose > 1:
            print('{}: {}'.format(state.board, minimax_value))

        return minimax_value, minimax_successor

    def _max_value(
        self,
        state: TwoPlayerGameState,
        depth: int,
    ) -> float:
        """Max step of the minimax algorithm."""

        if state.end_of_game or depth == 0:
            minimax_value = self.heuristic.evaluate(state)
            minimax_successor = None
        else:
            minimax_value = -np.inf

            for successor in self.generate_successors(state):
                if self.verbose > 1:
                    print('{}: {}'.format(state.board, minimax_value))

                successor_minimax_value, _ = self._min_value(
                    successor,
                    depth - 1,
                )
                if (successor_minimax_value > minimax_value):
                    minimax_value = successor_minimax_value
                    minimax_successor = successor

        if self.verbose > 1:
            print('{}: {}'.format(state.board, minimax_value))

        return minimax_value, minimax_successor


class MinimaxAlphaBetaStrategy(Strategy):
    """Minimax alpha-beta strategy."""

    def __init__(
        self,
        heuristic: Heuristic,
        max_depth_minimax: int,
        verbose: int = 0,
    ) -> None:
        super().__init__(verbose)
        self.heuristic = heuristic
        self.max_depth_minimax = max_depth_minimax

    def next_move(
        self,
        state: TwoPlayerGameState,
        gui: bool = False,
    ) -> TwoPlayerGameState:
        """Compute the next state in the game."""
        #genera los sucesores para el estado actual
        successors = self.generate_successors(state)
        #inicializa el valor minimax con infinito negativo
        minimax_value = -np.inf

        # Itera a través de los sucesores para encontrar el que tiene el máximo valor minimax.
        for successor in successors:
            # Imprime información detallada si el nivel de detalle (verbose) es mayor que 1.
            if self.verbose >1:
                print(f'{state.board}: {minimax_value} [{-np.inf} : {np.inf}]')
            
            # Calcula el valor minimax para el sucesor actual utilizando la Poda Alfa-Beta.
            successor_minimax_value = self._min_alpha_beta_value(
                successor,
                -np.inf,
                np.inf,
                self.max_depth_minimax
            )
            # Actualiza el valor minimax y el sucesor correspondiente si se encuentra un movimiento mejor.
            if (successor_minimax_value > minimax_value):
                minimax_value = successor_minimax_value
                minimax_successor = successor
        # Imprime información sobre el valor Minimax si el nivel de detalle (verbose) es mayor que 0.
        if self.verbose > 0:
            # Imprime información sobre el valor Minimax si el nivel de detalle (verbose) es mayor que 0.
            if self.verbose > 1:
                print('\nGame state before move:\n')
                print(state.board)
                print()
            print(f'Minimax value = {minimax_value}')
        cd # Retorna el sucesor con el máximo valor Minimax.
        return minimax_successor
    
    def _min_alpha_beta_value(
        self,
        state: TwoPlayerGameState,
        alpha: float,
        beta: float,
        depth: int,
    ) -> float:

        #Si es el final del juego o se alcanza la profundidad limite,
        #evalúa el estado y retorna el valor de la heurística
        if state.end_of_game or depth == 0:
            minimax_value = self.heuristic.evaluate(state)

        else:
            #inicializa minimax_value con infinito negativo
            minimax_value = np.inf
            
            #genera los sucesores del estado actual
            successors = self.generate_successors(state)
            for successor in successors:
                #si verbose es mayor que 1, imprime informacion detallada
                if self.verbose > 1:
                    print(f'{state.board}: {minimax_value} [{alpha} : {beta}]')

                #calcula el valor Minimax para el sucesor actual, intercambiando los roles de Min y Max 
                successor_minimax_value = self._max_alpha_beta_value(
                    successor, alpha, beta, depth - 1
                )

                #Actualiza minimax_value si el valor del sucesor es menor
                if (successor_minimax_value < minimax_value):
                    minimax_value = successor_minimax_value

                #Poda alpha-beta: Si minimax_value es menor o igual que el valor de alpha
                if minimax_value <= alpha:
                    return minimax_value
                #de lo contrario se actualiza el valor de beta
                if (minimax_value < beta):
                    beta = minimax_value

        #si verbose es mayor que 1 se indica informacion detallada
        if self.verbose > 1:
            print(f'{state.board}: {minimax_value} [{alpha} : {beta}]')

        #retorna el valor minimax calculado para el estado actual
        return minimax_value

    def _max_alpha_beta_value(
        self,
        state: TwoPlayerGameState,
        alpha: float,
        beta: float,
        depth: int,
    ) -> float:
        #Si es el final del juego o se alcanza la profundidad limite,
        #evalúa el estado y retorna el valor de la heurística
        if state.end_of_game or depth == 0:
            minimax_value = self.heuristic.evaluate(state)
        else:
            #inicializa minimax_value con infinito positivo
            minimax_value = -np.inf
            #genera los sucesores del estado actual
            successors = self.generate_successors(state)
            for successor in successors:
                #si verbose es mayor que 1, imprime informacion detallada
                if self.verbose > 1:
                    print(f'{state.board}: {minimax_value} [{alpha} : {beta}]')
                #calcula el valor Minimax para el sucesor actual, intercambiando los roles de Min y Max 
                successor_minimax_value = self._min_alpha_beta_value(
                    successor, alpha, beta, depth - 1
                )
                #Actualiza minimax_value si el valor del sucesor es mayor al actual
                if (successor_minimax_value > minimax_value):
                    minimax_value = successor_minimax_value
                #Poda alpha-beta: Si minimax_value es mayor o igual que el valor de alpha
                if minimax_value >= beta:
                    return minimax_value
                #de lo contrario se actualiza el valor de alpha
                if (minimax_value > alpha):
                    alpha = minimax_value
         #si verbose es mayor que 1 se indica informacion detallada
        if self.verbose > 1:
            print(f'{state.board}: {minimax_value} [{alpha} : {beta}]')
        #retorna el valor minimax calculado para el estado actual
        return minimax_value
