:- module(carrinho, [verifica_produto_carrinho/2, adiciona_produto_carrinho/3, deletar_carrinho/1, deletar_produto_carrinho/2, listar_produtos_carrinho/1, valor_compra/2, finaliza_compra/2, data_finaliza_compra/1, load_carrinho_db/0, deletar_carrinho/1]).
:- dynamic carrinho/3.
:- use_module(usuario, [verificaExistenciaUsuario/1]).
:- use_module(loja, [verificaId/1, produto/4, pega_detalhes_produto/5, pega_valor_produto/2, pega_nome_Produto/2]).


:- initialization(load_carrinho_db).

load_carrinho_db :-
    retractall(carrinho(_, _, _)),
    ( exists_file('data/carrinho_db.pl') ->
        consult('data/carrinho_db.pl')
    ; true ).

verifica_produto_carrinho(Usr, Count) :-
    
    findall(_, carrinho(_, Usr, _), Carrinho),
    length(Carrinho, Count).


save_carrinho_db :-
    tell('data/carrinho_db.pl'),
    listing(carrinho/3),
    told.

adiciona_produto_carrinho(UsrCli, IdProd, Resultado) :-
    ( \+ verificaExistenciaUsuario(UsrCli) ->
        Resultado = 'Usuario Inexistente!'
    ; \+ verificaId(IdProd) ->
        Resultado = 'Produto Inexistente!'
    ; gera_id_carrinho(IdCarrinho),
      assertz(carrinho(IdCarrinho, UsrCli, IdProd)),
      save_carrinho_db,
      Resultado = 'Produto Adicionado ao Carrinho!'
    ).

gera_id_carrinho(IdCarrinho) :-
    ( aggregate_all(max(Id), carrinho(Id, _, _), MaxId) ->
        IdCarrinho is MaxId + 1
    ; IdCarrinho = 1
    ).

deletar_carrinho(UsrCli) :-
    retractall(carrinho(_, UsrCli, _)),
    save_carrinho_db,
    writeln('Todos os Produtos Foram Excluidos do Seu Carrinho').

deletar_produto_carrinho(UsrCli, IdProd) :-
    consult('data/carrinho_db.pl'),
    ( retract(carrinho(_, UsrCli, IdProd)) ->
        save_carrinho_db,
        writeln('Produto Excluido do Seu Carrinho!')
    ; writeln('Produto Não Encontrado no Seu Carrinho!')
    ).

listar_produtos_carrinho(Usr) :- 
    consult('data/carrinho_db.pl'),
    findall(carrinho(_, Usr, IdProd), carrinho(_, Usr, IdProd), Produtos),
    (Produtos \= [] -> mostrarListaProdutos(Produtos)
    ; write('Nenhum produto encontrado!'), nl).

mostrarListaProdutos([]).
mostrarListaProdutos([carrinho(_, _, IdProd) | Resto]) :-
    write('Id Produto: '), write(IdProd), nl,
    mostrarListaProdutos(Resto).

valor_compra(UsrCli, Total) :-
    findall(Valor, (carrinho(_, UsrCli, IdProd), pega_valor_produto(IdProd, Valor)), Valores),
    sum_list(Valores, Total).

finaliza_compra(UsrCli, Resultado) :-
    findall(Nome, (carrinho(_, UsrCli, IdProd), pega_nome_Produto(IdProd, Nome)), NomesProdutos),
    atomic_list_concat(NomesProdutos, ', ', TodosProd),
    ( TodosProd == '' ->
        Resultado = 'Carrinho Vazio!'
    ; valor_compra(UsrCli, Total),
      format(string(Resultado), 'Produtos: ~w. Total: ~2f', [TodosProd, Total]),
      deletar_carrinho(UsrCli)
    ).

data_finaliza_compra(DataString) :-
    get_time(Timestamp),
    stamp_date_time(Timestamp, DateTime, local),
    format_time(atom(DataString), '%d-%m-%Y %H:%M', DateTime).

