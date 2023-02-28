vim9script

export def Ability(): dict<any>
    final self: dict<any> = {
        name: "Ability",
        source: null
    }

    def Use(target: dict<any>)
        echow $'{self.source.name} used {self.name} on {target.name}'
    enddef
    self.Use = Use
    
    return self
enddef

export def Attack(damage: number): dict<any>
    final self = Ability()

    self.damage = damage

    var Super_Use = self.Use
    def Use(target: dict<any>)
        Super_Use(target)
        target.health -= self.damage
    enddef
    self.Use = Use

    return self
enddef
