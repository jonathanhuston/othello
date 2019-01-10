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
    
    ;repeat row 8 [
;        repeat col 8 [
;            append ttt compose/deep [
;                button 82x82 extra (col) react [face/text: to string! board/square] [
;                    print face/extra
;                    print board/square
;                    board/square: board/square + 1
;                ]
;            ]
;        ]
        ; append ttt [return]
    ;]
    
    repeat row 8 [
        repeat col 8 [
            square: rejoin [{[
                button 82x82 extra [} row { } col {] react [face/text: to string! board/square/} row {/} col {] [
                print board/square/} row {/} col { } {
                board/square/} row {/} col {: board/square/} row {/} col { + 1]]
            }]
            append ttt load square
        ]
        append ttt [return]
    ]
]

comment {
    append ttt compose/deep [
        button 82x82 extra 2 react [face/text: to string! board/square/2] [
            print face/extra
            print board/square/2
            board/square/2: board/square/2 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 3 react [face/text: to string! board/square/3] [
            print face/extra
            print board/square/3
            board/square/3: board/square/3 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 4 react [face/text: to string! board/square/4] [
            print face/extra
            print board/square/4
            board/square/4: board/square/4 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 5 react [face/text: to string! board/square/5] [
            print face/extra
            print board/square/5
            board/square/5: board/square/5 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 6 react [face/text: to string! board/square/6] [
            print face/extra
            print board/square/6
            board/square/6: board/square/6 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 7 react [face/text: to string! board/square/7] [
            print face/extra
            print board/square/7
            board/square/7: board/square/7 + 1
        ]
    ]
    append ttt compose/deep [
        button 82x82 extra 8 react [face/text: to string! board/square/8] [
            print face/extra
            print board/square/8
            board/square/8: board/square/8 + 1
        ]
    ]
}


board: make deep-reactor! [square: copy/deep INIT-BOARD]
ttt: init-ttt
probe ttt
view/options ttt [offset: window.offset]
