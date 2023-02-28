vim9script

import "./art.vim" as Art
import "./button.vim"
import "./math.vim" as Math

var npcs = ["Pippin", "Daisy", "Bubbles", "Fluffy", "Snuggles", "Sprinkles", "Teddy", "Rosie", "Cupcake", "Noodle"]
const Button = button.Button


export def Town(): dict<any>
    final self: dict<any> = {
        name: '',
        visitor: null
    }

    self.NewDay = () => {
        self.visitor = npcs[Math.RandInt(npcs->len())]
    }
    self.NewDay()

    return self
enddef

def Farm(): dict<any>
    final self: dict<any> = {
        plots: []
    }

    self.AddCrop = (crop) => {
        self.plots->add(crop)
    }

    return self
enddef

def Crop(name: string, growth_time: number): dict<any>
    final self: dict<any> = {
        name: name,
        growth_time: growth_time
    }
    return self
enddef

export def FarmState(): dict<any>
    final self = GameState()

    self.farm = Farm()
    self.farm.AddCrop(Crop("Carrot", 3000))
    self.farm.AddCrop(Crop("Eggplant", 3000))
    self.farm.AddCrop(Crop("Eggplant", 3000))
    self.farm.AddCrop(Crop("Carrot", 3000))


    self.GetFrame = () => {
        var crops = []
        for crop in self.farm.plots
            crops->add(crop.name)
        endfor
        return ["Farm:"] + crops
    }

    return self
enddef

export def JustifyLines(left: list<string>, right: list<string>, max_len: number): list<string>
    var result = []

    var shorter_length = min([left->len(), right->len()])

    var i = 0
    while i < shorter_length
        var spaces = max_len - left[i]->len() - right[i]->len()
        result->add(left[i] .. repeat(" ", spaces) .. right[i])
        ++i
    endwhile
    while i < left->len()
        var spaces = max_len - left[i]->len()
        result->add(left[i] .. repeat(" ", spaces))
        ++i
    endwhile
    while i < right->len()
        var spaces = max_len - right[i]->len()
        result->add(repeat(" ", spaces) .. right[i])
        ++i
    endwhile

    return result
enddef


export def GameState(): dict<any>
    final self: dict<any> = {
        state_machine: null,
        game_ref: null,
    }

    self.GetName = () => "GameState"

    self.Enter = (msg = {}) => {
    }
    self.Update = () => {

    }
    self.GetFrame = () => []
    self.Exit = () => {

    }

    return self
enddef

export def TitleScreen(): dict<any>
    final self = GameState()

    self.GetName = () => "TitleScreen"

    var new_game_btn = Button("New Game")
    new_game_btn.OnSelect = () => {
        self.state_machine.TransitionTo("StartGame")
        g:game.Render()
    }
    var exit_btn = Button("Exit")
    exit_btn.OnSelect = () => {
        g:manager.CloseAllWindows()
    }

    self.GetFrame = () => {
        var lines: list<any> = Art.intro_art->copy()
        lines += ["Animal Crossing"]
        lines += ["A vim life-sim by Chris Pane"]
        lines += [new_game_btn, exit_btn]
        return lines
    }

    self.Exit = () => {
        #g:manager.buttons = []
    }

    return self
enddef

export def StartGame(): dict<any>
    final self = GameState()

    self.phase = 0
    self.GetName = () => "StartGame"
    self.player_name = ""
    self.town_name = ""

    self.Enter = (msg) => {

    }

    self.Update = () => {

    }

    var name_enter_btn = Button("Enter Name")
    name_enter_btn.OnSelect = () => {
        self.player_name = input("Please enter your name: ")
    }
    var town_enter_btn = Button("Enter Town")
    town_enter_btn.OnSelect = () => {
        self.town_name = input("Please enter the name of your town: ")
    }
    var confirm_btn = Button("Confirm")
    confirm_btn.OnSelect = () => {
        echow "Confirmed!"
        self.phase += 1
        self.game_ref.Render()
    }
    var phase_0_dialog =<< trim END
    Welcome!

    Before you head off to your new 
    town, please fill out the following 
    form with some of your personal information!

    END
    var phase_1_dialog =<< trim END
    Okay, you are about to begin your journey
    at your new town?
    END
    self.GetFrame = () => {
        if self.phase == 0
            var frame: list<any> = JustifyLines(phase_0_dialog, Art.mountains, 80)
            frame += [name_enter_btn, town_enter_btn, "", confirm_btn]
            return frame
        else
            #g:manager.buttons = []
            var frame: list<any> = JustifyLines(phase_1_dialog, Art.mountains, 80)
            var btn = Button("Start Journey")
            btn.OnSelect = () => {
                self.state_machine.TransitionTo("Overworld")
                g:game.Render()
            }
            frame += [btn]
            return frame
        endif
    }

    self.Exit = () => {
        var town = Town()
        town.name = self.town_name
        self.game_ref.town = town
        echow town
    }

    return self
enddef


export def Overworld(): dict<any>
    final self = GameState()

    self.GetName = () => "Overworld"

    self.Update = () => {

    }

    var goto_farm_btn = Button("Farm")
    goto_farm_btn.OnSelect = () => {
        self.state_machine.TransitionTo("FarmState")
        self.game_ref.Render()
    }

    self.GetIntroText = () => {
        return [
            $'It is: {strftime("%I:%M %p on %A")}'
        ]
    }

    self.GetFrame = () => {
        return self.GetIntroText() + [goto_farm_btn] + ["Visitor: ", self.game_ref.town.visitor]
    }

    return self
enddef
