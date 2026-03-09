-- yazi-git init.lua
-- Git-focused yazi config with colored linemode

local git_stats_cache = {}
local git_root_fetched = nil

local function fetch_git_stats(root_str)
    if git_root_fetched == root_str then return end
    
    git_root_fetched = root_str
    git_stats_cache = {}
    
    local h = io.popen('cd "' .. root_str .. '" && git status --porcelain 2>/dev/null')
    if h then
        for line in h:lines() do
            local xy = line:sub(1, 2)
            local path = line:sub(4)
            if path:sub(1, 1) == '"' then
                path = path:sub(2, -2)
            end
            
            local status = "M"
            if xy:match("^%?%?") then status = "?"
            elseif xy:match("^.A") or xy:match("^A.") then status = "A"
            elseif xy:match("^.D") or xy:match("^D.") then status = "D"
            end
            
            git_stats_cache[path] = { status = status }
        end
        h:close()
    end
    
    local h2 = io.popen('cd "' .. root_str .. '" && git diff --numstat HEAD 2>/dev/null')
    if h2 then
        for line in h2:lines() do
            local a, r, p = line:match("(%d+)\t(%d+)\t(.+)")
            if p and git_stats_cache[p] then
                git_stats_cache[p].added = tonumber(a) or 0
                git_stats_cache[p].removed = tonumber(r) or 0
            end
        end
        h2:close()
    end
end

function Linemode:git_stats()
    local file = self._file
    if not file then return "" end
    
    local url = file.url
    local url_str = tostring(url)
    
    -- Find git root and relative path
    local root = nil
    local rel_path = nil
    
    -- Check if this is a search URL (contains ::)
    if url.is_search then
        -- Search URL format: /repo::Git changes/path/to/file.rs
        -- Extract repo root before ::
        root = url_str:match("^([^:]+)::")
        -- Extract path after the search name
        rel_path = url_str:match("::[^/]+/(.+)$")
    else
        -- Normal directory
        local path = url_str:match("^(.+)/[^/]+$")
        while path and path ~= "" do
            if io.open(path .. "/.git", "r") then
                root = path
                break
            end
            local p = path:match("^(.+)/[^/]+$")
            if p == path then break end
            path = p
        end
        if root and url_str:find(root, 1, true) then
            rel_path = url_str:sub(#root + 2)
        end
    end
    
    if not root or not rel_path or rel_path == "" then return "" end
    
    fetch_git_stats(root)
    
    local stats = git_stats_cache[rel_path]
    if not stats then return "" end
    
    -- Build colored status
    local status = stats.status or ""
    local style = ui.Style():fg("yellow")
    
    if status == "?" then style = ui.Style():fg("magenta")
    elseif status == "A" then style = ui.Style():fg("green")
    elseif status == "D" then style = ui.Style():fg("red")
    end
    
    local parts = { ui.Span(status):style(style) }
    
    if stats.added and stats.added > 0 then
        table.insert(parts, ui.Span(" +" .. stats.added):style(ui.Style():fg("green")))
    end
    
    if stats.removed and stats.removed > 0 then
        table.insert(parts, ui.Span(" -" .. stats.removed):style(ui.Style():fg("red")))
    end
    
    return ui.Line(parts)
end
