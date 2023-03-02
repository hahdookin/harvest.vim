vim9script

import "./art.vim" as Art
import "./button.vim"
import "./math.vim" as Math

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
        return [
            SpaceEvenly(crops, TEXT_WIDTH)
        ]
    }

    return self
enddef

export def CenterLine(content: any, max_len: number): list<any>
    var res = []

    var content_str = content
    if type(content) != v:t_string
        content_str = content.ToString()
    endif

    var len = content_str->len()
    var spaces = max_len - len
    var padding_left = spaces / 2
    var padding_right = spaces - spaces / 2

    return [
        repeat(" ", padding_left), 
        content, 
        repeat(" ", padding_right)
    ]
enddef

export def CenterLines(content: list<any>, max_len: number): list<list<any>>
    var res = []
    for item in content
        res->add(CenterLine(item, max_len))
    endfor
    return res
enddef


export def SpaceEvenly(contents: list<any>, max_len: number): list<any>
    var res = []
    var total_chars = 0
    for content in contents
        var this_str = content
        if type(content) != v:t_string
            this_str = content.ToString()
        endif
        total_chars += this_str->len()
    endfor
    var spaces = max_len - total_chars
    var slots = contents->len() - 1
    var spaces_per_slot = spaces / slots
    var extra_spaces = spaces % slots
    echow spaces_per_slot
    echow extra_spaces

    for i in range(contents->len())
        res->add(contents[i])
        if i != contents->len() - 1
            var added = 0
            if extra_spaces > 0
                added = 1
                extra_spaces -= 1
            endif

            res->add(repeat(" ", spaces_per_slot + added))
        endif
    endfor

    return res
enddef
#echow join(SpaceEvenly(["hello", Button("Btn"), "Another thing", Button("Other")], TEXT_WIDTH), "")

export def JustifyLine(left: any, right: any, max_len: number): list<any>
    var result = []

    var left_str = left
    var right_str = right
    # Check if either are butttons
    if type(left) != v:t_string
        left_str = left.ToString()
    endif
    if type(right) != v:t_string
        right_str = right.ToString()
    endif

    var spaces = max_len - left_str->len() - right_str->len()

    return [left, repeat(' ', spaces), right]
enddef

export def JustifyLines(left: list<any>, right: list<any>, max_len: number): list<list<any>>
    var result = []

    var shorter_length = min([left->len(), right->len()])

    var i = 0
    while i < shorter_length
        #var spaces = max_len - left[i]->len() - right[i]->len()
        #result->add(left[i] .. repeat(" ", spaces) .. right[i])
        result->add(JustifyLine(left[i], right[i], max_len))
        ++i
    endwhile
    while i < left->len()
        var spaces = max_len - left[i]->len()
        result->add([left[i], repeat(" ", spaces)])
        ++i
    endwhile
    while i < right->len()
        var spaces = max_len - right[i]->len()
        result->add([repeat(" ", spaces), right[i]])
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
    self.GetFrame = (): list<list<any>> => []
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
        self.game_ref.Render()
    }
    var exit_btn = Button("Exit")
    exit_btn.OnSelect = () => {
        g:manager.CloseAllWindows()
    }

    self.GetFrame = () => {
        return CenterLines(Art.intro_art + [
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
            return JustifyLines(left, right, TEXT_WIDTH)
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
            return JustifyLines(left, right, TEXT_WIDTH)
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
        return $'It is: {strftime("%I:%M %p on %A")}'
    }

    self.GetFrame = () => {
        #return self.GetIntroText() + [goto_farm_btn] + ["Visitor:", self.game_ref.town.visitor]
        var visitor = self.game_ref.town.visitor
        var btn = Button("Speak", () => {
            echow $"Speaking with: {visitor}"
            self.state_machine.TransitionTo("Dialogue", { with: visitor })
            self.game_ref.Render()
        })
        var left = [self.GetIntroText(), "", $"Today's Visitor: {visitor}", btn, goto_farm_btn]
        var right = Art.mountains
        return JustifyLines(left, right, TEXT_WIDTH)
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
            self.state_machine.TransitionTo("Overworld")
        endif
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
        endif
    }

    self.GetFrame = () => {
        var cur_dialogue = self.dialogues[self.progress]
        var left = cur_dialogue + ["", self.next_btn]
        var right = Art.character_1
        return JustifyLines(left, right, TEXT_WIDTH)
    }

    return self
enddef
