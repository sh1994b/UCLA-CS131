%_____________tower implementation
tower(0,[],counts([],[],[],[])).
tower(N,T,C) :-
        C = counts(Top, Bot, Left, Right), 
	length(T,N),
	rows_length_correct(N,T),
	rows_unique(T),
	rows_in_range(N,T),
	transpose(T,TT),
	rows_length_correct(N,TT),
        rows_unique(TT),
        rows_in_range(N,TT),
	maplist(reverse,T,RevT),
	maplist(reverse,TT,RevTT),
	check_counts(T,Left),
	check_counts(TT,Top),
	check_counts(RevT,Right),
	check_counts(RevTT,Bot),
	maplist(fd_labeling,T).

%The following part has been directly copied from
%https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolo
%___________________________________________________
transpose([],[]).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).
%___________________________________________________

rows_length_correct(_,[]).
rows_length_correct(N,[H|T]) :-
	length(H,N),
	rows_length_correct(N,T).

rows_unique([]).
rows_unique([H|T]) :- 
	fd_all_different(H),
	rows_unique(T).

rows_in_range(_,[]).
rows_in_range(N,[H|T]) :-
	fd_domain(H,1,N),
	rows_in_range(N,T).

counts_in_range(0,counts([],[],[],[])).
counts_in_range(N,counts(T,B,L,R)) :-
	list_in_range(N,T),
	list_in_range(N,B),
        list_in_range(N,L),
        list_in_range(N,R).

list_in_range(_,[]).
list_in_range(N,L) :-
	fd_domain(L,1,N), length(L,N). 

check_counts([],[]).
check_counts([H|T],[C|RC]):-
	count_correct(C,H,0),
	check_counts(T,RC).

count_correct(0,[],_).
count_correct(VisibleTowers,[Height|R],LastMax) :-
	Height #> LastMax,
	DecVisibleTowers #= VisibleTowers-1,
	count_correct(DecVisibleTowers,R,Height).

count_correct(VisibleTowers,[Height|R],LastMax) :-
	Height #< LastMax,
	count_correct(VisibleTowers,R,LastMax).



%_____________plain_tower implementation
plain_tower(0,[],counts([],[],[],[])).
plain_tower(N,T,C) :-
        C = counts(Top, Bot, Left, Right),
        length(T,N),
        rows_length_correct(N,T),
        plain_rows_unique(T),
        plain_rows_in_range(N,T),
        transpose(T,TT),
        rows_length_correct(N,TT),
        plain_rows_unique(TT),
        plain_rows_in_range(N,TT),
        maplist(reverse,T,RevT),
        maplist(reverse,TT,RevTT),
        plain_check_counts(T,Left),
        plain_check_counts(TT,Top),
        plain_check_counts(RevT,Right),
        plain_check_counts(RevTT,Bot).

plain_rows_unique([]).
plain_rows_unique([H|T]):-
	plain_row_unique(H),
	plain_rows_unique(T).

plain_row_unique([]).
plain_row_unique([H|T]):-
	delete(T,H,NewT),
	length(T,N),
	length(NewT,N),
	plain_row_unique(T).

%I used the TA slides to implement the following part:
%______________________________
plain_rows_in_range(_,[]).
plain_rows_in_range(N,[H|T]):-
	maplist(between(1,N),H),
	plain_rows_in_range(N,T).
%______________________________

plain_check_counts([],[]).
plain_check_counts([H|T],[C|RC]):-
	plain_count(0,C,H),
	plain_check_counts(T,RC).

plain_count(LastMax,CalculatedCount,[Height]):-
	Height > LastMax,
	CalculatedCount=1.
plain_count(_,CalculatedCount,[_]):-
	CalculatedCount=0.
plain_count(LastMax,CalculatedCount,[H|T]):-
	H > LastMax,
	plain_count(H,CC,T),
	succ(CC,CalculatedCount).
plain_count(LastMax,CalculatedCount,[_|T]):-
	plain_count(LastMax,CalculatedCount,T).


%_____________speedup implementation
speedup(Ratio):-
	tower(4,_,_),
	statistics(cpu_time,[_,StopT]),
	plain_tower(4,_,_),
	statistics(cpu_time,[_,StopP]),
	Ratio is StopP/StopT.

%_____________ambiguous
ambiguous(N, C, T1, T2):-
	findall(T,tower(N,T,C),[T1,T2|_]).


