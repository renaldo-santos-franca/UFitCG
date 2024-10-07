:- module(aulaCliente, [adicionarAulaExtra/2, cancelarAula/2, listarAulasCliente/1, cancelarAulas/1]).
:- ['data/aulas_cliente_db.pl'].
:- ['aulaExtra.pl'].
:- dynamic aulaCliente/2.

adicionarAulaExtra(Usr, Id) :-
    (verificaUsrAula(Usr, Id) -> writeln("Usuario Ja Cadastrado a Aula")
    ; verificaId(Id) -> insertClienteAula(Usr, Id), writeln("Aula Adicionada")
    ; writeln("Aula Nao Cadastrada")
    ).

verificaUsrAula(Usr, Id) :-
    reconsult('data/aulas_cliente_db.pl'),
    aulaCli(Usr, Id).

insertClienteAula(Usr, Id) :-
    assertz(aulaCliente(Usr, Id)),
    open('data/aulas_cliente_db.pl', append, Stream),
    format(Stream, 'aulaCli("~w", ~w).~n', [Usr, Id]),
    close(Stream).



cancelarAulas(Id) :-
    consult('data/aulas_cliente_db.pl'),
    retract(aulaCli(_, Id)),
    atualizar_arquivo_aula_db.



cancelarAula(Usr, Id) :-
    (verificaUsrAula(Usr, Id) -> deleteAula(Usr, Id), writeln("Aula Cancelada")
    ; writeln("Aula Inexistente")
    ).

deleteAula(Usr, Id) :- 
    consult('data/aulas_cliente_db.pl'),
    retract(aulaCli(Usr, Id)),
    atualizar_arquivo_aula_db.

atualizar_arquivo_aula_db :-
    open('data/aulas_cliente_db.pl', write, Stream),
    format(Stream, ':- dynamic(aulaCli/2).~n', []),
    forall(aulaCli(Usr, Id), format(Stream, 'aulaCli("~w", ~w).~n', [Usr, Id])),
    close(Stream).

listarAulasCliente(Usr) :-
    reconsult('data/aulas_cliente_db.pl'),
    findall(aulaCli(Usr, Id), aulaCli(Usr, Id), Aulas),
    (Aulas \= [] -> mostrarListaAulasCli(Aulas)
    ; writeln('Nenhuma Aula Cadastrada')
    ).

mostrarListaAulasCli([]).
mostrarListaAulasCli([aulaCli(Usr, Id) | T]) :-
    pegaInfoAula(Id, Materia, Personal, Data),
    write("Materia: "), writeln(Materia),
    write("Personal: "), writeln(Personal),
    write("Data_Hora: "), writeln(Data), nl,
    mostrarListaAulasCli(T).

