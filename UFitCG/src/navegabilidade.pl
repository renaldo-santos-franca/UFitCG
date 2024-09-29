:- module(navegabilidade, [menuInicial/0]).

clear_screen :- write('\e[H\e[2J').

menuInicial :-
    clear_screen,
    writeln("|------------------------------|\n|      Bem vindo à UFitCG      |\n|                              |\n|      Digite 1 para Login     |\n|      Digite 2 para Sair      |\n|------------------------------|\n"),
    read_line_to_codes(user_input, X3),
    string_to_atom(X3,X2),
    atom_number(X2,Opcao),
    acaotelainicial(Opcao),
    halt.

acaotelainicial(1) :- abalogin.
acaotelainicial(2) :- halt.
acaotelainicial(_) :- write("opção invalida"), menuInicial.

abalogin :-
    clear_screen,
    writeln("LOGIN"),
    write("Usuário: "),
    read_line_to_codes(user_input, X3),
    string_to_atom(X3,X2),
    atom_string(X2,Login),
    write("Senha: "),
    read_line_to_codes(user_input, Y3),
    string_to_atom(Y3,Y2),
    atom_string(Y2,Senha),
    halt.