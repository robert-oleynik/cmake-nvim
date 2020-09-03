if exists('g:loaded_cmake_nvim')
    finish
endif

augroup cmake_nvim
    autocmd!
    autocmd VimEnter,DirChanged * lua require('cmake').load_settings()
    autocmd BufWritePost settings.json lua require('cmake').update_settings()
augroup END

command! CMakeOpenSettings edit settings.json
command! CMakeLoadSettings lua require('cmake').load_settings()
command! CMakeConfigure lua require('cmake').configure()
command! CMakeBuild lua require('cmake').build()
command! CMakeClean lua require('cmake').clean_config()
command! -nargs=? CMakeSelectBuildType call luaeval("require('cmake').select_build_type(_A)","<args>")
command! -nargs=? CMakeSelectConfig call luaeval("require('cmake').select_config(_A)","<args>")