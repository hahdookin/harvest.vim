vim9script

import "./art.vim" as Art
import "./button.vim"
import "./math.vim" as Math
import "./ui.vim" as UI
import "./item.vim"

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

const fishes = [
  'Angelfish',
  'Barracuda',
  'Grouper',
  'Piranha',
  'Triggerfish',
]

const fishes_art = [
    Art.ArtToUIFrame(Art.fish_1),
    Art.ArtToUIFrame(Art.fish_2),
    Art.ArtToUIFrame(Art.fish_3),
    Art.ArtToUIFrame(Art.fish_4),
    Art.ArtToUIFrame(Art.fish_5),
    Art.ArtToUIFrame(Art.fish_6),
    Art.ArtToUIFrame(Art.fish_7),
    Art.ArtToUIFrame(Art.fish_8),
    Art.ArtToUIFrame(Art.fish_9),
    Art.ArtToUIFrame(Art.fish_10),
    Art.ArtToUIFrame(Art.fish_11),
    Art.ArtToUIFrame(Art.fish_12),
    Art.ArtToUIFrame(Art.fish_13),
    Art.ArtToUIFrame(Art.fish_14),
    Art.ArtToUIFrame(Art.fish_15),
]

const Button = button.Button
const Item = item.Item
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

export def Shop(): dict<any>
    final self: dict<any> = {}
    self.items = [
        Item("Fishing Pole I", 100, 50, 'e'),
        Item("Shovel I", 200, 100, 'e'),
        Item("Hoe II", 300, 150, 'e'),
        Item("Couch", 300, 150, 'c'),
        Item("Jeans", 300, 150, 'c'),
        Item("Iced Coffee", 300, 150, 'f'),
        Item("Matcha Tea Powder", 300, 150, 'f'),
    ]
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

#+---+---+---+---+      +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  <-  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  ->  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+      +---+---+---+---+
export def ShopState(): dict<any>
    final self = GameState()

    var overworld_btn = Button("Overworld", () => {
        self.state_machine.TransitionTo("Overworld")
        self.game_ref.Render()
    })

    self.Update = () => {
        # echow self.game_ref
    }

    const rows = 3
    const cols = 4
    const slots = rows * cols
    self.buttons = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i']
    # self.buttons = self.items->mapnew((_, item) => Button(item.category, () => {
    #     # echow $"Name: {item.name} Buy: {item.buy_price} Sell: {item.sell_price}"
    #     echow $"Name: {item.name}"
    # }, '%s'))
    self.buttons->map((_, val) => Button(val, () => {
        echow $"Button: {val}"
    }, '%s'))
    for i in range(slots - self.buttons->len())
        self.buttons->add(null)
    endfor

    const horiz_sep_start = '+---'
    const horiz_sep_end = '---+'
    const horiz_sep_mid = repeat(['+'], cols - 1)->join('---')
    const horiz_sep = horiz_sep_start .. horiz_sep_mid .. horiz_sep_end
    const vert_sep_start = '| '
    const vert_sep_mid   = ' | '
    const vert_sep_end   = ' |'

    var lines: list<any> = [[horiz_sep]]
    var cur_row: list<any> = []
    for row in range(rows)
        cur_row->add(vert_sep_start)
        for col in range(cols)
            var btn = self.buttons[row * cols + col]
            cur_row->add(btn ?? " ")
            cur_row->add(col == cols - 1 ? '' : vert_sep_mid)
        endfor
        cur_row->add(vert_sep_end)
        lines->add(cur_row)
        lines->add([horiz_sep])
        cur_row = []
    endfor

    self.GetFrame = () => {
        var player = self.game_ref.player
        var left: list<any> = []
        left->add(["Welcome to the shop!"])
        for line in lines
            left->add(line)
        endfor
        left->add([""])
        left->add([overworld_btn])
        # var right = Art.fish_3->mapnew((_, val) => [val])
        var right = Art.ArtToUIFrame(Art.character_1)
        return UI.JustifyLines(left, right, TEXT_WIDTH)
        # return left
    }

    return self
enddef

export def FishState(): dict<any>
    final self = GameState()

    const MAX_TICKS = 6
    const FISHING_STATE = {
        CAST: 0,
        BITE: 1,
        REEL: 2,
        CATCH_SUCCESS: 3,
        CATCH_FAILURE: 4,
    }
    const FISHING_STATE_MAP = [
        'CAST',
        'BITE',
        'REEL',
        'CATCH_SUCCESS',
        'CATCH_FAILURE',
    ]

    const FISHING_STATE_FRAMES = [
        [
            Art.ArtToUIFrame(Art.Styled(Art.fishing_cast_1)),
            Art.ArtToUIFrame(Art.Styled(Art.fishing_cast_2)),
            Art.ArtToUIFrame(Art.Styled(Art.fishing_cast_3)),
        ],
        [
            Art.ArtToUIFrame(Art.Styled(Art.fishing_bite)),
        ],
        [
            Art.ArtToUIFrame(Art.Styled(Art.fishing_reel_1)),
            Art.ArtToUIFrame(Art.Styled(Art.fishing_reel_2)),
        ],
        [
            Art.ArtToUIFrame(Art.Styled(Art.fishing_catch_success)),
        ],
        [
            Art.ArtToUIFrame(Art.Styled(Art.fishing_catch_failure)),
        ],
    ]
    const FISHING_STATE_FRAMES_COUNT = FISHING_STATE_FRAMES->mapnew((_, val) => {
        return val->len()
    })

    self.fishing_state = FISHING_STATE.CAST
    self.output = ''
    self.progress = ''
    self.catch = false
    self.caught_fish_index = -1
    self.num_ticks = 0
    self.ticks_til_catch = 0
    self.current_frame = 0

    var overworld_btn = Button("Overworld", () => {
        self.state_machine.TransitionTo("Overworld")
        self.game_ref.Render()
    })

    self.DoFishing = () => {
        self.progress = ''
        self.catch = Math.Randf() > 0.5
        self.num_ticks = 0
        self.ticks_til_catch = self.catch ? 1 + Math.RandInt(MAX_TICKS - 1) : MAX_TICKS
        self.caught_fish_index = Math.RandInt(fishes->len())
        # self.fishing_state = FISHING_STATE.CAST
        self.UpdateFishingState(FISHING_STATE.CAST)
        self.game_ref.Render()
        sleep 1000m
        # self.fishing_state = FISHING_STATE.REEL
        self.UpdateFishingState(FISHING_STATE.REEL)
        for i in range(self.ticks_til_catch)
            self.progress ..= '-'
            self.num_ticks += 1
            self.game_ref.Render()
            sleep 1000m
        endfor
        
        # Render the result
        self.game_ref.Render()
    }

    var cast_btn = Button('Fish', self.DoFishing)

    self.IncrementAnimFrame = () => {
        const frame_count = FISHING_STATE_FRAMES_COUNT[self.fishing_state]
        self.current_frame += 1
        self.current_frame %= frame_count
    }

    self.UpdateFishingState = (state: number) => {
        self.fishing_state = state
        self.current_frame = 0
    }

    self.Update = () => {
        self.output = FISHING_STATE_MAP[self.fishing_state]
        if self.fishing_state == FISHING_STATE.CAST

        elseif self.fishing_state == FISHING_STATE.REEL
            if self.num_ticks == self.ticks_til_catch
                if self.catch
                    # self.fishing_state = FISHING_STATE.CATCH_SUCCESS
                    self.UpdateFishingState(FISHING_STATE.CATCH_SUCCESS)
                else
                    # self.fishing_state = FISHING_STATE.CATCH_FAILURE
                    self.UpdateFishingState(FISHING_STATE.CATCH_FAILURE)
                endif
            endif
        elseif self.fishing_state == FISHING_STATE.CATCH_SUCCESS
            const caught_fish = fishes[self.caught_fish_index]
            self.progress = $'Caught something! {caught_fish}'
        elseif self.fishing_state == FISHING_STATE.CATCH_FAILURE
            self.progress = 'Better luck next time...'
        endif
    }

    self.GetFrame = () => {
        var left: list<any> = [
            [self.progress],
            [], # [self.output],
            [], # [$"num_ticks: {self.num_ticks}"],
            [], # [$"ticks_til_catch: {self.ticks_til_catch}"],
            [], # [$"catch: {self.catch}"],
            [], # [$"current_frame: {self.current_frame}"],
            [cast_btn],
            [overworld_btn],
        ]
        var right = FISHING_STATE_FRAMES[self.fishing_state][self.current_frame]

        self.IncrementAnimFrame()
        return UI.JustifyLines(left, right, TEXT_WIDTH)
        # return left
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
        self.state_machine.PushState("FishState")
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
