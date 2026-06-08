--- `<Plug>` mappings and optional default key bindings.
local M = {}

-- Public, remappable entry points. Bind these yourself if you disable the
-- defaults via `keys = { ... = false }`.
local plugs = {
  task_pane = "<Plug>(TodoNavTaskPane)",
  task_float = "<Plug>(TodoNavTaskFloat)",
  index_pane = "<Plug>(TodoNavIndexPane)",
  index_float = "<Plug>(TodoNavIndexFloat)",
}

function M.apply(cfg)
  local todo = require("todo-nav")

  for name, lhs in pairs(plugs) do
    vim.keymap.set("n", lhs, function()
      todo[name]("n")
    end, { desc = "todo-nav: " .. name })
    vim.keymap.set("x", lhs, function()
      todo[name]("v")
    end, { desc = "todo-nav: " .. name })
  end

  for name, key in pairs(cfg.keys or {}) do
    if key and plugs[name] then
      vim.keymap.set({ "n", "x" }, key, plugs[name], {
        remap = true,
        desc = "todo-nav: " .. name,
      })
    end
  end
end

return M
