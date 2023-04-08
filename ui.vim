vim9script

import "./button.vim"

const Button = button.Button
const TEXT_WIDTH = 80

export def CenterLine(content: any, max_len: number): list<any>
    var res = []

    var content_str = content
    if type(content) != v:t_string
        content_str = content.ToString()
    endif

    var len = content_str->len()
    var spaces = max_len - len
    var padding_left = spaces / 2
    var padding_right = spaces - spaces / 2

    return [
        repeat(" ", padding_left), 
        content, 
        repeat(" ", padding_right)
    ]
enddef

export def CenterLines(content: list<any>, max_len: number): list<list<any>>
    var res = []
    for item in content
        res->add(CenterLine(item, max_len))
    endfor
    return res
enddef


export def SpaceEvenly(contents: list<any>, max_len: number, margin = [0, 0]): list<any>
    var res = []
    var total_chars = 0
    for content in contents
        var this_str = content
        if type(content) != v:t_string
            this_str = content.ToString()
        endif
        total_chars += this_str->len()
    endfor
    var actual_max_len = max_len - margin[0] - margin[1]
    var spaces = actual_max_len - total_chars
    var slots = contents->len() - 1
    var spaces_per_slot = spaces / slots
    var extra_spaces = spaces % slots

    res->add(" "->repeat(margin[0]))
    for i in range(contents->len())
        res->add(contents[i])
        if i != contents->len() - 1
            var added = 0
            if extra_spaces > 0
                added = 1
                extra_spaces -= 1
            endif

            res->add(repeat(" ", spaces_per_slot + added))
        endif
    endfor
    res->add(" "->repeat(margin[1]))

    return res
enddef
#echo join(SpaceEvenly(["hello", Button("Btn"), "Another thing", Button("Other")], TEXT_WIDTH), "")
#echo join(SpaceEvenly(["hello", "Another thing"], TEXT_WIDTH), "")

export def JustifyLine(left: any, right: any, max_len: number): list<any>
    var result = []

    var left_str = left
    var right_str = right
    # Check if either are butttons
    if type(left) != v:t_string
        left_str = left.ToString()
    endif
    if type(right) != v:t_string
        right_str = right.ToString()
    endif

    var spaces = max_len - left_str->len() - right_str->len()

    return [left, repeat(' ', spaces), right]
enddef

export def JustifyLines(left: list<any>, right: list<any>, max_len: number): list<list<any>>
    var result = []

    var shorter_length = min([left->len(), right->len()])

    var i = 0
    while i < shorter_length
        #var spaces = max_len - left[i]->len() - right[i]->len()
        #result->add(left[i] .. repeat(" ", spaces) .. right[i])
        result->add(JustifyLine(left[i], right[i], max_len))
        ++i
    endwhile
    while i < left->len()
        var spaces = max_len - left[i]->len()
        result->add([left[i], repeat(" ", spaces)])
        ++i
    endwhile
    while i < right->len()
        var spaces = max_len - right[i]->len()
        result->add([repeat(" ", spaces), right[i]])
        ++i
    endwhile

    return result
enddef
