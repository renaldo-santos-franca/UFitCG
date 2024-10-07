:- module(aulaExtra, [cadastraAula/4, listarAulas/0, listarAulasPersonal/1, removeAula/1, verificaId/1, pegaInfoAula/4]).
:- use_module(usuario, [verfivaPersonal/1]).
:- use_module(aulaCliente, [cancelarAulas/1]).
:- ['data/aula_db.pl'].
:- dynamic aula/5.
:- dynamic usuario/7.

cadastraAula(Materia, Usr_per, Data_horario, Limite) :-
    reconsult('data/aula_db.pl'),
    (Limite =< 0 -> writeln("Limite Invalido")
    ; string_length(Data_horario, Len), Len \= 22 -> writeln("Horario Invalido")
    ; \+ verfivaPersonal(Usr_per) -> writeln("Usuario Invalido")
    ; insertAula(Materia, Usr_per, Data_horario, Limite),
      writeln("Aula Cadastrada com Sucesso")
    ).

pegaIdAula(Id) :-
    id_aula(Id).

insertAula(Materia, Usr_per, Data_horario, Limite) :-
    pegaIdAula(Id),
    assertz(aula(Id, Materia, Usr_per, Data_horario, Limite)),
    open('data/aula_db.pl', append, Stream),
    format(Stream, 'aula(~w, "~w", "~w", "~w", ~w).~n', [Id, Materia, Usr_per, Data_horario, Limite]),
    close(Stream),
    incrementa_id_aula.

verificaId(Id) :-
    aula(Id, _, _, _, _).

incrementa_id_aula :-
    id_aula(IdAtual),
    retract(id_aula(IdAtual)),
    NovoId is IdAtual + 1,
    atualiza_arquivo_aula_db(NovoId).

atualiza_arquivo_aula_db(NovoId) :-
    open('data/aula_db.pl', write, Stream),
    format(Stream, ':- dynamic(id_aula/1).~n', []),
    format(Stream, 'id_aula(~w).~n', [NovoId]),
    close(Stream),
    open('data/aula_db.pl', append, StreamAula),
    forall(aula(Id, Materia, Usr_per, Data_horario, Limite), format(StreamAula, 'aula(~w, "~w", "~w", "~w", ~w).~n', [Id, Materia, Usr_per, Data_horario, Limite])),
    close(StreamAula).

listarAulas :-
    reconsult('data/aula_db.pl'),
    findall(aula(Id, Materia, Usr_per, Data_horario, Limite), aula(Id, Materia, Usr_per, Data_horario, Limite), Aulas),
    (Aulas \= [] -> mostrarListaAulas(Aulas)
    ; writeln('Nenhuma Aula Cadastrada')
    ).

mostrarListaAulas([]).
mostrarListaAulas([aula(Id, Materia, Usr, Data_horario, Limite) | T]) :-
    write('ID: '), writeln(Id),
    write('Materia: '), writeln(Materia),
    write('Usuario: '), writeln(Usr),
    write('Data-Horario: '), writeln(Data_horario),
    write('Limite: '), writeln(Limite), nl,
    mostrarListaAulas(T).

listarAulasPersonal(Usr) :-
    reconsult('data/aula_db.pl'),
    (   aula(_, _, Usr, _, _) -> 
        forall(aula(Id, Materia, Usr, Data_horario, Limite),
               format(' ID: ~w~n Matéria: ~w~n Usuário: ~w~n Data/Horário: ~w~n Limite: ~w~n~n', [Id, Materia, Usr, Data_horario, Limite]))
    ;   writeln('Nenhuma Aula Cadastrada')
    ).

removeAula(Id_str) :-
    reconsult('data/aula_db.pl'),
    atom_number(Id_str, Id),
    (verificaId(Id) -> 
        retract(aula(Id, Materia, Usr_per, Data_horario, Limite)),
        (cancelarAulas(Id) -> true; true),
        writeln('Aula removida com sucesso!'),
        atualizar_arquivo_aula_db
    ; writeln("ID Invalido")
    ).

atualizar_arquivo_aula_db :-
    open('data/aula_db.pl', write, Stream),
    format(Stream, ':- dynamic(id_aula/1).~n', []),
    forall(id_aula(Id), format(Stream, 'id_aula(~w).~n', [Id])),
    forall(aula(IdAula, Materia, Usr_per, Data_horario, Limite), format(Stream, 'aula(~w, "~w", "~w", "~w", ~w).~n', [IdAula, Materia, Usr_per, Data_horario, Limite])),
    close(Stream).

pegaInfoAula(Id, Materia, Personal, Data) :-
    aula(Id, Materia, Personal, Data, _).