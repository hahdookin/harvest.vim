vim9script

import "../art.vim" as Art
import "../button.vim"
import "../globals.vim"
import "../math.vim" as Math
import "../ui.vim" as UI
import "../states.vim"

const GameState = states.GameState
const Button = button.Button
const TEXT_WIDTH = globals.TEXT_WIDTH

const fishes = [
  'Angelfish',
  'Barracuda',
  'Grouper',
  'Piranha',
  'Triggerfish',
]

const fishes_art = [
    Art.ArtToUIFrame(Art.Styled(Art.fish_1)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_2)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_3)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_4)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_5)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_6)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_7)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_8)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_9)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_10)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_11)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_12)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_13)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_14)),
    Art.ArtToUIFrame(Art.Styled(Art.fish_15)),
]

export def Fish(name: string, desc: string): dict<any>
    final self: dict<any> = {
        name: name,
        desc: desc,
        likelihood: 0.5,
        season: "fall",
    }

    return self
enddef

export def FishingState(): dict<any>
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
    self.show_catch = false
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
        self.catch = true # Math.Randf() > 0.5
        self.show_catch = false
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
            self.show_catch = true
        elseif self.fishing_state == FISHING_STATE.CATCH_FAILURE
            self.progress = 'Better luck next time...'
            self.show_catch = true
        endif
    }

    self.GetFrame = () => {
        var left: list<any> = [
            [overworld_btn],
            [cast_btn],
            [self.progress],
            # [], # [self.output],
            # [], # [$"num_ticks: {self.num_ticks}"],
            # [], # [$"ticks_til_catch: {self.ticks_til_catch}"],
            # [], # [$"catch: {self.catch}"],
            # [], # [$"current_frame: {self.current_frame}"],
        ]
        if self.fishing_state == FISHING_STATE.CATCH_SUCCESS && self.show_catch
            # left += Art.ArtToUIFrame(Art.fish_4)
            const keep_btn = Button("Keep")
            const release_btn = Button("Release")
            const art = Math.RandChoice(fishes_art)
            const btns = [ [keep_btn], [release_btn] ]
            left += UI.JustifyLines(art, btns, 32)
        endif


        var right = FISHING_STATE_FRAMES[self.fishing_state][self.current_frame]

        self.IncrementAnimFrame()
        return UI.JustifyLines(left, right, TEXT_WIDTH)
        # return left
    }

    return self
enddef
