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