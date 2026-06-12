--- ripgrep-backed search for task and index entries.
local M = {}

--- `--glob` exclusion args. Always exclude the index file from task/file search
--- (so a hit lands in a workstream file), plus any configured `exclude_glob`
--- patterns — e.g. `*.archive.md` siblings — so navigation lands on the live
--- tracker (its digest row) rather than archived detail.
local function exclude_args(cfg)
  local args = { "--glob", "!" .. cfg.index_file }
  for _, pattern in ipairs(cfg.exclude_glob or {}) do
    args[#args + 1] = "--glob"
    args[#args + 1] = "!" .. pattern
  end
  return args
end

--- argv for the task search: vimgrep-format hits for `query` across the tracker
--- directory, with the index and configured archives excluded and a stable sort
--- so the "first match" the caller jumps to is deterministic.
function M.task_cmd(cfg, query)
  local cmd = { "rg", "--vimgrep", "--fixed-strings", "--sort", "path" }
  vim.list_extend(cmd, exclude_args(cfg))
  cmd[#cmd + 1] = query
  cmd[#cmd + 1] = cfg._todo_path
  return cmd
end

--- argv for the index fallback's file lookup: tracker files matching `query`,
--- index and archives excluded, stable-sorted so `files[1]` is deterministic.
function M.files_cmd(cfg, query)
  local cmd = { "rg", "--files-with-matches", "--fixed-strings", "--sort", "path" }
  vim.list_extend(cmd, exclude_args(cfg))
  cmd[#cmd + 1] = query
  cmd[#cmd + 1] = cfg._todo_path
  return cmd
end

--- vimgrep-format hits for `query` across the tracker directory.
function M.task_results(cfg, query)
  return vim.fn.systemlist(M.task_cmd(cfg, query))
end

--- vimgrep-format hits locating the index entry for `query`: prefer a direct
--- identifier hit in the index file, then fall back to the index line that
--- references the workstream file containing the task.
function M.index_results(cfg, query)
  local hits = vim.fn.systemlist({
    "rg",
    "--vimgrep",
    "--fixed-strings",
    query,
    cfg._index_path,
  })

  if vim.v.shell_error == 0 and #hits > 0 then
    return hits
  end

  local files = vim.fn.systemlist(M.files_cmd(cfg, query))

  if vim.v.shell_error ~= 0 or #files == 0 then
    return {}
  end

  return vim.fn.systemlist({
    "rg",
    "--vimgrep",
    "--fixed-strings",
    vim.fn.fnamemodify(files[1], ":t"),
    cfg._index_path,
  })
end

return M
