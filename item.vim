vim9script

export def Item(name: string, buy_price: number, sell_price: number, category: string): dict<any>
    final self: dict<any> = {
        name: name,
        buy_price: buy_price,
        sell_price: sell_price,
        category: category,
    }
    return self
enddef
