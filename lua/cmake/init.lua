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

local utils = require'cmake.utils'
local ui = require'cmake.ui'

local M = require'cmake.settings'

local build_type = "Debug"
local config_name = nil

function M.load_settings()
    build_type = "Debug"
    M.update_settings()
end

function M.update_settings()
    M.settings = M.default_settings

    local cwd = vim.api.nvim_eval("getcwd()")
    local settings_file = io.open(cwd.."/settings.json", "r")
    if settings_file~=nil then
        io.input(settings_file)
        local json_text = ""
        while true do
            local line = io.read()
            if line==nil then
                break
            end
            json_text = json_text..line.."\n"
        end
        io.close(settings_file)
        if json_text=="" then
            return
        end
        local json = vim.api.nvim_call_function("json_decode",{json_text})
        if json["cmake"]~=nil then
            local cmake = json["cmake"]

            -- Load configs
            if cmake["configurations"]~=nil then
                M.settings.configs =  cmake["configurations"]
            else
                vim.api.nvim_err_writeln("CMake settings contains no configurations")
            end

            -- Load binary
            if cmake["bin"]~=nil then
                M.settings.bin = cmake["bin"]
            end
        end
    end
end

function M.configure()
    local name = config_name
    if name==nil then
        for _,config in ipairs(M.settings.configs) do
            name = config.name
            break
        end
    end

    for _,config in ipairs(M.settings.configs) do
        if name == config.name then
            if config.build_dir == nil then
                local cwd = vim.api.nvim_eval("getcwd()")
                config.build_dir = cwd.."/build/"
            end
            local args = ""
            if config.generator~=nil then
                args=args.." -G \""..config.generator.."\""
            end
            if config.build_dir~=nil then
                local path = utils.parse_path(config.build_dir, config, build_type)
                args=args.." -B \""..path.."\""
            end
            if config.build_type~=nil then
                args=args.." -DCMAKE_BUILD_TYPE=\""..config.build_type.."\""
            else
                args=args.." -DCMAKE_BUILD_TYPE=\""..build_type.."\""
            end
            if config.definitions~=nil then
                args = args..utils.build_config_definitions(config.definitions)
            end
            local text = vim.api.nvim_call_function("execute",{"!"..M.settings.bin..args})
            print(text)
            return
        end
    end

    vim.api.nvim_err_writeln("cmake: No matching configuration with name '"..name.."' found")
end

function M.build()
    local name = config_name
    if name==nil then
        for _,config in ipairs(M.settings.configs) do
            name = config.name
            break
        end
    end

    for _,config in ipairs(M.settings.configs) do
        if name == config.name then
            if config.build_dir == nil then
                local cwd = vim.api.nvim_eval("getcwd()")
                config.build_dir = cwd.."/build/"
            end

            if not utils.is_build_dir_configured(config.build_dir) then
                M.configure(name)
            end

            local cfg = config
            if cfg.build_type==nil then
                cfg.build_type = build_type
            end
            local args = " --build "..utils.parse_path(config.build_dir, config, build_type)
            if config.build_args~=nil then
                args=args..utils.build_args(config.build_args)
            end

            local text = vim.api.nvim_call_function("execute",{"!"..M.settings.bin..args})
            print(text)

            return
        end
    end

    vim.api.nvim_err_writeln("cmake: No matching configuration with name '"..name.."' found")
end

function M.clear_config()
    local name = config_name
    if name==nil then
        for _,config in ipairs(M.settings.configs) do
            name = config.name
            break
        end
    end

    for _,config in ipairs(M.settings.configs) do
        if name==config.name then
            if config.build_dir == nil then
                local cwd = vim.api.nvim_eval("getcwd()")
                config.build_dir = cwd.."/build/"
            end

            local cfg = config
            if cfg.build_type==nil then
                cfg.build_type = build_type
            end
            vim.api.nvim_call_function("execute", {"!rm -rf "..utils.parse_path(config.build_dir,cfg)})
            return
        end
    end

    vim.api.nvim_err_writeln("cmake: No matching configuration with name '"..name.."' found")
end

function M.select_build_type(build_type_str)
    if build_type_str==nil or build_type_str=="" then
        ui.create_selection({"Debug","Release","RelWithDebInfo","MinSizeRel"}, M.select_build_type)
    else
        build_type=build_type_str
    end
end

function M.select_config(config_name_str)
    if config_name_str==nil or config_name_str=="" then
        local config_names = {}
        for _,config in ipairs(M.settings.configs) do
            table.insert(config_names,config.name)
        end
        ui.create_selection(config_names, M.select_config)
    else
        config_name=config_name_str
    end
end

return M