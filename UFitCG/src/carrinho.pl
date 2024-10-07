:- module(carrinho, [verifica_produto_carrinho/2, adiciona_produto_carrinho/3, deletar_carrinho/1, deletar_produto_carrinho/2, listar_produtos_carrinho/1, valor_compra/2, finaliza_compra/2, data_finaliza_compra/1, load_carrinho_db/0, deletar_carrinho/1]).
:- dynamic carrinho/3.
:- use_module(usuario, [verificaExistenciaUsuario/1]).
:- use_module(loja, [verificaId/1, produto/4]).

:- initialization(load_carrinho_db).

load_carrinho_db :-
    retractall(carrinho(_, _)),
    ( exists_file('data/carrinho_db.pl') ->
        consult('data/carrinho_db.pl')
    ; true ).

verifica_produto_carrinho(Usr, Count) :-
    
    findall(_, carrinho(Usr, _), Carrinho),
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
    retractall(carrinho(UsrCli, _)),
    save_carrinho_db,
    writeln('Todos os Produtos Foram Excluidos do Seu Carrinho').

deletar_produto_carrinho(UsrCli, IdProd) :-
    ( retract(carrinho(_, UsrCli, IdProd)) ->
        save_carrinho_db,
        writeln('Produto Excluido do Seu Carrinho!')
    ; writeln('Produto Não Encontrado no Seu Carrinho!')
    ).

listar_produtos_carrinho(UsrCli) :-
    forall(carrinho(UsrCli, IdProd), print_produto(IdProd)).

print_produto(IdProd) :-
    pega_detalhes_produto(IdProd, Nome, Valor, Descricao, Categorias),
    format('Id: ~w~n', [IdProd]),
    format('Nome do Produto: ~w~n', [Nome]),
    format('Preço: ~w~n', [Valor]),
    format('Descricao: ~w~n', [Descricao]),
    format('Categoria: ~w~n', [Categorias]),
    nl.

valor_compra(UsrCli, Total) :-
    findall(Valor, (carrinho(UsrCli, IdProd), pega_valor_produto(IdProd, Valor)), Valores),
    sum_list(Valores, Total).

finaliza_compra(UsrCli, Resultado) :-
    findall(Nome, (carrinho(UsrCli, IdProd), pega_nome_Produto(IdProd, Nome)), NomesProdutos),
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




pega_detalhes_produto(IdProd, Nome, Valor, Descricao, Categorias) :-
    ( produto(IdProd, Nome, Valor, Descricao, Categorias) ->
        true
    ; Nome = 'Produto Não Encontrado',
      Valor = 0,
      Descricao = 'N/A',
      Categorias = 'N/A'
    ).


pega_valor_produto(IdProd, Valor) :-
    ( produto(IdProd, _, Valor, _, _) ->
        true
    ; Valor = 0
    ).

pega_nome_Produto(IdProd, Nome) :-
    ( produto(IdProd, Nome, _, _, _) ->
        true
    ; Nome = 'Produto Não Encontrado'
    ).
