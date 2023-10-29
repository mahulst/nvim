vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.del("n", "<leader>gg")
vim.keymap.del("n", "<leader>gG")

vim.keymap.set("n", "J", "mzJ`z")
-- Keep cursor in middle while jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keep cursor in middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste over while keeping your copied value
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set({ "n", "v" }, "<leader><leader>s", "<cmd>w<CR>")

-- Toggle git blame
vim.keymap.set({ "n", "v" }, "<leader>gb", "<cmd>ToggleBlame<CR>")

vim.keymap.set({ "n", "v" }, "<leader>cx", "<cmd>RustRunnables<CR>")
