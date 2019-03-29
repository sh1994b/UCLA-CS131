open List

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let rec exists x l =
	if l = [] then false
	else if mem x l then true
	else exists x (tl l);;

let rec subset a b = match a with
	[] -> true
	| x::l -> if not (exists x b) then false else subset l b;;

let equal_sets a b = 
	if subset a b = true && subset b a = true then true else false;;

let rec set_union a b = match a with
	[] -> b
	| x::l -> if not (exists x b) then x :: set_union l b
	else set_union l b;;

let rec set_intersection a b = match a with 
	[] -> []
	| x::l -> if exists x b then x :: set_intersection l b
	else set_intersection l b;;

let rec set_diff a b = match a with
	[] -> []
        | x::l -> if not (exists x b) then x :: set_diff l b
	else set_diff l b;;

let rec computed_fixed_point eq f x = 
	if eq (f x) x then x
	else computed_fixed_point eq f (f x);;

let rec find_nonterminals l = match l with
	[] -> []
	| (N x)::r -> x :: find_nonterminals r
	| (T x)::r -> find_nonterminals r;;

let rec nonterminals_list n l = match l with
	[] -> []
	| t::r -> 
		(match t with 
		(x, li) -> if x = n then (find_nonterminals li)@(nonterminals_list n r)
		else nonterminals_list n r);;

let rec remove_duplicates l = match l with
	[] -> []
	| x::r -> if exists x r then remove_duplicates r
		else x::remove_duplicates r;;

let rec reachable_nonterminals ntlist rules processed = match ntlist with
	[] -> []
	| nt::ntr -> (match rules with 
		[] -> []
		| r::rr -> if exists nt processed then reachable_nonterminals ntr rules processed
			else remove_duplicates((nt::(nonterminals_list nt rules))@(reachable_nonterminals (nonterminals_list nt rules) rules (nt::processed))@(reachable_nonterminals ntr rules (nt::processed))));;


let rec filter_reachable_rules ss rules staticrules = match rules with
        [] -> []
	| (nt,l)::rest -> let valid = reachable_nonterminals [ss] staticrules [] in
		if exists nt valid
		then (nt,l)::(filter_reachable_rules ss rest staticrules)
		else filter_reachable_rules ss rest staticrules;;

let filter_reachable g = match g with
	(s, []) -> (s, [])
	| (s, rules) -> (s, filter_reachable_rules s rules rules);;
