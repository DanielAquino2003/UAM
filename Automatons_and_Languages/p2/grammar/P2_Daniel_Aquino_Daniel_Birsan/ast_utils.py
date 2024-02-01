import ast

class ASTNestedIfCounter(ast.NodeVisitor):
    def __init__(self):
        self.max_depth = 0
        self.current_depth = 0

    def generic_visit(self, node):
        for field_name, field_value in ast.iter_fields(node):
            if isinstance(field_value, list):
                for item in field_value:
                    if isinstance(item, ast.AST):
                        self.visit(item)
            elif isinstance(field_value, ast.AST):
                self.visit(field_value)
        return self.max_depth

    def visit_If(self, node):
        self.current_depth += 1
        self.max_depth = max(self.max_depth, self.current_depth)

        # Cambio aquí para asegurarse de que se visite el cuerpo del if
        self.generic_visit(node)

        self.current_depth -= 1
        

class ASTDotVisitor(ast.NodeVisitor):

    idcounter: int

    def generic_visit(self, node: ast.AST) -> None:
        self.idcounter = 0
        print("digraph {")
        self.visit_node(node)
        print("}")

    def visit_node(self, node: ast.AST) -> None:
        nodeid = self.idcounter
        print('s{}[label="{}({})", shape=box]'.
              format(nodeid, type(node).__name__, self.my_vars(node)))

        for field, value in ast.iter_fields(node):
            if isinstance(value, list) and value:
                for item in value:
                    self.visit_child_node(field, item, nodeid)
            elif isinstance(value, ast.AST):
                self.visit_child_node(field, value, nodeid)

    def visit_child_node(self, field: str, node: ast.AST, parentid: int) -> None:
        self.idcounter += 1
        print(f's{parentid} -> s{self.idcounter}[label="{field}"]')
        self.visit_node(node)

    def my_vars(self, obj: ast.AST) -> str:
        return ", ".join(
            f"{key}='{value}'"
            for key, value in ast.iter_fields(obj)
            if not isinstance(value, (ast.AST, list))
        )
    

"""
    PRUEBA DE FUNCIONAMIENTO PARA EJERCICIO1-
    GENERARA DOS ARCHIVOS .DOT CON EL RESULTADO
    PARA ENTENDER DICHO RESULTADO MEJOR, EJECUTANDO (dot -Tpng fun1.dot -o fun1.png)y (dot -Tpng fun2.dot -o fun2.png)

import inspect
import sys

def fun1(p):
    a = 1
    b = 2
    if a == 1:
        print(a)
    if b == 1:
        print(b)

def fun2(p):
    a = 1
    if a == 1:
        print(a)
    if True:
        if True:
            if a == 1:
                print(a)

def main() -> None:
    counter = ASTNestedIfCounter()

    # Prueba para fun1
    source_fun1 = inspect.getsource(fun1)
    my_ast_fun1 = ast.parse(source_fun1)
    print("fun1: máximo número de if anidados:", counter.visit(my_ast_fun1))

    # Redirigir la salida a un archivo DOT
    with open('fun1.dot', 'w') as dot_file:
        sys.stdout = dot_file
        # Crear una instancia de ASTDotVisitor y visualizar el AST de fun1
        dot_visitor_fun1 = ASTDotVisitor()
        dot_visitor_fun1.generic_visit(my_ast_fun1)

    # Restaurar la salida estándar al terminal
    sys.stdout = sys.__stdout__

    # Prueba para fun2
    source_fun2 = inspect.getsource(fun2)
    my_ast_fun2 = ast.parse(source_fun2)
    print("fun2: máximo número de if anidados:", counter.visit(my_ast_fun2))

    # Redirigir la salida a un archivo DOT
    with open('fun2.dot', 'a') as dot_file:
        sys.stdout = dot_file
        # Crear una instancia de ASTDotVisitor y visualizar el AST de fun2
        dot_visitor_fun2 = ASTDotVisitor()
        dot_visitor_fun2.generic_visit(my_ast_fun2)

    # Restaurar la salida estándar al terminal
    sys.stdout = sys.__stdout__

if __name__ == "__main__":
    main() 
"""
