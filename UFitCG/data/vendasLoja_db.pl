:- dynamic(venda_id/1).
venda_id(1).
venda(2, "Produtos: abacaxi. Total: 12.00", "Clara", "2024-10-07 13:57:13", 0.00).
assert(venda(1,"Produtos: abacaxi, abacaxi, abacaxi. Total: 36.00","Clara","2024-10-07 14:02:50",0.0)).
