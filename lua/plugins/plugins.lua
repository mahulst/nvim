-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
return { 
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        kotlin_language_server = {},
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
    keys = {
      { "<leader>ha", function() require('harpoon.mark').add_file() end, desc = "Mark file with harpoon" },
      { "<ileader>hn", function () require('harpoon.ui').nav_next() end, desc = "Go to next harpoon mark" },
      { "<leader>hp", function () require('harpoon.ui').nav_prev() end, desc = "Go to previous harpoon mark" },
      { "<C-h>", function () require('harpoon.ui').nav_file(1) end, desc = "Go to harpoon 1" },
      { "<C-t>", function () require('harpoon.ui').nav_file(2) end, desc = "Go to harpoon 2" },
      { "<C-n>", function () require('harpoon.ui').nav_file(3) end, desc = "Go to harpoon 3" },
      { "<C-s>", function () require('harpoon.ui').nav_file(4) end, desc = "Go to harpoon 4" },
      { "<leader>hm", function () require('harpoon.ui').toggle_quick_menu() end, desc = "Show harpoon marks" },
    }
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<C-p>",
        function() require("telescope.builtin").git_files() end,
        desc = "Find files in git",
      },
    },
    -- change some options
  },
  { "tpope/vim-fugitive" }
}
