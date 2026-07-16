-module(sudoku).
-export([find_empty/1, solve/1, print_board/1, empty_cells/1]).

find_empty(Board) ->
    find_empty(Board, 1).

find_empty([], _) ->
    none;

find_empty([Row | Rest], RowIndex) ->
    case find_empty_in_row(Row, 1) of
        {found, ColIndex} ->
            {RowIndex, ColIndex};

        not_found ->
            find_empty(Rest, RowIndex + 1)
    end.

find_empty_in_row([], _) ->
    not_found;

find_empty_in_row([0 | _], ColIndex) ->
    {found, ColIndex};

find_empty_in_row([_ | Rest], ColIndex) ->
    find_empty_in_row(Rest, ColIndex + 1).

empty_cells(Board) ->
    Coords = [{R, C} || R <- lists:seq(1, length(Board)),
                         C <- lists:seq(1, length(lists:nth(R, Board)))],
    lists:filter(
        fun({R, C}) -> get_cell(Board, R, C) =:= 0 end,
        Coords
    ).

%% That finds the emply spots, this retrieves the cell

get_cell(Board, Row, Col) ->
    lists:nth(Col, lists:nth(Row, Board)).

set_cell(Board, Row, Col, Val) ->
    OldRow = lists:nth(Row, Board),
    NewRow = replace_nth(Col, Val, OldRow),
    replace_nth(Row, NewRow, Board).

%% Guard:

replace_nth(N, Val, List) when N > 0, N =< length(List) ->
    lists:sublist(List, N - 1) ++ [Val] ++ lists:nthtail(N, List).

%% This checks validity 

valid(Board, Row, Col, Num) ->
    not lists:member(Num, lists:nth(Row, Board)) andalso
    not lists:member(Num, column_values(Board, Col)) andalso
    not lists:member(Num, box_values(Board, Row, Col)).

column_values(Board, Col) ->
    [lists:nth(Col, R) || R <- Board].

box_values(Board, Row, Col) ->
    BoxRowStart = ((Row - 1) div 3) * 3 + 1,
    BoxColStart = ((Col - 1) div 3) * 3 + 1,
    [get_cell(Board, R, C)
     || R <- lists:seq(BoxRowStart, BoxRowStart + 2),
        C <- lists:seq(BoxColStart, BoxColStart + 2)].





solve(Board) ->
    case find_empty(Board) of
        none ->
            {solved, Board};
        {Row, Col} ->
            try_numbers(Board, Row, Col, lists:seq(1, 9))
    end.

try_numbers(_Board, _Row, _Col, []) ->
    no_solution;

try_numbers(Board, Row, Col, [Num | Rest]) ->
    case valid(Board, Row, Col, Num) of
        true ->
            NewBoard = set_cell(Board, Row, Col, Num),
            case solve(NewBoard) of
                {solved, Solved} -> {solved, Solved};
                no_solution -> try_numbers(Board, Row, Col, Rest)
            end;
        false ->
            try_numbers(Board, Row, Col, Rest)
    end.

%% ---------- convenience: printing ----------

print_board(Board) ->
    lists:foreach(
        fun(Row) ->
            io:format("~p~n", [Row])
        end,
        Board
    ).
