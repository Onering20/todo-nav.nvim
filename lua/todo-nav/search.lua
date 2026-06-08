--- ripgrep-backed search for task and index entries.
local M = {}

--- vimgrep-format hits for `query` across the tracker directory, excluding the
--- index file so navigation lands in a workstream file.
function M.task_results(cfg, query)
  return vim.fn.systemlist({
    "rg",
    "--vimgrep",
    "--fixed-strings",
    "--glob",
    "!" .. cfg.index_file,
    query,
    cfg._todo_path,
  })
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

  local files = vim.fn.systemlist({
    "rg",
    "--files-with-matches",
    "--fixed-strings",
    "--glob",
    "!" .. cfg.index_file,
    query,
    cfg._todo_path,
  })

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
