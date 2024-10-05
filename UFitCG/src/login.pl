:- module(login, [login/3]).

login(User, Senha, Result) :-
    verifica_dados_login(User, Senha, VeriDados),
    (   VeriDados == true 
    ->  verifica_horario(User, VeriHorario),
        (   VeriHorario == true
        ->  veri_usuario(User, Senha, Tipo),
            Result = Tipo
        ;   Result = 'h'
        )
    ;   Result = ''
    ).

veri_usuario(User, Senha, Tipo) :-
    consult('data/dataBase.pl'),
    usuario(User, Senha, Tipo, _, _, _, _).

verifica_dados_login(User, Senha, VeriDados) :-
    consult('data/dataBase.pl'),
    (   usuario(User, Senha, _, _, _, _, _)
    ->  VeriDados = true
    ;   VeriDados = false
    ).

verifica_horario(User, VeriHorario) :-
    consult('data/dataBase.pl'),
    usuario(User, _, _, _, _, _, TipoAssinatura),
    get_time(CurrentTime),
    stamp_date_time(CurrentTime, DateTime, local),
    date_time_value(hour, DateTime, Hour),
    (   TipoAssinatura == 'SIL'
    ->  (   Hour >= 6, Hour =< 14
        ->  VeriHorario = true
        ;   VeriHorario = false
        )
    ;   VeriHorario = true
    ).