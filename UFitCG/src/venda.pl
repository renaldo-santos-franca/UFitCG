:- module(venda, [cadastrar_venda/1, filtrar_vendas/1, remove_venda_loja/2, listar_vendas/0]).
:- use_module(library(persistency)).
:- use_module(library(date)).
:- use_module(carrinho, [deletar_carrinho/1, verifica_produto_carrinho/2, finaliza_compra/2, valor_compra/2, load_carrinho_db/0, carrinho/2]).

:- dynamic venda_id/1.
:- dynamic venda/5.

:- persistent
    venda(id:integer, produtos:string, usr:string, data_horario:string, valor_total:float).

:- initialization(init_venda_db).

init_venda_db :-
    load_carrinho_db,
    db_attach('data/vendasLoja_db.pl', []).

pega_id(Id) :-
    (   venda_id(MaxId)
    ->  Id is MaxId + 1
    ;   Id = 1
    ),
    with_mutex(vendas_db, (
        retractall(venda_id(_)),
        assertz(venda_id(Id))
    )),
    atualiza_base_de_dados.

atualiza_base_de_dados :-
    open('data/vendasLoja_db.pl', write, Stream),
    format(Stream, ':- dynamic(venda_id/1).~n', []),

    findall(venda_id(IdVenda), venda_id(IdVenda), Ids),
    forall(member(venda_id(IdVenda), Ids),
           format(Stream, 'venda_id(~w).~n', [IdVenda])),

    findall(venda(Id, Produtos, Usr, DataHorario, ValorTotal),
            venda(Id, Produtos, Usr, DataHorario, ValorTotal), Vendas),
    forall(member(venda(Id, Produtos, Usr, DataHorario, ValorTotal), Vendas),
           format(Stream, 'venda(~w, "~w", "~w", "~w", ~2f).~n', [Id, Produtos, Usr, DataHorario, ValorTotal])),
    close(Stream).

cadastrar_venda(Usr) :-
    verifica_produto_carrinho(Usr, VeriCar),
    (   VeriCar =:= 0
    ->  writeln('Carrinho Vazio')
    ;   finaliza_compra(Usr, Produtos),
        get_time(TimeStamp),
        format_time(string(DataAtual), '%Y-%m-%d %H:%M:%S', TimeStamp),
        valor_compra(Usr, ValorTotalInt),
        ValorTotal is float(ValorTotalInt),
        pega_id(Id),
        with_mutex(vendas_db, assert_venda(Id, Produtos, Usr, DataAtual, ValorTotal)),
        deletar_carrinho(Usr),
        writeln('Compra Efetuada')
    ).

assert_venda(Id, Produtos, Usr, DataHorario, ValorTotal) :-
    assertz(venda(Id, Produtos, Usr, DataHorario, ValorTotal)).

filtrar_vendas(Usr) :-
    findall(venda(Id, Produtos, Usr, DataHorario, ValorTotal), venda(Id, Produtos, Usr, DataHorario, ValorTotal), VendasUsr),
    maplist(format_venda, VendasUsr).

quantidade_vendas_loja(IdVen, Count) :-
    findall(_, venda(IdVen, _, _, _, _), Vendas),
    length(Vendas, Count).

verifica_venda_loja(IdVen, Exists) :-
    quantidade_vendas_loja(IdVen, Count),
    (   Count =:= 1
    ->  Exists = true
    ;   Exists = false
    ).

remove_venda_loja(IdVen, Res) :-
    verifica_venda_loja(IdVen, Exists),
    (   Exists
    ->  with_mutex(vendas_db, retractall_venda(IdVen, _, _, _, _)),
        Res = 'Venda Removida Com Sucesso'
    ;   Res = 'Venda Não Cadastrada'
    ).

listar_vendas :-
    findall(venda(Id, Produtos, Usr, DataHorario, ValorTotal), venda(Id, Produtos, Usr, DataHorario, ValorTotal), Vendas),
    maplist(format_venda, Vendas).

format_venda(venda(Id, Produto, Usr, DataVenda, Valor)) :-
    format('Id: ~w~n', [Id]),
    format('Produto: ~w~n', [Produto]),
    format('Usuario: ~w~n', [Usr]),
    format('Data: ~w~n', [DataVenda]),
    format('Valor: ~2f~n~n', [Valor]).