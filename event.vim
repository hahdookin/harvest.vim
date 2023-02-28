vim9script

export def Event(): dict<any>
    final self: dict<any> = {
        name: "Event",
    }
    
    return self
enddef

export def UpgradeEvent(): dict<any>
    final self = Event()

    self.name = "UpgradeEvent"

    return self
enddef
