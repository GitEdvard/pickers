local strings = require("plenary.strings")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local callback_handler = require("config-picker")
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local flatten = vim.tbl_flatten

local files = {}

local get_selected_text = function(prompt_bufnr)
    local selection = action_state.get_selected_entry(prompt_bufnr)
    return selection[1]
end

local trigger_actions = function(prompt_bufnr)
  local selection = get_selected_text(prompt_bufnr)
  actions.close(prompt_bufnr)
  local metadata = { ["text"] = selection }
  if selection ~= nil then
    callback_handler.emit_on_change(metadata)
  end
end

local config_picker_fnc = function(opts)
  opts = opts or {}

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  require('telescope.builtin').find_files({
    prompt_title = opts.title,
    search_dirs= opts.search_dirs,
    attach_mappings = function(_, map)
      actions.select_default:replace(trigger_actions)
      return true
    end
  })

end

return require("telescope").register_extension({
  exports = {
      config_picker = config_picker_fnc
  }
})
