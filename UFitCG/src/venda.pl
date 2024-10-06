:- use_module(library(persistency)).
:- use_module(library(date)).

:- persistent
    venda(id:integer, produtos:string, usr:string, data_horario:string, valor_total:float).

:- initialization(db_attach('../data/vendaloja_db.pl', [])).

pega_id(Id) :-
    consult('../data/vendaloja_db.pl'),
    venda_id(Id),
    retract(venda_id(Id)),
    IdNovo is Id + 1,
    assertz(venda_id(IdNovo)),
    atualiza_base_de_dados.

atualiza_base_de_dados :-
    open('../data/vendaloja_db.pl', write, Stream),

    findall(venda_id(IdVenda),
            venda_id(IdVenda), 
            Ids),
    forall(member(venda_id(IdVenda), Ids),
           format(Stream, 'venda_id(~w).~n', 
                  [IdVenda])),
    
    findall(venda(Id, Produtos, Usr, DataHorario, ValorTotal),
            venda(Id, Produtos, Usr, DataHorario, ValorTotal), 
            Vendas),
    forall(member(venda(Id, Produtos, Usr, DataHorario, ValorTotal), Vendas),
           format(Stream, 'venda(~w, "~w", "~w", "~w", ~2f).~n', 
                  [Id, Produtos, Usr, DataHorario, ValorTotal])),
    close(Stream).

cadastrar_venda(Usr, Res) :-
    verifica_produto_carrinho(Usr, VeriCar),
    (   VeriCar =:= 0
    ->  Res = 'Carrinho Vazio'
    ;   finaliza_compra(Usr, Produtos),
        get_time(TimeStamp),
        format_time(atom(DataAtual), '%Y-%m-%d %H:%M:%S', TimeStamp),
        valor_compra(Usr, ValorTotal),
        pega_id(Id),
        with_mutex(vendas_db, assert_venda(Id, Produtos, Usr, DataAtual, ValorTotal)),
        open('../data/vendaloja_db.pl', append, Stream),
        format(Stream, 'venda(~w, "~w", "~w", "~w", ~2f).~n', [Id, Produtos, Usr, DataAtual, ValorTotal]),
        close(Stream),
        deletar_carrinho(Usr),
        Res = 'Compra Efetuada'
    ).

verifica_produto_carrinho(Usr, Count) :-
    findall(_, carrinho(Usr, _), Carrinho),
    length(Carrinho, Count).

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