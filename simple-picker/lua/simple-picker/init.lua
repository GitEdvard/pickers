local M = {}
local on_change_callbacks = {}

M.emit_on_change = function(metadata)
  for idx = 1, #on_change_callbacks do
    on_change_callbacks[idx](metadata)
  end
end

M.on_config_selected = function(cb)
  table.insert(on_change_callbacks, cb)
end

M.reset = function()
  on_change_callbacks = {}
end

return M
