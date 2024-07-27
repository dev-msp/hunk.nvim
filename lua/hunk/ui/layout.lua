local highlights = require("hunk.api.highlights")
local config = require("hunk.config")

local M = {}

local function create_vertical_split()
  vim.api.nvim_command("vsplit")
  local winid = vim.api.nvim_get_current_win()
  -- vim.api.nvim_set_option_value("diff", true, {
  --   win = winid,
  -- })
  return winid
end

local function create_horizontal_split()
  vim.api.nvim_command("split")
  local winid = vim.api.nvim_get_current_win()
  return winid
end

local function resize_tree(tree, left, right, size, layout)
  local total_width = vim.api.nvim_get_option_value("columns", {})
  local remaining_width = total_width - size
  local equal_width = math.floor(remaining_width / 2)

  vim.api.nvim_win_set_width(tree, size)

  if layout == "vertical" then
    vim.api.nvim_win_set_width(left, equal_width)
    vim.api.nvim_win_set_width(right, equal_width)
  end
end

function M.create_layout()
  local tree_window = vim.api.nvim_get_current_win()

  local left_diff = create_vertical_split()
  local right_diff
  if config.ui.layout == "vertical" then
    right_diff = create_vertical_split()
  elseif config.ui.layout == "horizontal" then
    right_diff = create_horizontal_split()
  else
    error("Unknown value '" .. config.ui.layout .. "' for config entry `ui.layout`")
  end

  highlights.set_win_hl(left_diff, {
    "DiffAdd:HunkDiffAddAsDelete",
    "DiffDelete:HunkDiffDeleteDim",

    "HunkSignSelected:Red",
    "HunkSignDeselected:Red",
  })

  highlights.set_win_hl(right_diff, {
    "DiffDelete:HunkDiffDeleteDim",
    "HunkSignSelected:Green",
    "HunkSignDeselected:Green",
  })

  resize_tree(tree_window, left_diff, right_diff, config.ui.tree.width, config.ui.layout)
  vim.api.nvim_set_option_value("winfixwidth", true, { win = tree_window })

  vim.api.nvim_set_current_win(tree_window)

  return {
    tree = tree_window,
    left = left_diff,
    right = right_diff,
  }
end

return M
