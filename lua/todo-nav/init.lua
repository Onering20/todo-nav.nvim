--- todo-nav: jump from a TODO identifier under the cursor to its workstream
--- entry or its index entry, in the current pane or a floating dialog.
local config = require("todo-nav.config")
local identifier = require("todo-nav.identifier")
local search = require("todo-nav.search")
local float = require("todo-nav.float")

local M = {}

--- Active configuration; lazily defaulted so commands work without setup().
function M._config()
  if not M.config then
    M.config = config.merge({})
  end
  return M.config
end

local function default_root()
  local ok, root = pcall(vim.fs.root, 0, ".git")
  if ok and root then
    return root
  end
  return vim.fn.getcwd()
end

--- Resolve absolute tracker/index paths for the current project root.
local function resolve(cfg)
  local resolved = vim.tbl_extend("force", {}, cfg)
  local root = (cfg.root and cfg.root()) or default_root()
  resolved._todo_path = root .. "/" .. cfg.todo_dir
  resolved._index_path = resolved._todo_path .. "/" .. cfg.index_file
  return resolved
end

local function query_for(mode)
  if mode == "v" then
    return identifier.selected_text()
  end
  return identifier.under_cursor(M._config().id_pattern)
end

local function run(mode, search_fn, as_float, whole_task, not_found, title)
  local query = vim.trim(query_for(mode) or "")
  if query == "" then
    vim.notify("todo-nav: no task text under cursor", vim.log.levels.WARN)
    return
  end

  local cfg = resolve(M._config())
  local results = search_fn(cfg, query)
  if #results == 0 then
    vim.notify("todo-nav: " .. not_found .. " " .. query, vim.log.levels.WARN)
    return
  end

  if as_float then
    float.float(cfg, results, query, whole_task)
  else
    float.quickfix(results, title .. ": " .. query)
  end
end

function M.task_pane(mode)
  run(mode or "n", search.task_results, false, true, "no task found for", "Task search")
end

function M.task_float(mode)
  run(mode or "n", search.task_results, true, true, "no task found for", "Task search")
end

function M.index_pane(mode)
  run(mode or "n", search.index_results, false, false, "no INDEX entry found for", "Index search")
end

function M.index_float(mode)
  run(mode or "n", search.index_results, true, false, "no INDEX entry found for", "Index search")
end

--- Configure todo-nav and apply key mappings.
function M.setup(opts)
  M.config = config.merge(opts)
  require("todo-nav.keymaps").apply(M.config)
end

return M
