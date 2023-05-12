vim9script

import "./states.vim" as states_ns
import "./states/FishingState.vim"

const TitleScreen = states_ns.TitleScreen
const StartGame = states_ns.StartGame
const Overworld = states_ns.Overworld
const FarmState = states_ns.FarmState
const ShopState = states_ns.ShopState
# const FishState = states_ns.FishState
# const FishState = states_ns.FishState
const Dialogue = states_ns.Dialogue

export def StateMachine(game_ref: dict<any>, starting_state_name: string): dict<any>
    final self: dict<any> = {
        current_state: null,
        game_ref: game_ref,
        state_stack: []
    }
    var states = {
        'TitleScreen': TitleScreen,
        'StartGame': StartGame,
        'Overworld': Overworld,
        'FarmState': FarmState,
        'ShopState': ShopState,
        'FishingState': FishingState.FishingState,
        'Dialogue': Dialogue
    }

    self.PushState = (state_name, msg = {}) => {
        var state_instance = states[state_name]()
        state_instance.AddStateMachine(self)
        state_instance.AddGameRef(self.game_ref)
        state_instance.Enter(msg)
        self.state_stack->add(state_instance)
    }
    
    self.PopState = () => {
        self.state_stack[-1].Exit()
        self.state_stack->remove(-1)
    }

    self.TransitionTo = (state_name, msg = {}) => {
        self.game_ref.manager.buttons = []
        self.PopState()
        self.PushState(state_name, msg)
    }

    self.GetCurrentState = () => {
        return self.state_stack[-1]
    }

    self.PushState(starting_state_name)

    return self
enddef
