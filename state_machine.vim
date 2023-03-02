vim9script

import "./states.vim" as states_ns

const TitleScreen = states_ns.TitleScreen
const StartGame = states_ns.StartGame
const Overworld = states_ns.Overworld
const FarmState = states_ns.FarmState
const Dialogue = states_ns.Dialogue

export def StateMachine(game_ref: dict<any>, starting_state_name: string): dict<any>
    final self: dict<any> = {
        current_state: null,
        states: {},
        game_ref: game_ref
    }
    var states = {
        "TitleScreen": TitleScreen(),
        "StartGame": StartGame(),
        "Overworld": Overworld(),
        "FarmState": FarmState(),
        "Dialogue": Dialogue()
    }
    self.states = states
    for state in self.states->values()
        state.state_machine = self
        state.game_ref = game_ref
    endfor
    self.current_state = states[starting_state_name]
    self.current_state.Enter()

    self.TransitionTo = (state_name, msg = {}) => {
        g:manager.buttons = []
        self.current_state.Exit()
        self.current_state = self.states[state_name]
        self.current_state.Enter(msg)
    }

    return self
enddef
