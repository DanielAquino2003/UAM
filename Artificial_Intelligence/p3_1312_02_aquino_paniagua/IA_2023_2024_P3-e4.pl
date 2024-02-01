/***************
*
* Autores: Daniel Aquino Jorge Paniagua
*
* Grupo: 1312
*
****************/

/***************
* EJERCICIO 4 (2p). Combate Pokémon
*
* Ash, Misty y Brock van a medir sus fuerzas en combates Pokémon. Para ello,
* Ash cuenta con sus amigos Pikachu, Charmander y Bulbasaur, Misty con sus 
* pokémon de tipo agua Psyduck, Staryu y Starmie y Brock con sus criaturas 
* de tipo roca Geodude, Golem y Onyx. Hemos creado el predicado pokemonOfTrainer/2 
* para relacionar cada pokémon con su entrenador. También hemos construido el 
* predicado pokemonOfType/2 que nos indica el tipo de cada pokémon. Por último, 
* hemos creado el predicado typeWins/2 para introducir la tabla de tipos, 
* que nos indica si un pokémon gana a otro en función de su tipo. 
*
****************/

pokemonOfTrainer(pikachu, ash).
pokemonOfTrainer(charmander, ash).
pokemonOfTrainer(bulbasaur, ash).

pokemonOfTrainer(psyduck, misty).
pokemonOfTrainer(staryu, misty).
pokemonOfTrainer(starmie, misty).

pokemonOfTrainer(geodude, brock).
pokemonOfTrainer(golem, brock).
pokemonOfTrainer(onyx, brock).

pokemonOfType(pikachu, electric).
pokemonOfType(charmander, fire).
pokemonOfType(bulbasaur, grass).
pokemonOfType(psyduck, water).
pokemonOfType(staryu, water).
pokemonOfType(starmie, water).
pokemonOfType(geodude, rock).
pokemonOfType(golem, rock).
pokemonOfType(onyx, rock).

typeWins(water, fire).
typeWins(fire, grass).
typeWins(grass, water).
typeWins(water, rock).
typeWins(rock, fire).
typeWins(grass, rock).
typeWins(electric, water).
typeWins(rock, electric).

% 1) Construye el predicado pokemonWins/2 que indique que un pokémon A gana a 
% un pokémon B si el tipo de A gana al tipo de B.

%Primero se obtienen los tipos de cada pokemon, y finalmente se verifica si el tipo del pokemon A gana al tipo del pokemon B
pokemonWins(A, B) :-
    once((pokemonOfType(A, AT), pokemonOfType(B, BT), typeWins(AT, BT))).

% 2) Construye el predicado trainerWins/2 que nos indique que un entrenador A
% gana a un entrenador B si...
% a) El primer pokémon del entrenador A gana al primero del B, el segundo de A
% gana al segundo de B y el tercero de A gana al tercero de B.
% b) Al menos dos pokémon del entrenador A ganan a sus equivalentes del entrenador B. 
% c) Un pokémon del entrenador A es capaz de ganar a los tres del entrenador B.

trainerWins(A, B) :-
    once((
		%Condicion a
		(pokemonOfTrainer(P7, A), pokemonOfTrainer(P8, A), pokemonOfTrainer(P9, A), pokemonOfTrainer(P10, B), pokemonOfTrainer(P11, B), pokemonOfTrainer(P12, B),
		 pokemonWins(P7, P10), pokemonWins(P8, P11), pokemonWins(P9, P12))
		;
		%Condicion b
		(pokemonOfTrainer(P3, A), pokemonOfTrainer(P4, A), pokemonOfTrainer(P5, B), pokemonOfTrainer(P6, B),
         pokemonWins(P3, P5), pokemonWins(P4, P6))
		;
		%Condicion c
        (pokemonOfTrainer(P, A), pokemonOfTrainer(P1, B), pokemonOfTrainer(P2, B), pokemonOfTrainer(P3, B),
         pokemonWins(P, P1), pokemonWins(P, P2), pokemonWins(P, P3))
    )).


% 3) ¿Quién gana los combates Ash vs Misty, Misty vs Brock y Brock vs Ash
% utilizando los criterios a, b y c?

%Ash vs Misty: ash gana a misty, y misty gana a ash, por tanto podria ganar cualquiera
%Misty vs Brock: misty gana a brock y brock no gana a misty, por tanto gana misty
%Brock vs Ash: brosk gana a ash y ash gana a brock
