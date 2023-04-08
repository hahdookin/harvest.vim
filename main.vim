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
const Farm = states.Farm
const TextPosition = text_position.TextPosition
const PlantedCrop = states.PlantedCrop
const Crop = states.Crop

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
        farm: null,
        manager: manager,
        state_machine: null
    }
    self.state_machine = StateMachine(self, "Overworld")
    #self.state_machine = StateMachine(self, "TitleScreen")
    self.player = Player()
    self.town = Town()
    self.farm = Farm()
    var now = localtime()
    self.farm.AddCrop(PlantedCrop(Crop("Carrot", 30), now))
    self.farm.AddCrop(PlantedCrop(Crop("Eggplant", 30), now))

    self.Render = () => {
        # Clear previous buttons
        self.manager.buttons = []

        # Update state logic
        self.state_machine.GetCurrentState().Update()

        # Create framebuffer (array of strings) to send to screen (manager)
        var lines = []
        for list in self.state_machine.GetCurrentState().GetFrame()
            var line = ""
            for item in list
                if type(item) != v:t_string
                    # Button here
                    self.manager.AddButton(item, lines->len() + 1, line->len() + 1)
                    line ..= item.ToString()
                else
                    # String here
                    line ..= item
                endif
            endfor
            lines->add(line)
        endfor
        self.manager.DrawLines(lines)
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
    setbufvar(bufnr, '&relativenumber', 0)
    setbufvar(bufnr, '&rnu', 0)

    var cmds = [
        'noremap <buffer><silent> <CR> :call g:manager.OnEnterPressed(line("."), col("."))<CR>',
        'noremap <buffer><silent> <TAB> :call g:manager.NextButton()<CR>',
    ]
    for cmd in cmds
        autocmd_add([{ event: 'BufEnter', bufnr: self.bufnr, cmd: cmd}])
    endfor

    self.NextButton = () => {
        var cursor = TextPosition(line('.'), col('.'))
        # Find closest 
        for button in self.buttons
            var btn_pos = button.pos
            if btn_pos.lnum < cursor.lnum 
                continue
            elseif btn_pos.lnum == cursor.lnum
                if btn_pos.col > cursor.col
                    button.pos.CursorTo()
                endif
            endif
        endfor
    }

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
            resize 14
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
            for i in range(lines->len())
                if type(lines[i]) == v:t_string
                    lines[i] = DelayedText(lines[i])
                endif
            endfor

            for i in range(lines->len())
                execute $'sleep {lines[i].delay}m'
                if i == 0
                    self.SetBufLine(1, lines[i].text)
                else
                    self.AddBufLine(lines[i].text)
                endif
                redraw!
            endfor

            if self.buttons->len() > 0
                self.buttons[0].pos.CursorTo()
            endif
        endif
    }

    self.AddButton = (button, linenr = -1, col = -1) => {
        var pos = TextPosition(linenr, col)
        self.buttons->add({ pos: pos, button: button })
    }

    self.OnEnterPressed = (lnum, col) => {
        var text_pos = TextPosition(lnum, col)
        for button in self.buttons
            var btn_display_length = button.button.DisplayLength()
            var btn_start = button.pos
            var btn_end = TextPosition(btn_start.lnum, btn_start.col + btn_display_length - 1)
            if text_pos.Between(btn_start, btn_end)
                button.button.OnSelect()
                return
            endif
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
map <leader>ho :echo g:game
map <leader>hi :echo g:manager

