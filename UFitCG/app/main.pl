% Carrega o arquivo da tela inicial
:- ['../src/navegabilidade'].

% Função principal que chama a tela inicial
:- initialization(main).

main :-
    menuInicial,
    halt.