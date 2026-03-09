-- yazi-zellij init.lua
-- Minimal config for sidebar mode

-- DEBUG: Check if init.lua is being loaded
ya.notify({title="Yazi", content="init.lua loading...", level="info", timeout=3})

-- Try to load plugins with error handling
local function safe_require(name, setup_fn)
    local ok, mod = pcall(require, name)
    if ok and mod then
        local ok2 = pcall(function()
            if setup_fn then
                setup_fn(mod)
            elseif mod.setup then
                mod:setup()
            end
        end)
        if not ok2 then
            ya.notify({title="Plugin", content=name.." setup failed", level="warn", timeout=3})
        else
            ya.notify({title="Plugin", content=name.." loaded OK", level="info", timeout=2})
        end
    else
        ya.notify({title="Plugin", content=name.." require failed", level="error", timeout=3})
    end
end

-- Load standard plugins
safe_require("git")
safe_require("full-border", function(mod)
    mod:setup({ type = ui.Border.ROUNDED })
end)

-- Load git-changes plugin
safe_require("git-changes")

-- Load no-status plugin
local ok, no_status = pcall(require, "no-status")
if ok and no_status then
    no_status:setup()
end
