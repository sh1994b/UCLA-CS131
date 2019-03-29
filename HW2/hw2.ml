open List

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let rec production_func rules ss = match rules with
	| [] -> []
	| rule::rr -> (match rule with
		| (nt, l) -> if nt = ss
			then l::production_func rr ss
			else production_func rr ss);;

let convert_grammar g = match g with
	(ss, rules) -> (ss, production_func rules);;

let rec parse_tree_leaves_helper treelist = match treelist with
	| [] -> []
	| (Leaf t)::r -> t::(parse_tree_leaves_helper r)
	| (Node (n,l))::r -> (parse_tree_leaves_helper l)
				@ (parse_tree_leaves_helper r);;

let parse_tree_leaves tree = parse_tree_leaves_helper [tree];;


let rec matcher rules pfun acceptor frag = match rules with
	| [] -> None
	| rule::rr -> (match (match_rule rule pfun acceptor frag) with
		| None -> matcher rr pfun acceptor frag
		| Some x -> Some x)

and match_rule symlist pfun acceptor frag = match symlist with
	| [] -> acceptor frag
	| sym::rs -> (match sym with
		| N nt -> matcher (pfun nt) pfun (match_rule rs pfun acceptor ) frag
		| T t -> (match frag with
			| [] -> None
			| f::r -> if t=f then match_rule rs pfun acceptor r
				else None ));;

let make_matcher gram = match gram with
	| (ss, pfun) -> matcher (pfun ss) pfun;;

let rec parserfunc ss rules prod frag = match rules with
	| [] -> (None, [])
	| rule::rr -> (match (parser_helper rule prod frag) with
		| (None, _) -> parserfunc ss rr prod frag
		| (Some x, f) -> ((Some (Node (ss, x))), f))

and parser_helper symlist prod frag = match symlist with
	| [] -> (Some [], frag)
	| sym::rs -> (match sym with
		| N nt -> (match parserfunc nt (prod nt) prod frag with
			| (None, _) -> (None, [])
                        | (Some y ,r_frag) -> (match parser_helper rs prod r_frag with
				| (None, f) -> (None, f)
				| (Some x, f) -> (Some (y::x), f)))
		| T t -> (match frag with
			| [] -> (None, frag)
			| pre::suf -> if t=pre then (match parser_helper rs prod suf with
				| (None, f) -> (None, f)
				| (Some x, f) -> (Some ((Leaf pre)::x), f)) 
				  else (None, suf)));;


let make_parser gram frag = match gram with
	| (ss, pfun) -> (match parserfunc ss (pfun ss) pfun frag with
		| (None, _) -> None
		| (Some x, _) -> Some x);;

