-- Copyright (c) 2020, Robert John Oleynik
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice, this
--   list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright notice,
--   this list of conditions and the following disclaimer in the documentation
--   and/or other materials provided with the distribution.
--
-- * Neither the name of [project] nor the names of its
--   contributors may be used to endorse or promote products derived from
--   this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local M = {}

local settings = {
    padding = {
        left = 2
    }
}
local items = {}
local namespace = vim.api.nvim_create_namespace("cmake-ui-selection-namespace")
local buf = 0
local win = 0
local cursor_pos = nil
local selected = 0
local callback = nil

local options = require'cmake.buffer_options'

function M.create_selection(pitems,callback_func)
    if buf~=0 then
        M.destroy()
    end

    local buffer = vim.api.nvim_create_buf(false, false)
    if not buffer==0 then
        vim.api.nvim_err_writeln("Couldn't create startpage")
        return 0
    end
    -- Opens a window on the bottom left with full width
    vim.api.nvim_command[[ botright split ]]
    local window = vim.api.nvim_get_current_win()

    buf = buffer
    win = window
    items = pitems
    callback = callback_func

    local left_padding = string.rep(" ",settings.padding.left)
    local lines = {}
    table.insert(lines, "")
    for _,item in pairs(items) do
        table.insert(lines, left_padding.."[ ] "..item)
    end

    vim.api.nvim_buf_set_lines(buffer,0,0,true,lines)
    vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)

    for linenr,line in ipairs(lines) do
        if line~="" then
            vim.api.nvim_buf_add_highlight(buffer, namespace, "Keyword", linenr-1, settings.padding.left, settings.padding.left+3)
            vim.api.nvim_buf_add_highlight(buffer, namespace, "String", linenr-1, settings.padding.left+3, -1)
        end
    end

    -- TODO: Set text
    local win_options = {
        colorcolumn="",
        foldcolumn="0",
        cursorcolumn=false,
        cursorline=false,
        list=false,
        number=false,
        relativenumber=false,
        spell=false,
        signcolumn="no",
    }
    options.win_set(win,win_options)

    local buffer_options = {
        bufhidden="wipe",
        matchpairs="",
        swapfile=false,
        filetype="cmake_selection",
        modifiable=false,
        modified=false
    }
    options.buffer_set(buffer,buffer_options)

    vim.api.nvim_win_set_height(win, table.maxn(lines)+1)
    vim.api.nvim_win_set_buf(win, buffer)

    selected = 1
    cursor_pos = {2,settings.padding.left+1}
    vim.api.nvim_win_set_cursor(win, cursor_pos)

    M.init()
end

function M.update_cursor()
    if cursor_pos==nil then
        return
    end

    local new_pos = vim.api.nvim_win_get_cursor(win)

    if new_pos[1] > cursor_pos[1] or new_pos[2] > cursor_pos[2] then
        local next = selected+1
        if next <= table.maxn(items) then
            selected = next
        end
    elseif new_pos[1] < cursor_pos[1] or new_pos[2] < cursor_pos[2] then
        local next = selected-1
        if next > 0 then
            selected = next
        end
    end

    cursor_pos = {selected+1, settings.padding.left+1}
    vim.api.nvim_win_set_cursor(win, cursor_pos)
end

function M.init()
    vim.api.nvim_command[[ augroup cmake-selection-cursor-moved ]]
        vim.api.nvim_command[[ autocmd! * <buffer> ]]
        vim.api.nvim_command[[ autocmd CursorMoved <buffer> lua require('cmake.ui').update_cursor() ]]
        vim.api.nvim_command[[ autocmd BufDelete <buffer> lua require('cmake.ui').cleanup() ]]
        vim.api.nvim_command[[ autocmd BufLeave <buffer> lua require('cmake.ui').destroy() ]]
    vim.api.nvim_command[[ augroup END ]]

    vim.api.nvim_buf_set_keymap(buf, "n", "<cr>", "<cmd>lua require('cmake.ui').submit()<cr>", {nowait=true})
end

function M.submit()
    callback(items[selected])
    M.destroy()
end

function M.cleanup()
    vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    items = {}
    buf = 0
    win = 0
    cursor_pos = nil
    selected = 0
end

function M.destroy()
    vim.api.nvim_win_close(win, true)
    M.cleanup()
end

return M