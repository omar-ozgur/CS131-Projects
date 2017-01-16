(* Filter the first list so that it only includes elements that exist in the second list. Check if
   this is the same as the original first list *)
let subset a b = List.filter (fun x -> List.exists (fun y -> x = y) b) a = a;;

(* Two sets are equal if they are subsets of each other *)
let equal_sets a b = subset a b && subset b a;;

(* Since duplicate elements are allowed in a list that represents a set, the union of two lists
   that represent tests is equal to the two lists combined *)
let set_union a b = a @ b;;

(* Filter the first list so that it only includes elements that exist in the second list *)
let set_intersection a b = List.filter (fun x -> List.exists (fun y -> x = y) b) a;;

(* Filter the first list so that it does not include elements that exist in the second list *)
let set_diff a b = List.filter (fun x -> not (List.exists (fun y -> x = y) b)) a;;

(* If x = f(x), return x. Otherwise if f(x) = f(f(x)), return f(x). Continue recursively until a
   fixed point is found *)
let rec computed_fixed_point eq f x = if eq (f x) x then x else computed_fixed_point eq f (f x);;

(* Change eq so that it compares x to the value of x with f applied p times. Then use this eq
   function to check x, f(x), ... until this value equals the value with f applied p times. *)
let rec computed_periodic_point eq f p x =
  if p > 0 then computed_periodic_point (fun x y -> eq (f x) y) f (p - 1) x else
  if eq x x then x else computed_periodic_point eq f p (f x);;

(* Append x, s x, s (s x), ... to a list until one of these values returns false when p is
   applied *)
let rec while_away s p x = if p x then x::(while_away s p (s x)) else [];;

(* If the integer associated with a value is greater than 0, add that element to the list that
   is created when (integer - 1) is associated with the value. Otherwise, skip the value and
   return a list that is created with the remaining pairs of integers and values *)
let rec rle_decode lp = match lp with
  | [] -> []
  | (n, v)::t -> if n > 0 then v::(rle_decode ((n - 1, v)::t)) else rle_decode t;;

(* Define terminal and nonterminal symbols *)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

(* filter_blind_alleys: Filter the given list of rules so that only rules that eventually terminate
     will remain. A helper function (terminal_rules_builder) is used to find rules that eventually
     terminate. The helper function stops being run when it no longer produces different lists of
     rules that terminate (accomplished by using computed_fixed_point). This function returns a
     tuple containing the starting symbol and a list of rules that eventually terminate
   terminal_rules_builder: A helper function that determines if any new rules should be added to a
     list of rules that terminate. This is done by utilizing another helper function (terminates)
     to check if a list of symbols causes a rule to eventually terminate. The function returns a
     list of rules that eventually terminate
   terminates: A helper function that checks each symbol in a list of symbols to see if a rule
     terminates based on existing knowledge. If a symbol is nonterminal, and the symbol does not
     exist in the current list of rules that terminate, then the function returns false since it
     is not clear if the rule terminates. Otherwise, the function returns true since we now know
     that the rule terminates based on prior knowledge *)
let filter_blind_alleys g =
  let rec terminates symbols terminalRules = match symbols with
    | [] -> true
    | headSymbol::tailSymbols -> match headSymbol with
      | T headSymbol -> terminates tailSymbols terminalRules
      | N headSymbol -> if List.exists (fun terminalRule -> (fst terminalRule) = headSymbol) terminalRules then terminates tailSymbols terminalRules else false in
  let rec terminal_rules_builder rules terminalRules = match rules with
    | [] -> terminalRules
    | headRule::tailRules -> if List.exists (fun terminalRule -> headRule = terminalRule) terminalRules then terminal_rules_builder tailRules terminalRules else
      if terminates (snd headRule) terminalRules then headRule::(terminal_rules_builder rules (headRule::terminalRules)) else terminal_rules_builder tailRules terminalRules in
  (fst g, List.filter (fun originalRule -> List.exists (fun terminalRule -> originalRule = terminalRule) (computed_fixed_point (=) (terminal_rules_builder (snd g)) [])) (snd g));;
