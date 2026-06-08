-- User commands. Mappings are applied by require("todo-nav").setup(); commands
-- work with default config even when setup() was never called.
if vim.g.loaded_todo_nav then
  return
end
vim.g.loaded_todo_nav = true

vim.api.nvim_create_user_command("TodoNavTask", function()
  require("todo-nav").task_float("n")
end, { desc = "Preview the TODO task under the cursor in a float" })

vim.api.nvim_create_user_command("TodoNavIndex", function()
  require("todo-nav").index_float("n")
end, { desc = "Preview the index entry for the task under the cursor in a float" })
