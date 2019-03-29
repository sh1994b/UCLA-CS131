let acceptor = function
	| h::t -> None
	| x -> Some x

type nonterminals = 
	| Meal | App | Main | Dessert | Drink

let gram = 
  (Meal, 
   function 
	| Meal ->
		[[N Main];
		 [N App; N Main];
	 	 [N App; N Main; N Dessert]]
	| Main ->
		[[N App];
		 [N Dessert];
		 [N App; T "+"; N Dessert]]
	| App ->
		[[T "cheese"; N Drink];
		 [T "salad"]]
	| Dessert ->
		[[N Drink];
		 [T "cake"];
		 [T "cookie"]]
	| Drink ->
		[[T "water"];
		 [T "wine"]])


let make_matcher_test = 
  ((make_matcher gram acceptor ["cheese"; "wine"; "salad"; "+"; "cake"; "cookie"]) = Some [])

let make_parser_test = 
  ((make_parser gram ["cheese"; "wine"]) = 
	Some
	 (Node (Meal,
	   [Node (Main, [Node (App, [Leaf "cheese"; Node (Drink, [Leaf "wine"])])])])))

