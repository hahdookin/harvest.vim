vim9script

import "../art.vim" as Art
import "../button.vim"
import "../globals.vim"
import "../math.vim" as Math
import "../ui.vim" as UI
import "../item.vim"
import "../states.vim"

const GameState = states.GameState
const Button = button.Button
const Item = item.Item
const TEXT_WIDTH = globals.TEXT_WIDTH

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


#+---+---+---+---+      +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  <-  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+  ->  +---+---+---+---+
#|   |   |   |   |      |   |   |   |   |
#+---+---+---+---+      +---+---+---+---+
export def ShopState(): dict<any>
    final self = GameState()

    self->extend({
        item_selected: false,
        selected_item: null,
        buttons: [],
    })

    const overworld_btn = Button("Overworld", () => {
        self.state_machine.TransitionTo("Overworld")
        self.game_ref.Render()
    })

    const go_back_btn = Button("Go back", () => {
        self.item_selected = false
        self.game_ref.Render()
    })

    self.Enter = (msg = {}) => {
        const items = self.game_ref.shop.items
        self.items = items
        self.lines = self.GenerateShop(items)
    }

    self.Update = () => {
        # echow self.game_ref
    }

    const rows = 3
    const cols = 4
    const slots = rows * cols

    const horiz_sep_start = '+---'
    const horiz_sep_end = '---+'
    const horiz_sep_mid = repeat(['+'], cols - 1)->join('---')
    const horiz_sep = horiz_sep_start .. horiz_sep_mid .. horiz_sep_end
    const vert_sep_start = '| '
    const vert_sep_mid   = ' | '
    const vert_sep_end   = ' |'

    self.GenerateShop = (items: list<any>) => {
        self.buttons = self.items->mapnew((_, val) => Button(val.category, () => {
            self.item_selected = true
            self.selected_item = val
            self.game_ref.Render()
        }, '%s'))
        for i in range(slots - self.buttons->len())
            self.buttons->add(null)
        endfor
        final lines: list<any> = [[horiz_sep]]
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
        return lines
    }

    self.GetFrame = () => {
        var left: list<any> = []
        var right: list<any> = []
        if self.item_selected
            var On_buy_btn_pressed = () => {
                self.game_ref.player.AddItem(self.selected_item)
            }
            left->add([$'You are viewing item: {self.selected_item.name}'])
            left->add([$'Cost: {self.selected_item.buy_price}'])
            left->add([Button("Buy", On_buy_btn_pressed)])
            left->add([''])
            left->add([go_back_btn])
        else
            left->add(["Welcome to the shop!"])
            for line in self.lines
                left->add(line)
            endfor
            left->add([""])
            left->add([overworld_btn])
            right = Art.ArtToUIFrame(Art.character_1)
        endif

        return UI.JustifyLines(left, right, TEXT_WIDTH)
    }

    return self
enddef

