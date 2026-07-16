-module(fibonacci).
-export([sequence/1]).

%% Generate a list of the first few (N?) Fibonacci numbers?
sequence(N) when N =< 0 -> [];
sequence(1) -> [0];
sequence(N) ->
    lists:reverse(sequence_tr(N - 2, [1, 0])).

%% Helper function using tail recursion
sequence_tr(0, Acc) -> Acc;
sequence_tr(Count, [A, B | _] = Acc) ->
    sequence_tr(Count - 1, [A + B | Acc]).
