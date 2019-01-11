Red [
    Title:  "Othello"
    Author: "Jonathan Huston"
    Needs:  View
    Deps:   Red 0.6.4
]

#include %/usr/local/lib/red/window.red

STONE: reduce [(load %black.png) (load %red.png) (load %empty.png)]
LABEL: ["Black: " "Red: "]
TURN: ["Black's turn" "Red's turn"]
WON: ["Black won!" "Red won!"]
PLAYER-COLOR: reduce [black red blue]
DELAY: 0.0
PASS-DELAY: 1.5
INF: 10
NINF: -10
INIT-BOARD: [[3 3 3 3 3 3 3 3] 
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 2 1 3 3 3]
             [3 3 3 1 2 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]]


opponent: function [player] [3 - player]


find-end: function [
    "Finds end stone for flipping, returns [none none] if none found"
    board player row col drow dcol
] [
    if all [(drow = -1) (row < 3)] [return reduce [none none]]
    if all [(drow = 1) (row > 6)] [return reduce [none none]]
    if all [(dcol = -1) (col < 3)] [return reduce [none none]]
    if all [(dcol = 1) (col > 6)] [return reduce [none none]]
    if board/square/(row + drow)/(col + dcol) <> opponent player [return reduce [none none]]
    current-row: row + (2 * drow)
    current-col: col + (2 * dcol)
    forever [
        if any [(current-row < 1) (current-row > 8) (current-col < 1) (current-col > 8)] [break]
        square: board/square/:current-row/:current-col
        if square = player [return reduce [current-row current-col]]
        if square = 3 [return reduce [none none]]
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
            board/square/:current-row/:current-col: player
            count/:player: count/:player + 1
            count/(opponent player): count/(opponent player) - 1
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
    "Given board, player, row, and column, determines if move is valid"
    board player row col
] [
    if board/square/:row/:col <> 3 [return false]
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
    repeat row 8 [
        repeat col 8 [
            if valid-square? board player row col [append/only valid-squares reduce [row col]]
        ]
        valid-squares
    ]
]


update-board: function [
    "Given board, player, count, row, and column, updates board"
    board player count row col
] [
    board/square/:row/:col: player
    count/:player: count/:player + 1
    flip board player count row col
]


player-dialogue: function [
    "Updates player display"
    player 
    /extern dialogue
] [
    dialogue/color: PLAYER-COLOR/:player
    dialogue/text: rejoin [TURN/:player]
]


pass-dialogue: function [
    "Forced pass on player's move"
    player
    /extern dialogue
] [
    dialogue/color: PLAYER-COLOR/:player
    dialogue/text: "FORCED PASS"
    wait PASS-DELAY
]


end-game: function [
    "Displays end-of-game dialogue"
    count
    /extern dialogue game? computer-move
] [
    game?/over?: true
    computer-move/enabled?: false
    if count/1 > count/2 [
        dialogue/color: PLAYER-COLOR/1
        dialogue/text: rejoin [WON/1]
    ] 
    if count/2 > count/1 [
        dialogue/color: PLAYER-COLOR/2
        dialogue/text: rejoin [WON/2]
    ]
    if count/1 = count/2 [
        dialogue/color: PLAYER-COLOR/3
        dialogue/text: "It's a tie!"
    ]
]


play-square: function [
    "Places player's mark on selected square and checks for winner"
    row col
    /extern board player counter game?
] [
    if all [(valid-square? board player row col) (not game?/over?)] [
        update-board board player counter/count row col
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
    /extern board player game? computer-move previous-move-by-computer?
] [
    computer-move/enabled?: false
    move: random/only find-valid-squares board player
    play-square move/1 move/2
    wait DELAY 
    if (not game?/over?) and (not previous-move-by-computer?) [computer-move/enabled?: true]
]


init-ttt: has [row col] [
    ttt: copy [ 
        title "Othello"
        backdrop white
        pad 5x0
        text 646x30 center bold font-size 16 react [face/text: dialogue/text face/font/color: dialogue/color]
        return
        pad 252x0
        text 78x30 font-color PLAYER-COLOR/1 bold font-size 12 react [face/text: rejoin [LABEL/1 counter/count/1]]
        text 78x30 font-color PLAYER-COLOR/2 bold font-size 12 react [face/text: rejoin [LABEL/2 counter/count/2]]
        return
        space -5x-6
    ]

    repeat row 8 [
        repeat col 8 [
            sq: rejoin [{[
                    button 82x82 react [face/image: STONE/(board/square/} row {/} col {)] [
                        play-square } row { } col { } {
                        previous-move-by-computer?: false
                    ] 
                ]}]
            append ttt load sq
        ]
        append ttt [return]
    ]

    append ttt [
        pad -4x10
        computer-move: button "Computer Move" [
            if face/enabled? [
                computer-turn
                if previous-move-by-computer? [
                    forever [
                        if game?/over? [break]
                        computer-turn
                    ]
                ]
                previous-move-by-computer?: true
            ]
        ]
        again: button "Again?" react [face/enabled?: game?/over?] [
            if face/enabled? [
                window.update face unview
            ]
        ]
        button "Quit" [quit]
    ]
]


random/seed now/time
forever [
    board: make deep-reactor! [square: copy/deep INIT-BOARD]
    player: 1
    counter: make deep-reactor! [count: copy [2 2]]
    dialogue: make reactor! [text: TURN/:player color: PLAYER-COLOR/:player]
    previous-move-by-computer?: false
    game?: make reactor! [over?: false]
    view/options init-ttt [offset: window.offset]
]
