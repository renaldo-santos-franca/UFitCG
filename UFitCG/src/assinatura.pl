:- module(assinatura, [cadastraAssinatura/7, removeAssinatura/1, mostrarAssinaturaTipo/1, mostrarAssinaturas/0, verificaExistenciaAssinatura/1]).
:- dynamic assinatura/7.
:- dynamic vendaAssinatura/5. 

cadastraAssinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso) :-
    (Mensal < 0 ; Semestral < 0 ; Anual < 0) -> (write("Valores Negativos Invalidos!"), nl);
    (Desconto < 0 -> (write("Desconto Negativo Invalido!"), nl));
    (Aulas < 0 -> (write("Numero de Aulas Invalidas!"), nl));
    (string_length(Sigla, L), L \= 3 -> (write("Sigla Com Tamanho Diferente de 3 Invalida!"), nl));
    (string_length(Acesso, Length), Length > 23 -> (write("Acesso Com Mais de 23 Caracteres Invalido!"), nl));
    insertAssinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
    write("Assinatura Inserida!"), nl.

insertAssinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso):-
    assertz(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso)),
    open('data/assinatura_db.pl', append, Stream), 
    format(Stream, 'assinatura("~w", ~w, ~w, ~w, ~w, ~w, "~w").~n', [Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso]),
    close(Stream).

removeAssinatura(Sigla) :-
    (verificaExistenciaAssinatura(Sigla) ->
        retract(assinatura(Sigla, _, _, _, _, _, _)),
        write('Assinatura removida com sucesso!'), nl,
        atualizaBaseDeDados
    ;
        write('Assinatura não encontrada!'), nl
    ).

verificaExistenciaAssinatura(Sigla) :-
    consult('data/assinatura_db.pl'),
    assinatura(Sigla, _, _, _, _, _, _).

mostrarAssinaturaTipo(Sigla):-
    (verificaExistenciaAssinatura(Sigla) -> (
        assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
        write('Tipo Assinatra: '), write(Sigla), nl,
        write('Mensal: '), write(Mensal), nl,
        write('Semestral: '), write(Semestral), nl,
        write('Anual: '), write(Anual), nl,
        write('Desconto: '), write(Desconto), nl,
        write('Aulas Gratis: '), write(Aulas), nl,
        (Acesso = "" -> (write('Acesso: Livre'), nl) ; (write('Acesso: '), write(Acesso), nl))
    ); write('Tipo de Assinatura Inexistente!'), nl).

mostrarAssinaturas:- 
    consult('data/assinatura_db.pl'),
    findall(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), Assinaturas),
    (Assinaturas \= [] -> mostrarListaAssinaturas(Assinaturas)
    ; write('Nenhuma assinatura encontrada!'), nl).

mostrarListaAssinaturas([]).
mostrarListaAssinaturas([assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso) | Resto]) :-
    assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
        write('Tipo Assinatra: '), write(Sigla), nl,
        write('Mensal: '), write(Mensal), nl,
        write('Semestral: '), write(Semestral), nl,
        write('Anual: '), write(Anual), nl,
        write('Desconto: '), write(Desconto), nl,
        write('Aulas Gratis: '), write(Aulas), nl,
        (Acesso = "" -> (write('Acesso: Livre'), nl) ; (write('Acesso: '), write(Acesso), nl)), nl,
    mostrarListaAssinaturas(Resto).


atualizaBaseDeDados :-
    open('data/assinatura_db.pl', write, Stream),
    findall(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
            assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), 
            Assinaturas),
    forall(member(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), Assinaturas),
           format(Stream, 'assinatura("~w", ~w, ~w, ~w, ~w, ~w, "~w").~n', 
                  [Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso])),
    close(Stream).
