:- module(venda, [cadastrar_venda/1, filtrar_vendas/1, remove_venda_loja/1, listar_vendas/0]).
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


atualizaBaseDeDados :-
    open('data/vendasLoja_db.pl', write, Stream),
    
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
    consult('data/vendasLoja_db.pl'),
    findall(venda(Id, Produto, Usr, DataVenda, Valor), venda(Id, Produto, Usr, DataVenda, Valor), Vendas),
    (Vendas \= [] -> print_vendas(Vendas)
    ; write('Nenhuma venda encontrada!'), nl).

quantidade_vendas_loja(IdVen, Count) :-
    findall(_, venda(IdVen, _, _, _, _), Vendas),
    length(Vendas, Count).

verifica_venda_loja(Id):-
    consult('data/vendasLoja_db.pl'),
    venda(Id, _, _, _, _).

remove_venda_loja(Id) :-
    (verifica_venda_loja(Id) ->
        retract(venda(Id, _, _, _, _)),
        write('Venda apagada com sucesso!'), nl,
        atualizaBaseDeDados 
    ; 
        write('Venda não encontrada!'), nl
    ).


listar_vendas :- 
    consult('data/vendasLoja_db.pl'),
    findall(venda(Id, Produto, Usr, DataVenda, Valor), venda(Id, Produto, Usr, DataVenda, Valor), Vendas),
    (Vendas \= [] -> print_vendas(Vendas)
    ; write('Nenhuma venda encontrada!'), nl).

print_vendas([]).
print_vendas([venda(Id, Produto, Usr, DataVenda, Valor) | Resto]) :-
    format('Id: ~w~n', [Id]),
    format('Produto: ~w~n', [Produto]),
    format('Usuario: ~w~n', [Usr]),
    format('Data: ~w~n', [DataVenda]),
    format('Valor: ~2f~n~n', [Valor]),
    print_vendas(Resto).