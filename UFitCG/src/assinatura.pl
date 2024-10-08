:- module(assinatura, [cadastraAssinatura/7, removeAssinatura/1, mostrarAssinaturaTipo/1, mostrarAssinaturas/0, verificaExistenciaAssinatura/1, cadastraVendaAssinatura/5, removeVendasAssinatura/1, listarVendasAssinaturas/0]).
:- use_module(usuario, [verificaExistenciaUsuario/1]).
:- dynamic assinatura/7.
:- dynamic venda_assinatura/6. 
:- dynamic vendaId/1.
:- ['data/vendasAssinatura_db.pl'].

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
        atualizaBaseDeDadosAssinatura
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

pegaId(Id):-
    vendaId(Id),
    retract(vendaId(Id)), IdNovo is Id + 1,
    assertz(vendaId(IdNovo)),
    atualizaBaseDeDadosVenda.

cadastraVendaAssinatura(Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio):-
    (\+ verificaExistenciaUsuario(Usr)) -> (write('Usuario Não Existe!'), nl) ; (
        (\+ verificaExistenciaAssinatura(Tipo_assinatura)) -> (write('Tipo de Assinatura Não Cadastrada!'), nl) ; (
            pegaId(Id),
            insertVendaAssinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio),
            write('Venda de Assinatura Cadastrada!'), nl
        )
    ).

insertVendaAssinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio):-
    open('data/vendasAssinatura_db.pl', append, Stream), 
    format(Stream, 'venda_assinatura(~w, "~w", "~w", "~w", ~w, "~w").~n', [Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio]),
    close(Stream).

verificaExistenciaVenda(Id):-
    consult('data/vendasAssinatura_db.pl'),
    venda_assinatura(Id, _, _, _, _, _).

removeVendasAssinatura(Id) :-
    (verificaExistenciaVenda(Id) ->
        retract(venda_assinatura(Id, _, _, _, _, _)),
        write('Venda removida com sucesso!'), nl,
        atualizaBaseDeDadosVenda
    ; 
        write('Venda não encontrada!'), nl
    ).

listarVendasAssinaturas :- 
    consult('data/vendasAssinatura_db.pl'),
    findall(venda_assinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio), venda_assinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio), Vendas),
    (Vendas \= [] -> mostrarListaVendas(Vendas)
    ; write('Nenhuma venda encontrada!'), nl).

mostrarListaVendas([]).
mostrarListaVendas([venda_assinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio) | Resto]) :-
    write('Id: '), write(Id), nl,
    write('Usuario: '), write(Usr), nl,
    write('Tipo de Assinatura: '), write(Tipo_assinatura), nl,
    write('Tipo de Parcela: '), write(Tipo_Parcela), nl,
    write('Parcelas Pagas: '), write(Parcelas_Pagas), nl,
    write('Data de Inicio: '), write(Data_inicio), nl,
    mostrarListaVendas(Resto).

atualizaBaseDeDadosAssinatura :-
    open('data/assinatura_db.pl', write, Stream),
    findall(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
            assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), 
            Assinaturas),
    forall(member(assinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso), Assinaturas),
           format(Stream, 'assinatura("~w", ~w, ~w, ~w, ~w, ~w, "~w").~n', 
                  [Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso])),
    close(Stream).

atualizaBaseDeDadosVenda :-
    open('data/vendasAssinatura_db.pl', write, Stream),

    findall(vendaId(IdAva),
            vendaId(IdAva), 
            Ids),
    forall(member(vendaId(IdAva), Ids),
           format(Stream, 'vendaId(~w).~n', 
                  [IdAva])),
    
    findall(venda_assinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio),
            venda_assinatura(Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio), 
            Vendas),
    forall(member(venda_assinatura(Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio), Vendas),
           format(Stream, 'venda_assinatura(~w, "~w", "~w", "~w", ~w, "~w").~n', 
                  [Id, Usr, Tipo_assinatura, Tipo_Parcela, Parcelas_Pagas, Data_inicio])),
   
    close(Stream).
