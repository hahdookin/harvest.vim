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

    self->extend({
        name: "Player",
        gold: 0,
        health: 10,
        experience: 0,
        level: 1,
        items: [],
        equipment: {
            neck: null,
            weapon: null,
            hands: null,
            feet: null,
        },
    })
    self.AddItem = (i) => {
        self.items->add(i)
    }

    return self
enddef

export def Enemy(): dict<any> # extends Entity
    final self = Entity()

    self.name = "Enemy"
    self.health = 5

    return self
enddef
