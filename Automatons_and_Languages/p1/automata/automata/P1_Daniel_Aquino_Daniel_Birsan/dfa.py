from automata.automaton import State, Transitions, FiniteAutomaton
from automata.utils import is_deterministic
from collections import deque
from functools import cmp_to_key
from typing import List
import numpy
import copy
import queue

def compare_states(state1, state2):
    name1 = state1.name.lower()
    name2 = state2.name.lower()

    if is_initial_state(name1):
        return -1
    elif is_initial_state(name2):
        return 1
    if is_empty_state(name1):
        return 1
    elif is_empty_state(name2):
        return -1
    if is_final_state(name1):
        return 1
    elif is_final_state(name2):
        return -1

    if are_digits_valid(name1) and are_digits_valid(name2):
        return compare_digits(name1, name2)

    val1 = calculate_value(name1)
    val2 = calculate_value(name2)

    return val1 - val2

def is_initial_state(name):
    return name == "initial"

def is_empty_state(name):
    return name == "empty"

def is_final_state(name):
    return name == "qf" or name == "final"

def are_digits_valid(name):
    return name[1:].isdigit()

def compare_digits(name1, name2):
    return int(name1[1:]) - int(name2[1:])

def calculate_value(name):
    return sum(ord(char) for char in name)


def combined_states(state_set: set) -> State:
    state_list = list(state_set)
    sorted_list = sort_states(state_list)

    new_state_name = ""
    is_final_state = False

    has_numbers = check_for_numbers(sorted_list)

    for state in sorted_list:
        new_state_name = construct_new_state_name(state, has_numbers, new_state_name)
        is_final_state = update_final_state_flag(state, is_final_state)

    return State(new_state_name, is_final_state)

def sort_states(states):
    return sorted(states, key=cmp_to_key(compare_states))

def check_for_numbers(states):
    if states[0].name[1:].isdigit():
        return True
    else:
        return False

def construct_new_state_name(state, has_numbers, current_name):
    if has_numbers:
        return current_name + "q" + state.name[1:]
    else:
        return current_name + state.name

def update_final_state_flag(state, current_flag):
    if state.is_final:
        return True
    else:
        return current_flag

from typing import List

def has_transitions_other_than_self(state: State, automaton: FiniteAutomaton) -> bool:
    for symbol in automaton.symbols:
        transitions = automaton.get_transition(state, symbol)
        if len(transitions) > 0 and any(q != state for q in transitions):
            return True
    return False

def find_empty_state(automaton: FiniteAutomaton) -> State:
    for state in automaton.states:
        if not has_transitions_other_than_self(state, automaton) and not state.is_final:
            return state

    return State("Empty", is_final=False)

def get_empty_state(automaton: FiniteAutomaton) -> State:
    return find_empty_state(automaton)


class DeterministicFiniteAutomaton(FiniteAutomaton):

    @staticmethod
    def to_deterministic(finiteAutomaton: FiniteAutomaton):
        """
        Returns an equivalent deterministic finite automaton.
        """

        # To avoid circular imports
        from automata.automaton_evaluator import FiniteAutomatonEvaluator
        evaluator = FiniteAutomatonEvaluator(finiteAutomaton)

        q = queue.Queue()
        init_states = combined_states(evaluator.current_states)
        states_table = dict()

        q.put(evaluator.current_states)
        states_nw = set()
        states_nw.add(init_states)

        states_em = get_empty_state(finiteAutomaton)
        flg = False

        while not q.empty():
            sta = q.get()
            newstate = combined_states(sta)
            for sym in finiteAutomaton.symbols:
                evaluator.current_states = sta
                evaluator.process_symbol(sym)
                if newstate not in states_table.keys():
                    states_table[newstate] = dict()
                if len(evaluator.current_states) == 0:
                    st_procc = states_em
                    states_nw.add(st_procc)
                    flg = True
                else:
                    st_procc = combined_states(evaluator.current_states)
                states_table[newstate][sym] = set()
                states_table[newstate][sym].add(st_procc)
                if st_procc not in states_nw:
                    q.put(evaluator.current_states)
                    states_nw.add(st_procc)
        if flg:
            states_table[states_em] = dict()
            for sym in finiteAutomaton.symbols:
                states_table[states_em][sym] = set()
                states_table[states_em][sym].add(states_em)

        transition_s = Transitions(states_table)
        return FiniteAutomaton(init_states,
                                states=states_nw,
                              symbols=finiteAutomaton.symbols, 
                              transitions=transition_s)

    @staticmethod
    def to_minimized(dfa):
        """
        Return a equivalent minimal automaton.
        Returns:
            Equivalent minimal automaton.
        """

        from automata.automaton_evaluator import FiniteAutomatonEvaluator
        evaluator = FiniteAutomatonEvaluator(dfa)
        evaluatorpre = FiniteAutomatonEvaluator(dfa)

        states_acc = set()
        states_acc.add(dfa.initial_state)
        q = queue.Queue()
        q.put(evaluator.current_states)

        while not q.empty():
            state = q.get()
            for sym in dfa.symbols:
                evaluator.current_states = state
                evaluator.process_symbol(sym)
                if len(evaluator.current_states) > 0:
                    flg = False
                    for st_nx in evaluator.current_states:
                        if st_nx not in states_acc:
                            if not flg:
                                q.put(evaluator.current_states)
                                flg = True
                            states_acc.add(st_nx)

        lista_acc = sorted(list(states_acc), key=cmp_to_key(compare_states))
        table_2 = len(lista_acc)
        class_table = numpy.ndarray(shape=(2, table_2))
        class_table[0] = [int(state.is_final) for state in lista_acc]
        class_table[1] = [None] * table_2

        while True:
            classcont = 0
            for j in range(table_2):
                if numpy.isnan(class_table[1][j]):
                    class_table[1][j] = classcont
                    classcont += 1
                    for i in range(1, table_2):
                        class_S = True
                        if numpy.isnan(class_table[1][i]):
                            if class_table[0][i] == class_table[0][j]:
                                for sym in dfa.symbols:
                                    evaluatorpre.current_states = {lista_acc[j]}
                                    evaluator.current_states = {lista_acc[i]}
                                    evaluatorpre.process_symbol(sym)
                                    evaluator.process_symbol(sym)
                                    pre_state = evaluatorpre.current_states.pop()
                                    state_now = evaluator.current_states.pop()
                                    if class_table[0][lista_acc.index(pre_state)] != class_table[0][lista_acc.index(state_now)]:
                                        class_S = False
                                        break
                                if class_S:
                                    class_table[1][i] = class_table[1][j]

            if numpy.array_equal(class_table[0], class_table[1]):
                break
            else:
                class_table[0] = class_table[1].copy()
                class_table[1] = [None] * table_2

        ifBigger = [class_table[0][i] for i in range(len(class_table[0]))]
        ifBigger.sort(reverse=True)
        tam_new = int(ifBigger[0]) + 1
        lst_stState = [set() for _ in range(tam_new)]
        new_states = set()

        for i in range(table_2):
            lst_stState[int(class_table[0][i])].add(lista_acc[i])

        n_transitions = dict()
        for i in range(tam_new):
            aux = combined_states(lst_stState[i])
            new_states.add(aux)
            n_transitions[aux] = dict()
            for symbol in dfa.symbols:
                evaluator.current_states = lst_stState[i]
                evaluator.process_symbol(symbol)
                n_transitions[aux][symbol] = set()
                if evaluator.current_states not in lst_stState:
                    aux_current = evaluator.current_states.pop()
                    evaluator.current_states = lst_stState[int(class_table[0][lista_acc.index(aux_current)])]
                n_transitions[aux][symbol].add(combined_states(evaluator.current_states))

        trans = Transitions(n_transitions)
        output = FiniteAutomaton(
            initial_state=combined_states(lst_stState[0]),
            states=new_states,
            symbols=dfa.symbols,
            transitions=trans
        )
        return output