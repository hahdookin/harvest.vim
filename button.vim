vim9script

export def Button(text: string, OnSelect = null_function, display_fmt = '<%s>'): dict<any>
    final self: dict<any> = {
        text: text,
        disabled: false,
    }

    self.OnSelect = OnSelect

    self.ToString = () => {
        return printf(display_fmt, self.text)
    }

    self.DisplayLength = () => {
        return self.ToString()->len()
    }

    return self
enddef
