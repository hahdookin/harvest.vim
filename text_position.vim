vim9script

export def TextPosition(lnum: number, col: number): dict<any>
    final self: dict<any> = {
        lnum: lnum,
        col: col
    }

    self.Equals = (other) => {
        return self.lnum == other.lnum && self.col == other.col
    }
    self.Between = (pos_a, pos_b) => {
        if pos_a.lnum != self.lnum || pos_b.lnum != self.lnum
            return false
        endif
        return self.col >= pos_a.col && self.col <= pos_b.col
    }


    self.CursorTo = () => {
        cursor(self.lnum, self.col)
    }

    return self
enddef
