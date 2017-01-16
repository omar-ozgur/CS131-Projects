let my_subset_test0 = subset [] ["a";"b";"c"] = true
let my_subset_test1 = subset [0] [1;2;3] = false
let my_subset_test2 = subset ["a";"c";"d"] ["a";"b";"c";"d";"e"] = true

let my_equal_sets_test0 = equal_sets [] [] = true
let my_equal_sets_test1 = equal_sets [1;1;2;2;3;3;4;5] [1;1;1;2;3;4;5] = true
let my_equal_sets_test2 = equal_sets [1;2;3] [1;3;3] = false

let my_set_union_test0 = equal_sets (set_union [1;2;3] [4;5]) [1;2;3;4;5] = true
let my_set_union_test1 = equal_sets (set_union [] []) [] = true
let my_set_union_test2 = equal_sets (set_union [1;2;3;4;5] [1;1;3;3;5;5]) [1;2;3;4;5] = true

let my_set_intersection_test0 = equal_sets (set_intersection [1;1;2;3] [1;3]) [1;3] = true
let my_set_intersection_test1 = equal_sets (set_intersection [1;3;5] [2;4;6]) [] = true
let my_set_intersection_test2 = equal_sets (set_intersection [] ["a";"b";"c"]) [] = true

let my_set_diff_test0 = equal_sets (set_diff [1;2;3;4;5] [2;4]) [1;3;5] = true
let my_set_diff_test1 = equal_sets (set_diff ["a";"a";"b";"c";"c"] ["b";"b"]) ["a";"c"] = true
let my_set_diff_test2 = equal_sets (set_diff [1;2;3] []) [1;2;3] = true

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> (x * x) - x - 3) 2 = -1
let my_computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> (x * x) - x - 3) 3 = 3
let my_computed_fixed_point_test2 = computed_fixed_point (=) (fun x -> (x * x * x) - (x * x) - (11 * x)) 63 = -3

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> 1 - (x * x)) 2 31 = 1
let my_computed_periodic_point_test1 = computed_periodic_point (=) (fun x -> x *. x) 0 2. = 2.
let my_computed_periodic_point_test2 = computed_periodic_point (=) (fun x -> (2 * x) - 5) 3 31 = 5

let my_while_away_test0 = while_away (fun x -> x * x) ((>) 100) 2 = [2;4;16]
let my_while_away_test1 = while_away (fun x -> x - 1) ((<) ~-5) 1 = [1;0;-1;-2;-3;-4]
let my_while_away_test2 = while_away (fun x -> x + 2) ((=) 4) 4 = [4]

let my_rle_decode_test0 = rle_decode [(3,"a")] = ["a";"a";"a"]
let my_rle_decode_test1 = rle_decode [(0,1);(1,2);(2,3)] = [2;3;3]
let my_rle_decode_test2 = rle_decode [] = []

type nonterminals =
  | Punctuation | Char | Word | Sentence | Chapter | Book | Series

let grammar =
  Book,
  [Punctuation, [T"."];
   Punctuation, [T"!"];
   Char, [T"a"];
   Char, [T"b"];
   Word, [N Char];
   Word, [N Char; N Char];
   Sentence, [N Word; N Punctuation];
   Sentence, [N Word; T" "; N Sentence];
   Chapter, [N Sentence];
   Chapter, [N Sentence; T" "; N Chapter];
   Book, [N Chapter];
   Book, [N Chapter; T" "; N Book];
   Book, [N Series; N Book];
   Series, [N Series; N Book];
   Series, [N Book; N Series]]

let my_filter_blind_alleys_test0 = filter_blind_alleys (Book, List.tl (snd grammar)) =
   (Book,
   [(Punctuation, [T "!"]); (Char, [T "a"]); (Char, [T "b"]);
    (Word, [N Char]); (Word, [N Char; N Char]);
    (Sentence, [N Word; N Punctuation]);
    (Sentence, [N Word; T " "; N Sentence]); (Chapter, [N Sentence]);
    (Chapter, [N Sentence; T " "; N Chapter]); (Book, [N Chapter]);
    (Book, [N Chapter; T " "; N Book])])

let my_filter_blind_alleys_test1 = filter_blind_alleys (Book, List.tl (List.tl (snd grammar))) =
   (Book,
   [(Char, [T "a"]); (Char, [T "b"]); (Word, [N Char]);
    (Word, [N Char; N Char])])

let my_filter_blind_alleys_test1 = filter_blind_alleys (Book, List.tl (List.tl (List.tl (List.tl (snd grammar))))) =
   (Book, [])
