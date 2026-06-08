-- Minimal init for headless test runs. Puts this plugin and plenary on the
-- runtimepath. Expects plenary.nvim checked out alongside this repo or under
-- the standard pack path.
local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(here)

for _, candidate in ipairs({
  here .. "/plenary.nvim",
  here .. "/../plenary.nvim",
  vim.fn.stdpath("data") .. "/lazy/plenary.nvim",
  vim.fn.stdpath("data") .. "/site/pack/vendor/start/plenary.nvim",
}) do
  if vim.fn.isdirectory(candidate) == 1 then
    vim.opt.runtimepath:prepend(candidate)
    break
  end
end

vim.cmd("runtime plugin/plenary.vim")
