local float = require("todo-nav.float")

local cfg = { task_boundary = "^%d+%." }

local function buf_with(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

describe("task_range", function()
  local lines = {
    "24. PREFIX-01 first item.", -- 1
    "    detail line.", -- 2
    "25. PREFIX-02 second item.", -- 3
    "    - slice a.", -- 4
    "    - slice b.", -- 5
    "    verification line.", -- 6
    "26. PREFIX-03 third item.", -- 7
    "", -- 8
    "## Heading", -- 9
  }

  it("spans a parent item and its indented slices", function()
    local buf = buf_with(lines)
    local first, last = float.task_range(cfg, buf, 3)
    assert.equals(3, first)
    assert.equals(6, last)
  end)

  it("walks up to the parent when the cursor is on a slice", function()
    local buf = buf_with(lines)
    local first, last = float.task_range(cfg, buf, 5)
    assert.equals(3, first)
    assert.equals(6, last)
  end)

  it("stops before a following heading and trims trailing blanks", function()
    local buf = buf_with(lines)
    local first, last = float.task_range(cfg, buf, 7)
    assert.equals(7, first)
    assert.equals(7, last)
  end)

  it("falls back to the single line outside any item", function()
    local buf = buf_with({ "no number here", "still none" })
    local first, last = float.task_range(cfg, buf, 2)
    assert.equals(2, first)
    assert.equals(2, last)
  end)
end)
