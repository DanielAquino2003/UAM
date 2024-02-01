/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312
*
****************/

/***************
* EJERCICIO 5 (2p). Procesamiento de sentencias
*
* Si bien un procesamiento completo de lenguaje es una tarea compleja, debido a que
* su uso no siempre es estructurado, podemos utilizar, a base de reglas sencillas, Prolog
* para identificar "frases bien formadas".
* Para ello, se os da una base de conocimiento inicial y se os pide que diseñéis un predicado
* que identifique si una frase es correcta. En el resto del ejercicio iréis ampliando las 
* reglas para identificar frases cada vez más complejas.
*
****************/

% Partimos de la siguiente base de conocimiento simplificada
determinantes([X]) :-
    articulo(X);
    demostrativo(X);
    posesivo(X);
    indefinido(X).

articulo([X]) :- articulo(X).
    articulo(el).

demostrativo([X]) :- demostrativo(X).
    demostrativo(este).
    demostrativo(ese).
    demostrativo(aquel).


posesivo([X]) :- posesivo(X).
    posesivo(mi).
    posesivo(tu).
    posesivo(su).
    posesivo(nuestro).
    posesivo(vuestro).

indefinido([X]) :- indefinido(X).
    indefinido(un).
    indefinido(ningun).
    indefinido(otro).


nombre([X]) :- nombre(X).
nombre(perro).
nombre(hueso).

verbo([X]) :- verbo(X).
verbo(come).
verbo(encuentra).

adjetivo([X]) :- adjetivo(X).
adjetivo(guapo).
adjetivo(bueno).
adjetivo(rico).


% 1. Define un predicado frase/1 que determine si una frase 
% (codificada como una lista de terminales) es correcta gramaticalmente.
% De momento, nos basta con identificar frases como la siguiente, donde hay un sintagma nominal
% y uno verbal, pero sin complemento de ningún tipo:
% :- frase([el, perro, come]).
% :- frase([la, perro, come]).
% Sin embargo, la siguiente fallaría:
% :- frase([come]). FAIL
% El predicado append/3 puede ser útil para asignar partes de una frase a variables.

%Obtenemos cada componente de la frase y lo igualamos a una variable, y comprobamos si estan correctamente cada uno en el orden "articulo, nombre, verbo"
frase(Lista) :-
    once((append([A, N, V], Lista), determinantes(A), nombre(N), verbo(V))).

% 2. Amplía la base de conocimiento con más hechos (nombres, verbos, determinantes). 
% Al igual que en el ejercicio anterior, no nos vamos a preocupar de la concordancia de género.
% Extiende el predicado anterior y llámalo frase2/1 para que reconozca frases 
% cuyo sintagma verbal tenga uno (o varios) complementos.
% Puedes reutilizar todos los predicados que consideres, pero si tienes que cambiar alguno, 
% renómbralo para mantener la compatibilidad con los ejercicios anteriores.

%Primero se ha mejorad en cierta medida la base de conocimiento para diferenciar entre determinantes

frase2(Lista) :-
    once((append([D, N, V, Comp], Lista), determinantes(D), nombre(N), verbo(V), maybe_complement(Comp))).

maybe_complement([]).
maybe_complement(Comp) :- 
    once((append([D, N, Comp2], Comp), determinantes(D), nombre(N), maybe_complement(Comp2))).

%Se siguen los pasos del primer apartado, pero añadiento un campo mas "Comp", con el cual llamamos a la regla maybe_complement, que se cumple si el complemento es de
%la forma "determinante, complemento" o si no existe complemento

%para observar el mejor funcionamiento se podria agregar la opcion de preposiciones para añadir mas tipos de complementos

% 3. Añade adjetivos a la base de conocimiento y crea el predicado frase3/1 que detecte si 
% un nombre va acompañado de un adjetivo. Es decir:
% :- frase3([el, perro, grande, come]).
% De manera opcional, permite la utilización de adjetivos tanto delante como detrás del nombre.

frase3(Lista) :-
    once((append([D, A, N, A2, V, Comp], Lista), determinantes(D), es_adjetivo(A), nombre(N), es_adjetivo(A2), verbo(V), maybe_complement2(Comp))).

maybe_complement2([]).
maybe_complement2(Comp) :- 
    once((append([D, A, N, A2, Comp2], Comp), determinantes(D), es_adjetivo(A), nombre(N), es_adjetivo(A2), maybe_complement(Comp2))).

es_adjetivo([]).
es_adjetivo(A) :-
    adjetivo(A).

%Se ha añadido la posibilidad tanto en frase3 como en maybecomplement de que exista adjetivo o delante de un nombre o detras.
%Si es un verbo o no se verifica con la regla "es_adjetivo" que es correcto, tanto como si no hay nada como si es un adjetivo recogido en la base de conocimiento

% 4. Identifica un ejemplo de frase que no lo detecte alguno de tus predicados y explica 
% cuál sería el motivo. Puedes utilizar la lectura declarativa o procedural 
% vista en el ejercicio 1 o apoyarte en trace/0 para tu explicación.

%Frases que contengan preposiciones, lo cual se podria arreglar agregando la regla de es_preposicion, que para los complementos verifique si hay una preposicion en dicho complemento.
%Tampoco verifica la concordancia sintactica de las frases.
