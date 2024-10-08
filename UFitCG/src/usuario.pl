:- module(usuario, [login/3, cadastraUsuario/7, removeUsuario/1, mostrarPerfil/1, mostrarUsuariosTipo/1, mostrarUsuarios/0, verificaExistenciaCliente/1, verfivaPersonal/1, verificaExistenciaUsuario/1]).
:- use_module(assinatura, [verificaExistenciaAssinatura/1]).
:- dynamic usuario/7.
:- dynamic assinatura/7.

login(User, Senha, Tipo) :-
    (verifica_dados_login(User, Senha, T) -> 
        (verifica_horario(User) -> Tipo = T; Tipo = "h")
    ; Tipo = "-").

verifica_dados_login(User, Senha, Tipo) :-
    consult('data/usuario_db.pl'),
    usuario(User, Senha, Tipo, _, _, _, _).

verifica_horario(User) :-
    consult('data/usuario_db.pl'),
    usuario(User, _, _, _, _, TipoAssinatura, _),
    (TipoAssinatura = "SIL" ->  
        get_time(CurrentTime),
        stamp_date_time(CurrentTime, DateTime, local),
        date_time_value(hour, DateTime, Hour),
        Hour >= 6, Hour =< 14
        ; true
    ).

verfivaPersonal(Usr) :-
    consult('data/usuario_db.pl'),
    usuario(Usr, _, "PER", _, _, _, _).

verificaExistenciaCliente(Usr) :-
    consult('data/usuario_db.pl'),
    usuario(Usr, _, "CLI", _, _, _, _).

cadastraUsuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario) :-
    (verificaExistenciaUsuario(Usr) -> write('Usuario Existente!'), nl
    ; string_length(Usr, Len), Len > 40 -> write('Nome de Usuario Deve Ter no Maximo 40 Caracteres!'), nl
    ; string_length(Senha, Len), Len =\= 8 -> write('Senha Deve Ter Exatamente 8 Caracteres!'), nl
    ; string_length(Data_nascimento, Len), Len =\= 10 -> write('Data de Nascimento Deve Ter Exatamente 10 Caracteres (dd/mm/aaaa)!'), nl
    ; Salario < 0 -> write('Erro: Salario Negativo!'), nl
    ; (Tipo_usr = ADM; Tipo_usr = PER) -> 
        (insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, "   ", Salario),
        write('Usuario Cadastrado Com Sucesso!'), nl) 
        ; 
      Tipo_usr = CLI -> 
        (verificaExistenciaAssinatura(Tipo_assinatura) -> 
            ((insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, 0),
            write('Usuario Cadastrado Com Sucesso!'), nl))
            ; write('Tipo de Assinatura Inválida!'), nl)
        ; write('Tipo de Usuario Invalido!'), nl
    ).

insertUser(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario):-
    open('data/usuario_db.pl', append, Stream), 
    format(Stream, 'usuario("~w", ~w, "~w", "~w", "~w", "~w", ~w).~n', [Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario]),
    close(Stream). 

verificaExistenciaUsuario(Usr):-
    consult('data/usuario_db.pl'),
    usuario(Usr, _, _, _, _, _, _).

removeUsuario(Usr) :-
    (verificaExistenciaUsuario(Usr) ->
        retract(usuario(Usr, _, _, _, _, _, _)),
        write('Usuário removido com sucesso!'), nl,
        atualizaBaseDeDados 
    ; 
        write('Usuário não encontrado!'), nl
    ).

mostrarPerfil(Usr):- 
    (verificaExistenciaUsuario(Usr) -> (
        usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario),
        write('Usuario: '), write(Usr), nl,
        ( TipoUsr = "CLI" -> write('Tipo de Usuario: Cliente')
        ; TipoUsr = "ADM" -> write('Tipo de Usuario: Administrador')
        ; write('Tipo de Usuario: Personal')
        ), nl,
        write('Nome: '), write(Nome), nl,
        write('Data de Nascimento: '), write(DataNascimento), nl,
        ( TipoUsr = "CLI" -> write('Tipo de Assinatura: '), write(TipoAssinatura)
        ; write('Salario: '), write(Salario)
        ), nl, !
    ) ; write('Usuario Inexistente!'), nl).

mostrarUsuarios :- 
    consult('data/usuario_db.pl'),
    findall(usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario), usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario), Usuarios),
    (Usuarios \= [] -> mostrarListaUsuarios(Usuarios)
    ; write('Nenhum usuario encontrado!'), nl).

mostrarListaUsuarios([]).
mostrarListaUsuarios([usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario) | Resto]) :-
    write('Usuario: '), write(Usr), nl,
    write('Tipo de Usuario: '), write(TipoUsr), nl,
    write('Nome: '), write(Nome), nl,
    write('Data de Nascimento: '), write(DataNascimento), nl,
    (TipoUsr = "CLI" -> (write('Tipo de Assinatura: '), write(TipoAssinatura), nl) ; write('Salario: '), write(Salario), nl),
    nl,
    mostrarListaUsuarios(Resto).

mostrarUsuariosTipo(TipoUsr) :-
    consult('data/usuario_db.pl'),
    findall(usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario), usuario(Usr, _, TipoUsr, Nome, DataNascimento, TipoAssinatura, Salario), Usuarios),
    (Usuarios \= [] -> mostrarListaUsuarios(Usuarios)
    ; write('Nenhum usuario encontrado para o tipo especificado!'), nl).

atualizaBaseDeDados :-
    open('data/usuario_db.pl', write, Stream),
    
    findall(usuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario),
            usuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario), 
            Usuarios),
    forall(member(usuario(Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario), Usuarios),
           format(Stream, 'usuario("~w", "~w", "~w", "~w", "~w", "~w", ~w).~n', 
                  [Usr, Senha, Tipo_usr, Nome, Data_nascimento, Tipo_assinatura, Salario])),
    close(Stream).
