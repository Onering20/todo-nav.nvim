--- `:checkhealth todo-nav` — verify runtime dependencies.
local M = {}

function M.check()
  vim.health.start("todo-nav")

  if vim.fn.executable("rg") == 1 then
    vim.health.ok("ripgrep (`rg`) found on PATH")
  else
    vim.health.error("ripgrep (`rg`) not found on PATH", {
      "todo-nav uses ripgrep for all searches.",
      "Install it: https://github.com/BurntSushi/ripgrep#installation",
    })
  end

  local ok = pcall(require, "todo-nav")
  if ok then
    vim.health.ok("todo-nav module loads")
  else
    vim.health.error("todo-nav module failed to load")
  end
end

return M
