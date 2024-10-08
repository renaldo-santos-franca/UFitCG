:- module(navegabilidade, [menuInicial/0]).
:- use_module(aulaExtra).
:- use_module(usuario).
:- use_module(fichaTreino).
:- use_module(avaliacaoFisica).
:- use_module(loja).
:- use_module(aulaCliente).
:- use_module(assinatura).
:- use_module(carrinho).
:- use_module(venda).
%clear_screen :- write('').
clear_screen :- write('\e[H\e[2J').

/*lembrar de converter todos os inputs de menus de atom pra string*/
menuInicial :-
    clear_screen,
    writeln("|------------------------------|\n|      Bem vindo à UFitCG      |\n|                              |\n|    Tecle ENTER para Login    |\n|      Digite - para Sair      |\n|------------------------------|\n"),
    read_line_to_codes(user_input, InputCodes),
    string_codes(Input, InputCodes),
    acaoTelaInicial(Input),
    clear_screen.

acaoTelaInicial("-") :- halt.
acaoTelaInicial(_) :- abalogin.

abalogin :-
    clear_screen,
    writeln("LOGIN"),
    write("Usuário: "),
    read_line_to_codes(user_input, X3),
    string_codes(Usr,X3),
    write("Senha: "),
    read_line_to_codes(user_input, Y3),
    string_codes(Senha, Y3),
    clear_screen,
    login(Usr, Senha, Tipo), 
    
    (Tipo = "-" ->
        writeln("Usuario ou Senha Invalido"),
        writeln("Aperte Enter Para Fazer Login Novamente ou '-' Para Sair"),
        read_line_to_codes(user_input, ComandoCodes),
        string_to_atom(ComandoCodes, Comando),
        (Comando == '-' -> menuInicial ; abalogin)
        ; Tipo == "h" ->
            writeln("Usuario fora de Horario de Acesso"),
            writeln("Aperte Enter Para Fazer Login Novamente ou '-' Para Sair"),
            read_line_to_codes(user_input, ComandoCodes),
            string_to_atom(ComandoCodes, Comando),
            (Comando == '-' -> menuInicial ; abalogin)
        ; tipoMenu(Tipo, Usr)
    ).

tipoMenu("ADM", Usr) :- menuAdm(Usr).
tipoMenu("PER", Usr) :- menuPer(Usr).
tipoMenu("CLI", Usr) :- menuCli(Usr).
tipoMenu(_, _) :- writeln("Erro").

menuAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Controle de Usuario\n2. Controle da Loja\n3. Controle Assinaturas\n4. Vendas Assinaturas\n5. Vendas Loja\n6. Perfil\n-. Sair"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuADM(ComandoStr, Usr).

acaoMenuADM("1", Usr) :- menuUsuarioAdm(Usr).
acaoMenuADM("2", Usr) :- menuLojaAdm(Usr).
acaoMenuADM("3", Usr) :- menuAssAdm(Usr).
acaoMenuADM("4", Usr) :- menuVendasAdm(Usr).
acaoMenuADM("5", Usr) :- menuVendasLojaAdm(Usr).
acaoMenuADM("6", Usr) :-
    mostrarPerfil(Usr),
    espera,
    clear_screen,
    menuAdm(Usr).
acaoMenuADM("-", _) :- menuInicial.
acaoMenuADM(_, Usr) :- menuAdm(Usr).

menuVendasLojaAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Debito Cliente\n2. Apagar Venda Loja\n3. Listar Vendas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuVendasLojaAdm(ComandoStr, Usr).

acaoMenuVendasLojaAdm("1", Usr) :-
    write("Cliente: "),
    read_line_to_string(user_input, Cliente),
    filtrar_vendas(Cliente),
    espera,
    clear_screen,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("2", Usr) :-
    write("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_codes(IdCodes, IdString),
    number_string(Id, IdString),
    remove_venda_loja(Id),
    espera,
    clear_screen,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("3", Usr) :-
    listar_vendas,
    espera,
    clear_screen,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("-", Usr) :- menuAdm(Usr).
acaoMenuVendasLojaAdm(_, Usr) :- menuVendasLojaAdm(Usr).

menuVendasAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Venda\n2. Cancelar Venda\n3. Listar Vendas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuVendasAdm(ComandoStr, Usr).

acaoMenuVendasAdm("1", Usr) :-
    write("Cliente: "),
    read_line_to_string(user_input, Cliente),
    write("Tipo de Assinatura: "),
    read_line_to_string(user_input, TipoAss),
    write("Tipo Parcela: "),
    read_line_to_codes(user_input, TipoParcelaCodes),
    string_to_atom(TipoParcelaCodes, TipoParcela),
    write("Parcelas Pagas: "),
    read_line_to_codes(user_input, ParcelasCode),
    string_codes(ParcelasStr, ParcelasCode),
    string_to_atom(ParcelasStr, ParcelasPagas),
    write("Data: "),
    read_line_to_codes(user_input, DataInicioCodes),
    string_to_atom(DataInicioCodes, DataInicio),
    cadastraVendaAssinatura(Cliente, TipoAss, TipoParcela, ParcelasPagas, DataInicio),
    espera,
    clear_screen,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("2", Usr) :-
    write("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    removeVendasAssinatura(Id),
    espera,
    clear_screen,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("3", Usr) :-
    listarVendasAssinaturas,
    espera,
    clear_screen,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("-", Usr) :- menuAdm(Usr).
acaoMenuVendasAdm(_, Usr) :- menuVendasAdm(Usr).

menuUsuarioAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Usuario\n2. Apagar Usuario\n3. Listar Usuarios\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuUsuarioAdm(ComandoStr, Usr).

acaoMenuUsuarioAdm("1", Usr) :-
    writeln("Usuario: "),
    read_line_to_codes(user_input, UsrCodes),
    string_to_atom(UsrCodes, Usuario),
    writeln("Senha: "),
    read_line_to_codes(user_input, SenhaCodes),
    string_to_atom(SenhaCodes, Senha),
    writeln("Tipo de Usuario: "),
    read_line_to_codes(user_input, TipoCodes),
    string_to_atom(TipoCodes, Tipo_usr),
    writeln("Nome: "),
    read_line_to_codes(user_input, NomeCodes),
    string_to_atom(NomeCodes, Nome),
    writeln("Data de Nascimento: "),
    read_line_to_codes(user_input, DataNascCodes),
    string_to_atom(DataNascCodes, Data_nas),
    writeln("Tipo de Assinatura: "),
    read_line_to_codes(user_input, TipoAssCodes),
    string_to_atom(TipoAssCodes, Tipo_assinatura),
    writeln("Salario: "),
    read_line_to_codes(user_input, SalarioCodes),
    string_to_atom(SalarioCodes, SalarioStr),
    atom_number(SalarioStr, Salario),
    cadastraUsuario(Usuario, Senha, Tipo_usr, Nome, Data_nas, Tipo_assinatura, Salario),
    espera,
    clear_screen,
    menuUsuarioAdm(Usr).

acaoMenuUsuarioAdm("2", Usr) :-
    writeln("Usuario: "),
    read_line_to_string(user_input, UsuarioRemove),
    removeUsuario(UsuarioRemove),
    espera,
    clear_screen,
    menuUsuarioAdm(Usr).

acaoMenuUsuarioAdm("3", Usr) :-
    menuUsuarioListarAdm(Usr).

acaoMenuUsuarioAdm("-", Usr) :- menuAdm(Usr).
acaoMenuUsuarioAdm(_, Usr) :- menuUsuarioAdm(Usr).

menuUsuarioListarAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Usuarios\n2. Listar Usuarios Por Tipo\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuUsuarioListarAdm(ComandoStr, Usr).

acaoMenuUsuarioListarAdm("1", Usr) :-
    mostrarUsuarios,
    espera,
    clear_screen,
    menuUsuarioListarAdm(Usr).
acaoMenuUsuarioListarAdm("2", Usr) :-
    writeln("Tipo de Usuario: "),
    read_line_to_string(user_input, Tipo_usr),
    mostrarUsuariosTipo(Tipo_usr),
    espera,
    clear_screen,
    menuUsuarioListarAdm(Usr).
acaoMenuUsuarioListarAdm("-", Usr) :- menuUsuarioAdm(Usr).
acaoMenuUsuarioListarAdm(_, Usr) :- menuUsuarioListarAdm(Usr).

menuLojaAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Produto\n2. Apagar Produto\n3. Listar Produtos\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuLojaAdm(ComandoStr, Usr).

acaoMenuLojaAdm("1", Usr) :-
    writeln("Nome do produto: "),
    read_line_to_codes(user_input, NomeCodes),
    string_to_atom(NomeCodes, Nome),
    writeln("Preco do produto: "),
    read_line_to_codes(user_input, PrecoCodes),
    string_to_atom(PrecoCodes, PrecoStr),
    atom_number(PrecoStr, Preco),
    writeln("Descricao: "),
    read_line_to_codes(user_input, DescricaoCodes),
    string_to_atom(DescricaoCodes, Descricao),
    writeln("Categorias: "),
    read_line_to_codes(user_input, CategoriasCodes),
    string_to_atom(CategoriasCodes, Categorias),
    cadastroProduto(Nome, Preco, Descricao, Categorias),
    espera,
    clear_screen,
    menuLojaAdm(Usr).

acaoMenuLojaAdm("2", Usr) :-
    writeln("Id: "),
    read_line_to_string(user_input, Idcode),
    string_codes(IdStr, Idcode),
    string_to_atom(IdStr, IdAtom),
    atom_number(IdAtom, Id),
    remove_produto(Id),
    espera,
    clear_screen,
    menuLojaAdm(Usr).

acaoMenuLojaAdm("3", Usr) :-
    menuLojaListarAdm(Usr).

acaoMenuLojaAdm("-", Usr) :- menuAdm(Usr).
acaoMenuLojaAdm(_, Usr) :- menuLojaAdm(Usr).

menuLojaListarAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Produtos\n2. Listar Produtos Por Categoria\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuLojaListarAdm(ComandoStr, Usr).

acaoMenuLojaListarAdm("1", Usr) :-
    listar_produtos,
    espera,
    clear_screen,
    menuLojaListarAdm(Usr).

acaoMenuLojaListarAdm("2", Usr) :-
    writeln("Categoria: "),
    read_line_to_codes(user_input, CategoriaCodes),
    string_to_atom(CategoriaCodes, Categoria),
    listar_produtos_por_categoria(Categoria),
    espera,
    clear_screen,
    menuLojaListarAdm(Usr).

acaoMenuLojaListarAdm("-", Usr) :- menuLojaAdm(Usr).
acaoMenuLojaListarAdm(_, Usr) :- menuLojaListarAdm(Usr).

menuAssAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Assinatura\n2. Apagar Assinatura\n3. Listar Assinaturas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuAssAdm(ComandoStr, Usr).

acaoMenuAssAdm("1", Usr) :-
    writeln("sigla: "),
    read_line_to_codes(user_input, SiglaCodes),
    string_to_atom(SiglaCodes, Sigla),
    writeln("Valor Mensal: "),
    read_line_to_codes(user_input, ValorCodes),
    string_to_atom(ValorCodes, ValorStr),
    atom_number(ValorStr, Mensal),
    writeln("Valor Semestral: "),
    read_line_to_codes(user_input, ValorSemCodes),
    string_to_atom(ValorSemCodes, ValorSemStr),
    atom_number(ValorSemStr, Semestral),
    writeln("Valor Anual: "),
    read_line_to_codes(user_input, ValorAnualCodes),
    string_to_atom(ValorAnualCodes, ValorAnualStr),
    atom_number(ValorAnualStr, Anual),
    writeln("Desconto em Aula Extra:"),
    read_line_to_codes(user_input, DescontoCodes),
    string_to_atom(DescontoCodes, DescontoStr),
    atom_number(DescontoStr, Desconto),
    writeln("Numero Aulas Gratis: "),
    read_line_to_codes(user_input, AulasCodes),
    string_to_atom(AulasCodes, AulasStr),
    atom_number(AulasStr, Aulas),
    writeln("Acesso: "),
    read_line_to_codes(user_input, AcessoCodes),
    string_to_atom(AcessoCodes, Acesso),
    cadastraAssinatura(Sigla, Mensal, Semestral, Anual, Desconto, Aulas, Acesso),
    espera,
    clear_screen,
    menuAssAdm(Usr).

acaoMenuAssAdm("2", Usr) :-
    writeln("Sigla da Assinatura a Apagar: "),
    read_line_to_string(user_input, Sigla),
    removeAssinatura(Sigla),
    espera,
    clear_screen,
    menuAssAdm(Usr).

acaoMenuAssAdm("3", Usr) :-
    mostrarAssinaturas,
    espera,
    clear_screen,
    menuAssAdm(Usr).

acaoMenuAssAdm("-", Usr) :- menuAdm(Usr).

menuPer(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Controle de Aulas\n2. Controle Avaliações Fisicas\n3. Controle Ficha de Treino\n4. Perfil\n-. Sair"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuPer(ComandoStr, Usr).

acaoMenuPer("1", Usr) :- menuAulasPer(Usr).
acaoMenuPer("2", Usr) :- menuAvaliacaoPer(Usr).
acaoMenuPer("3", Usr) :- menuTreinoPer(Usr).
acaoMenuPer("4", Usr) :-
    mostrarPerfil(Usr),
    espera,
    clear_screen,
    menuPer(Usr).
acaoMenuPer("-", _) :- menuInicial.
acaoMenuPer(_, Usr) :- menuPer(Usr).

menuTreinoPer(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Treino\n2. Apagar Treino\n3. Listar Treinos\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuTreinoPer(ComandoStr, Usr).

acaoMenuTreinoPer("1", Usr) :-
    writeln("Cliente: "),
    read_line_to_codes(user_input, ClienteCodes),
    string_to_atom(ClienteCodes, Clienteatom),
    atom_string(Clienteatom, Cliente),
    writeln("Exercicios: "),
    read_line_to_codes(user_input, ExerciciosCodes),
    string_to_atom(ExerciciosCodes, Exercicios),
    writeln("Observacoes: "),
    read_line_to_codes(user_input, ObservacoesCodes),
    string_to_atom(ObservacoesCodes, Observacoes),
    cadastraFicha(Cliente, Usr, Exercicios, Observacoes),
    espera,
    clear_screen,
    menuTreinoPer(Usr).

acaoMenuTreinoPer("2", Usr) :-
    writeln("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id_ficha),
    removeFicha(Id_ficha),
    espera,
    clear_screen,
    menuTreinoPer(Usr).

acaoMenuTreinoPer("3", Usr) :-
    mostrarFichaPersonal(Usr),
    espera,
    clear_screen,
    menuTreinoPer(Usr).

acaoMenuTreinoPer("-", Usr) :- menuPer(Usr).
acaoMenuTreinoPer(_, Usr) :- menuTreinoPer(Usr).

menuAvaliacaoPer(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Avaliacao Fisica\n2. Apagar Avaliacao Fisica\n3. Listar Avaliacoes Fisicas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuAvaliacaoPer(ComandoStr, Usr).

acaoMenuAvaliacaoPer("1", Usr) :-
    writeln("Cliente: "),
    read_line_to_codes(user_input, ClienteCodes),
    string_to_atom(ClienteCodes, Clienteatom),
    atom_string(Clienteatom, Cliente),
    writeln("Avaliação: "),
    read_line_to_codes(user_input, AvaliacaoCodes),
    string_to_atom(AvaliacaoCodes, Avaliacao),
    writeln("Observações: "),
    read_line_to_codes(user_input, ObservacoesCodes),
    string_to_atom(ObservacoesCodes, Observacoes),
    writeln("Data: "),
    read_line_to_codes(user_input, DataCodes),
    string_to_atom(DataCodes, Data_ava),
    cadastraAvaliacao(Cliente, Usr, Avaliacao, Observacoes, Data_ava),
    espera,
    clear_screen,
    menuAvaliacaoPer(Usr).

acaoMenuAvaliacaoPer("2", Usr) :-
    writeln("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id_ava),
    removeAvaliacao(Id_ava),
    espera,
    clear_screen,
    menuAvaliacaoPer(Usr).

acaoMenuAvaliacaoPer("3", Usr) :-
    mostrarAvaliacaoPersonal(Usr),
    espera,
    clear_screen,
    menuAvaliacaoPer(Usr).

acaoMenuAvaliacaoPer("-", Usr) :- menuPer(Usr).
acaoMenuAvaliacaoPer(_, Usr) :- menuAvaliacaoPer(Usr).

menuAulasPer(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Aula\n2. Apagar Aula\n3. Listar Aulas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuAulasPer(ComandoStr, Usr).

acaoMenuAulasPer("1", Usr) :-
    writeln("Materia: "),
    read_line_to_codes(user_input, MateriaCodes),
    string_codes(Materia, MateriaCodes),
    writeln("Data e Horario: "),
    read_line_to_codes(user_input, DataHoraCodes),
    string_codes(DataHora, DataHoraCodes),
    writeln("Limite de Alunos: "),
    read_line_to_codes(user_input, LimiteCodes),
    string_to_atom(LimiteCodes, LimiteStr),
    atom_number(LimiteStr, Limite),
    cadastraAula(Materia, Usr, DataHora, Limite),
    espera,
    clear_screen,
    menuAulasPer(Usr).

acaoMenuAulasPer("2", Usr) :-
    writeln("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, Id),
    removeAula(Id),
    espera,
    clear_screen,
    menuAulasPer(Usr).

acaoMenuAulasPer("3", Usr) :- menuListaAulaPer(Usr).
acaoMenuAulasPer("-", Usr) :- menuPer(Usr).
acaoMenuAulasPer(_, Usr) :- menuAulasPer(Usr).

menuListaAulaPer(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Minhas Aulas\n2. Listar todas Aulas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuListaAulaPer(ComandoStr, Usr).

acaoMenuListaAulaPer("1", Usr) :-
    listarAulasPersonal(Usr),
    espera,
    clear_screen,
    menuListaAulaPer(Usr).

acaoMenuListaAulaPer("2", Usr) :-
    listarAulas,
    espera,
    clear_screen,
    menuListaAulaPer(Usr).

acaoMenuListaAulaPer("-", Usr) :- menuAulasPer(Usr).
acaoMenuListaAulaPer(_, Usr) :- menuListaAulaPer(Usr).

menuCli(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Controle Aulas\n2. Listar Minhas Fichas de Trieno\n3. Minhas Avaliações Fisicas\n4. MarcketPlace\n5. Suporte\n6. Perfil\n-. Sair"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuCli(ComandoStr, Usr).

acaoMenuCli("1", Usr) :- menuAulasCli(Usr).
acaoMenuCli("2", Usr) :-
    mostrarFichaCliente(Usr),
    espera,
    clear_screen,
    menuCli(Usr).

acaoMenuCli("3", Usr) :-
    mostrarAvaliacaoCliente(Usr),
    espera,
    clear_screen,
    menuCli(Usr).

print_file(FilePath) :-
    open(FilePath, read, Stream),
    read_file(Stream),
    close(Stream).

read_file(Stream) :-
    read_line_to_string(Stream, Line),
    ( Line \= end_of_file ->
        writeln(Line),
        read_file(Stream) 
    ; true 
    ).

acaoMenuCli("4", Usr) :- menuMarketPlaceCli(Usr).
acaoMenuCli("5", Usr) :- 
    print_file('data/suporte.txt'),
    espera,
    clear_screen,
    menuCli(Usr).
acaoMenuCli("6", Usr) :-
    mostrarPerfil(Usr),
    espera,
    clear_screen,
    menuCli(Usr).
acaoMenuCli("-", _) :- menuInicial.
acaoMenuCli(_, Usr) :- menuCli(Usr).

menuAulasCli(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Inscrever em Aula\n2. Cancelar Inscrição\n3. Listar Aulas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuAulasCli(ComandoStr, Usr).

acaoMenuAulasCli("1", Usr) :-
    writeln("Id da Aula: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    adicionarAulaExtra(Usr, Id),
    espera,
    clear_screen,
    menuAulasCli(Usr).

acaoMenuAulasCli("2", Usr) :-
    writeln("Id da Aula: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    cancelarAula(Usr, Id),
    espera,
    clear_screen,
    menuAulasCli(Usr).

acaoMenuAulasCli("3", Usr) :- menuAulasListarCli(Usr).
acaoMenuAulasCli("-", Usr) :- menuCli(Usr).
acaoMenuAulasCli(_, Usr) :- menuAulasCli(Usr).

menuAulasListarCli(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Minhas Aulas\n2. Listar todas Aulas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuAulasListarCli(ComandoStr, Usr).

acaoMenuAulasListarCli("1", Usr) :-
    listarAulasCliente(Usr),
    espera,
    clear_screen,
    menuAulasListarCli(Usr).

acaoMenuAulasListarCli("2", Usr) :-
    listarAulas,
    espera,
    clear_screen,
    menuAulasListarCli(Usr).

acaoMenuAulasListarCli("-", Usr) :- menuAulasCli(Usr).
acaoMenuAulasListarCli(_, Usr) :- menuAulasListarCli(Usr).

menuMarketPlaceCli(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Produtos\n2. Carrinho\n3. Adicionar Produto ao Carrinho\n4. Remover Produto do Carrinho\n5. Pagar\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuMarketPlaceCli(ComandoStr, Usr).

acaoMenuMarketPlaceCli("1", Usr) :- menuMarcketPlaceListarProdCli(Usr).
acaoMenuMarketPlaceCli("2", Usr) :- 
    listar_produtos_carrinho(Usr),
    espera,
    clear_screen,
    menuMarketPlaceCli(Usr).
acaoMenuMarketPlaceCli("3", Usr) :-
    writeln("Id do Produto: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    adiciona_produto_carrinho(Usr, Id, Resultado),
    writeln(Resultado),
    espera,
    clear_screen,
    menuMarketPlaceCli(Usr).
acaoMenuMarketPlaceCli("4", Usr) :-
    writeln("Id do Produto: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    deletar_produto_carrinho(Usr, Id),
    espera,
    clear_screen,
    menuMarketPlaceCli(Usr).
acaoMenuMarketPlaceCli("5", Usr) :-
    writeln("Digite Enter Para Confirmar a Compra\nDigite - Para Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    (Comando == '-' -> menuMarketPlaceCli(Usr) 
    ; cadastrar_venda(Usr), espera, clear_screen, menuMarketPlaceCli(Usr)).

acaoMenuMarketPlaceCli("-", Usr) :- menuCli(Usr).
acaoMenuMarketPlaceCli(_, Usr) :- menuMarketPlaceCli(Usr).

menuMarcketPlaceListarProdCli(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Listar Todos os Produtos\n2. Listar Produto por Categoria\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    atom_string(Comando, ComandoStr),
    clear_screen,
    acaoMenuMarcketPlaceListarProdCli(ComandoStr, Usr).

acaoMenuMarcketPlaceListarProdCli("1", Usr) :-
    listar_produtos,
    espera,
    clear_screen,
    menuMarcketPlaceListarProdCli(Usr).

acaoMenuMarcketPlaceListarProdCli("2", Usr) :-
    writeln("Categoria: "),
    read_line_to_string(user_input, Categoria),
    listar_produtos_por_categoria(Categoria),
    espera,
    clear_screen,
    menuMarcketPlaceListarProdCli(Usr).

acaoMenuMarcketPlaceListarProdCli("-", Usr) :- menuMarketPlaceCli(Usr).
acaoMenuMarcketPlaceListarProdCli(_, Usr) :- menuMarcketPlaceListarProdCli(Usr).

espera :-
    read_line_to_codes(user_input, _).
