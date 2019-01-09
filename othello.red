Red [
    Title:  "Othello"
    Author: "Jonathan Huston"
    Needs:  View
    Deps:   Red 0.6.4
]

#include %/usr/local/lib/red/window.red

EMPTY: load %empty.png
STONE: reduce [(load %black.png) (load %red.png)]
LABEL: ["Black: " "Red: "]
TURN: ["Black's turn" "Red's turn"]
WON: ["Black won!" "Red won!"]
PLAYER-COLOR: reduce [black red blue]
DELAY: 0.0
PASS-DELAY: 1.5
INF: 10
NINF: -10

; internal representation of empty board
INIT-BOARD: [[0 0 0 0 0 0 0 0] 
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


get-row-col: function [
    "Given square, returns row and column"
    square
] [
    move: square/extra
    col: (move - 1) % 8 + 1
    row: (move - 1) / 8 + 1
    return reduce [row col]
]


opponent: function [player] [3 - player]


find-end: function [
    "Finds end stone for flipping, returns [none none] if none found"
    board player row col drow dcol
] [
    if all [(drow = -1) (row < 3)] [return reduce [none none]]
    if all [(drow = 1) (row > 6)] [return reduce [none none]]
    if all [(dcol = -1) (col < 3)] [return reduce [none none]]
    if all [(dcol = 1) (col > 6)] [return reduce [none none]]
    if board/(row + drow)/(col + dcol) <> opponent player [return reduce [none none]]
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
    board player count row col drow dcol
] [
    end: find-end board player row col drow dcol
    end-row: end/1
    end-col: end/2
    if all [end-row end-col] [
        current-row: row + drow
        current-col: col + dcol
        forever [
            if all [(current-row = end-row) (current-col = end-col)] [break]
            board/:current-row/:current-col: player
            count/:player: count/:player + 1
            count/(opponent player): count/(opponent player) - 1
            square: get to-word rejoin ["square" get-square-num current-row current-col]
            square/image: STONE/:player
            current-row: current-row + drow
            current-col: current-col + dcol
        ]
    ]
]


flip: function [
    "Given board, player, row, and column, flips stones"
    board player count row col
] [
    foreach drow [-1 0 1] [
        foreach dcol [-1 0 1] [
            flip-direction board player count row col drow dcol
        ]
    ]
]


valid-square?: function [
    "Given board, player, and square, determines if move is valid"
    board player square
] [
    if square/image <> EMPTY [return false]
    move: get-row-col square
    row: move/1
    col: move/2
    foreach drow [-1 0 1] [
        foreach dcol [-1 0 1] [
            end: find-end board player row col drow dcol
            if any [end/1 end/2] [return true]
        ]
    ]
    return false
]


find-valid-squares: function [
    "Given board and player, returns array of valid squares"
    board player
] [
    valid-squares: copy []
    repeat square-num 64 [
        square: get to-word rejoin ["square" square-num]
        if valid-square? board player square [append valid-squares square-num]
    ]
    valid-squares
]


update-board: function [
    "Given board, player, and square, updates board"
    board player count square
] [
    move: get-row-col square
    row: move/1
    col: move/2
    board/:row/:col: player
    count/:player: count/:player + 1
    square/image: STONE/:player
    flip board player count row col
]


player-dialogue: function [
    "Updates player display"
    player
] [
    dialogue/font/color: PLAYER-COLOR/:player
    dialogue/text: rejoin [TURN/:player]
]


pass-dialogue: function [
    "Forced pass on player's move"
    player
] [
    dialogue/font/color: PLAYER-COLOR/:player
    dialogue/text: "FORCED PASS"
    wait PASS-DELAY
]


end-game: function [
    "Displays end-of-game dialogue"
    count
] [
    again/enabled?: true
    computer-move/enabled?: false
    if count/1 > count/2 [
        dialogue/font/color: PLAYER-COLOR/1
        dialogue/text: rejoin [WON/1]
    ] 
    if count/2 > count/1 [
        dialogue/font/color: PLAYER-COLOR/2
        dialogue/text: rejoin [WON/2]
    ]
    if count/1 = count/2 [
        dialogue/font/color: PLAYER-COLOR/3
        dialogue/text: "It's a tie!"
    ]
]


comment {
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
    if count/1 = 9 [return 0]
    score: second _minimax board (opponent player) count (not maximizing) depth alpha beta
]


_minimax: function [
    "Minimax helper function"
    board player count 
    maximizing  "is this the maximizing player?"
    depth       "current depth of analysis"
    alpha beta  "alpha and beta values for pruning"
] [
    possible-moves: find-valid-squares board player
    either maximizing [best-score: NINF] [best-score: INF]
    foreach move possible-moves [
        test-board: copy/deep board
        update-board test-board player move
        score: evaluate test-board player (count/1 + 1) maximizing (depth + 1) alpha beta
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
}


play-square: function [
    "Places player's mark on selected square and checks for winner"
    square  
    /extern board player counter
] [
    if all [(valid-square? board player square) (not again/enabled?)] [
        update-board board player counter/count square
        either counter/count/1 + counter/count/2 = 64 [
            end-game counter/count
        ] [
            player: opponent player
            if empty? find-valid-squares board player [
                either empty? find-valid-squares board opponent player [
                    end-game counter/count
                ] [
                    pass-dialogue player
                    player: opponent player
                ]
            ]
            player-dialogue player
        ]
    ]
]


computer-turn: function [
    "Generates computer move"
    /extern board player
] [
    computer-move/enabled?: false
    until [
        ; move: first minimax board player count
        move: random/only find-valid-squares board player
        square: get to-word rejoin ["square" move]
        play-square square
        wait DELAY
        (not computer-move/extra) or again/enabled?
    ]
    if (not again/enabled?) [computer-move/enabled?: true]
]


init-ttt: has [
    init-square
] [    
    ttt: compose/deep [ 
        title "Othello"
        backdrop white
        pad 5x0
        dialogue: text 646x30 center font-color PLAYER-COLOR/:player bold font-size 16 (TURN/:player)
        return
        pad 252x0
        text 78x30 font-color PLAYER-COLOR/1 bold font-size 12 react [face/text: rejoin [LABEL/1 counter/count/1]]
        text 78x30 font-color PLAYER-COLOR/2 bold font-size 12 react [face/text: rejoin [LABEL/2 counter/count/2]]
        return
        space -5x-6
    ]

    repeat square-num 64 [
        square-set-word: to-set-word rejoin ["square" square-num ":"]
        init-square: EMPTY
        if any [(square-num = 29) (square-num = 36)] [init-square: STONE/1]
        if any [(square-num = 28) (square-num = 37)] [init-square: STONE/2]
        append ttt compose/deep [
            (square-set-word) button 82x82 (init-square) extra (square-num) [
                play-square face
                computer-move/extra: false  
            ]
        ]
        if square-num % 8 = 0 [append ttt [return]]
    ]

    append ttt [
        pad -4x10
        computer-move: button "Computer Move" extra false [
            if face/enabled? [
                computer-turn
                face/extra: true
            ]
        ]
        again: button disabled "Again?" [
            if face/enabled? [
                window.update face unview
            ]
        ]
        button "Quit" [quit]
    ]
]


random/seed now/time
forever [
    board: copy/deep INIT-BOARD
    player: 1
    counter: make deep-reactor! [count: copy [2 2]]
    view/options compose/deep init-ttt [offset: window.offset]
]
