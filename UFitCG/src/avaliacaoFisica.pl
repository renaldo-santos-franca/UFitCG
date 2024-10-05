:- module(avaliacaoFisica, [cadastraAvaliacao/5, mostrarAvaliacaoCliente/1, mostrarAvaliacaoPersonal/1, removeAvaliacao/1]).
:- dynamic avaliacao_fisica/6, avaliacaoId/1.
:- ['../src/Usuario'].

cadastraAvaliacao(Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava):-
    (\+ verificaExistenciaUsuario(Usr_cli)) -> (write('Usuario Inexistente!'), nl) ; (
        string_length(Data_ava, L), L =\= 10 -> (write('Data Invalida!'), nl) ; (
            pegaId(Id),
            insertAssinatura(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava),
            write('Avaliacao Adicionada!'), nl
        )
    ).

pegaId(Id):- 
    consult('data/avaliacao_db.pl'),
    avaliacaoId(Id),
    retract(avaliacaoId(Id)), IdNovo is Id + 1,
    assertz(avaliacaoId(IdNovo)),
    atualizaBaseDeDados.

insertAssinatura(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava):-
    assertz(avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava)),
    open('data/avaliacao_db.pl', append, Stream), 
    format(Stream, 'avaliacao_fisica(~w, "~w", "~w", "~w", "~w", "~w").~n', [Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava]),
    close(Stream).

removeAvaliacao(Id) :-
    (verificaExistenciaAvaliacao(Id) -> 
        retract(avaliacao_fisica(Id, _, _, _, _, _)),
        write('Avaliação removida com sucesso!'), nl,
        atualizaBaseDeDados 
    ; 
        write('Avaliação não encontrada!'), nl
    ).

verificaExistenciaAvaliacao(Id) :-
    consult('data/avaliacao_db.pl'),
    avaliacao_fisica(Id, _, _, _, _, _).

mostrarAvaliacaoCliente(Usr) :-
    consult('data/avaliacao_db.pl'),
    findall(avaliacao_fisica(_, Usr, Usr_Per, Avaliacao, Observacoes, Data_ava), avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava), Avaliacoes),
    (Avaliacoes \= [] -> mostrarListaAvaliacoes(Avaliacoes)
    ; write('Nenhuma avaliação encontrada para o cliente!'), nl).

mostrarAvaliacaoPersonal(Usr) :-
    consult('data/avaliacao_db.pl'),
    findall(avaliacao_fisica(_, Usr_cli, Usr, Avaliacao, Observacoes, Data_ava), avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava), Avaliacoes),
    (Avaliacoes \= [] -> mostrarListaAvaliacoes(Avaliacoes)
    ; write('Nenhuma avaliação encontrada para o Personal!'), nl).

mostrarListaAvaliacoes([]).
mostrarListaAvaliacoes([avaliacao_fisica(_, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava) | Resto]) :-
    write('Cliente: '), write(Usr_cli), nl,
    write('Personal: '), write(Usr_Per), nl,
    write('Avaliação: '), write(Avaliacao), nl,
    write('Observações: '), write(Observacoes), nl,
    write('Data da Avaliação: '), write(Data_ava), nl,
    nl,
    mostrarListaAvaliacoes(Resto).

atualizaBaseDeDados :-
    open('data/avaliacao_db.pl', write, Stream),

    findall(avaliacaoId(IdAva),
            avaliacaoId(IdAva), 
            Ids),
    forall(member(avaliacaoId(IdAva), Ids),
           format(Stream, 'avaliacaoId(~w).~n', 
                  [IdAva])),
    
    findall(avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava),
            avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava), 
            Avaliacoes),
    forall(member(avaliacao_fisica(Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava), Avaliacoes),
           format(Stream, 'usuario(~w, "~w", "~w", "~w", "~w", "~w").~n', 
                  [Id, Usr_cli, Usr_Per, Avaliacao, Observacoes, Data_ava])),
   
    close(Stream).