% Carrega o arquivo da tela inicial
:- ['../src/navegabilidade'].
:- ['../src/usuario'].

main :-
    cadastraUsuario("Eurico", 12345678, "ADM", "Renaldo França", "20/10/2003", "  ", 1500).