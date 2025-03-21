Red []

_letter: complement charset ""
_text: [any _letter]
_firstletter: complement charset {#@-+!>|[}
_link_letter: complement charset "[]"
_link_text: [any _link_letter]

title1: ["#" any space copy c_t _text (addhtml h1 c_t)]

title2: ["##" any space copy c_t _text (addhtml h2 c_t)] 

text: [copy c_t [_firstletter any _letter] (
    addhtml p c_t
)]

image: ["[" copy c_link thru "]" (
    link_: reverse remove (reverse c_link)
    addhtml img link_
)]

olist: ["1" ["." | ")"] any space copy c_t [any _letter](
    lines_: split c_t "^/"
    addhtml ol lines_
)]

ulist: ["-" any space copy c_t [any _letter](
    lines_: split c_t "^/"
    addhtml ul lines_
)]

blockquote: [">" any space (c_link: copy "") 0 1 ["[" copy c_link _link_text "]"] copy c_t [any _letter](
    addhtml q c_t c_link
    c_link: copy ""
)]

warning: ["!!" any space copy c_t [any _letter](
    either (find c_t "^/")[
        lines_: split c_t "^/"
        title_: lines_/1
        remove lines_
        text_: rejoin lines_
    ][
        title_: c_t
        text_: ""
    ]
    addhtml (div/warning title_ text_)
)]

info: ["!" any space copy c_t [any _letter](
    either (find c_t "^/")[
        lines_: split c_t "^/"
        title_: lines_/1
        remove lines_
        text_: rejoin lines_
    ][
        title_: c_t
        text_: ""
    ]
    addhtml (div/info title_ text_)
)]

utable: ["|" any space copy c_table [any _letter](
    lines_: split c_table "^/"
    title_: lines_/1
    remove lines_
    addhtml (table title_ lines_)
)]