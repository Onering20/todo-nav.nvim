local identifier = require("todo-nav.identifier")

-- Unicode dash bytes (UTF-8), kept as explicit escapes so the spec does not
-- depend on `\u{}` support.
local EN = "\226\128\147" -- U+2013 en dash
local EM = "\226\128\148" -- U+2014 em dash
local MINUS = "\226\136\146" -- U+2212 minus sign

describe("normalize_dashes", function()
  it("collapses en/em/minus to an ASCII hyphen", function()
    assert.equals("PROJ-39", identifier.normalize_dashes("PROJ" .. EN .. "39"))
    assert.equals("PROJ-39", identifier.normalize_dashes("PROJ" .. EM .. "39"))
    assert.equals("PROJ-39", identifier.normalize_dashes("PROJ" .. MINUS .. "39"))
  end)

  it("leaves an ASCII identifier unchanged", function()
    assert.equals("PROJ-39", identifier.normalize_dashes("PROJ-39"))
  end)

  it("preserves surrounding prose while normalizing dashes", function()
    assert.equals("see PROJ-39 here", identifier.normalize_dashes("see PROJ" .. EM .. "39 here"))
  end)
end)

describe("under_cursor", function()
  local function with_line(text, col, fn)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, { 1, col })
    local result = fn()
    vim.api.nvim_buf_delete(buf, { force = true })
    return result
  end

  local pattern = "[A-Z][A-Z0-9]+%-%d%d?%.?%d*"

  it("extracts an ASCII identifier under the cursor", function()
    local id = with_line("25. PROJ-39 title", 5, function()
      return identifier.under_cursor(pattern)
    end)
    assert.equals("PROJ-39", id)
  end)

  it("extracts an em-dash identifier under the cursor", function()
    local id = with_line("25. PROJ" .. EM .. "39 title", 5, function()
      return identifier.under_cursor(pattern)
    end)
    assert.equals("PROJ-39", id)
  end)
end)
