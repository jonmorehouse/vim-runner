"""
""" Go Project runners
"""
fu! file_runners#GoRunner(target)
    " run the project
    if isdirectory(a:target)
        " find the root main.go file
        let file=substitute(system("find ". g:basePath ." -type f -name \"*main.go\""), "\n", "", "")
        :call utilities#CleanShell("go run ". file)
    " if this is a test file - redirect to the test caller
    elseif a:target =~ "_test.go"
        :call file_runners#GoTestRunner(a:target)
    " if it doesn't look like a file - then go ahead and try to call the
    " correct file as needed
    else 
        :call utilities#CleanShell("go run ". a:target)
    endif

endfunction

fu! file_runners#GoTestRunner(target)
    " check to see if any go test flags are set ...
    let flags=""
    if exists("g:goTestFlags")
        let flags = g:goTestFlags 
    endif

    " test the current package
    if isdirectory(a:target)
        :call utilities#CleanShell("go test ". flags ." .")
    " this looks like a normal test file
    elseif a:target =~ "_test.go"
        :call utilities#CleanShell("go test ". flags ." ". a:target)
    " attempt to try the test version of this file
    else 
        let file=substitute(a:target, ".go", "_test.go", "")
        :call utilities#CleanShell("go test ". flags ." ". file)
    endif
endfunction

"""
""" Python Project Runners
"""
fu! file_runners#PythonRunner(target)

    if isdirectory(a:target) && exists("g:runCommand")
        :call utilities#CleanShell(g:runCommand)
    " this is just a file - call the single file method
    elseif filereadable(a:target)
        :call utilities#CleanShell("python ". a:target)
    endif

endfunction

fu! file_runners#PythonTestRunner(target)
    
    if isdirectory(a:target)
        :call utilities#CleanShell("cd ". g:basePath, "source bin/activate", "\./bin/nosetests --nocapture")
    elseif ! a:target =~ "_test.py" 
        let file=substitute(a:target, ".py", "_test.py", "")
        :call utilities#CleanShell("cd ". g:basePath, "source bin/activate", "\./bin/nosetests --nocapture ". file)
    else
        :call utilities#CleanShell("cd ". g:basePath, "source bin/activate", "\./bin/nosetests --nocapture ". a:target)
    endif
endfunction

"""
""" Docker Project Runners
"""
fu! file_runners#DockerfileRunner(...)
    " initialize the tag needed
    let tag="test"
    if exists("g:dockerTag")
        let tag=g:dockerTag
    endif
    " initialize the run command
    let command="docker run -i -t ". tag ." /bin/bash" 
    if exists("g:dockerRunCommand")
        let command=g:dockerRunCommand
    endif
    " now call the correct command
    :call utilities#CleanShell(command)
endfunction

fu! file_runners#DockerfileTestRunner(...)
    " initialize the tag needed
    let tag="test"
    if exists("g:dockerTag")
        echo "RUNNER"
        let tag=g:dockerTag
    endif
    let command="docker build -t ". tag ." ."
    :call utilities#CleanShell(command)
endfunction

"""
""" Ruby Project Runners
"""
fu! file_runners#RubyRunner(target)

    if isdirectory(a:target) && exists("g:runCommand")
        :call utilities#CleanShell("cd ". g:basePath, g:runCommand)
    else
        :call utilities#CleanShell("ruby ". a:target)
    endif
endfunction

fu! file_runners#RubyTestRunner(target)
    
    " check rake tasks to see if tests exists
    " some ideas could be - look into rake 
    " look for a .cucumber file
    " look for a spec file

endfunction


"""
""" Cucumber Project Runners
"""
fu! file_runners#CucumberRunner(target)
    echo a:target
    " build entire project as needed
    if isdirectory(a:target)
        :call utilities#CleanShell("cd ". g:basePath, "cucumber")
    else
        " need to find this exact path
        :call utilities#CleanShell("cd ". g:basePath, "cucumber ". a:target)
    endif
endfunction

fu! file_runners#CucumberTestRunner(target)
    :call file_runners#CucumberRunner(a:target)
endfunction

"""
""" Coffeescript/Node Project Runners
"""
fu! file_runners#CoffeeRunner(target)

    if filereadable(g:basePath ."/Cakefile")
        call utilities#CleanShell("cake test")
    else
        call utilities#CleanShell("coffee ". a:target)
    endif

endfunction

fu! file_runners#CoffeeDebugRunner(target)

    if filereadable(g:basePath. "/Cakefile")
        call utilities#CleanShell("cake debug")
    endif

endfunction

fu! file_runners#JavascriptRunner(target)
    
    :call utilities#CleanShell("node ". a:target)

endfunction

"""
""" Haskell
"""
fu! file_runners#HaskellRunner(target)
    :call utilities#CleanShell("runghc ". @%)
endfunction

