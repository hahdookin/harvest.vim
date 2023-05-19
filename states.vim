vim9script

import "./art.vim" as Art
import "./button.vim"
import "./globals.vim"
import "./math.vim" as Math
import "./ui.vim" as UI

var npcs = [
    'Blossom',
    'Bluebell',
    'Bubbles', 
    'Cupcake', 
    'Daisy', 
    'Fluffy', 
    'Fuzzy',
    'Honeycomb',
    'Noodle',
    'Pippin', 
    'Poppyseed',
    'Puddles',
    'Rosie', 
    'Sherbert',
    'Snuggles', 
    'Sprinkles', 
    'Sunny',
    'Teddy', 
]

const Button = button.Button
const TEXT_WIDTH = globals.TEXT_WIDTH

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
    self.GetFrame = (): list<list<any>> => [] # List<List<Button | String>>
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
        var art_lines = Art.ArtToUIFrame(Art.intro_art)
        var text_lines = [
            ["Animal Crossing"],
            ["A vim life-sim by Chris Pane"],
            [new_game_btn],
            [exit_btn],
        ]
        var buffer = art_lines + text_lines
        return UI.CenterLines(buffer, TEXT_WIDTH)
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
            var left = [
                [name_enter_btn],
                [town_enter_btn],
                [""],
                [confirm_btn],
            ]
            left = Art.ArtToUIFrame(phase_0_dialog) + left
            var right = Art.ArtToUIFrame(Art.mountains)
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
            var left = [
                [""],
                [btn],
            ]
            left = Art.ArtToUIFrame(phase_1_dialog) + left
            var right = Art.ArtToUIFrame(Art.mountains)
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

export def Overworld(): dict<any>
    final self = GameState()

    self.show_inventory = false

    self.GetName = () => "Overworld"

    self.Update = () => {

    }

    var goto_farm_btn = Button("Farm", () => {
        self.state_machine.PushState("FarmState")
        self.game_ref.Render()
    })
    var goto_shop_btn = Button("Shop", () => {
        self.state_machine.PushState("ShopState")
        self.game_ref.Render()
    })
    var start_fishing_btn = Button("Fish", () => {
        self.state_machine.PushState("FishingState")
        self.game_ref.Render()
    })
    var open_inventory_btn = Button("Inventory", () => {
        self.show_inventory = true
    })
    var save_game_btn = Button("Save", () => {
        self.game_ref.Save()
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
        var left = [
            [self.GetIntroText()], 
            [""], 
            [$"Today's Visitor: {visitor}"], 
            [btn],
            [goto_farm_btn],
            [goto_shop_btn],
            [open_inventory_btn],
            [start_fishing_btn],
            [""], 
            [save_game_btn],
        ]
        # var left = [self.GetIntroText(), "", $"Today's Visitor: {visitor}", btn]
        # left += [goto_farm_btn, goto_shop_btn, open_inventory_btn]
        # left += ["", save_game_btn]
        var right = Art.ArtToUIFrame(Art.mountains)
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
