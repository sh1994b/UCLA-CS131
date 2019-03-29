let my_exists_test0 = exists 2 [2]
let my_exists_test1 = not (exists 5 [])
let my_exists_test2 = exists 3 [5;4;3]
let my_exists_test3 = not (exists 9 [5;6;7])

let my_subset_test0 = subset [] []
let my_subset_test1 = subset [] [1;2]
let my_subset_test2 = subset [4;5;8] [5;8;4]
let my_subset_test3 = subset [3;6] [6;9;10;3]
let my_subset_test4 = not (subset [4;5] [4;6;7])
let my_subset_test5 = not (subset [1] [2])

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [4;5;6] [5;6;4]
let my_equal_sets_test2 = not(equal_sets [4] [5])

let my_set_union_test0 = equal_sets (set_union [] []) []
let my_set_union_test1 = equal_sets (set_union [] [3;4]) [3;4]
let my_set_union_test2 = equal_sets (set_union [1;2;3;4] [2;5]) [1;2;3;4;5]
let my_set_union_test3 = equal_sets (set_union [2] [2]) [2]

let my_set_interstion_test0 = equal_sets (set_intersection [] [2]) []
let my_set_interstion_test1 = equal_sets (set_intersection [3;4] [3]) [3]
let my_set_interstion_test2 = equal_sets (set_intersection [5;6;7] [6;7]) [6;7]

let my_set_diff_test0 = equal_sets (set_diff [] [3]) []
let my_set_diff_test1 = equal_sets (set_diff [1;5;6] [6;5]) [1]
let my_set_diff_test2 = equal_sets (set_diff [6;7] [7;6]) []

let my_computed_fixed_point_test0 = 
  computed_fixed_point (=) (fun x -> x / 5) 1000  = 0
let my_computed_fixed_point_test1 =
  computed_fixed_point (=) (fun x -> x *. 10.) 5. = infinity
let my_computed_fixed_point_test2 =
  computed_fixed_point (<) (fun x -> x - 10) 15 = 15


type awksub_nonterminals =
  | Verb | Noun | Adj | Adv
let my_find_nonterminals_test0 = 
  equal_sets (find_nonterminals [N Verb; T "1"]) [Verb]
let my_find_nonterminals_test1 =
  equal_sets (find_nonterminals [T "man"; T "0"]) []
let my_find_nonterminals_test2 = 
  equal_sets (find_nonterminals [N Verb; N Noun; N Adj]) [Verb; Noun; Adj]

let rules = 
[ Noun, [T":"; N Noun; T" "; N Verb];
  Noun, [T" "; N Adj];
  Verb, [T"."];
  Verb, [T" "; N Adv];
  Adj, [N Adj];
  Adj, [N Noun];
  Adv, [T"ly"]]

let grammar = Noun, rules

let my_nonterminals_list_test0 = 
  equal_sets (nonterminals_list Noun rules) [Noun; Verb; Adj]
let my_nonterminals_list_test1 =
  equal_sets (nonterminals_list Adv rules) []

let my_remove_duplicates_test0 =
  equal_sets (remove_duplicates [1;1;1;2;3;3]) [1;2;3]
let my_remove_duplicates_test1 =
  equal_sets (remove_duplicates []) []

let my_reachable_nonterminals_test0 = 
  equal_sets (reachable_nonterminals [Noun] rules []) [Verb; Adj; Noun; Adv]
let my_reachable_nonterminals_test1 =
  equal_sets (reachable_nonterminals [Verb] rules []) [Adv; Verb]

let my_filter_reachable_rules_test0 = 
  equal_sets (filter_reachable_rules Noun rules rules) rules 
let my_filter_reachable_rules_test1 =
  equal_sets (filter_reachable_rules Adv rules rules) [Adv, [T"ly"]]

let my_filter_reachable_test0 = 
  filter_reachable grammar = grammar
let my_filter_reachable_test1 = 
  filter_reachable (Verb, rules) = 
    (Verb,
     [ Verb, [T"."];
       Verb, [T" "; N Adv];
       Adv, [T"ly"]])
