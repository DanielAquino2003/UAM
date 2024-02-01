/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312
*
****************/

/***************
* EJERCICIO 6 (1p). Librería clpb
*
* La librería CLP(B) (ver https://www.swi-prolog.org/pldoc/man?section=clpb)
* permite resolver problemas combinatorios con restricciones.
*
* A continuación se os da la solución al siguiente problema resuelto con esta librería:
* Tenemos a 3 sospechosos de un robo, Alice (A), Bob (B) y Carl (C). 
* Al menos uno de ellos es culpable. Condiciones:
* Si A es culpable, tiene exactamente 1 cómplice.
* Si B es culpable, tiene exactamente 2 cómplices.
* ¿Quién es culpable?
*
****************/

:- use_module(library(clpb)).

solve(A,B,C) :-
 % Hay al menos un culpable
 sat(A + B + C),
 % Si A es culpable, tiene exactamente 1 cómplice.
 sat(A =< B # C),
 % Si B es culpable, tiene exactamente 2 cómplices.
 sat(B =< A * C),
 % Asigna valores a las variables de manera que se satisfagan todas las restricciones.
 labeling([A,B,C]).


% 1. Plantea una solución a este problema que sea equivalente a la encontrada por la librería.

solve_manual(A, B, C) :-
    % Hay al menos un culpable
    (A = 1; B = 1; C = 1),

    % Si A es culpable, tiene exactamente 1 cómplice.
    (A = 0 ; (A = 1, (B = 1, C = 0 ; B = 0, C = 1))),

    % Si B es culpable, tiene exactamente 2 cómplices
    (B = 0 ; (B = 1, A = 1, C = 1)).

% 2. Discute las ventajas e inconvenientes entre la solución encontrada y el uso de la librería.
% es que no se dispone de toda la informacion completa de como se ha llegado a dicho resultado, por lo que se puede llegar a tener dificultad a la hora de afrontar un problema
%En algunos casos, especialmente en problemas menos complejos, la solución manual podría ofrecer más flexibilidad y control directo sobre la lógica del problema
