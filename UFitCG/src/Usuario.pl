:- module(usuario, [cadastraUsuario/7]).
:- dynamic usuario/7.

cadastraUsuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario) :-
    (verificaExistenciaUsuario(Usr) -> write('Usuario Existente!'), nl
    ; string_length(Usr, Len), Len > 40 -> write('Nome de Usuario Deve Ter no Maximo 40 Caracteres!'), nl
    ; string_length(Senha, Len), Len =\= 8 -> write('Senha Deve Ter Exatamente 8 Caracteres!'), nl
    ; string_length(Data_nascimento, Len), Len =\= 10 -> write('Data de Nascimento Deve Ter Exatamente 10 Caracteres (dd/mm/aaaa)!'), nl
    ; Salario < 0 -> write('Erro: Salario Negativo!'), nl
    ; (Tipo_usr = "ADM"; Tipo_usr = "PER") -> 
        (insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, "   ", Salario),
        write('Usuario Cadastrado Com Sucesso!'), nl) 
        ; 
      Tipo_usr = "CLI" -> 
        ((insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, 0),
        write('Usuario Cadastrado Com Sucesso!'), nl))
        ; write('Tipo de Usuario Invalido!'), nl
    ).

insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario):-
    assertz(usuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario)),
    open('data/dataBase.pl', append, Stream), 
    format(Stream, 'usuario("~w", ~w, "~w", "~w", "~w", "~w", ~w).~n', [Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario]),
    close(Stream). 


verificaExistenciaUsuario(Usr):-
    consult('data/dataBase.pl'),
    usuario(Usr, _, _, _, _, _, _).