:- module(fichaTreino, [cadastraFicha/4, removeFicha/1, mostrarFichaCliente/1, mostrarFichaPersonal/1]).
:- ['../src/usuario'].
:- dynamic ficha_treino/5, fichaId/1.

cadastraFicha(Usr_cli, Usr_per, Exercicios, Observacoes):-
    \+ verificaExistenciaUsuario(Usr_cli) -> (write('"Usuario Inexistente!'), nl) ; (
        pegaId(Id),
        insertFicha(Id, Usr_cli, Usr_per, Exercicios, Observacoes),
       write('Ficha de Treino Adicionada com Sucesso!'), nl
    ).

insertFicha(Id, Usr_cli, Usr_per, Exercicios, Observacoes):-
    assertz(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes)),
    open('data/ficha_db.pl', append, Stream), 
    format(Stream, 'ficha_treino(~w, "~w", "~w", "~w", "~w").~n', [Id, Usr_cli, Usr_per, Exercicios, Observacoes]),
    close(Stream). 

pegaId(Id):- 
    consult('data/ficha_db.pl'),
    fichaId(Id),
    retract(fichaId(Id)), IdNovo is Id + 1,
    assertz(fichaId(IdNovo)),
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
    consult('data/ficha_db.pl'),
    ficha_treino(Id, _, _, _, _).

mostrarFichaCliente(Usr) :-
    consult('data/ficha_db.pl'),
    findall(ficha_treino(_, Usr, Usr_per, Exercicios, Observacoes), ficha_treino(_, Usr, Usr_per, Exercicios, Observacoes), Fichas),
    (Fichas \= [] -> mostrarListaFichas(Fichas)
    ; write('Nenhuma ficha de treino encontrada para o cliente!'), nl).

mostrarFichaPersonal(Usr) :-
    consult('data/ficha_db.pl'),
    findall(ficha_treino(_, Usr_cli, Usr, Exercicios, Observacoes), ficha_treino(_, Usr_cli, Usr, Exercicios, Observacoes), Fichas),
    (Fichas \= [] -> mostrarListaFichas(Fichas)
    ; write('Nenhuma ficha encontrada para o Personal!'), nl).

mostrarListaFichas([]).
mostrarListaFichas([ficha_treino(_, Usr_cli, Usr_per, Exercicios, Observacoes) | Resto]) :-
    write('Cliente: '), write(Usr_cli), nl,
    write('Personal: '), write(Usr_Per), nl,
    write('Exercicios: '), write(Exercicios), nl,
    write('Observações: '), write(Observacoes), nl,
    nl,
    mostrarListaFichas(Resto).

atualizaBaseDeDados :-
    open('data/ficha_db.pl', write, Stream),

    findall(fichaId(IdFicha),
            fichaId(IdFicha), 
            Ids),
    forall(member(fichaId(IdFicha), Ids),
           format(Stream, 'fichaId(~w).~n', 
                  [IdFicha])),
    
    findall(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes),
            ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes), 
            Fichas),
    forall(member(ficha_treino(Id, Usr_cli, Usr_per, Exercicios, Observacoes), Fichas),
           format(Stream, 'ficha_treino(~w, "~w", "~w", "~w", "~w").~n', 
                  [Id, Usr_cli, Usr_per, Exercicios, Observacoes])),
    close(Stream).