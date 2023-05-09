vim9script

import "./ability.vim" as Ability
import "./item.vim"

const Attack = Ability.Attack
const Item = item.Item

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
    # self.items = [
    #     Item("Fishing Pole I", 100, 50),
    #     Item("Shovel I", 200, 100),
    #     Item("Hoe II", 300, 150),
    # ]

    return self
enddef

export def Enemy(): dict<any> # extends Entity
    final self = Entity()

    self.name = "Enemy"
    self.health = 5

    return self
enddef
