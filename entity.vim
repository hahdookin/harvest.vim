vim9script

import "./ability.vim" as Ability

const Attack = Ability.Attack

def Entity(): dict<any>
    final self: dict<any> = {
        name: "Entity",
        health: 0
    }

    def Method()
        echow $'Name: {self.name}, HP: {self.health}'
    enddef
    self.Method = Method
    
    return self
enddef

export def Player(): dict<any> # extends Entity
    final self = Entity()
    
    self.name = "Player"
    self.gold = 0
    self.health = 10
    self.experience = 0
    self.level = 1
    self.equipment = {
        neck: null,
        weapon: null,
        hands: null,
        feet: null,
    }
    self.items = ["a", "b", "c", "d"]

    return self
enddef

export def Enemy(): dict<any> # extends Entity
    final self = Entity()

    self.name = "Enemy"
    self.health = 5

    return self
enddef
