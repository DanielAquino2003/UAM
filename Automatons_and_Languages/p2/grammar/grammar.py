from __future__ import annotations

from collections import deque
from typing import AbstractSet, Collection, MutableSet, Optional, Dict, List, Optional, Callable, Iterable, Deque
from typing import Set
from typing import Tuple
from copy import deepcopy

class RepeatedCellError(Exception):
    """Exception for repeated cells in LL(1) tables."""

class SyntaxError(Exception):
    """Exception for parsing errors."""

class Grammar:
    """
    Class that represents a grammar.

    Args:
        terminals: Terminal symbols of the grammar.
        non_terminals: Non terminal symbols of the grammar.
        productions: Dictionary with the production rules for each non terminal
          symbol of the grammar.
        axiom: Axiom of the grammar.

    """

    def __init__(
        self,
        terminals: AbstractSet[str],
        non_terminals: AbstractSet[str],
        productions: Dict[str, List[str]],
        axiom: str,
    ) -> None:
        if terminals & non_terminals:
            raise ValueError(
                "Intersection between terminals and non terminals "
                "must be empty.",
            )

        if axiom not in non_terminals:
            raise ValueError(
                "Axiom must be included in the set of non terminals.",
            )

        if non_terminals != set(productions.keys()):
            raise ValueError(
                f"Set of non-terminals and productions keys should be equal."
            )
        
        for nt, rhs in productions.items():
            if not rhs:
                raise ValueError(
                    f"No production rules for non terminal symbol {nt} "
                )
            for r in rhs:
                for s in r:
                    if (
                        s not in non_terminals
                        and s not in terminals
                    ):
                        raise ValueError(
                            f"Invalid symbol {s}.",
                        )

        self.terminals = terminals
        self.non_terminals = non_terminals
        self.productions = productions
        self.axiom = axiom

    def __repr__(self) -> str:
        return (
            f"{type(self).__name__}("
            f"terminals={self.terminals!r}, "
            f"non_terminals={self.non_terminals!r}, "
            f"axiom={self.axiom!r}, "
            f"productions={self.productions!r})"
        )
    
    def compute_first(self, sentence: str) -> AbstractSet[str]:
        """
        Method to compute the first set of a string.

        Args:
            str: string whose first set is to be computed.

        Returns:
            First set of str.
        """
        i = 0
        for char in sentence and sentence:
            if char not in self.terminals:
                if char not in self.non_terminals:
                    raise ValueError("Invalid char")
            i += 1
        if i == 0:
            return {""}

        abstractSet: MutableSet[str] = set()
        firsts = self.get_firsts()

        flag = 1
        for char in sentence:
            if char in self.terminals:
                abstractSet.add(char)
                abstractSet.discard("")
                return abstractSet

            if "" not in firsts.get(str(char), set()):
                flag = 0

            abstractSet.update(firsts.get(str(char), set()))
            if flag == 0:
                abstractSet.discard("")
                return abstractSet
            
        return abstractSet
    
    def get_firsts(self) -> Dict[str, Set[str]]:
        memo: Dict[str, Set[str]] = {}
        def helper(nt: str) -> Set[str]:
            if nt in memo:
                return memo[nt]
            firsts: Set[str] = set()
            for string in self.productions.get(nt, []):
                if not string:
                    firsts.add(string)
                else:
                    for ch in string:
                        if ch in self.terminals:
                            firsts.add(str(ch))
                            break
                        else:
                            firsts |= helper(str(ch))
                            if "" in firsts:
                                firsts.remove("")
                            else:
                                break
                    else:
                        firsts.add("")
            memo[nt] = firsts
            return firsts
        for nt in self.non_terminals:
            helper(nt)
        return memo

    def compute_follow(self, symbol: str) -> AbstractSet[str]:
        """
        Method to compute the follow set of a non-terminal symbol.

        Args:
            symbol: non-terminal whose follow set is to be computed.

        Returns:
            Follow set of symbol.
        """
        if not symbol:
            return set()

        self.validate_symbol(symbol)

        first_sets = self.get_firsts()
        previous_follow_dict, current_follow_dict = self.initialize_follow_dicts()

        while previous_follow_dict != current_follow_dict:
            previous_follow_dict = {k: v.copy() for k, v in current_follow_dict.items()}

            for non_terminal in self.non_terminals:
                self.update_follow_set(non_terminal, first_sets, previous_follow_dict, current_follow_dict)

        return previous_follow_dict.get(symbol, set())

    def validate_symbol(self, symbol: str):
        if symbol not in self.terminals:
            if symbol not in self.non_terminals:
                raise ValueError("Invalid symbol")

    def initialize_follow_dicts(self) -> Tuple[Dict[str, Set[str]], Dict[str, Set[str]]]:
        return {nt: set("1") for nt in self.non_terminals}, {nt: set() for nt in self.non_terminals}

    def update_follow_set(self, non_terminal: str, first_sets: Dict[str, Set[str]],
                          previous_follow_dict: Dict[str, Set[str]], current_follow_dict: Dict[str, Set[str]]):
        if non_terminal == self.axiom:
            current_follow_dict[non_terminal].add("$")

        for production_string in self.productions.get(non_terminal, []):
            self.update_follow_set_for_production_string(non_terminal, production_string, first_sets,
                                                          previous_follow_dict, current_follow_dict)

    def update_follow_set_for_production_string(self, non_terminal: str, production_string: str,
                                                first_sets: Dict[str, Set[str]], previous_follow_dict: Dict[str, Set[str]],
                                                current_follow_dict: Dict[str, Set[str]]):
        previous_char = ""
        for current_char in reversed(production_string):
            self.update_follow_set_for_char(non_terminal, previous_char, current_char, first_sets,
                                            previous_follow_dict, current_follow_dict)
            previous_char = current_char

    def update_follow_set_for_char(self, non_terminal: str, previous_char: str, current_char: str,
                                   first_sets: Dict[str, Set[str]], previous_follow_dict: Dict[str, Set[str]],
                                   current_follow_dict: Dict[str, Set[str]]):
        if current_char in self.non_terminals and previous_char == "":
            current_follow_dict[current_char].update(previous_follow_dict[non_terminal])
        elif current_char in self.non_terminals and previous_char in self.non_terminals:
            self.update_follow_set_for_non_terminal(current_char, previous_char, first_sets, current_follow_dict)
        elif current_char in self.non_terminals:
            current_follow_dict[current_char].add(previous_char)
        else:
            previous_char = current_char

    def update_follow_set_for_non_terminal(self, current_char: str, previous_char: str,
                                           first_sets: Dict[str, Set[str]], current_follow_dict: Dict[str, Set[str]]):
        aux_first_sets = first_sets[previous_char].copy()
        aux_first_sets.discard("")
        current_follow_dict[current_char].update(current_follow_dict[previous_char], aux_first_sets)

    def get_ll1_table(self) -> Optional[LL1Table]:
        """
        Method to compute the LL(1) table.

        Returns:
            LL(1) table for the grammar, or None if the grammar is not LL(1).
        """

        ll1_table = LL1Table(non_terminals=self.non_terminals,terminals=self.terminals | {"$"})

        for non_terminal, production_rules in self.productions.items():
            for production_rule in production_rules:
                first_rhs = self.compute_first(production_rule)
                for term in first_rhs - {""}:
                    ll1_table.add_cell(non_terminal, term, production_rule)
                if "" in first_rhs:
                    for term in self.compute_follow(non_terminal):
                        ll1_table.add_cell(non_terminal, term, production_rule)

        return ll1_table


    def is_ll1(self) -> bool:
        return self.get_ll1_table() is not None


class LL1Table:
    """
    LL1 table. Initially all cells are set to None (empty). Table cells
    must be filled by calling the method add_cell.

    Args:
        non_terminals: Set of non terminal symbols.
        terminals: Set of terminal symbols.

    """
    def __init__(
        self,
        non_terminals: AbstractSet[str],
        terminals: AbstractSet[str],
    ) -> None:

        if terminals & non_terminals:
            raise ValueError(
                "Intersection between terminals and non terminals "
                "must be empty.",
            )

        self.terminals: AbstractSet[str] = terminals
        self.non_terminals: AbstractSet[str] = non_terminals
        self.cells: Dict[str, Dict[str, Optional[str]]] = {nt: {t: None for t in terminals} for nt in non_terminals}

    def __repr__(self) -> str:
        return (
            f"{type(self).__name__}("
            f"terminals={self.terminals!r}, "
            f"non_terminals={self.non_terminals!r}, "
            f"cells={self.cells!r})"
        )

    def add_cell(self, non_terminal: str, terminal: str, cell_body: str) -> None:
        """
        Adds a cell to an LL(1) table.

        Args:
            non_terminal: Non termial symbol (row)
            terminal: Terminal symbol (column)
            cell_body: content of the cell 

        Raises:
            RepeatedCellError: if trying to add a cell already filled.
        """
        if non_terminal not in self.non_terminals:
            raise ValueError(
                "Trying to add cell for non terminal symbol not included "
                "in table.",
            )
        if terminal not in self.terminals:
            raise ValueError(
                "Trying to add cell for terminal symbol not included "
                "in table.",
            )
        if not all(x in self.terminals | self.non_terminals for x in cell_body):
            raise ValueError(
                "Trying to add cell whose body contains elements that are "
                "not either terminals nor non terminals.",
            )            
        if self.cells[non_terminal][terminal] is not None:
            raise RepeatedCellError(
                f"Repeated cell ({non_terminal}, {terminal}).")
        else:
            self.cells[non_terminal][terminal] = cell_body

    def analyze(self, input_string: str, start: str) -> ParseTree:
        """
        Method to analyze a string using the LL(1) table.

        Args:
            input_string: string to analyze.
            start: initial symbol.

        Returns:
            ParseTree object with either the parse tree (if the elective exercise is solved)
            or an empty tree (if the elective exercise is not considered).

        Raises:
            SyntaxError: if the input string is not syntactically correct.
        """
        def initialize_stack_and_tree() -> Tuple[deque, Dict[int, ParseTree], int]:
            stack = deque(list((("$", -1), (start, 0))))
            count = 1
            tree_dict = {0: ParseTree(start, [])}
            return stack, tree_dict, count

        def parse_input_string(input_string: str, stack: deque, tree_dict: Dict[int, ParseTree], count: int) -> ParseTree:
            while stack and input_string:
                stacktop, IDstacktop = stack.pop()
                nxt = input_string[0]

                if stacktop in self.non_terminals:
                    if self.cells[stacktop][nxt] is None:
                        raise SyntaxError(f"No hay una regla asociada para ({stacktop}, {nxt}).")
                    ids: Callable[[], Iterable[int]] = lambda: range(count, count + len(rhs))
                    rhs_ids: Callable[[], Iterable[Tuple[str, int]]] = lambda: zip(rhs, ids())
                    rhs = list(self.cells[stacktop][nxt] or [])
                    stack.extend(list(rhs_ids())[::-1])
                    rhs = rhs if rhs else [""]
                    for sym_, id_ in rhs_ids():
                        tree_dict[id_] = ParseTree(sym_ if sym_ else "λ", [])
                    tree_dict[IDstacktop].add_children([tree_dict[i] for i in ids()])
                    count += len(rhs)
                else:
                    if stacktop != nxt:
                        raise SyntaxError(f"Se esperaba {nxt},se encontro {stacktop}.")
                    input_string = input_string[1:]

            if not input_string and not stack:
                return tree_dict[0]

            raise SyntaxError(f"Error en el analisis.")

        if any(terminal not in self.terminals for terminal in input_string):
            raise SyntaxError("Simbolos no pertenecientes a la gramatica.")

        stack, tree_dict, count = initialize_stack_and_tree()

        try:
            result_tree = parse_input_string(input_string, stack, tree_dict, count)
            return result_tree
        except SyntaxError as e:
            raise e
        
class ParseTree():
    """
    Parse Tree.

    Args:
        root: root node of the tree.
        children: list of children, which are also ParseTree objects.
    """
    def __init__(self, root: str, children: Collection[ParseTree] = []) -> None:
        self.root = root
        self.children = children

    def __repr__(self) -> str:
        return (
            f"{type(self).__name__}({self.root!r}: {self.children})"
        )

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, type(self)):
            return NotImplemented
        return (
            self.root == other.root
            and len(self.children) == len(other.children)
            and all([x.__eq__(y) for x, y in zip(self.children, other.children)])
        )

    def add_children(self, children: Collection[ParseTree]) -> None:
        self.children = children
