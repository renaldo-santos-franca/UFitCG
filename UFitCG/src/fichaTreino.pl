:- module(fichaTreino, [cadastraFicha/4, removeFicha/1, mostrarFichaCliente/1, mostrarFichaPersonal/1]).
:- ['data/ficha_db.pl'].
:- ['src/usuario.pl'].
:- dynamic(ficha_treino/5).
:- dynamic(fichaId/1).

cadastraFicha(Usr_cli, Usr_per, Exercicios, Observacoes) :-
    (verificaExistenciaCliente(Usr_cli) -> 
        pegaId(Id), 
        insertFicha(Id, Usr_cli, Usr_per, Exercicios, Observacoes),
        write('Ficha de Treino Adicionada com Sucesso!'), nl
    ; 
        writeln('Usuario Inexistente!')
    ).

insertFicha(Id, Usr_cli, Usr_per, Exercicios, Observacoes) :-
    assertz(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes)),
    open('data/ficha_db.pl', append, Stream), 
    format(Stream, 'ficha_treino(~w, "~w", "~w", "~w", "~w").~n', [Id, Usr_cli, Usr_per, Exercicios, Observacoes]),
    close(Stream).

pegaId(Id) :- 
    fichaId(Id),
    retract(fichaId(Id)), 
    NovoId is Id + 1,
    assertz(fichaId(NovoId)),
    atualizaBaseDeDados.

removeFicha(Id) :-
    (verificaExistenciaFicha(Id) -> 
        retract(ficha_treino(Id, _, _, _, _)),
        write('Ficha de Treino removida com sucesso!'), nl,
        atualizaBaseDeDados 
    ; 
        write('Ficha de Treino não encontrada!'), nl
    ).

verificaExistenciaFicha(Id) :-
    ficha_treino(Id, _, _, _, _).

mostrarFichaCliente(Usr) :-
    findall(ficha_treino(Id, Usr, Usr_per, Exercicios, Observacoes), ficha_treino(Id, Usr, Usr_per, Exercicios, Observacoes), Fichas),
    (Fichas \= [] -> mostrarListaFichas(Fichas)
    ; 
        write('Nenhuma ficha de treino encontrada para o cliente!'), nl).

mostrarFichaPersonal(Usr) :-
    findall(ficha_treino(Id, Usr_cli, Usr, Exercicios, Observacoes), ficha_treino(Id, Usr_cli, Usr, Exercicios, Observacoes), Fichas),
    (Fichas \= [] -> mostrarListaFichas(Fichas)
    ; 
        write('Nenhuma ficha encontrada para o Personal!'), nl).

mostrarListaFichas([]).
mostrarListaFichas([ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes) | Resto]) :-
    write('ID: '), write(Id), nl,
    write('Cliente: '), write(Usr_cli), nl,
    write('Personal: '), write(Usr_per), nl,
    write('Exercícios: '), write(Exercicios), nl,
    write('Observações: '), write(Observacoes), nl,
    nl,
    mostrarListaFichas(Resto).

atualizaBaseDeDados :-
    open('data/ficha_db.pl', write, Stream),
    format(Stream, ':- dynamic(ficha_treino/5).~n', []),
    findall(fichaId(IdFicha), fichaId(IdFicha), Ids),
    forall(member(IdFicha, Ids), format(Stream, 'fichaId(~w).~n', [IdFicha])),
    findall(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes), ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes), Fichas),
    forall(member(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes), Fichas), 
           format(Stream, 'ficha_treino(~w, "~w", "~w", "~w", "~w").~n', [Id, Usr_cli, Usr_per, Exercicios, Observacoes])),
    close(Stream).