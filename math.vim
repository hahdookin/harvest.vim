vim9script

export def Randf(): float
    return (rand() * 1.0) / (2.0 * 2147483647.0)
enddef

# [min, max)
export def RandRange(min: number, max: number): number
    return (Randf() * (max - min) + min)->float2nr()
enddef

export def RandInt(max: number): number
    return RandRange(0, max)
enddef

export def RandChoice(arr: list<any>): any
    return arr[RandInt(arr->len())]
enddef

export def Clamp(n: number, min: number, max: number): number
    if n < min
        return min
    elseif n > max
        return max
    endif
    return n
enddef
