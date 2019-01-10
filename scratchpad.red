Red [
    Title:  "Othello"
    Author: "Jonathan Huston"
    Needs:  View
    Deps:   Red 0.6.4
]

#include %/usr/local/lib/red/window.red

INIT-BOARD: [[3 3 3 3 3 3 3 3] 
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 2 1 3 3 3]
             [3 3 3 1 2 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]
             [3 3 3 3 3 3 3 3]]

init-ttt: does [
    ttt: copy []
    
    repeat row 8 [
        repeat col 8 [
            append ttt compose/deep [
                button 82x82 extra [(row) (col)] react [face/text: to string! board/square/(face/extra/1)/(face/extra/2)] [
                    print board/square/(face/extra/1)/(face/extra/2)
                    board/square/(face/extra/1)/(face/extra/2): board/square/(face/extra/1)/(face/extra/2) + 1
                ]
            ]
        ]
        append ttt [return]
    ]
]

board: make deep-reactor! [square: copy/deep INIT-BOARD]
view/options init-ttt [offset: window.offset]

