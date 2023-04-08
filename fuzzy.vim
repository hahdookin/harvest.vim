vim9script

popup_clear()

class FuzzyFind
    this.search_values: list<any>
    this.prompt_bufnr: number
    this.popup_bufnr: number
    this.prompt_winid: number
    this.popup_winid: number
    this.last_win: number
    def new(this.search_values)
        this.last_win = win_getid()
        botright :1new
        startinsert
        this.prompt_bufnr = bufnr()
        #imap <buffer> <CR> <C-c>:call g:FuzzyOnEnter(getline('.'))<CR>a<ESC>
        bufload(this.prompt_bufnr)
        setbufvar(this.prompt_bufnr, '&buftype', 'nofile')
        setbufvar(this.prompt_bufnr, '&bufhidden', 'hide')
        setbufvar(this.prompt_bufnr, '&buflisted', 0)
        setbufvar(this.prompt_bufnr, '&number', 0)
        setbufvar(this.prompt_bufnr, '&relativenumber', 0)
        setbufvar(this.prompt_bufnr, '&rnu', 0)
        this.prompt_winid = win_findbuf(this.prompt_bufnr)[0]
        this.popup_winid = popup_create(search_values, {
            pos: 'botleft',
            line: 'cursor-1',
            col: 'cursor'
        })
        this.popup_bufnr = winbufnr(this.popup_winid)
    enddef

    def Match(query: string): list<any>
        return matchfuzzy(this.search_values, query)
    enddef

    def UpdateResults()
        const query = getline(1)
        const display = query == "" ? this.search_values : matchfuzzy(this.search_values, query)
        win_execute(this.popup_winid, ':%d')
        for i in range(len(display))
            setbufline(this.popup_bufnr, i + 1, display[i])
        endfor
    enddef
    def DeleteBuffers()
        win_execute(this.prompt_winid, "close")
        popup_close(this.popup_winid)
        execute $'bw {this.prompt_bufnr} {this.popup_bufnr}'
        win_gotoid(this.last_win)
    enddef
    def OnEnter()
        const query = getline('.')
        win_execute(this.last_win, "edit " .. matchfuzzy(systemlist('ls'), query)[0])
    enddef
endclass

def InitFuzzyFind()
    g:fuzzy_find = FuzzyFind.new(systemlist('ls'))
    augroup fuzzy
        au!
        au InsertLeave <buffer> g:fuzzy_find.DeleteBuffers()
        au TextChangedI <buffer> g:fuzzy_find.UpdateResults()
    augroup END
    imap <buffer> <CR> <ScriptCmd>g:fuzzy_find.OnEnter()<CR><ESC>
enddef

InitFuzzyFind()

