" Bootstrap the plugin
fu! runner#Bootstrap()
    " make sure to bootstrap the basePath as needed
    call utilities#BasePath()
    " now load up local vimrc files
    call utilities#LoadLocalVimrc()
    " open up explore if no args are passed on startup
    if len(argv()) == 0 
        Explore
    " check to make sure directory wasn't passed
    elseif isdirectory(argv()[0])
        let g:basePath=argv()[0]
        Explore
    endif
endfunction

" bootstrap a new buffer / autocommand etc
fu! runner#BootstrapFile()
    let type=utilities#Capitalize(utilities#GetFileType(@%))
    if !exists("g:fileLock") || g:fileLock != "true"
        " bootstrap test mappings
        call TestMapper(type)
        " bootstrap run mapping
        call RunMapper(type)
        call DebugMapper(type)
        " now that we have mapped the commands, call the local vimrc to ensure
        " that no re-mapping occurs
        call utilities#LoadLocalVimrc()
    endif
endfunction

fu! runner#BootstrapCurrentFile()
    " remove lock
    let g:fileLock="false"
    " bootstrap the current file
    :call runner#BootstrapFile()
    " lock again
    let g:fileLock="true"
endfunction

fu! runner#ToggleFileLock()

    if !exists("g:fileLock")
        let g:fileLock="true"
    endif
    if g:fileLock == "true"
        let g:fileLock="false"
    else
        let g:fileLock="true"
    endif
    echo "g:fileLock = ". g:fileLock

endfunction

if !exists("*BeforeHook")
    function BeforeHook()
    endfunction
endif

if !exists("*AfterHook")
    function AfterHook()
    endfunction
endif

"""
""" Autocommand Event Mappings
"""
" link up autocommands as needed
" :help autocmd-events
au BufNewFile,BufRead,BufEnter,BufWinEnter * call runner#BootstrapFile()
" now lets actually call the global vimrc file at all times
autocmd VimEnter * call runner#Bootstrap()

"""
""" LEADER MAPPINGS
"""
map<Leader>ll :call runner#BootstrapCurrentFile()<CR>
map<Leader>lu :call runner#ToggleFileLock()<CR>

"""
""" PRIVATE METHODS
"""
" now configure the leader mappings as needed
fu! TestMapper(type)
    :call utilities#BasePath()
    let functionName="file_runners#". a:type ."TestRunner"
    let path=expand('%:p') 

    if exists("*".functionName)
        " bootstrap the file command
        let fileCommand=":call ". functionName ."(\"". path ."\")"
        :execute("map<Leader>rt ". fileCommand ."<CR>")
        " bootstrap the project command
        let projectCommand=":call ". functionName ."(\"". g:basePath ."\")"
        :execute("map<Leader>rtp ". projectCommand ."<CR>")
    endif
endfunction

" initialize run commands
fu! RunMapper(type)
    :call utilities#BasePath()
    let functionName="file_runners#". a:type ."Runner"
    let path=expand('%:p') 
    if exists("*". functionName)
        " bootstrap the file command
        let fileCommand=":call BeforeHook() <CR> \\| :call ". functionName ."(\"". path ."\") \\| :redraw \\| :call AfterHook()<CR>"
        :execute("map<Leader>, ". fileCommand)
        " bootstrap the project command
        let projectCommand=":call ". functionName ."(\"". g:basePath ."\")"
        :execute("map<Leader>rp ". projectCommand ."<CR>")
    endif
endfunction

fu! DebugMapper(type)
    :call utilities#BasePath()
    let functionName="file_runners#". a:type ."DebugRunner"
    let path=expand('%:p') 

    if exists("*".functionName)
        " bootstrap the file command
        let fileCommand=":call ". functionName ."(\"". path ."\")"
        execute("map<Leader>rd ". fileCommand ."<CR>")
    endif
endfunction

