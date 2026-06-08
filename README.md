# todo-nav.nvim

Jump from a TODO identifier under the cursor (or a visual selection) to its
workstream entry or its index entry — in the current pane or a floating dialog.

Built for file-based, identifier-keyed TODO systems where each workstream lives
in its own markdown file under a tracker directory, with a central index file.

## Features

- `<leader>gt` / `<leader>gT` — task entry in the current pane / a floating dialog.
- `<leader>gi` / `<leader>gI` — index entry in the current pane / a floating dialog.
- The task float highlights the **whole item** (the numbered parent line plus its
  indented slices); the index float highlights the matched line.
- Floats close with `q` or `<Esc>`; the float-only mappings and highlight are torn
  down on close so the underlying buffer is never left modified.
- Identifier detection is **robust to typographic dashes** — `PROJ—39` (em-dash),
  `PROJ–39` (en-dash) and `PROJ−39` (minus) all resolve like `PROJ-39`.
- Works in normal mode (identifier under cursor) and visual mode (selection).

Requires [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) on `PATH`.
Run `:checkhealth todo-nav` to verify.

## Install

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "you/todo-nav.nvim",
  opts = {
    -- all defaults shown; override what differs for your project
    todo_dir = "docs/ai_todos",
    index_file = "INDEX.md",
  },
}
```

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({ "you/todo-nav.nvim", config = function() require("todo-nav").setup({}) end })
```

## Configuration

```lua
require("todo-nav").setup({
  todo_dir = "docs/ai_todos",          -- tracker dir, relative to project root
  index_file = "INDEX.md",             -- index inside todo_dir
  id_pattern = "[A-Z][A-Z0-9]+%-%d%d?%.?%d*", -- Lua pattern, no capture group
  task_boundary = "^%d+%.",            -- marks the first line of a top-level item
  highlight = "Visual",                -- highlight group for matched line(s)
  float = { width = 0.8, height = 0.8, border = "rounded" },
  root = nil,                          -- function(): string; defaults to .git root, else cwd
  keys = {
    task_pane = "<leader>gt",
    task_float = "<leader>gT",
    index_pane = "<leader>gi",
    index_float = "<leader>gI",
  },
})
```

Set any `keys` entry to `false` to disable that default and bind the matching
`<Plug>` mapping yourself:

```lua
require("todo-nav").setup({ keys = { task_float = false } })
vim.keymap.set({ "n", "x" }, "<leader>tt", "<Plug>(TodoNavTaskFloat)", { remap = true })
```

Available `<Plug>` mappings: `(TodoNavTaskPane)`, `(TodoNavTaskFloat)`,
`(TodoNavIndexPane)`, `(TodoNavIndexFloat)`.

Commands (work without `setup()`): `:TodoNavTask`, `:TodoNavIndex`.

## How the index fallback works

`index_file` typically summarizes one line *per workstream file*, not per
identifier. So the index search first looks for a direct identifier hit; if there
is none, it finds the workstream file containing the task and jumps to the index
line that references that file.

## Provenance

Extracted from a project-local `.nvim.lua` navigation setup into a reusable plugin.

## Tests

```sh
make test   # requires plenary.nvim on the runtimepath
```

## License

MIT
