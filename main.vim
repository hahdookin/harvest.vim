vim9script

import "./art.vim" as Art
import "./event.vim" as Event
import "./entity.vim" as Entity
import "./ability.vim" as Ability
import "./state_machine.vim"
import "./states.vim"
import "./text_position.vim"

const Player = Entity.Player
const Enemy = Entity.Enemy
const Attack = Ability.Attack
const StateMachine = state_machine.StateMachine
const Town = states.Town
const TextPosition = text_position.TextPosition

def DelayedText(text: string, delay: number = 50): dict<any>
    final self: dict<any> = {
        text: text,
        delay: delay
    }

    return self
enddef


def Game(manager: dict<any>): dict<any>
    final self: dict<any> = {
        town: null,
        player: null,
        manager: manager,
        state_machine: null
    }
    self.state_machine = StateMachine(self, "Overworld")
    self.player = Player()
    self.town = Town()

    self.Render = () => {
        # Clear previous buttons
        self.manager.buttons = []

        # Update state logic
        self.state_machine.current_state.Update()

        # Create framebuffer (array of strings) to send to screen (manager)
        var lines = []
        for line in self.state_machine.current_state.GetFrame()
            if type(line) != v:t_string
                # Button here
                lines->add(line.ToString())
                var this_button_linenr = lines->len()
                self.manager.AddButton(line, this_button_linenr)
            else
                lines->add(line)
            endif
        endfor
        self.manager.DrawLines(lines)
    }

    self.PrintState = () => {
        echow self.state_machine.current_state.GetName()
    }


    return self
enddef

def Manager(bufnr: number): dict<any>
    final self: dict<any> = {
        bufnr: bufnr,
        buttons: []
    }

    bufload(bufnr)

    setbufvar(bufnr, '&buftype', 'nofile')
    setbufvar(bufnr, '&bufhidden', 'hide')
    setbufvar(bufnr, '&buflisted', 0)
    setbufvar(bufnr, '&modifiable', 0)

    setbufvar(bufnr, '&number', 0)
    setbufvar(bufnr, '&rnu', 0)

    var cmd = 'noremap <silent> <CR> :call g:manager.OnEnterPressed(line("."))<CR>'
    autocmd_add([{ event: 'BufEnter', bufnr: self.bufnr, cmd: cmd}])

    self.AddBufLine = (text: string) => {
        setbufvar(bufnr, '&modifiable', 1)
        appendbufline(self.bufnr, '$', text)
        setbufvar(bufnr, '&modifiable', 0)
    }

    self.SetBufLine = (linenr: number, text: string) => {
        setbufvar(bufnr, '&modifiable', 1)
        setbufline(self.bufnr, linenr, text)
        setbufvar(bufnr, '&modifiable', 0)
    }

    self.Open = () => {
        if !self.IsOpenInWindow()
            execute "sbuffer " .. bufnr
        endif
    }
    self.CloseAllWindows = () => {
        for winid in win_findbuf(self.bufnr)
            win_execute(winid, "close")
        endfor
    }

    self.Toggle = () => {
        if self.IsOpenInWindow()
            self.CloseAllWindows()
        else
            self.Open()
        endif
    }

    self.IsOpenInWindow = () => {
        for win in getwininfo()
            if win.bufnr == self.bufnr
                return true
            endif
        endfor
        return false
    }

    self.GetWinId = () => {
        var wins = win_findbuf(self.bufnr)
        if wins->len() > 0
            return wins[0]
        endif
        return -1
    }

    self.ClearBuffer = () => {
        var wins = win_findbuf(self.bufnr)
        if wins->len() > 0
            setbufvar(bufnr, '&modifiable', 1)
            win_execute(wins[0], ":%delete")
            setbufvar(bufnr, '&modifiable', 0)
        endif
    }

    self.DrawLines = (lines) => {
        self.ClearBuffer()
        if lines->len() > 0
            # Check if a lines starts with <<[DELAY] and extract the delay
            for i in range(lines->len())
                #var match = matchstrpos(lines[i], "^<<[.\\{-\}\\]")
                #if match[0] != ""
                    #var nr_part = str2nr(match[0][match[1] + 3 : match[2] - 1])
                    #if nr_part == 0
                        #lines[i] = lines[i][1 : ]
                        #lines[i] = DelayedText(lines[i])
                    #else
                        #lines[i] = DelayedText(lines[i], nr_part)
                    #endif
                #else
                    #lines[i] = DelayedText(lines[i])
                #endif
                if type(lines[i]) == v:t_string
                    lines[i] = DelayedText(lines[i])
                endif
            endfor

            execute $'sleep {lines[0].delay}m'
            self.SetBufLine(1, lines[0].text)
            redraw!

            for i in range(1, lines->len() - 1)
                execute $'sleep {lines[i].delay}m'
                self.AddBufLine(lines[i].text)
                redraw!
            endfor

            if self.buttons->len() > 0
                cursor(self.buttons[0].linenr, 1)
            endif
        endif
    }

    self.AddButton = (button, linenr = -1) => {
        #self.AddBufLine(button.ToString())
        var ln = linenr
        if linenr == -1
            ln = line('$', self.GetWinId()) - 1
        endif
        self.buttons->add({ linenr: ln, button: button })
    }

    self.OnEnterPressed = (linenr) => {
        for button in self.buttons
            if button.linenr == linenr
                button.button.OnSelect()
                return
            endif
        endfor
    }

    self.PrintButtons = () => {
        for btn in self.buttons
            echow btn
        endfor
    }


    return self
enddef

# Needs to be global for access in autocmd in constructor
g:manager = Manager(bufadd('Animal Crossing'))
g:game = Game(g:manager)

g:manager.Open()
g:game.Render()

map <leader>hh <ScriptCmd>g:manager.Toggle()<CR>
map <leader>ho :echow g:game

