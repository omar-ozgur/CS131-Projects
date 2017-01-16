type book_nonterminals =
  | Punctuation | Char | Word | Sentence | Chapter | Book

let book_grammar =
  Book, function
    | Book -> [[N Chapter]; [N Book; T" "; N Chapter]]
    | Chapter -> [[N Sentence]; [N Chapter; T" "; N Sentence]]
    | Sentence -> [[N Word; N Punctuation]; [N Word; T" "; N Sentence]]
    | Word -> [[N Char]; [N Word; N Char]]
    | Char -> [[T"a"]; [T"b"]; [T"c"]; [T""]]
    | Punctuation -> [[T"."]; [T"!"]; [T""]]

let rec contains_empty_punctuation = function
  | [] -> false
  | (Punctuation, [T""])::_ -> true
  | _::rules -> contains_empty_punctuation rules

let accept_only_non_empty_punctuation rules frag =
  if contains_empty_punctuation rules then None else Some (rules, frag)

(* Ignore a certain terminal symbol that is given in a symbol's production function output (Ex: ignore the empty
   string even through it's part of 'Punctuation' in this case) *)
let test_1 = (parse_prefix book_grammar) accept_only_non_empty_punctuation ["a"; ""; "b"; "c"; "!"; " "; "a"; "."] =
  Some
   ([(Book, [N Chapter]); (Chapter, [N Sentence]);
     (Sentence, [N Word; N Punctuation]); (Word, [N Word; N Char]);
     (Word, [N Word; N Char]); (Word, [N Word; N Char]); (Word, [N Char]);
     (Char, [T "a"]); (Char, [T ""]); (Char, [T "b"]); (Char, [T "c"]);
     (Punctuation, [T "!"])],
    [" "; "a"; "."])

type sentence_nonterminals =
  | Sentence | NP | Article | Noun | Verb | Conj | Adj

let sentence_grammar =
  Sentence, function
    | Sentence -> [[N NP; N Verb]; [N NP; N Verb; N Conj; N Sentence]]
    | NP -> [[N Article; N Noun]; [N Article; N Adj; N Noun]]
    | Article -> [[T"the"]; [T"a"]]
    | Noun -> [[T"man"]; [T"woman"]; [T"boy"]; [T"girl"]]
    | Verb -> [[T"laughed"]; [T"played"]; [T"cried"]]
    | Adj -> [[T"tall"]; [T"short"]; [T"happy"]; [T"sad"]]
    | Conj -> [[T"and"]; [T"while"]]

let rec contains_conjunction = function
  | [] -> false
  | (Conj, _)::_ -> true
  | _::rules -> contains_conjunction rules

let accept_only_with_conjunctions rules frag =
  if contains_conjunction rules then Some (rules, frag) else None

(* Only output derivations that include a specific symbol ('Conj' in this case) *)
let test_2 = (parse_prefix sentence_grammar) accept_only_with_conjunctions ["the"; "happy"; "man"; "laughed"; "while"; "the"; "boy"; "cried"] =
  Some
   ([(Sentence, [N NP; N Verb; N Conj; N Sentence]);
     (NP, [N Article; N Adj; N Noun]); (Article, [T "the"]);
     (Adj, [T "happy"]); (Noun, [T "man"]); (Verb, [T "laughed"]);
     (Conj, [T "while"]); (Sentence, [N NP; N Verb]);
     (NP, [N Article; N Noun]); (Article, [T "the"]); (Noun, [T "boy"]);
     (Verb, [T "cried"])],
    [])

