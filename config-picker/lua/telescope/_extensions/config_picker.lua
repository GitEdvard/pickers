local strings = require("plenary.strings")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local callback_handler = require("config-picker")

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

local open_indata = function(prompt_bufnr)
  local selection = get_selected_text(prompt_bufnr)
  actions.close(prompt_bufnr)
  local metadata = { ["text"] = selection }
  if metadata ~= nil then
    callback_handler.emit_on_indata_open(metadata)
  end
end

local config_picker_fnc = function(opts)
  opts = opts or {}
  -- local opts.entries = {}
  -- for file in io.popen([[dir "run-configs" /b]]):lines() do 
  --   table.insert(opts.entries, file) 
  -- end
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

  local displayer = require("telescope.pickers.entry_display").create {
    separator = " ",
    items = {
      { width = widths.text },
    },
  }

  local make_display = function(entry)
    return displayer {
      { entry.text, "TelescopeResultsIdentifier" },
    }
  end

  local wrap_user_defined = function(prompt_bufnr, user_defined_fnc)
    local selection = get_selected_text(prompt_bufnr)
    actions.close(prompt_bufnr)
    local metadata = { ["text"] = selection }
    if metadata ~= nil then
      user_defined_fnc(selection)
    end
  end

  local apply_mappings = function(opts, prompt_bufnr, map)
    local mappings = opts.mappings or {}
    for mode, binding in pairs(mappings) do
      for key, fnc in pairs(binding) do
        local wrapped_fnc = function()
          wrap_user_defined(prompt_bufnr, fnc)
        end
        map(mode, key, wrapped_fnc)
      end
    end
  end

  pickers.new(opts or {}, {
      prompt_title = opts.title or "Pick something",
      -- prompt_title = "Run configurations",
      finder = finders.new_table {
          results = results,
          entry_maker = function(entry)
              entry.value = entry.text
              entry.ordinal = entry.text
              entry.display = make_display
              return entry
          end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
          action_set.select:replace(trigger_actions)
          apply_mappings(opts, prompt_bufnr, map)
          map("i", "<c-i>", open_indata)
          return true
      end
  }):find()
end

return require("telescope").register_extension(
           {
        exports = {
            config_picker = config_picker_fnc
        }
    })
