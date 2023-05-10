vim9script

export def Randf(): float
    return (rand() * 1.0) / (2.0 * 2147483647.0)
enddef

export def RandInt(max: number): number
    return float2nr(floor(Randf() * (1.0 * max)))
enddef

export def Clamp(n: number, min: number, max: number): number
    if n < min
        return min
    elseif n > max
        return max
    endif
    return n
enddef
