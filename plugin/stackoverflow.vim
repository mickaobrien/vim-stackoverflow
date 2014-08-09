if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

command! -nargs=1 StackOverflow call stackoverflow#StackOverflow(<f-args>)
