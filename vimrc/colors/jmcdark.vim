" Vim color file
" Created by: JMC (2016-08-07). Updated: 2023-08-30.
" Version: 1.1
" Based on "desert256.vim" by Henry So, Jr. <henryso@panix.com>

" These are the colors of the "darkblue" theme but not exactly.
" This is how you see the "darkblue" theme when using an 8 color xterm,
" more precisely an unconfigured KDE Konsole, in which the 16 available
" colors come from the "Linux Colors" preset. It turns out it is a very
" good dark theme that way, with just the right contrast.
"
" Using this file, one can get that look even on 256 color xterms and on gvim GUI.
"
" Also, the functions allow to specify each color Once And Only Once,
" instead of having to repeat for GUI and console (24bit RGB values are
" converted 8, 16 or 256 palette indexes, depending on the console (t_Co)).
"
" For 8 color consoles, it handles auto setting the bold attribute for bright
" colors.
"
" The original "darkblue" theme is bundled with VIM.
" The file "desert256.vim" on which I based this one, and got the 256 color
" conversion routines, is from here:
"       http://www.vim.org/scripts/script.php?script_id=1243
" I refactored those functions, fixed a bug in the grey level functions, added
" conversion from true color to 16 color palette, and added a couple of tests.
"
" Tested with 8, 16, 256 and gvim 24bit RGB. It is untested for 88 color xterms but
" it should probably work.
"
" Also fixed respective to the combination of "darkblue" plus Konsole with LinuxColors:
"    -Text inside HTML anchors <a></a> was unreadable (too dark).
"    -Some diffs with vimdiff were unreadable
"    -Squiggly lines in NonText had no contrast
"    -In gvim, now the cursor is a reverse mask (instead of fixed color), like
"     in terminal.
"


set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="jmcdark"


"Configuration ----------------------------------------------- {{{

"Use global setting:
"     g:JmcDarkForce16ColorsInConsole
"Setting it will avoid using the 256 color extended palette when available in
"the console.
"  The GUI gvim colors are not affected by this option.
"  When 1 or "v:true", the best approximation to the standard xterm 16 colors is
"searched for each RGB value.
"  When 0 or "v:false", it uses the best approximation in the whole 256 color palette
"if the console has 256 colors (&t_Co == 256). This would sound like the best,
"except that the palette indexes >= 16 cannot be customized in terminal apps,
"and it still isn't true color (one could make the 16 colors any 24bit color
"one wants by configuring the terminal application).
if !exists("g:JmcDarkForce16ColorsInConsole")
    "Default:
    let g:JmcDarkForce16ColorsInConsole = 0
endif


"Use global setting:
"     g:JmcDarkUseGreyBackground
"Setting it will use a slight grey background instead of pure black. If the console
"is forced to 16 colors, it might look black anyways in the console even if
"this option is set. Setting to zero uses a pure black background.
if !exists("g:JmcDarkUseGreyBackground")
    "Default:
    let g:JmcDarkUseGreyBackground = 1
endif


"Set this to "true" to run the unit tests on load, on color conversion functions
"(only useful while testing changes)
let s:UNIT_TESTS = 0

" }}}


"Functions --------------------------------------------------- {{{

"Returns an approximate grey index for the given actual grey value
function! ApproximateGreyLevel(x)
    if &t_Co == 88
        if a:x < 23
            return 0
        elseif a:x < 69
            return 1
        elseif a:x < 103
            return 2
        elseif a:x < 127
            return 3
        elseif a:x < 150
            return 4
        elseif a:x < 173
            return 5
        elseif a:x < 196
            return 6
        elseif a:x < 219
            return 7
        elseif a:x < 243
            return 8
        else
            return 9
        endif
    else
        "When t_Co == 256:
        "0 is index 0
        "0x8 is index 1
        "intervals of 10 until 0xEE which is index 24
        "0xFF is index 25
        if a:x < 4
            return 0
        elseif a:x > 238 && a:x <= 246
            return 24
        elseif a:x > 246
            return 25
        else
            let l:n = 1 + (a:x - 8) / 10
            let l:m = (a:x - 8) % 10
            if l:m >= 5
                let l:n = l:n + 1
            endif
            return l:n
        endif
    endif
endfunction

"Returns the actual grey value represented by the grey index
function! GreyLevelToActual(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 46
        elseif a:n == 2
            return 92
        elseif a:n == 3
            return 115
        elseif a:n == 4
            return 139
        elseif a:n == 5
            return 162
        elseif a:n == 6
            return 185
        elseif a:n == 7
            return 208
        elseif a:n == 8
            return 231
        else
            return 255
        endif
    else
        "When t_Co == 256:
        if a:n == 0
            return 0
        elseif a:n < 25
            return 8 + ((a:n - 1) * 10)
        else
            return 255
        endif
    endif
endfunction

"Returns the palette index for the given grey index
function! GreyLevelsToPaletteIndex(n)
    if &t_Co == 88
        if a:n == 0
            return 16
        elseif a:n == 9
            return 79
        else
            return 79 + a:n
        endif
    else
        "When t_Co == 256:
        if a:n == 0
            return 16
        elseif a:n == 25
            return 231
        else
            return 231 + a:n
        endif
    endif
endfunction

"Returns an approximate color index for the given actual color value
function! ApproximateColorLevel(x)
    if &t_Co == 88
        if a:x < 69
            return 0
        elseif a:x < 172
            return 1
        elseif a:x < 230
            return 2
        else
            return 3
        endif
    else
        "When t_Co == 256:
        if a:x < 75
            return 0
        else
            let l:n = (a:x - 55) / 40
            let l:m = (a:x - 55) % 40
            if l:m < 20
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfunction

"Returns the actual color value for the given color index
function! ColorLevelToActual(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 139
        elseif a:n == 2
            return 205
        else
            return 255
        endif
    else
        "When t_Co == 256:
        if a:n == 0
            return 0
        else
            return 55 + (a:n * 40)
        endif
    endif
endfunction

"Returns the standard xterm palette index for the given R/G/B color discrete levels
function! ColorLevelsToPaletteIndex(x, y, z)
    if &t_Co == 88
        return 16 + (a:x * 16) + (a:y * 4) + a:z
    else
        "When t_Co == 256:
        return 16 + (a:x * 36) + (a:y * 6) + a:z
    endif
endfunction

"Returns the palette index to approximate the given R/G/B actual color values
function! RgbToIndex(r, g, b)
    "Get the closest grey
    let l:gx = ApproximateGreyLevel(a:r)
    let l:gy = ApproximateGreyLevel(a:g)
    let l:gz = ApproximateGreyLevel(a:b)

    "Get the closest color
    let l:x = ApproximateColorLevel(a:r)
    let l:y = ApproximateColorLevel(a:g)
    let l:z = ApproximateColorLevel(a:b)

    if l:gx == l:gy && l:gy == l:gz
        "Asked for grey, but if a non-grey color is closer, return the color.
        let l:dgr = GreyLevelToActual(l:gx) - a:r
        let l:dgg = GreyLevelToActual(l:gy) - a:g
        let l:dgb = GreyLevelToActual(l:gz) - a:b
        let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
        let l:dr = ColorLevelToActual(l:gx) - a:r
        let l:dg = ColorLevelToActual(l:gy) - a:g
        let l:db = ColorLevelToActual(l:gz) - a:b
        let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:dgrey < l:drgb
            "Use the grey
            return GreyLevelsToPaletteIndex(l:gx)
        else
            "Use the color
            return ColorLevelsToPaletteIndex(l:x, l:y, l:z)
        endif
    else
        return ColorLevelsToPaletteIndex(l:x, l:y, l:z)
    endif
endfunction

let s:standard16Colors =
                    \    [["0",  0x00, 0x00, 0x00],
                    \     ["1",  0x80, 0x00, 0x00],
                    \     ["2",  0x00, 0x80, 0x00],
                    \     ["3",  0x80, 0x80, 0x00],
                    \     ["4",  0x00, 0x00, 0x80],
                    \     ["5",  0x80, 0x00, 0x80],
                    \     ["6",  0x00, 0x80, 0x80],
                    \     ["7",  0xc0, 0xc0, 0xc0],
                    \     ["8",  0x80, 0x80, 0x80],
                    \     ["9",  0xff, 0x00, 0x00],
                    \     ["10", 0x00, 0xff, 0x00],
                    \     ["11", 0xff, 0xff, 0x00],
                    \     ["12", 0x00, 0x00, 0xff],
                    \     ["13", 0xff, 0x00, 0xff],
                    \     ["14", 0x00, 0xff, 0xff],
                    \     ["15", 0xff, 0xff, 0xff]]

"NOTE: VIM 8 color indexes are different from 16 color indexes.
"      So, the best for ResolveTerminalColor is to return named colors
"      (t_Co==8 vs t_Co==16). Otherwise, "Red" (9) and "Yellow" (11) don't work
"      right in 8 color consoles, because Vim knows how to fall back to the
"      8 colors in those consoles. Adding "bold" attrs is be necessary, to
"      get the bright color in those cases.
"        Also, "DarkYellow" and "DarkGrey" are approximated by VIM from
"      the extended palette when using a 256 color console (t_Co==256),
"      maybe to workaround consoles that use yellow instead of brown for index
"      number 3 and so on. If one wants to customize "DarkYellow" from the terminal
"      app, then "3" must be returned in that particular case.
"
let s:standard16ColorNames =
                    \    { 0: "Black",
                    \      1: "DarkRed",
                    \      2: "DarkGreen",
                    \      3: "DarkYellow",
                    \      4: "DarkBlue",
                    \      5: "DarkMagenta",
                    \      6: "DarkCyan",
                    \      7: "LightGrey",
                    \      8: "DarkGrey",
                    \      9: "Red",
                    \     10: "Green",
                    \     11: "Yellow",
                    \     12: "Blue",
                    \     13: "Magenta",
                    \     14: "Cyan",
                    \     15: "White"}
                    "\      3: "Brown",
                    "\      8: "DarkGrey",

function! MatchStandard16Color(r, g, b)
    let l:bestEntry = []
    let l:bestDistance = -1
    for item in s:standard16Colors
        let l:dr = item[1] - a:r
        let l:dg = item[2] - a:g
        let l:db = item[3] - a:b
        let l:dist = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:bestDistance == -1 || l:dist < l:bestDistance
            let l:bestEntry = item
            let l:bestDistance = l:dist
        endif
    endfor
    if l:bestEntry != []
        return l:bestEntry[0] - 0
    endif
    return 0
endfunction

let s:resolvedCache = {}

function! ResolveTerminalColor(rgb)
    "Avoid computing twice:
    if has_key(s:resolvedCache, a:rgb)
        return s:resolvedCache[a:rgb]
    endif

    "Find closest match:
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
    let l:result = s:standard16ColorNames[MatchStandard16Color(l:r, l:g, l:b)]

    if &t_Co == 256 || &t_Co == 88
        "Prevent VIM from mapping these outside the 16 color palette,
        "otherwise it tries to find better colors for these in the
        "extended palette when available:
        if l:result == "DarkYellow"
            let l:result = 3
        elseif l:result == "DarkGrey"
            let l:result = 8
        endif
    endif

    let s:resolvedCache[a:rgb] = l:result
    return l:result
endfunction

"Translates a 24bit color into a console palette index.
"Consoles can be: 8, 16, 88, or 256 colors (see &t_Co vim variable).
"   -The first 16 colors are supposed to be standard but in practice every
"    console/terminal program lets the users apply themes to the first 16
"    colors, or are altered by default.
"   -The indexes 16-255, if supported, are standard and can be relied
"    upon. The console application is not supposed to mess with those.
function! RgbToConsolePalette(rgb)
    if a:rgb == "NONE" || a:rgb == "bg" || a:rgb == "fg"
       \ || a:rgb == "background" || a:rgb == "foreground"

        return a:rgb
    endif
    if !g:JmcDarkForce16ColorsInConsole && (has("gui_running") || &t_Co == 88 || &t_Co == 256)
        let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
        let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
        let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

        return RgbToIndex(l:r, l:g, l:b)
    else
        return ResolveTerminalColor(a:rgb)
    endif
endfunction

function! PrefixHash(colorOrNone)
    "For GUI 24 bit colors, prepend "#" unless it is "NONE" or the special
    "values "fg" and "bg" (which I think map to Normal group fg and bg):
    if a:colorOrNone == "NONE" || a:colorOrNone == "bg" || a:colorOrNone == "fg"
       \ || a:colorOrNone == "background" || a:colorOrNone == "foreground"

        return a:colorOrNone
    else
        return "#" . a:colorOrNone
    endif
endfunction

"If a ctermfg (terminal foreground) is specified in this list,
"the bold attribute is automatically added for 8 color consoles (&t_Co==8),
"which is the way to tell them to use a bright color:
let s:isBrightColorName = {
                    \     "DarkGray": 1, "DarkGrey": 1,
                    \     "Red": 1,      "LightRed": 1,
                    \     "Green": 1,    "LightGreen": 1,
                    \     "Yellow": 1,   "LightYellow": 1,
                    \     "Blue": 1,     "LightBlue": 1,
                    \     "Magenta": 1,  "LightMagenta": 1,
                    \     "Cyan": 1,     "LightCyan": 1,
                    \     "White": 1}

"Issues the :hi (:highlight) command.
"
"This function allows to:
"   -Avoid repetition by specifying the color or attribute only once, for both
"    GUI and Console.
"   -Specify colors always in 24bit RGB. The issued ctermfg and ctermbg will
"    have an automatic approximation. NOTE: It's best to enable 256 color mode
"    in your console to have the best approximation. Example:
"           export TERM='xterm-256color'
"   -Handles exceptional cases in which one needs a different color or
"    attribute for GUI and console, by also accepting arguments in the list form: [GUI, Console]
"
"For the foreground and background arguments:
"   -Pass RGB 24 bit colors strings. Example: "aa11ff"
"   -Pass "" to not say anything for that foreground or background.
"   -Pass "NONE" to force "fg" or "bg" to empty (useful when that default VIM color didn't start empty)
"   -Pass ["1144ff", "aabbcc"] to have a GUI gvim color of #1144ff and a
"    console color of #aabbcc. (Most useful for specifying different
"    background for console than GUI, ej: default for console and a specific
"    color for GUI.
"   -Pass the "fg" or "bg" strings as aliases to the color defined by
"    the "Normal" color group.
"
"For the attr argument:
"   -The attribute can be "bold", "reverse", "none", "underline", "undercurl", etc. (see VIM help).
"    Specify more than one by separating with commas. Example: "bold,underline".
"   -If the argument is a string, that attribute is applied to both GUI and
"    console.
"   -If it is a list, one can specify different attributes. Example: ["undercurl", "underline"]
"
"NOTES:
"    -The settings guifg and guibg don't need translation since they can take
"     24bit colors (gvim).
"    -But when vim starts in a terminal, it reads ctermfg and ctermbg, which
"     are limited. The terminals can support 8 colors, 16, 88 or 256 colors.
"     Vim tries to autodetect console color count and put it in the variable &t_Co.
function! MakeHi(group, fg, bg, attr)
    "Split arguments

    if type(a:fg) == 3
        "Argument is a list [gui, console]. Both must be 24bit RGB.
        let [l:guifg, l:ctermfg] = a:fg
    else
        let l:guifg = a:fg
        let l:ctermfg = a:fg
    endif

    if type(a:bg) == 3
        "Argument is a list [gui, console]. Both must be 24bit RGB.
        let [l:guibg, l:ctermbg] = a:bg
    else
        let l:guibg = a:bg
        let l:ctermbg = a:bg
    endif

    if type(a:attr) == 3
        "Argument is a list [gui, console].
        let [l:gui, l:cterm] = a:attr
    else
        let l:gui = a:attr
        let l:cterm = a:attr
    endif

    "Resolve console index or color name:
    if l:ctermfg != ""
        let l:ctermfg = RgbToConsolePalette(l:ctermfg)

        "Fix bright colors in 8 color console:
        if &t_Co == 8 && (has_key(s:isBrightColorName, l:ctermfg) || ((l:ctermfg + 0) > 7 && (l:ctermfg + 0) < 16))
            if stridx(l:cterm, "bold") == -1
                if l:cterm != ""
                    let l:cterm .= ","
                endif
                let l:cterm .= "bold"
            endif
        endif
    endif

    "Resolve console index or color name:
    if l:ctermbg != ""
        let l:ctermbg = RgbToConsolePalette(l:ctermbg)
    endif


    "Foreground
    if l:guifg != "" || l:ctermfg != ""
        exec "hi " . a:group
           \ . ((l:guifg != "")?   (" guifg=" . PrefixHash(l:guifg)) : "")
           \ . ((l:ctermfg != "")? (" ctermfg=" . l:ctermfg) : "")
    endif

    "Background
    if l:guibg != "" || l:ctermbg != ""
        exec "hi " . a:group
           \ . ((l:guibg != "")?   (" guibg=" . PrefixHash(l:guibg)) : "")
           \ . ((l:ctermbg != "")? (" ctermbg=" . l:ctermbg) : "")
    endif

    "Attributes
    if l:gui != "" || l:cterm != ""
        exec "hi " . a:group
           \ . ((l:gui != "")?   (" gui=" . l:gui) : "")
           \ . ((l:cterm != "")? (" cterm=" . l:cterm) : "")
    endif
endfunction
" }}}


"Unit tests -------------------------------------------------- {{{

if s:UNIT_TESTS
    "(Test for 16 colors)
    function! Test_MatchStandard16Color(x, expected)
        let l:r = ("0x" . strpart(a:x, 0, 2)) + 0
        let l:g = ("0x" . strpart(a:x, 2, 2)) + 0
        let l:b = ("0x" . strpart(a:x, 4, 2)) + 0

        let l:v = MatchStandard16Color(l:r, l:g, l:b)
        if l:v != a:expected
            echo "ERROR: MatchStandard16Color: x=" a:x " expected=" a:expected " returned=" l:v
        endif
    endfun
    echo "Testing MatchStandard16Color..."
    call Test_MatchStandard16Color("000000", 0)
    call Test_MatchStandard16Color("b21818", 1)
    call Test_MatchStandard16Color("ff5454", 9)
    call Test_MatchStandard16Color("ff5454", 9)
    "
    call Test_MatchStandard16Color("242424", 0)
    call Test_MatchStandard16Color("b21818", 1)
    call Test_MatchStandard16Color("18b218", 2)
    call Test_MatchStandard16Color("b26818", 3)
    call Test_MatchStandard16Color("1818b2", 4)
    call Test_MatchStandard16Color("b218b2", 5)
    call Test_MatchStandard16Color("18b2b2", 6)
    call Test_MatchStandard16Color("b2b2b2", 7)
    call Test_MatchStandard16Color("686868", 8)
    call Test_MatchStandard16Color("ff5454", 9)
    call Test_MatchStandard16Color("54ff54", 10)
    call Test_MatchStandard16Color("ffff54", 11)
    call Test_MatchStandard16Color("5454ff", 12)
    call Test_MatchStandard16Color("ff54ff", 13)
    call Test_MatchStandard16Color("54ffff", 14)
    call Test_MatchStandard16Color("ffffff", 15)
    call Test_MatchStandard16Color("ffffff", 15)
    delf Test_MatchStandard16Color

    "(Test for 256 colors)
    function! Test_ApproximateGreyLevel(x, expected)
        let l:v = ApproximateGreyLevel(a:x)
        if l:v != a:expected
            echo "ERROR: ApproximateGreyLevel: x=" a:x " expected=" a:expected " returned=" l:v
        endif
    endfun
    echo "Testing ApproximateGreyLevel..."
    call Test_ApproximateGreyLevel(0x3, 0)
    call Test_ApproximateGreyLevel(0x4, 1)
    call Test_ApproximateGreyLevel(0xc, 1)
    call Test_ApproximateGreyLevel(0xd, 2)
    call Test_ApproximateGreyLevel(0xe, 2)
    call Test_ApproximateGreyLevel(0x24, 4)
    call Test_ApproximateGreyLevel(0x30, 5)
    call Test_ApproximateGreyLevel(0xb2, 18)
    call Test_ApproximateGreyLevel(0xee, 24)
    call Test_ApproximateGreyLevel(0xff, 25)
    delf Test_ApproximateGreyLevel


    "(Test for 256 colors)
    function! Test_ApproximateColorLevel(x, expected)
        let l:v = ApproximateColorLevel(a:x)
        if l:v != a:expected
            echo "ERROR: ApproximateColorLevel: x=" a:x " expected=" a:expected " returned=" l:v
        endif
    endfun
    echo "Testing ApproximateColorLevel..."
    call Test_ApproximateColorLevel(0x5f-21, 0)
    call Test_ApproximateColorLevel(0x5f-20, 1)
    call Test_ApproximateColorLevel(0x5f, 1)
    call Test_ApproximateColorLevel(0x5f+19, 1)
    call Test_ApproximateColorLevel(0x5f+20, 2)
    call Test_ApproximateColorLevel(0x87, 2)
    call Test_ApproximateColorLevel(0xaf, 3)
    call Test_ApproximateColorLevel(0xd7, 4)
    call Test_ApproximateColorLevel(0xff, 5)
    delf Test_ApproximateColorLevel


    "Test for 256 colors:
    function! Test_ColorLevelToActual(x, expected)
        let l:v = ColorLevelToActual(a:x)
        if l:v != a:expected
            echo "ERROR: ColorLevelToActual a:x " expected=" a:expected " returned=" l:v
        endif
    endfun
    echo "Testing ColorLevelToActual..."
    call Test_ColorLevelToActual(0, 0)
    call Test_ColorLevelToActual(1, 0x5f)
    call Test_ColorLevelToActual(2, 0x87)
    call Test_ColorLevelToActual(3, 0xaf)
    call Test_ColorLevelToActual(4, 0xd7)
    call Test_ColorLevelToActual(5, 0xff)
    delf Test_ColorLevelToActual
endif

" }}}


"LinuxColors Konsole Palette --------------------------------- {{{
"(But with grey #242424 background instead of black)

if g:JmcDarkUseGreyBackground
    "Use a slight grey. With 0x242424 for GUI and 0x1c1c1c for console:
    let s:BACKGROUND = ["242424", "1c1c1c"]
else
    let s:BACKGROUND = "000000"
endif
let s:BLACK = s:BACKGROUND     "00
let s:DARK_RED = "b21818"      "01
let s:DARK_GREEN = "18b218"    "02
let s:BROWN = "b26818"         "03
let s:DARK_BLUE = "1818b2"     "04
let s:DARK_MAGENTA = "b218b2"  "05
let s:DARK_CYAN = "18b2b2"     "06
let s:LIGHT_GREY = "b2b2b2"    "07
let s:DARK_GREY = "686868"     "08
let s:RED = "ff5454"           "09
let s:GREEN = "54ff54"         "10
let s:YELLOW = "ffff54"        "11
let s:BLUE = "5454ff"          "12
let s:MAGENTA = "ff54ff"       "13
let s:CYAN = "54ffff"          "14
let s:WHITE = "ffffff"         "15

" }}}


"Highlighting ------------------------------------------------ {{{

"Window background and Normal text foreground:
"NOTE: Use "NONE" to use default xterm background in console:
"    call MakeHi("Normal", s:LIGHT_GREY, "NONE", "")
call MakeHi("Normal", s:LIGHT_GREY, s:BACKGROUND, "")

"Endlines of :set list and Bottom of the window when zz to the end
"(squigglies ~ ~ and their background):
call MakeHi("NonText", s:CYAN, "NONE", "bold")

"Cursor. Make it like a console cursor (reverse mask on character below):
"NOTES:
"   -For consoles, it doesn't have an effect.
"   -The default Cursor was:
"       hi Cursor guifg=bg guibg=fg
"    which means: In the GUI, make it have the fixed Normal bg and fg inverted.
call MakeHi("Cursor", "NONE", "NONE", "reverse")

"lCursor. This alternative cursor only shows up when VIM is using a
"language mapping, for instance DVORAK. Although I couldn't make it have
"an effect.
"    To use DVORAK  :set keymap=dvorak
"    To unset       :set keymap=
call MakeHi("lCursor", "NONE", "NONE", "reverse")

"CursorIM
call MakeHi("CursorIM", "NONE", "NONE", "reverse")

"Cursor background on oposite matching parenthesis:
call MakeHi("MatchParen", "NONE", s:DARK_CYAN, "none")

":Explore Netrw horizontal highlight bar (CursorLine):
"    These are the cross lines that highlight the entire cursor row and column
"    They can be activated with
"          :set cursorcolumn
"          :set cursorline
"This works to have :Explore be the same in GUI gvim as in terminal (underline):
call MakeHi("CursorLine", "NONE", "NONE", "underline")

"CursorColumn. It's useful to fix vertical alignment
"of indented blocks :set cursorcolumn
call MakeHi("CursorColumn", "NONE", s:DARK_GREY, "")

"CursorLineNr
"When both :set cursorline and :set number  or :set relativenumber,
"the current line number in the left margin is highlighted with this color:
call MakeHi("CursorLineNr", s:YELLOW, "NONE", "bold")

"Color column. Like a vertical wrap margin marker. Example:  :set cc=80
call MakeHi("ColorColumn", "NONE", s:DARK_RED, "")

"SignColumn: Vertical margin for IDE-like signs:
"   Test with:
"       :sign define piet text=>> texthl=Search
"       :exe ":sign place 2 line=23 name=piet file=" . expand("%:p")
"    Remove with:
"       :sign unplace 2
call MakeHi("SignColumn", s:CYAN, "NONE", "bold")

"Conceal
call MakeHi("Conceal", s:LIGHT_GREY, s:DARK_GREY, "none")

"Ignore
call MakeHi("Ignore", s:BACKGROUND, "NONE", "none")

"Test these with  :set spell  or  :set nospell
"SpellBad
"SpellCap
"SpellRare
"SpellLocal

"Pop Up menu that shows for autocompletion CTRL-N
"Pmenu
call MakeHi("Pmenu", s:LIGHT_GREY, s:DARK_MAGENTA, "")
"PmenuSel
call MakeHi("PmenuSel", s:WHITE, "NONE", "bold")
"These control the text scroll bar in the popup menu (eg: try to autocomplete '$' in a PHP file).
"PmenuSbar
call MakeHi("PmenuSbar", "NONE", s:DARK_GREY, "")
"PmenuThumb
call MakeHi("PmenuThumb", "NONE", s:WHITE, "bold")


"Directory: how dirs look when browsing netrm
call MakeHi("Directory", s:CYAN, "NONE", "bold")

"Diffs were broken in original DarkBlue, and were unreadable if the text
"below had syntax highlighting. By setting a foreground color in all Diff
"colors, this gets fixed.
"DiffAdd
call MakeHi("DiffAdd", s:LIGHT_GREY, s:DARK_BLUE, "none")
"DiffChange
call MakeHi("DiffChange", s:LIGHT_GREY, s:DARK_MAGENTA, "none")
"DiffDelete
call MakeHi("DiffDelete", s:BLUE, s:DARK_CYAN, "bold")
"DiffText
call MakeHi("DiffText", s:WHITE, s:DARK_RED, "bold")

"ErrorMsg that appears when typing :asdfasdf123 etc.
call MakeHi("ErrorMsg", s:WHITE, s:DARK_BLUE, "bold")

"Vertical line after splitting with CTRL-W V
call MakeHi("VertSplit", "NONE", "NONE", "reverse")

"Collapsed fold line and vertical margin:
call MakeHi("Folded", s:DARK_GREY, "NONE", "bold")
call MakeHi("FoldColumn", s:DARK_GREY, "NONE", "bold")

"Highlight for searches while typed when :set incsearch
call MakeHi("IncSearch", s:LIGHT_GREY, s:DARK_BLUE, "none")

"LineNr. Color of line numbers for  :set number
call MakeHi("LineNr", s:DARK_GREEN, "NONE", "")

"The little text at the bottom that says '-- INSERT --' or '-- REPLACE --':
call MakeHi("ModeMsg", s:BLUE, "NONE", "bold")

"More message when list is too long, like when running :set all
call MakeHi("MoreMsg", s:DARK_GREEN, "NONE", "none")

"Prompt to press ENTER after :ls runs
call MakeHi("Question", s:DARK_GREEN, "NONE", "none")

"Search match:
call MakeHi("Search", s:LIGHT_GREY, s:DARK_BLUE, "underline")

"How ^M and ^H etc. appear for instance in vimrc RemoveCtrlM command:
call MakeHi("SpecialKey", s:DARK_CYAN, "NONE", "")

"Status line. See  :set statusline=
call MakeHi("StatusLine", s:DARK_BLUE, s:LIGHT_GREY, "none")
call MakeHi("StatusLineNC", s:BLACK, s:LIGHT_GREY, "none")

"First line of output of :set all
call MakeHi("Title", s:MAGENTA, "NONE", "bold")

"Selection of text:
call MakeHi("Visual", s:LIGHT_GREY, s:DARK_BLUE, "none")
"VisualNOS. Selection of text when window lost focus or something:
call MakeHi("VisualNOS", s:LIGHT_GREY, s:DARK_BLUE, "underline")

"Message at the bottom for instance 'W10: Warning: Changing a readonly file'
call MakeHi("WarningMsg", s:RED, "NONE", "bold")

"WildMenu. To use do :set wildmenu  and then :b <TAB> or :colors <TAB>
"and then the options appear in an horizontal menu.
call MakeHi("WildMenu", s:BROWN, "NONE", "")

"Menu
"Scrollbar
"Tooltip

call MakeHi("Comment", s:DARK_RED, "NONE", "none")
call MakeHi("Constant", s:DARK_MAGENTA, "NONE", "none")
call MakeHi("Identifier", s:DARK_CYAN, "NONE", "none")
call MakeHi("Statement", s:BROWN, "NONE", "none")
"PreProc is the 'function' keyword that declares PHP functions.
call MakeHi("PreProc", s:DARK_MAGENTA, "NONE", "")
call MakeHi("Type", s:DARK_GREEN, "NONE", "none")
call MakeHi("Special", s:BROWN, "NONE", "none")

"Underlined. This is the text between html's <a> and </a>:
"This was broken in original DarkBlue because it was too dark, unreadable.
call MakeHi("Underlined", s:LIGHT_GREY, "NONE", "underline")

"Error. An error in color Red in the edited file, like mismatched parenthesis in Lisp.
call MakeHi("Error", s:WHITE, s:DARK_RED, "bold")

"ToDo comments. Example: //TODO: blabla.
call MakeHi("Todo", s:RED, s:DARK_BLUE, "bold")

" }}}


"Remove Functions -------------------------------------------- {{{
delf MakeHi
delf ApproximateColorLevel
delf ApproximateGreyLevel
delf ColorLevelToActual
delf ColorLevelsToPaletteIndex
delf GreyLevelToActual
delf GreyLevelsToPaletteIndex
delf PrefixHash
delf ResolveTerminalColor
delf RgbToConsolePalette
delf RgbToIndex
delf MatchStandard16Color
" }}}


" vim: set fdl=0 fdm=marker:
