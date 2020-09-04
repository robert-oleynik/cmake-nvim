" Copyright (c) 2020, Robert John Oleynik
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" * Redistributions of source code must retain the above copyright notice, this
"   list of conditions and the following disclaimer.
"
" * Redistributions in binary form must reproduce the above copyright notice,
"   this list of conditions and the following disclaimer in the documentation
"   and/or other materials provided with the distribution.
"
" * Neither the name of [project] nor the names of its
"   contributors may be used to endorse or promote products derived from
"   this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if exists('g:loaded_cmake_nvim')
    finish
endif

lua require('cmake')

augroup cmake_nvim
    autocmd!
    autocmd VimEnter,DirChanged * lua require('cmake').load_settings()
    autocmd BufWritePost settings.json lua require('cmake').update_settings()
augroup END

command! CMakeOpenSettings edit settings.json
command! CMakeLoadSettings lua require('cmake').load_settings()
command! CMakeConfigure lua require('cmake').configure()
command! CMakeBuild lua require('cmake').build()
command! CMakeClear lua require('cmake').clear_config()
command! -nargs=? CMakeSelectBuildType call luaeval("require('cmake').select_build_type(_A)","<args>")
command! -nargs=? CMakeSelectConfig call luaeval("require('cmake').select_config(_A)","<args>")