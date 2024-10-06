:- module(login, [login/3]).
:- usuario/7.

login(User, Senha, Tipo) :-
    (verifica_dados_login(User, Senha, T) -> 
        (verifica_horario(User) -> Tipo = T; Tipo = "h")
    ; Tipo = "-").

verifica_dados_login(User, Senha, Tipo) :-
    consult('data/usuario_db.pl'),
    usuario(User, Senha, Tipo, _, _, _, _).

verifica_horario(User) :-
    usuario(User, _, _, _, _, TipoAssinatura, _),
    (TipoAssinatura = "SIL" ->  
        get_time(CurrentTime),
        stamp_date_time(CurrentTime, DateTime, local),
        date_time_value(hour, DateTime, Hour),
        Hour >= 6, Hour =< 14
        ; true
    ).