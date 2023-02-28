vim9script

export def Button(text: string): dict<any>
    final self: dict<any> = {
        text: text
    }

    self.OnSelect = null_function

    self.ToString = () => {
        return $'<{self.text}>'
    }

    return self
enddef
