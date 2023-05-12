vim9script

import "../button.vim"
import "../globals.vim"
import "../ui.vim" as UI
import "../states.vim"

const Button = button.Button

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


export def Farm(): dict<any>
    final self: dict<any> = {
        plots: []
    }

    self.AddCrop = (crop) => {
        self.plots->add(crop)
    }

    return self
enddef

export def FarmState(): dict<any>
    final self = states.GameState()

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
            UI.SpaceEvenly(crops, globals.TEXT_WIDTH, [20, 20]),
            [""],
            [overworld_btn]
        ]
    }

    return self
enddef
