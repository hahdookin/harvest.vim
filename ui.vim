vim9script

import "./button.vim"

const Button = button.Button
const TEXT_WIDTH = 80

# TYPES: 
# UIEle -> string | Button
# UILine -> list<UIEle>
# UIFrame -> list<UILine>

def UIEleScreenLen(ele: any): number
    return type(ele) != v:t_string ? ele.ToString()->len() : ele->len()
enddef

def UILineScreenLen(line: list<any>): number
    return line->reduce((acc, ele) => acc + UIEleScreenLen(ele), 0)
enddef

# line: UILine
# Returns: UILine
export def CenterLine(line: list<any>, max_len: number): list<any>
    var res = []

    var len = UILineScreenLen(line)
    var spaces = max_len - len
    var padding_left = spaces / 2
    var padding_right = spaces - spaces / 2

    return [repeat(' ', padding_left)] + line + [repeat(' ', padding_right)]
enddef

# line: UIFrame
# Returns: UIFrame
export def CenterLines(lines: list<list<any>>, max_len: number): list<list<any>>
    var res = []
    for line in lines
        res->add(CenterLine(line, max_len))
    endfor
    return res
enddef

export def SpaceEvenlyX(contents: list<any>, max_len: number, margin = [0, 0]): list<any>
    var res = []
    var total_chars = UILineScreenLen(contents)
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
# echo join(SpaceEvenly(["hello", Button("Btn"), "Another thing", Button("Other")], TEXT_WIDTH), "")
# echo join(SpaceEvenly(["hello", "Another thing"], TEXT_WIDTH), "")

export def JustifyLine(left: list<any>, right: list<any>, max_len: number): list<any>
    const Reducer = (acc, val) => {
        return acc + (type(val) != v:t_string ? val.ToString()->len() : val->len())
    }
    var left_len = left->reduce(Reducer, 0)
    var right_len = right->reduce(Reducer, 0)
    var spaces = max_len - left_len - right_len
    var res = []
    return left + [repeat(' ', spaces)] + right
enddef

export def JustifyLines(left: list<list<any>>, right: list<list<any>>, max_len: number): list<list<any>>
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
        var spaces = max_len - UILineScreenLen(left[i])
        result->add(left[i] + [repeat(" ", spaces)])
        ++i
    endwhile
    while i < right->len()
        var spaces = max_len - UILineScreenLen(right[i])
        result->add([repeat(" ", spaces)] + right[i])
        ++i
    endwhile

    return result
enddef
