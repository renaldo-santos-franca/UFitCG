:- module(navegabilidade, [menuInicial/0]).

clear_screen :- write('\e[H\e[2J').

menuInicial :-
    clear_screen,
    writeln("|------------------------------|\n|      Bem vindo à UFitCG      |\n|                              |\n|      Digite 1 para Login     |\n|      Digite 2 para Sair      |\n|------------------------------|\n"),
    read_line_to_codes(user_input, X3),
    string_to_atom(X3,X2),
    atom_number(X2,Opcao),
    acaotelainicial(Opcao),
    halt.

acaotelainicial(1) :- abalogin.
acaotelainicial(2) :- halt.
acaotelainicial(_) :- write("opção invalida"), menuInicial.

abalogin :-
    clear_screen,
    writeln("LOGIN"),
    write("Usuário: "),
    read_line_to_codes(user_input, X3),
    string_to_atom(X3,X2),
    atom_string(X2,Usr),
    write("Senha: "),
    read_line_to_codes(user_input, Y3),
    string_to_atom(Y3,Y2),
    atom_string(Y2,Senha),
    clear_screen,
    
    (login(Usr, Senha, Veri) ->
        (Veri == null ->
            writeln("Usuario ou Senha Invalido"),
            writeln("Aperte Enter Para Fazer Login Novamente ou '-' Para Sair"),
            read_line_to_codes(user_input, ComandoCodes),
            string_to_atom(ComandoCodes, Comando),
            (Comando == '-' -> menuInicial ; abalogin)
        ; Veri == 'h' ->
            writeln("Usuario fora de Horario de Acesso"),
            writeln("Aperte Enter Para Fazer Login Novamente ou '-' Para Sair"),
            read_line_to_codes(user_input, ComandoCodes),
            string_to_atom(ComandoCodes, Comando),
            (Comando == '-' -> menuInicial ; abalogin)
        ; tipoMenu(Veri, Usr)
        )
    ; writeln("Erro ao verificar login"), abalogin
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
    clear_screen,
    acaoMenuADM(Comando, Usr).

acaoMenuADM("1", Usr) :- menuUsuarioAdm(Usr).
acaoMenuADM("2", Usr) :- menuLojaAdm(Usr).
acaoMenuADM("3", Usr) :- menuAssAdm(Usr).
acaoMenuADM("4", Usr) :- menuVendasAdm(Usr).
acaoMenuADM("5", Usr) :- menuVendasLojaAdm(Usr).
acaoMenuADM("6", Usr) :-
    mostrarPerfil(Usr),
    espera,
    menuAdm(Usr).
acaoMenuADM("-", _) :- menuInicial.
acaoMenuADM(_, Usr) :- menuAdm(Usr).

menuVendasLojaAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Debito Cliente\n2. Apagar Venda Loja\n3. Listar Vendas\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    clear_screen,
    acaoMenuVendasLojaAdm(Comando, Usr).

acaoMenuVendasLojaAdm("1", Usr) :-
    write("Cliente: "),
    read_line_to_codes(user_input, ClienteCodes),
    string_to_atom(ClienteCodes, Cliente),
    filtrarVendas(Cliente),
    espera,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("2", Usr) :-
    write("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, Id),
    removeVendaLoja(Id, Mensagem),
    writeln(Mensagem),
    espera,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("3", Usr) :-
    listarVendas,
    espera,
    menuVendasLojaAdm(Usr).
acaoMenuVendasLojaAdm("-", Usr) :- menuAdm(Usr).
acaoMenuVendasLojaAdm(_, Usr) :- menuVendasLojaAdm(Usr).

menuVendasAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Venda\n2. Cancelar Venda\n3. Listar Vendas\n4. Adicionar Parcela Paga\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    clear_screen,
    acaoMenuVendasAdm(Comando, Usr).

acaoMenuVendasAdm("1", Usr) :-
    write("Cliente: "),
    read_line_to_codes(user_input, ClienteCodes),
    string_to_atom(ClienteCodes, Cliente),
    write("Tipo de Assinatura: "),
    read_line_to_codes(user_input, TipoAssCodes),
    string_to_atom(TipoAssCodes, TipoAss),
    write("Tipo Parcela: "),
    read_line_to_codes(user_input, TipoParcelaCodes),
    string_to_atom(TipoParcelaCodes, TipoParcela),
    write("Parcelas Pagas: "),
    read_line_to_codes(user_input, ParcelasPagasCodes),
    string_to_atom(ParcelasPagasCodes, ParcelasPagasStr),
    atom_number(ParcelasPagasStr, ParcelasPagas),
    write("Data: "),
    read_line_to_codes(user_input, DataInicioCodes),
    string_to_atom(DataInicioCodes, DataInicio),
    cadastraVendaAssinatura(Cliente, TipoAss, TipoParcela, ParcelasPagas, DataInicio, Mensagem),
    writeln(Mensagem),
    espera,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("2", Usr) :-
    write("Id: "),
    read_line_to_codes(user_input, IdCodes),
    string_to_atom(IdCodes, IdStr),
    atom_number(IdStr, Id),
    removeVendasAssinatura(Id, Mensagem),
    writeln(Mensagem),
    espera,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("3", Usr) :-
    listarVendasAssinaturas,
    espera,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("4", Usr) :-
    write("Cliente: "),
    read_line_to_codes(user_input, ClienteCodes),
    string_to_atom(ClienteCodes, Cliente),
    adicionarParcelaPaga(Cliente, Mensagem),
    writeln(Mensagem),
    espera,
    menuVendasAdm(Usr).
acaoMenuVendasAdm("-", Usr) :- menuAdm(Usr).
acaoMenuVendasAdm(_, Usr) :- menuVendasAdm(Usr).

menuUsuarioAdm(Usr) :-
    writeln("Digite O Numero Do Comando A Sua Escolha"),
    writeln("1. Cadastrar Usuario\n2. Apagar Usuario\n3. Listar Usuarios\n-. Voltar"),
    read_line_to_codes(user_input, ComandoCodes),
    string_to_atom(ComandoCodes, Comando),
    clear_screen,
    acaoMenuUsuarioAdm(Comando, Usr).

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
    menuUsuarioAdm(Usr).

acaoMenuUsuarioAdm("2", Usr) :-
    writeln("Usuario: "),
    read_line_to_codes(user_input, UsrCodes),
    string_to_atom(UsrCodes, Usuario),
    removeUsuario(Usuario, Mensagem),
    writeln(Mensagem),
    espera,
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
    clear_screen,
    acaoMenuUsuarioListarAdm(Comando, Usr).

acaoMenuUsuarioListarAdm("1", Usr) :-
    mostrarUsuarios,
    espera,
    menuUsuarioListarAdm(Usr).
acaoMenuUsuarioListarAdm("2", Usr) :-
    writeln("Tipo de Usuario: "),
    read_line_to_codes(user_input, TipoCodes),
    string_to_atom(TipoCodes, Tipo_usr),
    mostrarUsuariosPorTipo(Tipo_usr),
    espera,
    menuUsuarioListarAdm(Usr).
acaoMenuUsuarioListarAdm("-", Usr) :- menuUsuarioAdm(Usr).
acaoMenuUsuarioListarAdm(_, Usr) :- menuUsuarioListarAdm(Usr).

