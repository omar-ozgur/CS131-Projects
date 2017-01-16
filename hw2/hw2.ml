type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

(* convert_grammar: Converts hw1-style grammer to hw2-style grammar
   get_alt_list: Takes a non-terminal symbol and returns a list that contains the lists of symbols
     corresponding to that symbol in the given rules *)
let convert_grammar gram1 = 
  let rec get_alt_list rules symbol = match rules with
    | [] -> []
    | head_rule::tail_rules -> match head_rule with
      | lhs, rhs -> if lhs = symbol then rhs::(get_alt_list tail_rules symbol) else get_alt_list tail_rules symbol
  in fst gram1, get_alt_list (snd gram1);;

(* parse_prefix: Returns a matcher for the given grammar that returns the first acceptable match
     of a prefix of the given fragment
   find_match: A helper function that checks if an acceptable derivation can be found for a
     fragment with a specific alternative list
   symbol_list_matcher: A helper function that checks if there is an acceptable match for a fragment
     based on a provided list of symbols *)
let parse_prefix gram = 
  let production_function = snd gram
  in let rec symbol_list_matcher symbols accept derivation frag = match symbols with
    | [] -> accept derivation frag
    | head_symbol::tail_symbols -> if frag = [] then None else match head_symbol with
      | N symbol -> find_match symbol (production_function symbol) derivation (symbol_list_matcher tail_symbols accept) frag
      | T symbol -> if (List.hd frag) = symbol then symbol_list_matcher tail_symbols accept derivation (List.tl frag) else None
  and find_match symbol alt_list derivation accept frag = match alt_list with
    | [] -> None
    | alt_list_head::alt_list_tail -> match symbol_list_matcher alt_list_head accept (derivation @ [symbol, alt_list_head]) frag with
      | None -> find_match symbol alt_list_tail derivation accept frag
      | element -> element
  in find_match (fst gram) (production_function (fst gram)) [];;
