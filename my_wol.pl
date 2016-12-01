%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PART 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%% TEST_STRATEGY
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% test_strategy/3

% test_strategy/3 calls a helper function test_strategy/11 
% which helps store encountered data

% Prints to the screen statistics about NumGames games of War of Life played 
% with specific strategies for both players

test_strategy(NumGames, P1Strategy, P2Strategy) :-
    test_strategy(NumGames, NumGames, P1Strategy, P2Strategy, 
              0, 0, 0, 0, 0, 0, 0).


%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% test_strategy/11

% test_strategy/11 is a helper function called by test_strategy/3
% It is a recursive function which stores data about the played games

% Base case, when number of games left to play is 0
% We then print out the collected data

test_strategy(0, TotalGames, _, _, NumDraws, NumP1Wins, NumP2Wins, LongestGame,
              ShortestGame, TotalLength, TotalTime) :-

    format('Number of Draws: ~w draws~n~n', [NumDraws]),
    format('Number of P1 Wins: ~w wins~n~n', [NumP1Wins]),
    format('Number of P2 Wins: ~w wins~n~n', [NumP2Wins]),
    format('Longest Game: ~w moves~n~n', [LongestGame]),
    format('Shortest Game: ~w moves~n~n', [ShortestGame]),
    AverageTime is TotalTime/TotalGames,
    AverageLength is TotalLength/TotalGames,
    format('Average Moves: ~w moves~n~n', [AverageLength]),
    format('Average Time: ~w ms~n~n', [AverageTime]).
    


test_strategy(NumGames, TotalGames, P1Strategy, P2Strategy, NumDraws, NumP1Wins, 
              NumP2Wins, LongestGame, ShortestGame, TotalLength, TotalTime) :-

% Using statistics library to calculate length of a game
    statistics(walltime, [Start,_]),
    play(quiet, P1Strategy, P2Strategy, NumMoves, Result),
    statistics(walltime, [End,_]),
    GameTime is End - Start,

% Decrementing number of games left to play
    NewNumGames is NumGames - 1,

% If the current Shortest Time is 0 (initial value) or larger than the new 
% recorded game time, then it takes the new recorded game time as new value
    (NumMoves < ShortestGame -> NewShortestGame is NumMoves; 
     ShortestGame = 0        -> NewShortestGame is NumMoves;
     NewShortestGame is ShortestGame),

% TotalLength and TotalTime are accumulators for game length and game time.
% We will divide them by the total number of games played when we reach 
% the base case, to calculate averages.
    NewTotalLength is TotalLength + NumMoves,
    NewTotalTime is TotalTime + GameTime,

% We check the result of each game and update the data accordingly
    (Result = 'draw'      -> NewNumDraws is NumDraws + 1,
                            (NumMoves > LongestGame -> 
                             NewLongestGame is NumMoves; 
                             NewLongestGame is LongestGame),
                             test_strategy(NewNumGames, TotalGames, P1Strategy, 
                                           P2Strategy, NewNumDraws, NumP1Wins, 
                                           NumP2Wins, NewLongestGame, 
                                           NewShortestGame, NewTotalLength, 
                                           NewTotalTime);

     Result = 'stalemate' -> NewNumDraws is NumDraws + 1,
                            (NumMoves > LongestGame -> 
                             NewLongestGame is NumMoves; 
                             NewLongestGame is LongestGame),
                             test_strategy(NewNumGames, TotalGames, P1Strategy, 
                                           P2Strategy, NewNumDraws, NumP1Wins, 
                                           NumP2Wins, NewLongestGame, 
                                           NewShortestGame, NewTotalLength, 
                                           NewTotalTime);

     Result = 'b'         -> NewNumP1Wins is NumP1Wins + 1,
                            (NumMoves > LongestGame -> 
                             NewLongestGame is NumMoves; 
                             NewLongestGame is LongestGame),
                             test_strategy(NewNumGames, TotalGames, P1Strategy, 
                                           P2Strategy, NumDraws, NewNumP1Wins, 
                                           NumP2Wins, NewLongestGame, 
                                           NewShortestGame, NewTotalLength, 
                                           NewTotalTime);

     Result = 'r'         -> NewNumP2Wins is NumP2Wins + 1,
                            (NumMoves > LongestGame -> 
                             NewLongestGame is NumMoves; 
                             NewLongestGame is LongestGame),
                             test_strategy(NewNumGames, TotalGames, P1Strategy, 
                                           P2Strategy, NumDraws, NumP1Wins, 
                                           NewNumP2Wins, NewLongestGame, 
                                           NewShortestGame, NewTotalLength, 
                                           NewTotalTime);

     NewNumDraws is NumDraws + 1,
     test_strategy(NewNumGames, TotalGames, P1Strategy, P2Strategy, 
                   NewNumDraws, NumP1Wins, NumP2Wins, LongestGame, 
                   NewShortestGame, NewTotalLength, NewTotalTime)).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PART 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% find_possible_moves/3
% Returns the list of possible moves given a player's pieces and his opponents' pieces

find_possible_moves(FriendlyPieces, OpponentPieces, PossMoves) :-
	findall([R1,C1,R2,C2], (member([R1,C1], FriendlyPieces),
                                neighbour_position(R1,C1,[R2,C2]),
                                \+member([R2,C2], FriendlyPieces),
                                \+member([R2,C2], OpponentPieces)),
        PossMoves).

%%%%%%%%%%%%%%%%%%%%%%% BLOODLUST
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% bloodlust/4
% Returns the best move and new board state after a player uses the bloodlust strategy

bloodlust('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], Move) :-
    find_possible_moves(AliveBlues, AliveReds, PossMoves),
    find_best_move_bloodlust('b', [AliveBlues, AliveReds], Move, [], 65, PossMoves),
    alter_board(Move, AliveBlues, NewAliveBlues).
    
bloodlust('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], Move) :-
    find_possible_moves(AliveReds, AliveBlues, PossMoves),
    find_best_move_bloodlust('r', [AliveBlues, AliveReds], Move, [], 65, PossMoves),
    alter_board(Move, AliveReds, NewAliveReds).


%%%%%%%%%%%%%%%%% find_best_move_bloodlust/6
% Returns the best move to be played by a player using the bloodlust strategy
    
find_best_move_bloodlust(_, _, BestMove, BestMove, _, []).

find_best_move_bloodlust('b', [AliveBlues, AliveReds], BestMove, M, NumReds, [Move|Moves]) :-
    get_number_opp_pieces_after_move('b', AliveBlues, AliveReds, Move, N),
    (N < NumReds -> 
       find_best_move_bloodlust('b', [AliveBlues, AliveReds], BestMove, Move, N, Moves);
     find_best_move_bloodlust('b', [AliveBlues, AliveReds], BestMove, M, NumReds, Moves)).


find_best_move_bloodlust('r', [AliveBlues, AliveReds], BestMove, M, NumBlues, [Move|Moves]) :-
    get_number_opp_pieces_after_move('r', AliveBlues, AliveReds, Move, N),
    (N < NumBlues -> 
       find_best_move_bloodlust('r', [AliveBlues, AliveReds], BestMove, Move, N, Moves);
     find_best_move_bloodlust('r', [AliveBlues, AliveReds], BestMove, M, NumBlues, Moves)).


%%%%%%%%%%%%%%%%% get_number_opp_pieces_after_move/5
% Returns the number of opponent pieces on the board after a move

get_number_opp_pieces_after_move('b', AliveBlues, AliveReds, Move, N) :-
	alter_board(Move, AliveBlues, NewAliveBlues),
    next_generation([NewAliveBlues, AliveReds], [_, NextReds]),
	length(NextReds, N).

get_number_opp_pieces_after_move('r', AliveBlues, AliveReds, Move, N):-
    alter_board(Move, AliveReds, NewAliveReds),
    next_generation([AliveBlues, NewAliveReds], [NextBlues, _]),
    length(NextBlues, N).


%%%%%%%%%%%%%%%%%%%%%%% SELF_PRESERVATION
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% self_preservation/4
% Returns the best move and new board state after a player uses the self_preservation strategy

self_preservation('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], Move) :-
    find_possible_moves(AliveBlues, AliveReds, PossMoves),
    find_best_move_self_preservation('b', [AliveBlues, AliveReds], Move, [], -1, PossMoves),
    alter_board(Move, AliveBlues, NewAliveBlues).
    
self_preservation('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], Move) :-
    find_possible_moves(AliveReds, AliveBlues, PossMoves),    
    find_best_move_self_preservation('r', [AliveBlues, AliveReds], Move, [], -1, PossMoves),
    alter_board(Move, AliveReds, NewAliveReds).


%%%%%%%%%%%%%%%%% find_best_move_self_preservation/6
% Returns the best move to be played by a player using the self_preservation strategy

find_best_move_self_preservation(_, _, BestMove, BestMove, _, []).

find_best_move_self_preservation('b', [AliveBlues, AliveReds], BestMove, M, NumBlues, [Move|Moves]) :-
    get_number_friendly_pieces_after_move('b', AliveBlues, AliveReds, Move, N),
    (N > NumBlues -> 
       find_best_move_self_preservation('b', [AliveBlues, AliveReds], BestMove, Move, N, Moves);
     find_best_move_self_preservation('b', [AliveBlues, AliveReds], BestMove, M, NumBlues, Moves)).


find_best_move_self_preservation('r', [AliveBlues, AliveReds], BestMove, M, NumReds, [Move|Moves]) :-
    get_number_friendly_pieces_after_move('r', AliveBlues, AliveReds, Move, N),
    (N > NumReds -> 
       find_best_move_self_preservation('r', [AliveBlues, AliveReds], BestMove, Move, N, Moves);
     find_best_move_self_preservation('r', [AliveBlues, AliveReds], BestMove, M, NumReds, Moves)).


%%%%%%%%%%%%%%%%% get_number_friendly_pieces_after_move/5
% Returns the number of friendly pieces on the board after a move

get_number_friendly_pieces_after_move('b', AliveBlues, AliveReds, Move, N) :-
    alter_board(Move, AliveBlues, NewAliveBlues),
    next_generation([NewAliveBlues, AliveReds], [NextBlues, _]),
    length(NextBlues, N).

get_number_friendly_pieces_after_move('r', AliveBlues, AliveReds, Move, N) :-
    alter_board(Move, AliveReds, NewAliveReds),
    next_generation([AliveBlues, NewAliveReds], [_, NextReds]),
    length(NextReds, N).


%%%%%%%%%%%%%%%%%%%%%%% LAND_GRAB
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% land_grab/4
% Returns the best move and new board state after a player uses the land_grab strategy

land_grab('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], Move) :-
    find_possible_moves(AliveBlues, AliveReds, PossMoves),
    find_best_move_land_grab('b', [AliveBlues, AliveReds], Move, [], -65, PossMoves),
    alter_board(Move, AliveBlues, NewAliveBlues).
    
land_grab('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], Move) :-
    find_possible_moves(AliveReds, AliveBlues, PossMoves),    
    find_best_move_land_grab('r', [AliveBlues, AliveReds], Move, [], -65, PossMoves),
    alter_board(Move, AliveReds, NewAliveReds).


%%%%%%%%%%%%%%%%% find_best_move_land_grab/6
% Returns the best move to be played by a player using the land_grab strategy

find_best_move_land_grab(_, _, BestMove, BestMove, _, []).

find_best_move_land_grab('b', [AliveBlues, AliveReds], BestMove, M, Diff, [Move|Moves]) :-
    get_diff_after_move('b', AliveBlues, AliveReds, Move, NewDiff),
    (NewDiff > Diff -> 
       find_best_move_land_grab('b', [AliveBlues, AliveReds], BestMove, Move, NewDiff, Moves);
     find_best_move_land_grab('b', [AliveBlues, AliveReds], BestMove, M, Diff, Moves)).


find_best_move_land_grab('r', [AliveBlues, AliveReds], BestMove, M, Diff, [Move|Moves]) :-
    get_diff_after_move('r', AliveBlues, AliveReds, Move, NewDiff),
    (NewDiff > Diff -> 
       find_best_move_land_grab('r', [AliveBlues, AliveReds], BestMove, Move, NewDiff, Moves);
     find_best_move_land_grab('r', [AliveBlues, AliveReds], BestMove, M, Diff, Moves)).


%%%%%%%%%%%%%%%%% get_diff_after_move/5
% Returns the difference between friendly pieces and opponent pieces on the board after a move

get_diff_after_move('b', AliveBlues, AliveReds, Move, Diff) :-
    alter_board(Move, AliveBlues, NewAliveBlues),
    next_generation([NewAliveBlues, AliveReds], [NextBlues, NextReds]),
    length(NextBlues, B),
    length(NextReds, R),
    Diff is B - R.

get_diff_after_move('r', AliveBlues, AliveReds, Move, Diff) :-
    alter_board(Move, AliveReds, NewAliveReds),
    next_generation([AliveBlues, NewAliveReds], [NextBlues, NextReds]),
    length(NextBlues, B),
    length(NextReds, R),
    Diff is R - B.


%%%%%%%%%%%%%%%%%%%%%%% MINIMAX
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% minimax/4
% Returns the best move and new board state after a player uses the minimax strategy

minimax('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], Move) :-
    find_possible_moves(AliveBlues, AliveReds, PossMoves),
    find_best_move_minimax('b', [AliveBlues, AliveReds], Move, [], 65, PossMoves),
    alter_board(Move, AliveBlues, NewAliveBlues).
    
minimax('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], Move) :-
    find_possible_moves(AliveReds, AliveBlues, PossMoves),    
    find_best_move_minimax('r', [AliveBlues, AliveReds], Move, [], 65, PossMoves),
    alter_board(Move, AliveReds, NewAliveReds).

    
%%%%%%%%%%%%%%%%% find_best_move_minimax/6
% Returns the best move for a player using the minimax strategy

find_best_move_minimax(_, _, BestMove, BestMove, _, []).

find_best_move_minimax('b', [AliveBlues, AliveReds], BestMove, M, Diff, [Move|Moves]) :-
    alter_board(Move, AliveBlues, NewAliveBlues),
    next_generation([NewAliveBlues, AliveReds], [NextBlues, NextReds]),
    find_best_land_grab_score('r', [NextBlues, NextReds], NewDiff),
    (NewDiff < Diff -> 
       find_best_move_minimax('b', [AliveBlues, AliveReds], BestMove, Move, NewDiff, Moves);
     find_best_move_minimax('b', [AliveBlues, AliveReds], BestMove, M, Diff, Moves)).


find_best_move_minimax('r', [AliveBlues, AliveReds], BestMove, M, Diff, [Move|Moves]) :-
    alter_board(Move, AliveReds, NewAliveReds),
    next_generation([AliveBlues, NewAliveReds], [NextBlues, NextReds]),
    find_best_land_grab_score('b', [NextBlues, NextReds], NewDiff),
    (NewDiff < Diff -> 
       find_best_move_minimax('r', [AliveBlues, AliveReds], BestMove, Move, NewDiff, Moves);
     find_best_move_minimax('r', [AliveBlues, AliveReds], BestMove, M, Diff, Moves)).


%%%%%%%%%%%%%%% find_best_land_grab_score/2
% Returns the best "land grab" score a player can obtain of the next turn.

find_best_land_grab_score('b', [AliveBlues, AliveReds], Diff) :-
    find_possible_moves(AliveBlues, AliveReds, PossMoves),
    find_best_diff_land_grab('b', [AliveBlues, AliveReds], Diff, -65, PossMoves).

find_best_land_grab_score('r', [AliveBlues, AliveReds], Diff) :-
    find_possible_moves(AliveReds, AliveBlues, PossMoves),
    find_best_diff_land_grab('r', [AliveBlues, AliveReds], Diff, -65, PossMoves).


%%%%%%%%%%%%%%% find_best_diff_land_grab/6
% Given a set of possible moves, returns the best "land grab" score obtainable.

find_best_diff_land_grab(_, _, BestDiff, BestDiff, []).

find_best_diff_land_grab('b', [AliveBlues, AliveReds], BestDiff, Diff, [Move|Moves]) :-
    get_diff_after_move('b', AliveBlues, AliveReds, Move, NewDiff),
    (NewDiff > Diff -> 
       find_best_diff_land_grab('b', [AliveBlues, AliveReds], BestDiff, NewDiff, Moves);
     find_best_diff_land_grab('b', [AliveBlues, AliveReds], BestDiff, Diff, Moves)).

find_best_diff_land_grab('r', [AliveBlues, AliveReds], BestDiff, Diff, [Move|Moves]) :-
    get_diff_after_move('r', AliveBlues, AliveReds, Move, NewDiff),
    (NewDiff > Diff -> 
       find_best_diff_land_grab('r', [AliveBlues, AliveReds], BestDiff, NewDiff, Moves);
     find_best_diff_land_grab('r', [AliveBlues, AliveReds], BestDiff, Diff, Moves)).


    
    
    
