vim9script

import "./art.vim" as Art
import "./button.vim"
import "./math.vim" as Math
import "./ui.vim" as UI

var npcs = ["Pippin", "Daisy", "Bubbles", "Fluffy", "Snuggles", "Sprinkles", "Teddy", "Rosie", "Cupcake", "Noodle"]

const Button = button.Button
const TEXT_WIDTH = 80

var json_str = join(readfile("./dialogue.json"), "\n")
var dialogue_db = json_decode(json_str)

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

export def Farm(): dict<any>
    final self: dict<any> = {
        plots: []
    }

    self.AddCrop = (crop) => {
        self.plots->add(crop)
    }

    return self
enddef

def Item(name: string, buy_price: number, sell_price: number): dict<any>
    final self: dict<any> = {
        name: name,
        buy_price: buy_price,
        sell_price: sell_price,
        category: '',
    }
    return self
enddef

def Seed(grows_into: dict<any>): dict<any>
    final self: dict<any> = {
        crop: grows_into
    }
    return self
enddef
export def Crop(name: string, growth_time: number): dict<any>
    final self: dict<any> = {
        name: name,
        growth_time: growth_time,
    }
    return self
enddef
export def PlantedCrop(crop: dict<any>, time_planted: number): dict<any>
    final self: dict<any> = {
        crop: crop,
        time_planted: time_planted
    }

    self.GetGrowthProgress = () => {
        return (1.0 * (localtime() - self.time_planted)) / (self.crop.growth_time * 1.0)
    }

    self.GetGrowthSymbol = () => {
        const growth_progress = self.GetGrowthProgress()
        if growth_progress < 0.25
            return '.'
        elseif growth_progress < 0.5
            return ';'
        elseif growth_progress < 0.75
            return 'o'
        elseif growth_progress < 1.0
            return 'O'
        else
            return 'D'
        endif

    }

    return self
enddef

var crops_db = [
    Crop("Carrot", 30),
    Crop("Eggplant", 30),
    Crop("Turnip", 30),
    Crop("Parsnip", 30),
]

export def FarmState(): dict<any>
    final self = GameState()

    var overworld_btn = Button("Overworld", () => {
        self.state_machine.TransitionTo("Overworld")
        self.game_ref.Render()
    })

    self.GetFrame = () => {
        var farm = self.game_ref.farm
        var crops = []
        for crop in farm.plots
            var capture_crop = crop.crop.name
            var btn = Button(crop.GetGrowthSymbol(), () => {
                echow $"{capture_crop}: {crop.GetGrowthProgress()}"
            }, '[%s]')
            crops->add(btn)
        endfor
        return [
            #UI.CenterLine(repeat("=", 40), TEXT_WIDTH),
            UI.SpaceEvenly(crops, TEXT_WIDTH, [20, 20]),
            [""],
            [overworld_btn]
        ]
    }

    return self
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
    self.GetFrame = (): list<list<any>> => []
    self.Exit = () => {

    }

    self.AddGameRef = (game_ref) => {
        self.game_ref = game_ref
    }
    self.AddStateMachine = (state_machine) => {
        self.state_machine = state_machine
    }

    return self
enddef

export def TitleScreen(): dict<any>
    final self = GameState()

    self.GetName = () => "TitleScreen"

    var new_game_btn = Button("New Game")
    new_game_btn.OnSelect = () => {
        self.state_machine.TransitionTo("StartGame")
        self.game_ref.Render()
    }
    var exit_btn = Button("Exit")
    exit_btn.OnSelect = () => {
        g:manager.CloseAllWindows()
    }

    self.GetFrame = () => {
        return UI.CenterLines(Art.intro_art + [
            "Animal Crossing",
            "A vim life-sim by Chris Pane",
            new_game_btn,
            exit_btn], TEXT_WIDTH)
    }

    self.Exit = () => {

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
    var town_enter_btn = Button("Enter Town", () => {
        self.town_name = input("Please enter the name of your town: ")
    })
    var confirm_btn = Button("Confirm", () => {
        echow "Confirmed!"
        self.phase += 1
        self.game_ref.Render()
    })
    var phase_0_dialog =<< trim END
    Welcome!

    Before you head off to your new 
    town, please fill out the following 
    form with some of your personal information!

    END
    self.GetFrame = () => {
        if self.phase == 0
            var left = phase_0_dialog + [name_enter_btn, town_enter_btn, "", confirm_btn]
            var right = Art.mountains
            #return UI.JustifyLines(left, right, TEXT_WIDTH)
            return UI.JustifyLines(left, right, TEXT_WIDTH)
        else
            var phase_1_dialog =<< trim eval END
            Okay, {self.player_name}, you are about to begin 
            your journey at your {self.town_name}.
            END
            var btn = Button("Start Journey", () => {
                self.state_machine.TransitionTo("Overworld")
                self.game_ref.Render()
            })
            var left = phase_1_dialog + ["", btn]
            var right = Art.mountains
            return UI.JustifyLines(left, right, TEXT_WIDTH)
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

#+---+---+---+---+      +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  <-  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  ->  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+      +---+---+---+---+
export def ShopState(): dict<any>
    final self = GameState()

    self.items = []

    self.GetFrame = () => {
        var player = self.game_ref.player
        return [
        ]
    }

    return self
enddef

export def Overworld(): dict<any>
    final self = GameState()

    self.show_inventory = false

    self.GetName = () => "Overworld"

    self.Update = () => {

    }

    var goto_farm_btn = Button("Farm", () => {
        self.state_machine.TransitionTo("FarmState")
        self.game_ref.Render()
    })
    var goto_shop_btn = Button("Shop", () => {
        self.state_machine.TransitionTo("ShopState")
        self.game_ref.Render()
    })
    var open_inventory_btn = Button("Inventory", () => {
        self.show_inventory = true
    })

    self.GetIntroText = () => {
        return $'It is: {strftime("%I:%M %p on %A")}'
    }

    self.GetFrame = () => {
        #return self.GetIntroText() + [goto_farm_btn] + ["Visitor:", self.game_ref.town.visitor]
        var visitor = self.game_ref.town.visitor
        var btn = Button("Speak", () => {
            echow $"Speaking with: {visitor}"
            self.state_machine.PushState("Dialogue", { with: visitor })
            self.game_ref.Render()
        })
        var left = [self.GetIntroText(), "", $"Today's Visitor: {visitor}", btn]
        left += [goto_farm_btn, goto_shop_btn, open_inventory_btn]
        var right = Art.mountains
        return UI.JustifyLines(left, right, TEXT_WIDTH)
    }

    return self
enddef

export def Dialogue(): dict<any>
    final self = GameState()

    self.GetName = () => "Dialogue"
    self.dialogues = []
    self.progress = 0

    self.next_btn = Button("Next", () => {
        self.progress += 1
        if self.progress == self.dialogues->len()
            #self.state_machine.TransitionTo("Overworld")
            self.state_machine.PopState()
        endif
        self.game_ref.Render()
    })

    self.end_btn = Button("End", () => {
        #self.state_machine.TransitionTo("Overworld")
        self.state_machine.PopState()
        self.game_ref.Render()
    })

    self.Enter = (msg) => {
        var with = msg.with
        echow "In dialogue with: " .. with
        var dialogue: string = dialogue_db["characters"]["Pippin"]["intro"]
        self.dialogues = split(dialogue, "\n\n")
        for i in range(self.dialogues->len())
            self.dialogues[i] = self.dialogues[i]->split("\n")
        endfor
        self.progress = 0
        self.next_btn.text = "Next"
    }

    self.Update = () => {
        if self.progress == self.dialogues->len() - 1
            self.next_btn.text = "Done"
            self.end_btn = ""
        endif
    }

    self.GetFrame = () => {
        var cur_dialogue = self.dialogues[self.progress]
        var left = cur_dialogue + ["", self.next_btn, self.end_btn]
        var right = Art.character_1
        return UI.JustifyLines(left, right, TEXT_WIDTH)
    }

    return self
enddef
