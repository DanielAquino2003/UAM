/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312 P02
*
****************/

/***************
* EJERCICIO 3 (2p). Cluedo
*
* Alguien ha cometido un terrible asesinato en la mansión. Hemos podido
* reunir algunas pruebas y pistas sobre los diferentes habitantes de la casa,
* los lugares en los que han estado y las posibles armas que han portado.
* Esto es posible gracias a los predicados fact\3, que relaciona a una persona
* con un lugar y una hora, y hint\3, que relaciona a una persona con un arma
* y una hora. 
*
****************/
%libreria de listas
:- use_module(library(lists)).

% Lista de personas
personas([amapola, rubio, blanco, prado, celeste, mora]).

fact(amapola, salon, 10).
fact(amapola, cocina, 12).
fact(amapola, comedor, 14).

fact(rubio, billar, 10).
fact(rubio, biblioteca, 12).

fact(blanco, cocina, 12).

fact(prado, biblioteca, 9).

fact(celeste, billar, 11).
fact(celeste, escaleras, 13).

fact(mora, biblioteca, 10).
fact(mora, terraza, 12).

hint(amapola, cuchillo, 10).
hint(amapola, tuberia, 12).

hint(rubio, cuchillo, 10).
hint(rubio, tuberia, 10).
hint(rubio, pistola, 9).

hint(blanco, cuchillo, 13).

hint(prado, cuchillo, 10).

hint(celeste, candelabro, 10).
hint(celeste, tuberia, 11).

hint(mora, pistola, 11).

% 1) Crea un método suspect\3 que devuelva true si la persona X estuvo 
% en la habitación H y empuñó el arma A. Utilízalo para averiguar
% los sospechosos de un crimen cometido en la biblioteca con el cuchillo.

% 2) Crea un método guilty\4 para obtener la persona X entre los sospechosos
% que es más probable que cometiera el crimen en la habitación H, usando
% el arma A y a la hora T. Utilízalo para averiguar el culpable del crimen
% cometido en la biblioteca con el cuchillo a las 10

%Soluciones
%1
%Encuentra una solucion para la persona que ha estado en el sitio H a una hora cualquiera y con el arma A a una hora cualquiera
suspect(X, H, A) :-
    once((fact(X, H, _), hint(X, A, _))).

%2
%Esta regla, encuentra todas las personas que son sospechosos, es decir que estuvieron con el arma A en el sitio H, y luego se elige entre ellos, 
%segun la persona que haya estado a una hora mas cercana de T en el sitio H
guilty(T, H, A, X) :-
    personas(Suspects),
    findall([Suspect, H, A],
        (member(Suspect, Suspects),
         once(suspect(Suspect, H, A)),
         fact(Suspect, H, Hour),
         abs(Hour - T) =< 1),
        X).

    

