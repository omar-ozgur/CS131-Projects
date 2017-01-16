% A valid 'encoding' is a list of 'tuples' where each 'tuple' contains the count of each character in order

% An empty list has an empty encoding
encoding([], []).

% A single character has only 1 instance
encoding([X], [[1, X]]).

% The head character has a valid count if the rest of the list has 1 less of that character at the beginning
encoding([HL|TL], [[Count, HL]|TE]):- encoding(TL, [[SubCount, HL]|TE]), succ(SubCount, Count).

% The head character has a count of 1 if the next character is different
encoding([HL|TL], [[1, HL], [Count, X]|TE]):- encoding(TL, [[Count, X]|TE]), HL \= X.



% A 'translation' correlates a count of a specific character to a morse code character

% An empty encoding has an empty translation
translation([], []).

% Various numbers of '1's have various translations
translation([[1, 1]|TE], ['.'|TT]):- translation(TE, TT).
translation([[2, 1]|TE], ['.'|TT]):- translation(TE, TT).
translation([[2, 1]|TE], ['-'|TT]):- translation(TE, TT).
translation([[3, 1]|TE], ['-'|TT]):- translation(TE, TT).
translation([[N, 1]|TE], ['-'|TT]):- N > 3, translation(TE, TT).

% Various numbers of '0's have various translations
translation([[1, 0]|TE], T):- translation(TE, T).
translation([[2, 0]|TE], T):- translation(TE, T).
translation([[2, 0]|TE], ['^'|TT]):- translation(TE, TT).
translation([[3, 0]|TE], ['^'|TT]):- translation(TE, TT).
translation([[4, 0]|TE], ['^'|TT]):- translation(TE, TT).
translation([[5, 0]|TE], ['^'|TT]):- translation(TE, TT).
translation([[5, 0]|TE], ['#'|TT]):- translation(TE, TT).
translation([[N, 0]|TE], ['#'|TT]):- N > 5, translation(TE, TT).



% 'signal_morse' correlates a list of characters to a valid morse code representation

% An empty list of characters corresponds to an empty morse code
signal_morse([], []).

% A non-empty morse code corresponds to a message if the translation
% of the message is a valid encoding
signal_morse(L, M):- L \= [], encoding(L, E), !, translation(E, M).



% 'morse' correlates characters to sets of morse code characters

morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)



% 'message' correlates morse code and an accumulator to a valid message

% Empty morse code corresponds to the message based on the accumulated characters
% If the morse code starts with '#' or '^', add characters to the message based on the accumulator
% If the morse code doesn't start with '#' or '^', append to the accumulator
message([], [], []).
message([], A, [M]):- morse(M, A), A \= [].
message(['#'|TMO], [], ['#'|TME]):- message(TMO, [], TME).
message(['#'|TMO], A, [HME,'#'|TME]):- morse(HME, A), message(TMO, [], TME).
message(['^'|TMO], [], TME):- message(TMO, [], TME).
message(['^'|TMO], A, [HME|TME]):- morse(HME, A), message(TMO, [], TME).
message([HMO|TMO], A, ME):- append(A, [HMO], B), message(TMO, B, ME).



% 'clean' correlates a message and an accumulator to a version of the message without error words
% I used the assumption that an error token can be a part of a word, and can be removed by other errors
% An empty message corresponds to the message that was accumulated
% A message consisting only of an 'error' has no corresponding message
% A message starting with a '#' character corresponds to a message that starts with the accumulated characters
% A message starting with an error corresponds to a message without the accumulated characters if the next character is not an error
% A message that doesn't start with an error or '#' character just appends to the accumulator and cleans the rest of the message
clean([], [], []).
clean([], A, A):- A \= [].
clean([error], _, []).
clean(['#'|TME], [], ['#'|TM]):- clean(TME, [], TM).
clean(['#'|TME], [HA|TA], [HA|TM]):- clean(['#'|TME], TA, TM), [HA|TA] \= [].
clean([error,X|TME], A, TM):- clean([X|TME], [], TM), A \= [], X \= error.
clean([error,error|TME], A, TM):- append(A, [error], B), clean([error|TME], B, TM), A \= [].
clean([HME|TME], [], TM):- clean(TME, [HME], TM).
clean([HME|TME], A, TM):- append(A, [HME], B), clean(TME, B, TM), HME \= error, A \= [].



% 'signal_message' correlates a list of characters ('1's and '0's) to a valid message with error words removed

% An empty list of characters corresponds to an empty message
signal_message([], []).

% A non-empty list corresponds to the cleaned message that is based on the morse code translation
signal_message(L, M):- L \= [], signal_morse(L, MO), once(message(MO, [], ME)), once(clean(ME, [], M)).
