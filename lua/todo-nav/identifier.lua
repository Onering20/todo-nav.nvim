--- Identifier extraction from the buffer, robust to typographic dashes.
local M = {}

--- Collapse Unicode dashes (en/em/figure/minus, U+2010-2015 and U+2212) to the
--- ASCII hyphen used in tracked identifiers, so navigation works even when the
--- text under the cursor was typed with a typographic dash that is visually
--- indistinguishable from a hyphen in a monospace font.
function M.normalize_dashes(text)
  return (text:gsub("\226\128[\144-\149]", "-"):gsub("\226\136\146", "-"))
end

--- The current visual selection as a single (dash-normalized) string.
function M.selected_text()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  local start_line = math.min(start_pos[2], end_pos[2])
  local end_line = math.max(start_pos[2], end_pos[2])
  local start_col = start_pos[2] <= end_pos[2] and start_pos[3] or end_pos[3]
  local end_col = start_pos[2] <= end_pos[2] and end_pos[3] or start_pos[3]
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    return ""
  end

  lines[1] = string.sub(lines[1], start_col)
  lines[#lines] = string.sub(lines[#lines], 1, end_col)
  return M.normalize_dashes(table.concat(lines, "\n"))
end

--- The identifier under the cursor for `id_pattern`, or the dash-normalized
--- WORD under the cursor as a fallback.
function M.under_cursor(id_pattern)
  local raw = vim.api.nvim_get_current_line()
  local line = M.normalize_dashes(raw)
  -- Map the cursor's raw byte column onto the normalized line, where each
  -- multibyte dash has collapsed to a single byte.
  local cursor_col = #M.normalize_dashes(string.sub(raw, 1, vim.fn.col(".")))
  local start_col = 1

  while true do
    local match_start, match_end, task_id =
      string.find(line, "(" .. id_pattern .. ")", start_col)

    if match_start == nil then
      break
    end

    if match_start <= cursor_col and cursor_col <= match_end then
      return task_id
    end

    start_col = match_end + 1
  end

  return M.normalize_dashes(
    string.gsub(string.gsub(vim.fn.expand("<cWORD>"), "^%p+", ""), "%p+$", "")
  )
end

return M
