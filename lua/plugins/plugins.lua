return {
    {
        "neovim/nvim-lspconfig",
        opts = {
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
            {
                "<leader>ha",
                function()
                    require("harpoon.mark").add_file()
                end,
                desc = "Mark file with harpoon",
            },
            {
                "<ileader>hn",
                function()
                    require("harpoon.ui").nav_next()
                end,
                desc = "Go to next harpoon mark",
            },
            {
                "<leader>hp",
                function()
                    require("harpoon.ui").nav_prev()
                end,
                desc = "Go to previous harpoon mark",
            },
            {
                "<leader>hy",
                function()
                    require("harpoon.ui").nav_file(1)
                end,
                desc = "Go to harpoon 1",
            },
            {
                "<leader>hu",
                function()
                    require("harpoon.ui").nav_file(2)
                end,
                desc = "Go to harpoon 2",
            },
            {
                "<leader>hi",
                function()
                    require("harpoon.ui").nav_file(3)
                end,
                desc = "Go to harpoon 3",
            },
            {
                "<leader>ho",
                function()
                    require("harpoon.ui").nav_file(4)
                end,
                desc = "Go to harpoon 4",
            },
            {
                "<leader>hm",
                function()
                    require("harpoon.ui").toggle_quick_menu()
                end,
                desc = "Show harpoon marks",
            },
        },
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
    {
        "tpope/vim-fugitive",
    },
    {
        "mbbill/undotree",
        keys = {
            { "<leader>ut", ":UndotreeShow<CR>", desc = "Toogle undo tree" },
        },
    },
    {
        "epwalsh/obsidian.nvim",
        lazy = true,
        event = {
            "BufReadPre  /home/mahulst/obsidian/vault/**.md",
            "BufNewFile /home/mahulst/obsidian/vault/**.md",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            dir = "~/obsidian/vault",
            mappings = {},
        },
    },
}
