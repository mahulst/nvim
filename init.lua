vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.wo.relativenumber = true
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- On attach per file type that uses lsp
local on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end
	vim.keymap.set({ "n", "v" }, "<leader>cu", vim.lsp.buf.references, { desc = "LSP: [C]ode [U]sages" })
	vim.keymap.set({ "n", "i" }, "<C-p>", vim.lsp.buf.signature_help, { desc = "LSP: [C]ode [P]arameters" })
	nmap("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
	nmap("<leader>ca", require("actions-preview").code_actions, "[C]ode [A]ction")

	nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	nmap("gD", vim.lsp.buf.type_definition, "[G]oto type [D]efiniton")
	nmap("<leader>cf", function()
		vim.lsp.buf.format()
	end, "[C]ode [F]ormat")
end

require("lazy").setup({
	{
		"FabijanZulj/blame.nvim",
	},
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<leader>gs", "<Cmd>Git<CR>", desc = "[G]it [S]tatus" },
			{ "<leader>gc", "<Cmd>Git commit<CR>", desc = "[G]it [C]ommit" },
			{ "<leader>gr", "<Cmd>Git pull --rebase<CR>", desc = "[G]it [R]ebase" },
			{ "<leader>gp", "<Cmd>Git push<CR>", desc = "[G]it [P]ush" },
			{ "<leader>gl", "<Cmd>Git push --force-with-lease<CR>", desc = "[G]it push --force-with-[L]ease" },
			{ "<leader>gn", "<Cmd>Git commit --amend --no-edit<CR>", desc = "[G]it --ame[N]d --no-edit" },
			{ "<leader>ga", "<Cmd>Git add -- .<CR>", desc = "[G]it [A]dd all" },
			{ "<leader>g%", "<Cmd>Git add %<CR>", desc = "[G]it add current file [%]" },
			{ "<leader>gb", "<cmd>ToggleBlame virtual<CR>", desc = "[G]it [B]lame" },
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			{ "j-hui/fidget.nvim", opts = {} },

			"folke/neodev.nvim",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.tsserver.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})
		end,
	},
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", ":UndotreeShow<CR>", desc = "Togle undo tree" },
		},
	},
	{
		"epwalsh/obsidian.nvim",
		lazy = true,
		event = {
			"BufReadPre " .. vim.fn.expand("~") .. "/projects/obsidian-vault/**.md",
			"BufNewFile " .. vim.fn.expand("~") .. "/projects/obsidian-vault/**.md",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			dir = "~/projects/obsidian-vault",
			mappings = {},
		},
	},

	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",

			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",

			-- Adds a number of user-friendly snippets
			"rafamadriz/friendly-snippets",
		},
	},
	-- Useful plugin to show you pending keybinds.
	{
		"folke/which-key.nvim",
		opts = {},
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to next hunk" })
				map({ "n", "v" }, "<leader>gH", function()
					require("gitsigns").preview_hunk()
				end, { desc ="[G]it preview [H]unk"})
				map({ "n", "v" }, "<leader>gh", function()
					require("gitsigns").preview_hunk_inline()
				end, { desc ="[G]it preview [H]unk"})
				map({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to previous hunk" })
			end,
		},
	},

	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("onedark")
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				icons_enabled = false,
				theme = "onedark",
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 4 } },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },

	-- Fuzzy Finder (files, lsp, etc)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		opts = {
			extensions = {
				["ui-select"] = {},
			},
		},
	},
	{ "aznhe21/actions-preview.nvim" },
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/neotest-plenary",
			"nvim-neotest/neotest-jest",
			"rouge8/neotest-rust",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rust")({ args = { "--no-capture" } }),
					require("neotest-jest")({
						jestCommand = "npm test --",

						jestConfigFile = function()
							local file = vim.fn.expand("%:p")
							if string.find(file, "/apps/") or string.find(file, "/packages/") then
								return string.match(file, "(.-/[^/]+/)src") .. "jest.config.js"
							end

							return vim.fn.getcwd() .. "/jest.config.ts"
						end,

						env = { CI = true },
						cwd = function()
							local file = vim.fn.expand("%:p")
							if string.find(file, "/apps/") or string.find(file, "/packages/") then
								return string.match(file, "(.-/[^/]+/)src")
							end
							return vim.fn.getcwd()
						end,
					}),
				},
			})
		end,
		keys = {
			{
				"<leader>tt",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run File",
			},
			{
				"<leader>tT",
				function()
					require("neotest").run.run(vim.loop.cwd())
				end,
				desc = "Run All Test Files",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
				end,
				desc = "Run Nearest",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle Summary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "Show Output",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Toggle Output Panel",
			},
			{
				"<leader>tS",
				function()
					require("neotest").run.stop()
				end,
				desc = "Stop",
			},
		},
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
				},
			})
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^3", -- Recommended
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					autoSetHints = true,
					inlay_hints = {
						show_parameter_hints = true,
						parameter_hints_prefix = "<- ",
						other_hints_prefix = "=> ",
					},
				},
				server = {
					on_attach = function(client, bufnr)
						on_attach(client, bufnr)
						vim.keymap.set("n", "<leader>cR", "<Cmd>RustLsp runnables<CR>", {})
						vim.keymap.set("n", "K", "<Cmd>RustLsp hover actions<CR>", {})
					end,
					settings = {
						["rust-analyzer"] = {
							assist = {
								importEnforceGranularity = true,
								importPrefix = "create",
							},
							cargo = { allFeatures = true },
							checkOnSave = {
								command = "clippy",
								allFeatures = true,
							},
							inlayHints = {
								lifetimeElisionHints = {
									enable = true,
									useParameterNames = true,
								},
							},
						},
					},
				},
			}
		end,
	},

	{
		"LunarVim/bigfile.nvim",
		opts = {
			filesize = 2,
			pattern = { "*" },
			features = {
				"indent_blankline",
				"illuminate",
				"lsp",
				"treesitter",
				"syntax",
				"vimopts",
				"filetype",
			},
		},
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup()
			require("dap").adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					--TODO: not absolute path
					args = { "/Users/mahulst/.config/js-debug/src/dapDebugServer.js", "${port}" },
				},
			}
			require("dap").configurations.typescriptreact = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
			}
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug [T]oggle breakpoint" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
			vim.keymap.set("n", "<leader>dt", function()
				require("neotest").run.run_last({ strategy = "dap" })
			end, { desc = "[D]ebug [T]est" })

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}, {})
-- Saving with control s
vim.keymap.set({ "n", "v" }, "<leader>w", ":wa!<CR>", { desc = "[W]rite open files" })
-- Redo last action

vim.keymap.set({ "n", "v" }, "<leader>r", ":@:<CR>", { desc = "[R]edo last action" })

-- quit with control q
vim.keymap.set({ "n", "v" }, "<C-q>", ":quit!<CR>", {})
vim.keymap.set({ "i" }, "<C-q>", "<C-o>:quit!<CR>", {})
-- undo highlight when pressing esc
vim.keymap.set({ "n" }, "<esc>", ":noh<CR>", {})
-- appending line to previous
vim.keymap.set("n", "J", "mzJ`z")
-- Keep cursor in middle while jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keep cursor in middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- Project commands
vim.keymap.set({ "n", "v" }, "<leader>pcc", ":terminal cargo check<CR>", { desc = "[C]argo [C]heck " })
vim.keymap.set({ "n", "v" }, "<leader>pcb", ":terminal cargo build<CR>", { desc = "[C]argo [B]uild " })
vim.keymap.set({ "n", "v" }, "<leader>pcr", ":terminal cargo run<CR>", { desc = "[C]argo [R]un " })
vim.keymap.set(
	{ "n", "v" },
	"<leader>pce",
	":terminal cargo run --example <C-r>=expand('%:t:r')<CR>",
	{ desc = "[C]argo run [E]xample" }
)

vim.keymap.set({ "n", "v" }, "<leader>pnc", ":terminal npm run lint<CR>", { desc = "[N]pm [C]heck " })
vim.keymap.set({ "n", "v" }, "<leader>pnb", ":terminal npm run build<CR>", { desc = "[N]pm [B]uild " })
vim.keymap.set({ "n", "v" }, "<leader>pnr", ":terminal npm run start<CR>", { desc = "[N]pm [R]un " })

-- Paste over while keeping your copied value
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "which_key_ignore" })
-- net rw
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "which_key_ignore" })

-- Make line numbers default
vim.wo.number = true

-- Disable mouse mode
vim.o.mouse = ""

vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
	-- Use the current buffer's path as the starting point for the git search
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	-- If the buffer is not associated with a file, return nil
	if current_file == "" then
		current_dir = cwd
	else
		-- Extract the directory from the current file's path
		current_dir = vim.fn.fnamemodify(current_file, ":h")
	end

	-- Find the Git root directory from the current file's path
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", function()
	require("telescope.builtin").oldfiles({ only_cwd = true })
end, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

local function telescope_live_grep_open_files()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end
vim.keymap.set("n", "<leader>s/", telescope_live_grep_open_files, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>ss", require("telescope.builtin").builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set({ "n" }, "<leader>sn>", function()
	require("telescope.builtin").git_files()
end, { desc = "[S]earch file[N]ame" })

vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })
vim.filetype.add({ extension = { wgsl = "wgsl" } })

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.wgsl = {
	install_info = {
		url = "https://github.com/szebniok/tree-sitter-wgsl",
		files = { "src/parser.c" },
	},
}
vim.defer_fn(function()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"lua",
			"rust",
			"wgsl",
			"tsx",
			"javascript",
			"typescript",
			"vimdoc",
			"vim",
			"bash",
		},

		auto_install = false,

		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<M-k>",
				node_incremental = "<M-k>",
				node_decremental = "<M-j>",
			},
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>A"] = "@parameter.inner",
				},
			},
		},
	})
end, 0)

-- document existing key chains
require("which-key").register({
	["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
	["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
	["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
	["<leader>t"] = { name = "[T]est", _ = "which_key_ignore" },
	["<leader>p"] = { name = "[P]roject", _ = "which_key_ignore" },
	["<leader>pc"] = { name = "[P]roject [Cargo]", _ = "which_key_ignore" },
	["<leader>pn"] = { name = "[P]roject [N]pm", _ = "which_key_ignore" },
})
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require("which-key").register({
	["<leader>"] = { name = "VISUAL <leader>" },
}, { mode = "v" })

require("mason").setup()
require("mason-lspconfig").setup()

local servers = {
	rust_analyzer = {},
	tsserver = {},
	html = {},

	lua_ls = {},
}

require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	completion = { completeopt = "noselect" },
	preselect = cmp.PreselectMode.None,
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<C-n>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-p>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})
require("telescope").load_extension("ui-select")
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
