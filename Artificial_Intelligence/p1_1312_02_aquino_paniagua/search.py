# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
#
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).

Name student 1: ...
Name student 2: ...
IA lab group and pair: gggg - mm

"""

import util


class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()


def tinyMazeSearch(search_problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    from game import Directions
    s = Directions.SOUTH
    w = Directions.WEST
    return [s, s, w, s, w, w, s, w]


def depthFirstSearch(search_problem):
    stack = util.Stack()
    path = []
    visited = []
    state = search_problem.getStartState()
    visited.append(state)

    parent = {}
    from_dir = {}
    parent[state] = state
    from_dir[state] = None
    
    while not search_problem.isGoalState(state):
        for successor in search_problem.getSuccessors(state):

            son_st = successor[0]
            if son_st not in visited:
                parent[son_st] = state
                from_dir[son_st] = successor[1]
                stack.push(son_st)

        while state in visited:
            if stack.isEmpty():
                return None

            state = stack.pop()
        visited.append(state)
    while parent[state] != state:
        path.insert(0, from_dir[state])
        state = parent[state]

    return path

def breadthFirstSearch(search_problem):
    queue = util.Queue()
    path = []
    visited = set()
    state = search_problem.getStartState()
    parent = {}
    from_dir = {}
    parent[state] = state
    from_dir[state] = None
    queue.push((state, path))
    while not queue.isEmpty():
        state, path = queue.pop()
        if search_problem.isGoalState(state):
            return path
        if state not in visited:
            visited.add(state)
            for successor in search_problem.getSuccessors(state):
                son_st = successor[0]
                if son_st not in visited:
                    parent[son_st] = state
                    from_dir[son_st] = successor[1]
                    queue.push((son_st, path + [successor[1]]))
    return None


def uniformCostSearch(search_problem):
    priority_queue = util.PriorityQueue()
    path = []
    visited = set()
    state = search_problem.getStartState()
    cost = 0

    parent = {}
    from_dir = {}
    parent[state] = state
    from_dir[state] = None

    priority_queue.push((state, path, cost), cost)

    while not priority_queue.isEmpty():
        state, path, cost = priority_queue.pop()

        if search_problem.isGoalState(state):
            return path

        if state not in visited:
            visited.add(state)
            for successor in search_problem.getSuccessors(state):
                son_st, action, step_cost = successor
                if son_st not in visited:
                    parent[son_st] = state
                    from_dir[son_st] = action
                    priority_queue.push((son_st, path + [action], cost + step_cost), cost + step_cost)

    return None

def nullHeuristic(state, search_problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0


def aStarSearch(search_problem, heuristic=nullHeuristic):
    """Search the node that has the lowest combined cost and heuristic first."""
    queue = util.PriorityQueue()
    ret = []
    expanded = []
    state = search_problem.getStartState()
    expanded.append(state)
    parent = {}
    direction = {}
    parent[state] = state
    direction[state] = None
    accumulatedCost = {}
    accumulatedCost[state] = 0
    while not search_problem.isGoalState(state):
        for successor in search_problem.getSuccessors(state):
            childState = successor[0]
            if childState not in expanded:
                newCost = accumulatedCost[state] + successor[2]
                if childState not in parent.keys() or accumulatedCost[childState] > newCost:
                    accumulatedCost[childState] = newCost
                    parent[childState] = state
                    direction[childState] = successor[1]
                queue.push(childState, accumulatedCost[childState] + heuristic(childState, search_problem))
        while state in expanded:
            if queue.isEmpty():
                return None
            state = queue.pop()
        expanded.append(state)
    while parent[state] != state:
        ret.insert(0, direction[state])
        state = parent[state]
    return ret



# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
