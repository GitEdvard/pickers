# simple-picker
## Motive
Declare the list to choose from, and what to to with the selection in the client code.

## Usage
```
require("telescope").load_extension("simple_picker")

local simple_picker = require("simple-picker")

local list_configs = function()
  local opts = { entries = { "alt #1", "alt #2" } }
  opts.title = "Run configurations"
  require('telescope').extensions.simple_picker.simple_picker(opts)
end

simple_picker.on_config_selected(function(metadata)
  print("Selected choice was " .. metadata.text)
end)

local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>q', list_configs, bufopts)
```

