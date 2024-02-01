/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312 P02
*
****************/

/***************
* EJERCICIO 2 (2p). Casa Stark
*
* Construir un árbol genealógico con Prolog es fácil. Basta con crear 
* un predicado parent\2 para indicar que una persona es padre o madre de otra 
* y así construir de generación en generación. Aquí hemos creado 
* la casa Stark de Juego de tronos. 
*
****************/

parent(eddard, robb).
parent(eddard, bran).
parent(eddard, rickon).
parent(eddard, sansa).
parent(eddard, arya).
parent(catelyn, robb).
parent(catelyn, bran).
parent(catelyn, rickon).
parent(catelyn, sansa).
parent(catelyn, arya).

parent(rickard, eddard).
parent(rickard, brandon).
parent(rickard, benjen).
parent(rickard, lyanna).
parent(lyarra, eddard).
parent(lyarra, brandon).
parent(lyarra, benjen).
parent(lyarra, lyanna).

male(rickard).
male(brandon).
male(eddard).
male(benjen).
male(robb).
male(bran).
male(rickon).

female(lyarra).
female(lyanna).
female(catelyn).
female(sansa).
female(arya).

% 1) Empleando el predicado parent, construye los siguientes métodos:
% father(M, N), que devuelva True si M es el padre de N.
% mother(M, N), que devuelva True si M es la madre de N.
% son(M, N), que devuelva True si M es el hijo de N.
% daugther(M, N), que devuelva True si M es la hija de N.

% 2) Construye los métodos grandparent, grandfather y grandmother 
% que permitan encontrar los abuelos de un Stark, así como los métodos
% grandson y grandaugther que devuelvan los nietos y nietas de un Stark.

% 3) ¿Cómo crearías los métodos de hermano (brother), hermana (sister),
% tío (uncle), tía (aunt), sobrino (nephew) y sobrina (niece).

%Soluciones

%1
father(M, N) :- male(M), parent(M, N).
mother(M, N) :- female(M), parent(M, N).
son(M, N) :- parent(N, M), male(M).
daugther(M, N) :- parent(N, M), female(M).

%2
grandparent(M, N) :- parent(M, X), parent(X, N).
grandfather(M, N) :- grandparent(M, N), male(M).
grandmother(M, N) :- grandparent(M, N), female(M).
grandson(M, N) :- grandparent(N, M), male(M).
grandaugther(M, N) :- grandparent(N, M), female(M).

%3
%hermano(brother):"brother(M, N)" seria verificar si tienen padres comunes y M es hombre y si M y N no son la misma persona.
brother(M, N) :- parent(P, M), parent(P, N), male(M), M \= N.
%hermana(sister): "sister(M, N)" seria verificar si tienen padres comunes y M es mujer y si M y N no son la misma persona.
sister(M, N) :- parent(P, M), parent(P, N), female(M), M \= N.
%tio(uncle): "uncle(M, N)" seria verificar si el padre o madre de N es hermano de M y ademas M es hombre
uncle(M, N) :- male(M), parent(P, N), brother(M, P).
%tia(aunt): "aunt(M, N)" seria verificar si el padre o madre de N es hermano de M y ademas M es mujer
aunt(M, N) :- female(M), parent(P, N), sister(M, P).

