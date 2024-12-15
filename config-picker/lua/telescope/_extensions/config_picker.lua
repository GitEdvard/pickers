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
    return selection.text
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
  local results = {}
  local widths = {
    text = 0,
  }

  local parse_line = function(line)
    local entry = {
      text = line,
    }
    local index = #results + 1
    for key, val in pairs(widths) do
      local entry_len = strings.strdisplaywidth(entry[key] or "")
      widths[key] = math.max(val, entry_len)
    end
    table.insert(results, index, entry)
  end

  for _, line in ipairs(opts.entries) do
    parse_line(line)
  end

  if #results == 0 then
    return
  end

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  pickers.new(opts or {}, {
      prompt_title = opts.title or "Find Files",
      finder = finders.new_table {
        results = results,
        entry_maker = opts.entry_maker
      },
      entry_maker = opts.entry_maker,
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
      attach_mappings = function(_, map)
          action_set.select:replace(trigger_actions)
          return true
      end
    })
    :find()
end

return require("telescope").register_extension(
           {
        exports = {
            config_picker = config_picker_fnc
        }
    })
