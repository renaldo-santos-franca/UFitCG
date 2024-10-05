:- module(loja, [cadastroProduto/4]).
:- dynamic produto/5.

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

remove_produto(Id) :-
    consult('data/loja_db.pl'),  
    ( produto(Id, _, _, _, _) ->  
        retract(produto(Id, _, _, _, _)),   
        atualizar_arquivo, 
        writeln("Produto removido!")
    ;   writeln("Produto Inexistente!")
    ).

atualizar_arquivo :-
    open('data/loja_db.pl', write, Stream), 
    forall(produto(Id, Nome, Valor, Descricao, Categorias),
        format(Stream, 'produto(~w, "~w", ~w, "~w", "~w").~n', [Id, Nome, Valor, Descricao, Categorias])
    ),
    close(Stream).

listar_produtos :-
    consult('data/loja_db.pl'),
    (   produto(_, _, _, _, _) ->  
        forall(produto(Id, Nome, Valor, Descricao, Categorias),  
            print_produto(Id, Nome, Valor, Descricao, Categorias) 
        )
    ;   writeln('Nenhum produto cadastrado.') 
    ).

print_produto(Id, Nome, Valor, Descricao, Categorias) :-
    format('Id: ~w~n', [Id]),
    format('Nome: ~w~n', [Nome]),
    format('Valor: ~2f~n', [Valor]),
    format('Descrição: ~w~n', [Descricao]),
    format('Categorias: ~w~n', [Categorias]),
    writeln('--------------------------').


listar_produtos_por_categoria(Categoria) :-
    consult('data/loja_db.pl'),
    (   produto(_, _, _, _, Categorias),
        sub_atom(Categorias, _, _, _, Categoria)  % Verifica se a categoria está na string de categorias
    ->  forall(
            (produto(Id, Nome, Valor, Descricao, Categorias),
            sub_atom(Categorias, _, _, _, Categoria)),
            print_produto(Id, Nome, Valor, Descricao, Categorias)
        )
    ;   format('Nenhum produto encontrado na categoria "~w".~n', [Categoria])
    ).