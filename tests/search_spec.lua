local search = require("todo-nav.search")

local function cfg(overrides)
  return vim.tbl_deep_extend("force", {
    index_file = "INDEX.md",
    exclude_glob = { "*.archive.md" },
    _todo_path = "docs/ai_todos",
    _index_path = "docs/ai_todos/INDEX.md",
  }, overrides or {})
end

local function has_glob(cmd, pattern)
  for i, arg in ipairs(cmd) do
    if arg == "--glob" and cmd[i + 1] == pattern then
      return true
    end
  end
  return false
end

describe("task_cmd", function()
  it("excludes the index file and configured archive globs", function()
    local cmd = search.task_cmd(cfg(), "PROJ-40")
    assert.is_true(has_glob(cmd, "!INDEX.md"))
    assert.is_true(has_glob(cmd, "!*.archive.md"))
  end)

  it("sorts by path so the first match is deterministic", function()
    local joined = table.concat(search.task_cmd(cfg(), "PROJ-40"), " ")
    assert.is_truthy(joined:find("--sort path", 1, true))
  end)

  it("ends with the query then the tracker path", function()
    local cmd = search.task_cmd(cfg(), "PROJ-40")
    assert.equals("PROJ-40", cmd[#cmd - 1])
    assert.equals("docs/ai_todos", cmd[#cmd])
  end)

  it("honors an empty exclude_glob so archives are searched too", function()
    local cmd = search.task_cmd(cfg({ exclude_glob = {} }), "PROJ-40")
    assert.is_false(has_glob(cmd, "!*.archive.md"))
    assert.is_true(has_glob(cmd, "!INDEX.md"))
  end)

  it("supports multiple exclude patterns", function()
    local cmd = search.task_cmd(cfg({ exclude_glob = { "*.archive.md", "draft_*.md" } }), "PROJ-40")
    assert.is_true(has_glob(cmd, "!*.archive.md"))
    assert.is_true(has_glob(cmd, "!draft_*.md"))
  end)
end)

describe("files_cmd", function()
  it("lists matching files with the same exclusions", function()
    local cmd = search.files_cmd(cfg(), "PROJ-40")
    assert.is_truthy(table.concat(cmd, " "):find("--files-with-matches", 1, true))
    assert.is_true(has_glob(cmd, "!INDEX.md"))
    assert.is_true(has_glob(cmd, "!*.archive.md"))
  end)
end)
