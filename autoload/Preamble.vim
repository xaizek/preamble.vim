if &cp || exists("s:loaded_preamble")
    finish
endif
let s:loaded_preamble = 1


" ########################################################
" Public Methods
" ########################################################


" ========================================================
" Enable: enables automatic preamble for the specified
"   filetypes
"
" Parameters --
"   filetypes - -- string of comma delimited filetypes,
"               -- an empty string disables the plugin
"               -- "*" enables plugin for all filetyps
" Example --
"   In your .vimrc file, add a line like this:
"       call Preamble#Enable("c,cpp,java")
" ========================================================

fun! Preamble#Enable(filetypes)
    silent! au! AugroupPreamble
    if a:filetypes == "" | return | endif

    augroup AugroupPreamble
        execute "au BufWinEnter " . a:filetypes . " call Preamble#Fold()"
    augroup END
endfunction



" ========================================================
" Fold: folds the preamble according to the options that
"   that are set
" ========================================================

fun! Preamble#Fold()
    if exists('b:preamble_disable_thisbuffer') && b:preamble_disable_thisbuffer != 0
        return
    endif

    call s:LoadOptions()

    let pl = s:Length()
    if pl < s:preamble_min_lines | return | endif
    if pl > s:preamble_max_lines && !s:preamble_fold_partial | return | endif

    " if a fold aleady exists in line 1, just close it
    if foldlevel(1) && foldclosed(1) == -1
        execute ":1,".pl."foldclose"
        return
    endif

    if &foldmethod=="syntax" | return | endif

    execute "set foldmethod=manual | :1,".pl."fold | :1,".pl."foldclose"
endfunction



" ########################################################
" Private Methods
" ########################################################

" ========================================================
" LoadOptions: Initializes user options
"
"   If defined, the buffer specific option is used.
"   Else, if defined, the global option is used.
"   Else, the default is used.
" ========================================================

fun! s:LoadOptions()

    " ------------------------------------------------------------------
    " Option: preamble_min_lines
    "
    " Minimum lines that preamble should have before it can be folded
    " If the preamble is less than this number, no fold is created
    "
    " Default: 25
    " ------------------------------------------------------------------

    if !exists('g:preamble_min_lines')
        let s:preamble_min_lines=25
    else
        let s:preamble_min_lines=g:preamble_min_lines
    endif
    if exists('b:preamble_min_lines')
        let s:preamble_min_lines=b:preamble_min_lines
    endif

    " ------------------------------------------------------------------
    " Option: preamble_max_lines
    "
    " Maximum lines to include in the preamble fold
    " If the preamble is greater than this number, behavior is
    " determined by the 'preamble_fold_partial' option
    "
    " Default: 150
    " ------------------------------------------------------------------

    if !exists('g:preamble_max_lines')
        let s:preamble_max_lines=150
    else
        let s:preamble_max_lines=g:preamble_max_lines
    endif
    if exists('b:preamble_max_lines')
        let s:preamble_max_lines=b:preamble_max_lines
    endif
    if line('$') < s:preamble_max_lines
        let s:preamble_max_lines = line('$')
    endif

    " ------------------------------------------------------------------
    " Option: preamble_fold_partial
    "
    " If the preamble is greater the 'max_lines'
    " fold or do not fold up to 'max_lines'
    "
    " Values:   0 = do not fold partial preambles  (default)
    "           1 = do fold max lines of the preamble
    " ------------------------------------------------------------------

    if !exists('g:preamble_fold_partial')
        let s:preamble_fold_partial=0
    else
        let s:preamble_fold_partial=g:preamble_fold_partial
    endif
    if exists('b:preamble_fold_partial')
        let s:preamble_fold_partial=b:preamble_fold_partial
    endif

    " ------------------------------------------------------------------
    " Option: b:preamble_disable_thisbuffer
    "
    " Disable folding for buffer
    " This option is only for buffer level folding
    "
    " Values:  exists and not 0 = do not create fold
    " ------------------------------------------------------------------
    " b:preamble_disable_thisbuffer


endfunction


" ========================================================
" Length: Calculates the preamble's length
"
"   The preamble
"       -- starts on line 1 of the file
"       -- includes initial blank lines
"       -- includes lines having a character in column one
"          with a 'Comment' syntax
"       -- stops when first non-Comment line is reached
"
"   Blank lines before the first comment are included.
"   Blank lines after the first comment line are not.
" ========================================================

fun! s:Length()

    let line_pos = 1
    let is_blankline = 1

    while(line_pos <= s:preamble_max_lines)

        " skip blank lines at top of file
        if is_blankline && getline(line_pos) =~ "\S"
            let is_blankline = 0
        endif

        " assume each line of a preamble has a character in col one
        if !is_blankline
            let synId = synID(line_pos, 1, 1)
            let realSynId = synIDtrans(synId)
            if (synIDattr( realSynId, 'name' ) != "Comment") | break | endif
        endif

        let line_pos = line_pos + 1
    endwhile

    return line_pos-1
 endfunction

