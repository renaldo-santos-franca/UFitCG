:- module(loja, [cadastroProduto/4, remove_produto/1, listar_produtos_por_categoria/1, listar_produtos/0]).
['../data/loja_db.pl'].
:- dynamic produto/4.

cadastroProduto(Nome, Valor, Descricao, Categorias) :- 
    (Valor < 0 -> writeln("Valor Negativo Invalido!")
    ; string_length(Nome, Len), Len < 1 -> writeln("Nome Invalido")
    ; string_length(Categorias, Len), Len < 1 -> writeln("Produto Precisa de Pelo Menos uma Categoria")
    ; insertProduto(Nome, Valor, Descricao, Categorias), writeln("Produto Inserido")
    ).

insertProduto(Nome, Valor, Descricao, Categorias) :- 
    pegaId(Id),
    assertz(produto(Id, Nome, Valor, Descricao, Categorias)),
    open('data/loja_db.pl', append, Stream),
    format(Stream, 'produto(~w, "~w", ~w, "~w", "~w").~n', [Id, Nome, Valor, Descricao, Categorias]),
    close(Stream).

pegaId(Id) :-
    consult("data/loja_db.pl"),
    id_produto(Id).

id_produto(NovoId) :-
    findall(Id, produto(Id, _, _, _, _), ListaIds), 
    ( ListaIds = [] ->  
        NovoId = 1
    ; max_list(ListaIds, MaxId), 
      NovoId is MaxId + 1         
    ).

verificaId(Id) :-
    produto(Id, _, _, _, _).

remove_produto(Id) :-
    consult('data/loja_db.pl'),  
    ( verificaId(Id) ->  
        retract(produto(Id, _, _, _, _)),   
        atualizar_arquivo, 
        writeln("Produto removido!")
    ;   writeln("Produto Inexistente!")
    ).

atualizar_arquivo :-
    open('data/loja_db.pl', write, Stream), 
    format(Stream, ':- dynamic(produto/5).~n', []),
    forall(produto(Id, Nome, Valor, Descricao, Categorias),
        format(Stream, 'produto(~w, "~w", ~w, "~w", "~w").~n', [Id, Nome, Valor, Descricao, Categorias])
    ),
    close(Stream).

listar_produtos :- 
    consult('data/loja_db.pl'),
    findall(produto(Id, Nome, Valor, Descricao, Categorias), produto(Id, Nome, Valor, Descricao, Categorias), Produtos),
    (Produtos \= [] -> print_produto(Produtos)
    ; write('Nenhum Produto encontrado!'), nl).

print_produto([]).
print_produto([produto(Id, Nome, Valor, Descricao, Categorias) | Resto]) :-
    format('Id: ~w~n', [Id]),
    format('Nome: ~w~n', [Nome]),
    format('Valor: ~2f~n', [Valor]),
    format('Descrição: ~w~n', [Descricao]),
    format('Categorias: ~w~n', [Categorias]),
    writeln('--------------------------'),
    print_produto(Resto).

listar_produtos_por_categoria(Cat) :-
    consult('data/loja_db.pl'),
    findall(produto(Id, Nome, Valor, Descricao, Cat), produto(Id, Nome, Valor, Descricao, Cat), Produtos),
    (Produtos \= [] -> print_produto(Produtos)
    ; write('Nenhum produto encontrado para a categoria!'), nl).