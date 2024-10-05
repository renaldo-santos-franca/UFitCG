% Carrega o arquivo da tela inicial
:- ['../src/navegabilidade'].
:- ['../src/Usuario'].
:- ['../src/assinatura'].
:- ['../src/fichaTreino'].

main :-
    cadastraFicha("Usr_cli", "Usr_per", "Exercicios", "Observacoes"),
    halt.