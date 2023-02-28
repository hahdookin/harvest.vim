vim9script

export def TextPosition(lnum: number, col: number): dict<any>
    final self: dict<any> = {
        self.lnum: lnum,
        self.col: col
    }

    self.CursorTo = () => {
        cursor(self.lnum, self.col)
    }

    return self
enddef
