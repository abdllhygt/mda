Red []

h1: func [text [string!]][
    return rejoin[{<h1 class="} cls/h1 {">} text "</h1>"]
]

h2: func [text [string!]][
    return rejoin[{<h2 class="} cls/h2 {">} text "</h2>"]
]

p: func[text [string!]][
    return rejoin[{<p class="} cls/p {">&emsp;} (tyle text) "</p>"]
]

img: func[text [string!]][
    return rejoin[{<img src="} text {" />}]
]

ol: func[lines [block!] /local olines][
    olines: rejoin[{<ol class="} cls/ol {">}]
    foreach l lines [
        append olines (rejoin["<li>" (tyle l) "</li>"])
    ]
    append olines "</ol>"
    return olines
]

ul: func[lines [block!] /local ulines][
    ulines: rejoin[{<ul class="} cls/ul {">}]
    foreach l lines [
        append ulines (rejoin["<li>" (tyle l) "</li>"])
    ]
    append ulines "</ul>"
    return ulines
]

q: func[text [string!] cite [string!]][
    either cite == "" [
        return rejoin[{<blockquote class="} cls/q {">} (tyle text) "</blockquote>"]
    ][
        return rejoin[{<blockquote class="} cls/q {" cite="} cite {">}
            {<span class="text-xs text-gray-400">} cite "</span><br>"
            (tyle text) 
        "</blockquote>"]
    ]
]

div: context [
    warning: func [title [string!] text [string!]][
        return rejoin [ {<div class="} cls/warning {">}
            {<h2 class="text-xl semibold">} title "</h2>"
            {<p>} (tyle text) "</p>"
        "</div>"]
    ]

    info: func [title [string!] text [string!]][
        return rejoin [ {<div class="} cls/info {">}
            {<h2 class="text-xl semibold">} title "</h2>"
            {<p>} (tyle text) "</p>"
        "</div>"]
    ]
]

table: func[title [string!] columns [block!] /local rtable items][
    rtable: rejoin[{<table class="} cls/table {">^/}
        {<tr class="bg-lime-200"><th colspan="2" class="px-5">} title "</th></tr>^/"
    ]
    foreach c columns [
        append rtable "<tr>^/"
        items: (split c "|")
        foreach i items [
            either (find i "[]")[
                i: replace i "[]" ""
                append rtable rejoin[{<td class="text-sky-600 hover:text-sky-500 p-1 px-5">} i 
                    {<button class="p-1 bg-sky-200 hover:bg-sky-100 rounded-xl text-zinc-900 text-xs">play</button></td>^/}]
            ][
                append rtable rejoin[{<td class="p-1 px-5">} i "</td>^/"]
            ]
        ]
        append rtable "</tr>^/"
    ]
    return rejoin[rtable "</table>^/"]
]