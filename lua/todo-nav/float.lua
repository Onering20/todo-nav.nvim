--- Result presentation: quickfix jump and floating preview with highlighting.
local M = {}

local ns = vim.api.nvim_create_namespace("todo_nav_float")

--- Extent of a tracked item containing line `target`: from its `task_boundary`
--- line down through indented continuation/slice lines, stopping before the next
--- boundary line or a markdown heading. Falls back to the single line when
--- `target` is not inside a boundary-delimited item.
function M.task_range(cfg, buf, target)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local first = target
  while first > 1 and not string.match(lines[first] or "", cfg.task_boundary) do
    first = first - 1
  end

  if not string.match(lines[first] or "", cfg.task_boundary) then
    return target, target
  end

  local last = first
  while last < #lines
    and not string.match(lines[last + 1] or "", cfg.task_boundary)
    and not string.match(lines[last + 1] or "", "^#")
  do
    last = last + 1
  end

  while last > first and string.match(lines[last] or "", "^%s*$") do
    last = last - 1
  end

  return first, last
end

--- Populate the quickfix list with `results` and jump to the first entry.
function M.quickfix(results, title)
  vim.fn.setqflist({}, "r", {
    title = title,
    lines = results,
  })
  vim.cmd("cfirst")
end

--- Open the first result in a centered floating window. When `whole_task` is
--- true, highlight the entire item (boundary line plus slices); otherwise just
--- the matched line. `q`/`<Esc>` close the float; the float-only mappings and
--- highlight are cleared on close so the underlying buffer is unaffected.
function M.float(cfg, results, label, whole_task)
  local filename, lnum = string.match(results[1], "^(.-):(%d+):")

  if filename == nil then
    vim.notify("todo-nav: could not parse location for " .. label, vim.log.levels.WARN)
    return
  end

  local target = tonumber(lnum)
  local buf = vim.fn.bufadd(filename)
  vim.fn.bufload(buf)

  local width = math.floor(vim.o.columns * cfg.float.width)
  local height = math.floor(vim.o.lines * cfg.float.height)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = cfg.float.border,
    title = " " .. label .. " ",
  })

  vim.api.nvim_win_set_cursor(win, { target, 0 })
  vim.api.nvim_win_call(win, function()
    vim.cmd("normal! zz")
  end)

  local hl_first, hl_last = target, target
  if whole_task then
    hl_first, hl_last = M.task_range(cfg, buf, target)
  end
  for line = hl_first, hl_last do
    vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
      line_hl_group = cfg.highlight,
    })
  end

  local function close_float()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close_float, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close_float, { buffer = buf, nowait = true })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      pcall(vim.keymap.del, "n", "q", { buffer = buf })
      pcall(vim.keymap.del, "n", "<Esc>", { buffer = buf })
      pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
    end,
  })
end

return M
