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

function M.build_config_definitions(definitions)
    local args = ""
    for key,value in pairs(definitions) do
        if type(value)=="string" then
            args=args.." -D"..key.."=\""..value.."\""
        elseif type(value)=="boolean" then
            if value then
                args=args.." -D"..key.."=ON"
            else
                args=args.." -D"..key.."=OFF"
            end
        elseif type(value)=="number" then
            args=args.." -D"..key.."="..value
        end
    end
    return args
end

function M.build_args(args_array)
    local args = ""
    for _,arg in ipairs(args_array) do
        args=args.." \""..arg.."\""
    end
    return args
end

function M.parse_path(path, config, default_build_type)
    local res = ""
    for str in string.gmatch(path,"[^/]*") do
        if str == "" then
            res=res.."/"
        else
            if str=="%name%" then
                res=res..config.name
            elseif str == "%build_type%" then
                if config.build_type~=nil then
                    res=res..string.lower(config.build_type)
                else
                    res=res..string.lower(default_build_type)
                end
            else
                res=res..str
            end
        end
    end
    return res
end

function M.is_build_dir_configured(dir)
    local cache_file = io.open(dir.."/CMakeCache.txt")
    local res = cache_file~=nil
    if res then
        io.close(cache_file)
    end
    return res
end

return M