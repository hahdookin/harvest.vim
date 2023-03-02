vim9script

export def Button(text: string, OnSelect = null_function): dict<any>
    final self: dict<any> = {
        text: text
    }

    self.OnSelect = OnSelect

    self.ToString = () => {
        return $'<{self.text}>'
    }

    self.DisplayLength = () => {
        return self.ToString()->len()
    }

    return self
enddef
