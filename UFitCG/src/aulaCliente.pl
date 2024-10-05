:- module(aulaCliente, [adicionarAulaExtra/2, cancelarAula/2, listarAulasCliente/1]).
:- dynamic aulaCliente/2.
:- dynamic aula/5.

adicionarAulaExtra(Usr, Id_str) :-
    atom_number(Id_str, Id),
    (verificaUsrAula(Usr, Id) -> writeln("Usuario Ja Cadastrado a Aula")
    ; verificaIdAula(Id) -> insertClienteAula(Usr, Id), writeln("Aula Adicionada")
    ; writeln("Aula Nao Cadastrada")
    ).

verificaIdAula(Id) :-
    consult('data/aula_db.pl'),
    aula(Id, _, _, _, _).

verificaUsrAula(Usr, Id) :-
    consult('data/aulas_cliente_db.pl'),
    aulaCli(Usr, Id).

insertClienteAula(Usr, Id) :-
    assertz(aulaCliente(Usr, Id)),
    open('data/aulas_cliente_db.pl', append, Stream),
    format(Stream, 'aulaCli("~w", ~w).~n', [Usr, Id]),
    close(Stream).

cancelarAula(Usr, Id_str) :-
    atom_number(Id_str, Id),
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
    consult('data/aulas_cliente_db.pl'),
    findall(aulaCli(Usr, Id), aulaCli(Usr, Id), Aulas),
    (Aulas \= [] -> mostrarListaAulasCli(Aulas)
    ; writeln('Nenhuma Aula Cadastrada')
    ).

pegaInfoAula(Id, Materia, Personal, Data) :-
    consult('data/aula_db.pl'),
    aula(Id, Materia, Personal, Data, _).

mostrarListaAulasCli([]).
mostrarListaAulasCli([aulaCli(Usr, Id) | T]) :-
    pegaInfoAula(Id, Materia, Personal, Data),
    write("Materia: "), writeln(Materia),
    write("Personal: "), writeln(Personal),
    write("Data_Hora: "), writeln(Data), nl,
    mostrarListaAulasCli(T).

