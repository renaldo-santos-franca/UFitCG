:- dynamic carrinho/2.

% Load existing facts from the file
:- initialization(load_carrinho_db).

load_carrinho_db :-
    retractall(carrinho(_, _)),
    ( exists_file('../data/carrinho_db.pl') ->
        consult('../data/carrinho_db.pl')
    ; true ).

save_carrinho_db :-
    tell('../data/carrinho_db.pl'),
    listing(carrinho/2),
    told.

adiciona_produto_carrinho(UsrCli, IdProd, Resultado) :-
    verifica_existencia(UsrCli, VerificaUsr),
    verifica_existencia_produto(IdProd, VerificaProduto),
    ( VerificaUsr < 1 ->
        Resultado = 'Usuario Inexistente!'
    ; VerificaProduto < 1 ->
        Resultado = 'Produto Inexistente!'
    ; assertz(carrinho(UsrCli, IdProd)),
      save_carrinho_db,
      Resultado = 'Produto Adicionado ao Carrinho!'
    ).

deletar_carrinho(UsrCli) :-
    retractall(carrinho(UsrCli, _)),
    save_carrinho_db,
    writeln('Todos os Produtos Foram Excluidos do Seu Carrinho').

deletar_produto_carrinho(UsrCli, IdProd, Resultado) :-
    ( retract(carrinho(UsrCli, IdProd)) ->
        save_carrinho_db,
        Resultado = 'Produto Excluido do Seu Carrinho!'
    ; Resultado = 'Produto Não Encontrado no Seu Carrinho!'
    ).

listar_produtos_carrinho(UsrCli) :-
    forall(carrinho(UsrCli, IdProd), print_produto(IdProd)).

print_produto(IdProd) :-
    % Assuming you have a way to get product details by IdProd
    get_product_details(IdProd, Nome, Valor, Descricao, Categorias),
    format('Id: ~w~n', [IdProd]),
    format('Nome do Produto: ~w~n', [Nome]),
    format('Preço: ~w~n', [Valor]),
    format('Descricao: ~w~n', [Descricao]),
    format('Categoria: ~w~n', [Categorias]),
    nl.

valor_compra(UsrCli, Total) :-
    findall(Valor, (carrinho(UsrCli, IdProd), get_product_value(IdProd, Valor)), Valores),
    sum_list(Valores, Total).

finaliza_compra(UsrCli, Resultado) :-
    findall(Nome, (carrinho(UsrCli, IdProd), get_product_name(IdProd, Nome)), NomesProdutos),
    atomic_list_concat(NomesProdutos, ', ', TodosProd),
    ( TodosProd == '' ->
        Resultado = ''
    ; atom_concat(TodosProd, '.', Resultado)
    ).

data_finaliza_compra(DataString) :-
    get_time(Timestamp),
    stamp_date_time(Timestamp, DateTime, local),
    format_time(atom(DataString), '%d-%m-%Y %H:%M', DateTime).

% Dummy implementations for verifica_existencia and verifica_existencia_produto
verifica_existencia(_, 1).
verifica_existencia_produto(_, 1).

% Dummy implementation for get_product_details
get_product_details(IdProd, Nome, Valor, Descricao, Categorias) :-
    Nome = 'Produto Exemplo',
    Valor = 100,
    Descricao = 'Descricao Exemplo',
    Categorias = 'Categoria Exemplo'.

% Dummy implementation for get_product_value
get_product_value(_, 100).

% Dummy implementation for get_product_name
get_product_name(_, 'Produto Exemplo').