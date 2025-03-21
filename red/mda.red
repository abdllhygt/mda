Red [
    author: "Abdullah Yiğiterol"
]

tyle: func[text [string!] /local new_text][ ; text style parser/replacer
    new_text: replace/all text "cr[" {<span class="text-red-600">}
    new_text: replace/all new_text "cg[" {<span class="text-lime-600">}
    new_text: replace/all new_text "cb[" {<span class="text-sky-600">}
    new_text: replace/all new_text "co[" {<span class="text-orange-600">}
    new_text: replace/all new_text "cp[" {<span class="text-purple-600">}
    new_text: replace/all new_text "b[" "<b>"
    new_text: replace/all new_text "]b" "</b>"
    new_text: replace/all new_text "i[" "<i>"
    new_text: replace/all new_text "]i" "</i>"
    new_text: replace/all new_text "]c" "</span>"
    return new_text
]

#include %classes.red
#include %tags.red
#include %tokens.red

html: ""

addhtml: func[text [string!]][
    append html text
    append html "^/"
]

parse-mda: func [mda-text [string!]][
    lines: split mda-text "^/^/"

    foreach l lines [
        parse l [
            title2
            | title1
            | image
            | olist
            | ulist
            | blockquote
            | warning
            | info
            | utable
            | text
        ]
    ]
]

ilk_g: system/options/args/1

either system/options/args == [] [
    source: read %./example.mda
    parse-mda source
    print html
][ ;not reading from console but from file
    source: read rejoin[%./ system/options/args/1]
    parse-mda source
    print html
]