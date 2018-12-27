Red [
    Title:  "Othello"
    Author: "Jonathan Huston"
    Needs:  View
    Deps:   Red 0.6.3
]

#include %/usr/local/lib/red/window.red

EMPTY: load %empty.png
PLAYER-1: load %black.png 
PLAYER-2: load %red.png
TURN: ["Black's turn" "Red's turn"]
WON: ["Black won!" "Red won!"]
DELAY: 0.0
INF: 10
NINF: -10

; internal representation of empty board
init-board: [[0 0 0 0 0 0 0 0] 
             [0 0 0 0 0 0 0 0]
             [0 0 0 0 0 0 0 0]
             [0 0 0 2 1 0 0 0]
             [0 0 0 1 2 0 0 0]
             [0 0 0 0 0 0 0 0]
             [0 0 0 0 0 0 0 0]
             [0 0 0 0 0 0 0 0]]


get-square-num: function [
    "Given row and column, returns square number"
    row col
] [
    (row - 1) * 8 + col
]


place-stone: function [
    "Place player's stone on square"
    player square
] [
    either (player = 1) [
        square/image: PLAYER-1
    ] [
        square/image: PLAYER-2
    ]
]


find-end: function [
    "Finds end stone for flipping"
    board player row col drow dcol
] [
    current-row: row + (2 * drow)
    current-col: col + (2 * dcol)
    forever [
        if any [(current-row < 1) (current-row > 8) (current-col < 1) (current-col > 8)] [break]
        stone: board/:current-row/:current-col
        if stone = player [return reduce [current-row current-col]]
        if stone = 0 [return reduce [none none]]
        current-row: current-row + drow
        current-col: current-col + dcol
    ]
    return reduce [none none]
]


flip-direction: function [
    "Flips stones in a given direction"
    board player row col drow dcol
] [
    if all [(drow = -1) (row < 3)] [exit]
    if all [(drow = 1) (row > 6)] [exit]
    if all [(dcol = -1) (col < 3)] [exit]
    if all [(dcol = 1) (col > 6)] [exit]
    if board/(row + drow)/(col + dcol) <> opponent player [exit]
    end: find-end board player row col drow dcol
    end-row: end/1
    end-col: end/2
    if all [end-row end-col] [
        current-row: row + drow
        current-col: col + dcol
        forever [
            if all [(current-row = end-row) (current-col = end-col)] [break]
            board/:current-row/:current-col: player
            square: get to-word rejoin ["square" form get-square-num current-row current-col]
            place-stone player square
            current-row: current-row + drow
            current-col: current-col + dcol
        ]
    ]
]


flip: function [
    "Given board, player, row, and column, flips stones"
    board player row col
] [
    flip-direction board player row col -1 0
    flip-direction board player row col 1 0
    flip-direction board player row col 0 -1
    flip-direction board player row col 0 1
    flip-direction board player row col -1 -1
    flip-direction board player row col -1 1
    flip-direction board player row col 1 -1
    flip-direction board player row col 1 1
]


update-board: function [
    "Given board, player, and square, updates board"
    board player square
] [
    move: square/extra
    col: (move - 1) % 8 + 1
    row: (move - 1) / 8 + 1
    board/:row/:col: player
    place-stone player square
    flip board player row col
]


opponent: function [player] [3 - player]


next-player: function [
    "Switches to next player, updating display"
    player
] [
    player: opponent player
    dialogue/text: rejoin [TURN/:player]
    player
]


winner?: function [
    "Given board, returns winning line if winner, else none"
    board   "Current board"
    player  "Current player"
] [
    winning-line: copy []
    repeat row 3 [
        if all [(board/:row/1 = player) (board/:row/2 = player) (board/:row/3 = player)] [
            append winning-line reduce [get-square-num row 1 get-square-num row 2 get-square-num row 3]
        ]
    ]
    repeat col 3 [
        if all [(board/1/:col = player) (board/2/:col = player) (board/3/:col = player)] [
            append winning-line reduce [get-square-num 1 col get-square-num 2 col get-square-num 3 col]
        ]
    ]
    if all [(board/1/1 = player) (board/2/2 = player) (board/3/3 = player)] [append winning-line [1 5 9]]
    if all [(board/1/3 = player) (board/2/2 = player) (board/3/1 = player)] [append winning-line [3 5 7]]
    if winning-line = [] [winning-line: none]
    winning-line
]


end-game: function [
    "Displays end-of-game dialogue"
    winning-line "Winning line, none if tie"
    player       "Last player"
] [
    exit
    again/enabled?: true
    computer-move/enabled?: false
    dialogue/font/color: red
    either winning-line [
        foreach square-num winning-line [
            square: get to-word rejoin ["square" form square-num]
            square/font/color: red
        ]
        dialogue/text: rejoin [WON/:player]
    ] [
        dialogue/text: "It's a tie!"
    ]
]


find-empty-squares: function [
    "Given board, returns array of empty square numbers"
    board
] [
    empty-squares: copy []
    repeat row 3 [repeat col 3 [if board/:row/:col = "" [append empty-squares get-square-num row col]]]
    empty-squares
]


evaluate: function [
    "Generates score for a given board"
    board player count 
    maximizing  "is this the maximizing player?"
    depth       "current depth of analysis"
    alpha beta  "alpha and beta values for pruning"
] [
    either maximizing [win: 1] [win: -1]
    if depth < 3 [win: win * 2]    ; choose sudden death over extended agony
    if winner? board player [return win]
    if count = 9 [return 0]
    score: second _minimax board (opponent player) count (not maximizing) depth alpha beta
]


_minimax: function [
    "Minimax helper function"
    board player count 
    maximizing  "is this the maximizing player?"
    depth       "current depth of analysis"
    alpha beta  "alpha and beta values for pruning"
] [
    possible-moves: find-empty-squares board
    either maximizing [best-score: NINF] [best-score: INF]
    foreach move possible-moves [
        test-board: copy/deep board
        update-board test-board player move
        score: evaluate test-board player (count + 1) maximizing (depth + 1) alpha beta
        if any [all [maximizing (score > best-score)] all [(not maximizing) (score < best-score)]] [
            best-move: move
            best-score: score
        ]
        either maximizing [alpha: max alpha best-score] [beta: min beta best-score]
        if alpha >= beta [break]
    ]
    reduce [best-move best-score]
]


minimax: function [
    "Given board, finds best move using minimax"
    board player count 
] [
    _minimax board player count true 0 NINF INF ; maximing depth alpha beta
]


play-square: function [
    "Places player's mark on selected square and checks for winner"
    square  
    /extern board player count
] [
    if all [(square/image = EMPTY) (not again/enabled?)] [
        update-board board player square
        count: count + 1
        winning-line: winner? board player
        either count = 60 [
            print "aaargh"
            end-game winning-line player
        ] [
            player: next-player player
        ]
    ]
]


computer-turn: function [
    "Generates computer move"
    /extern board player count
] [
    computer-move/enabled?: false
    view ttt
    forever [
        move: first minimax board player count
        square: get to-word rejoin ["square" form move]
        play-square square
        if count > 1 [wait DELAY]
        if any [(not computer-move/extra) again/enabled?] [break]
        view ttt
    ]
    if (not again/enabled?) [computer-move/enabled?: true]
]


init-ttt: does [
    ttt: copy [ 
        title "Othello"
        backdrop white
        pad 5x0
        do [dialogue-text: rejoin [TURN/:player]]
        dialogue: text 646x30 center font-color black bold font-size 16 dialogue-text
        return
        space -5x-6
    ]

    repeat square-num 64 [
        square-set-word: to-set-word rejoin ["square" form square-num ":"]
        init-square: EMPTY
        if any [(square-num = 29) (square-num = 36)] [init-square: PLAYER-1]
        if any [(square-num = 28) (square-num = 37)] [init-square: PLAYER-2]
        append ttt reduce [square-set-word 'button 82x82 init-square 'extra square-num [
            play-square face
            computer-move/extra: false  
        ]]
        if square-num % 8 = 0 [append ttt 'return]
    ]

    append ttt reduce ['pad -4x10]

    append ttt reduce [to-set-word "computer-move" 'button "Computer Move" 'extra false [if face/enabled? [
        computer-turn
        computer-move/extra: true
    ]]]
    append ttt reduce [to-set-word "again" 'button 'disabled "Again?" [if face/enabled? [window.update face unview]]
    
    ]
    append ttt reduce ['button "Quit" [quit]]
]


random/seed now/time
forever [
    board: copy/deep init-board
    player: 1
    count: 0
    ttt: layout init-ttt
    view/options ttt [offset: window.offset]
]
