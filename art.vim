vim9script

set cpo+=C

export def ArtToUIFrame(art: list<string>): list<list<string>>
    return art->mapnew((_, val) => [val])
enddef

final DEFAULT_OPTIONS = {}
DEFAULT_OPTIONS.padding = [0, 0, 0, 0] # T R B L
DEFAULT_OPTIONS.vert_border = '|'
DEFAULT_OPTIONS.horiz_border = '-'
DEFAULT_OPTIONS.corners = "..`'" # TL TR BL BR

# Requires an art that has a ` |` at the end of each line
export def Styled(art: list<string>, options = {}): list<string>
    const opts = extendnew(DEFAULT_OPTIONS, options)
    const res = art->mapnew((_, val) => {
        const padding_right = ' '->repeat(opts.padding[1])
        const padding_left = ' '->repeat(opts.padding[3])
        const border = opts.vert_border
        const stripped = val[ : -3 ]
        return $'{border}{padding_left}{stripped}{padding_right}{border}'
    })
    const total_padding_horiz = opts.padding[1] + opts.padding[3]
    const horiz_len = art[0]->strdisplaywidth() - 2 + total_padding_horiz
    const horiz = repeat(opts.horiz_border, horiz_len)
    const horiz_empty = repeat(' ', horiz_len)
    const top = $'{opts.corners[0]}{horiz}{opts.corners[1]}'
    const bot = $'{opts.corners[2]}{horiz}{opts.corners[3]}'
    const padding_top_bot = $'{opts.vert_border}{horiz_empty}{opts.vert_border}'
    const padding_top = [padding_top_bot]->repeat(opts.padding[0])
    const padding_bot = [padding_top_bot]->repeat(opts.padding[2])
    return [top] + padding_top + res + padding_bot + [bot]
enddef

export var intro_art =<< END
.-=-=-=-=-=-=-=-=-=-=-=-=-.
|   .           .         |
|\_      _  *        *   /|
|  \,   ((        .    _/ |
| __ \_  `          _^/  ^|
|/  \-'\      *    /.' ^_ |
|    \ /==~=-=~=-=-;.  _/ |
|-'.--\ =-=~_=-=~=^/  _ `-|
|      `.~-^=-=~=^=.-'    |
`-=-=-=-=-=-=-=-=-=-=-=-=-'
END

export var mountains =<< END
.-=-=-=-=-=-=-=-=-=-=-=-=-.
|        _    .  ,   .    |
|    *  / \_ *  / \_      |
|      /    \  /    \,    |
| .   /\/\  /\/ :' __ \_  |
|    /    \/  \  _/  \-'\ |
|  /\  .-   `. \/     \ /\|
| /  `-.__ ^   / .-'.--\  |
|/        `.  / /       `.|
`-=-=-=-=-=-=-=-=-=-=-=-=-'
END

export var shop_interior =<< END

END

export var game_map_start =<< END
.-=-=-=-=-=-=-=-=-=-=-=-=-.
|      |    |    |        |
|      |    |    |        |
:      $    ?    x        :
:       \   |   /         :
.        \  |  /          .
:         \ | /           :
:          \|/            :
|           O             |
|                         |
`-=-=-=-=-=-=-=-=-=-=-=-=-'
END

export var game_map_mid =<< END
.-=-=-=-=-=-=-=-=-=-=-=-=-.
|      |    |    |        |
|      |    |    |        |
:      x    $    ?        :
:      |    |    |        :
.      |    |    |        .
:      |    |    |        :
:      |    |    |        :
|      |    |    |        |
|      |    |    |        |
`-=-=-=-=-=-=-=-=-=-=-=-=-'
END

export var character_1 =<< END
.-=-=-=-=-=-=-=-=-=-=-=-=-.
|      _  .   .   .       |
|    .' '; '-' '-'|-.     |
|   (     '------.'  )    |
|    ;            \ /     |
|     :     '   ' |/      |
|     '._._       \    .; |
|    .-'   ;--.    '--' / |
|   /      \-'---.___.'   |
|  |     / 7 \(>o<) /\    |
`-=-=-=-=-=-=-=-=-=-=-=-=-'
END

export var fishing_cast_1 =<< END
           '\       .            |
          '  \  (..)             |
        '     \@  |              |
      '        `\/|              |
    '           __|     *   *    |
  '           //| |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END
export var fishing_cast_2 =<< END
           '\       ..           |
          '  \  (..)             |
        '     \@  |              |
      '        `\/|              |
    '           __|     *   *    |
  '           //| |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END
export var fishing_cast_3 =<< END
           '\       ...          |
          '  \  (..)             |
        '     \@  |              |
      '        `\/|              |
    '           __|     *   *    |
  '           //| |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fishing_bite =<< END
           '\       !            |
          '  \  (oo)             |
        '     \@  |              |
      '        `\/|              |
    '            /|     *   *    |
  '              \|   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fishing_reel_1 =<< END
           '\       ,            |
          '  \  (><)             |
        '     \@  |              |
      '        `\/|              |
    '            /|     *   *    |
  '             / |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fishing_reel_2 =<< END
           \        .            |
          ' \   (><)             |
        '    \@   |              |
      '        `\/|              |
    '            /|     *   *    |
  '             | |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fishing_catch_success =<< END
           '\                    |
           ' \  (^^)             |
           A  \@  |              |
           ^   `\/|              |
                __|     *   *    |
              //| |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fishing_catch_failure =<< END
           '\                    |
           ' \  (--)             |
           J  \@  |              |
               `\/|              |
                __|     *   *    |
              //| |   (/  )/     |
'~-~-~-~-~-~""""""""""*""""""*"" |
~-~-~-~"""""""""""""")/"""""(/"  |
END

export var fish_1 =<< END
  _  |
><_> |
END

export var fish_2 =<< END
 __v_    |
(____\/{ |
END

export var fish_3 =<< END
  ;,//;,    ,;/ |
 o:::::::;;///  |
>::::::::;;\\\  |
  ''\\\\\'" ';\ |
END

export var fish_4 =<< END
      /"*._         _ |
  .-*'`    `*-.._.-'/ |
< * ))     ,       (  |
  `*-._`._(__.--*"`.\ |
END

export var fish_5 =<< END
   _\_  |
\\/  o\ |
//\___= |
   ''   |
END

export var fish_6 =<< END
      .       |
\_____)\_____ |
/--v____ __`< |
        )/    |
        '     |
END

export var fish_7 =<< END
|\   \\\\__  |
| \_/    o \ |
> _   (( <_  |
| / \__+___/ |
|/     |/    |
END

export var fish_8 =<< END
      /`·.¸         |
     /¸...¸`:·      |
 ¸.·´  ¸   `·.¸.·´) |
: © ):´;      ¸  {  |
 `·.¸ `·  ¸.·´\`·¸) |
     `\\´´\¸.·´     |
END

export var fish_9 =<< END
      /\         |
    _/./         |
 ,-'    `-:..-'/ |
: o )      _  (  |
"`-....,--; `-.\ |
    `'           |
END

export var fish_10 =<< END
         ,      |
      .:/       |
  ,,///;,   ,;/ |
 o)::::::;;///  |
>::::::::;;\\\  |
  ''\\\\\'" ';\ |
     ';\        |
END

export var fish_11 =<< END
     |\     |
    |  \    |
|\ /    .\  |
| |       ( |
|/ \     /  |
    |  /    |
     |/     |
END

export var fish_12 =<< END
      \/)/)     |
    _'  oo(_.-. |
  /'.     .---' |
/'-./    (      |
)     ; __\     |
\_.'\ : __|     |
     )  _/      |
    (  (,.      |
     '-.-'      |
END

export var fish_13 =<< END
       .'.'       |
      .'-'.       |
  .  (  o O)      |
   \_ `  _,   _   |
-.___'.) ( ,-'    |
     '-.O.'-..-.. |
 ./\/\/ | \_.-._  |
        ;         |
     ._/          |
END

export var fish_14 =<< END
  _____     ____  |
 /      \  |  o | |
|        |/ ___\| |
|_________/       |
|_|_| |_|_|       |
END

export var fish_15 =<< END
 ____        |
 )  =\       |
/    =\      |
\      `-._  |
 )__(`\____) |
END

export var fish_16 =<< END
 ____  |
|,--.| |
||__|| |
|+  o| |
|,'o | |
`----' |
END

export var fish_17 =<< END
    .---.     |
   /     \    |
   \.@-@./    |
   /`\_/`\    |
  //  _  \\   |
 | \     )|_  |
/`\_`>  <_/ \ |
\__/'---'\__/ |
END

export var fish_18 =<< END
 _________  |
|^|     | | |
| |_____| | |
|  _____  | |
| |     | | |
| |_____| | |
|_|_____|_| |
END

export var fish_19 =<< END
  ,sSSs    |
,SSSS_/ ,_ |
sS/`))\//  |
S//|_(\/   |
S\\|::\    |
SS` \:|    |
     \|__  |
     /:::\ |
     \:`'` |
END

export var fish_20 =<< END
   |    |
 .'|'.  |
/.'|\ \ |
| /|'.| |
 \ |\/  |
  \|/   |
   `    |
END

export var book_1 =<< END
   ,   , |
  /////| |
 ///// | |
|~~~|  | |
|===|  | |
| v |  | |
| i |  | |
| m | /  |
|===|/   |
'---'    |
END

export var book_2 =<< END
        _.-"\       |
    _.-"     \      |
 ,-"          \     |
( \            \    |
 \ \            \   |
  \ \            \  |
   \ \         _.-; |
    \ \    _.-"   : |
     \ \,-"    _.-" |
      \(   _.-"     |
       `--"         |
END

set cpo-=C
var styled = Styled(fish_8, {
    padding: [0, 1, 0, 1],
    corners: "$$$$"
})
# for line in styled
#     echo line
# endfor
