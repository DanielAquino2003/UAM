/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312 P02
*
****************/

/***************
* Introducción
*
* Os recomendamos echar un vistazo a la colección de 99 problemas de Prolog publicados en 
* https://www.ic.unicamp.br/~meidanis/courses/mc336/2009s2/prolog/problemas/
* Ahí puedes encontrar una gran serie de problemas con código que te pueden ayudar 
* como entrenamiento.
*
****************/

/***************
* Entrega
*
* Se debe entregar un único fichero comprimido cuyo nombre, todo él en minúsculas y sin acentos, 
* tildes, o caracteres especiales, tendrá la siguiente estructura:
*       p3_gggg_mm_apellido1_apellido2.zip
* Donde gggg es el identificador del grupo y mm es el de la pareja.
* Este fichero debe incluir los ficheros .pl entregados por los profesores con sus correspondientes
* soluciones y descripciones de las mismas como comentarios (no hace falta entregar una memoria por separado).
*
* Recordad utilizar nombres informativos para los términos (hechos, reglas) así como comentar vuestro código 
* adecuadamente para que resulte de fácil lectura.
*
****************/


/***************
* EJERCICIO 1 (1p). Ejercicio de lectura
*
* Escribe la lectura declarativa (para el caso general) 
* y procedural (para la consulta slice([1, 2, 3, 4], 2, 3, L2))
* del predicado slice/4, disponible en
* https://www.ic.unicamp.br/~meidanis/courses/mc336/2009s2/prolog/problemas/p18.pl
*
* Véase https://www.metalevel.at/prolog/reading para un ejemplo.
*
****************/

/*PREDICADO*/

% P18 (**):  Extract a slice from a list

% slice(L1,I,K,L2) :- L2 is the list of the elements of L1 between
%    index I and index K (both included).
%    (list,integer,integer,list) (?,+,+,?)

slice([X|_],1,1,[X]).
slice([X|Xs],1,K,[X|Ys]) :- K > 1, 
   K1 is K - 1, slice(Xs,1,K1,Ys).
slice([_|Xs],I,K,Ys) :- I > 1, 
   I1 is I - 1, K1 is K - 1, slice(Xs,I1,K1,Ys).

/*
	Lectura declarativa: 
	- Este codigo se utiliza para extraer un porcíon de una lista, tomando como argumentos
	  una lista L1, dos indices "I ,K" y la lista resultante L2. La nueva lista L2 contiene los valores de la lista L1 contenidos entre los indices I Y K.
	- slice([X|_],1,1,[X]). : Si los valores de los indices I y K son igual a 1, la lista resultante L2, contendra el primer valor de la lista L1
	- slice([X|Xs],1,K,[X|Ys]) :- K > 1, K1 is K - 1, slice(Xs,1,K1,Ys). :Si el índice de inicio I es 1 y el índice de fin K es mayor que 1, 
	  se toma el primer elemento de la lista original L1, y la nueva lista L2 se forma recursivamente con el resto de la lista Xs y decrementando el índice de fin K.
	- slice([_|Xs], I, K, Ys) :- I > 1, I1 is I - 1, K1 is K - 1, slice(Xs, I1, K1, Ys).: Si el índice de inicio I es mayor que 1, se omite el primer elemento de la lista original L1,
	  y la nueva lista L2 se forma recursivamente con el resto de la lista Xs, decrementando tanto el índice de inicio I como el índice de fin K.
	
	La consulta slice([1, 2, 3, 4], 2, 3, L2) devuelve: L2 = [2,3] .
	Primero se cumple "slice([_|Xs], I, K, Ys) :- I > 1, I1 is I - 1, K1 is K - 1, slice(Xs, I1, K1, Ys).". Se omite el primer elemento de la lista y luego se realiza una llamad recursiva con el resto de la lista [2,3,4] y K e I decrementado.
	Se aplica a continuación "slice([X|Xs], 1, K, [X|Ys])" ya que I es ahora 1 y K ahora es 2. Toma el siguiente elemento X de la lista y realiza otra llamada recursiva con [3,4] y K decrementado
	Finalmente se alcanza la base de recursion siendo I y J = 1. y se devuelve la lista con [3]. Por lo tanto la unificacion de L2 = [2,3]

*/
