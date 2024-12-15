# config-picker

## Usage
```
require("telescope").load_extension("config_picker")

local config_picker = require("config-picker")

local list_configs = function()
  local root_path = find_root_path()
  local config_dir = root_path .. "\\" .. "run-configs"
  local opts = {}
  opts.title = "Run configurations"
  opts.search_dirs = {config_dir}
  require('telescope').extensions.config_picker.config_picker(opts)
end

config_picker.on_config_selected(function(metadata)
  print("Selected choice was " .. metadata.text)
end)

local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>q', list_configs, bufopts)
``` 
