--- Default configuration and merge helper for todo-nav.
local M = {}

--- Default options. Override any of these via `require("todo-nav").setup(opts)`.
M.defaults = {
  -- Directory (relative to the resolved project root) that holds the trackers.
  todo_dir = "docs/ai_todos",
  -- Index file inside `todo_dir`. Excluded from task search; used for index search.
  index_file = "INDEX.md",
  -- Lua pattern matching a tracked identifier under the cursor (no capture group).
  id_pattern = "[A-Z][A-Z0-9]+%-%d%d?%.?%d*",
  -- Lua pattern marking the first line of a top-level item, used to compute the
  -- whole-task highlight range for the task float.
  task_boundary = "^%d+%.",
  -- Highlight group applied to the matched line(s) in a float.
  highlight = "Visual",
  -- Floating window geometry (fractions of editor size) and border.
  float = { width = 0.8, height = 0.8, border = "rounded" },
  -- Resolve the project root. Defaults to the nearest `.git` ancestor, else cwd.
  root = nil,
  -- Default key mappings. Set any entry to `false` to skip it; remap the
  -- corresponding `<Plug>(TodoNav*)` mapping yourself instead.
  keys = {
    task_pane = "<leader>gt",
    task_float = "<leader>gT",
    index_pane = "<leader>gi",
    index_float = "<leader>gI",
  },
}

--- Merge user options over the defaults.
function M.merge(opts)
  return vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
