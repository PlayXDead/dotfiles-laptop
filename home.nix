{ pkgs, ... }:

{
  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "25.05";

  programs.nix-search-tv.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      lualine-nvim
      nvim-web-devicons
      toggleterm-nvim
      telescope-nvim
      plenary-nvim
      (nvim-treesitter.withPlugins (plugins: [
        plugins.nix
        plugins.lua
        plugins.python
        plugins.bash
        plugins.json
        plugins.markdown
        plugins.javascript
        plugins.typescript
        plugins.dart
      ]))
      nvim-treesitter-textobjects
      which-key-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      lspkind-nvim
      onedark-nvim
      nvim-tree-lua
    ];

    extraConfig = ''
      " General Vim settings
      set number
      set cursorline
      set list
      set termguicolors
      syntax on
      colorscheme onedark

      lua << EOF
        -- =================================================================
        -- CORE SETUP
        -- =================================================================
        vim.g.mapleader = " "
        local map = vim.keymap.set
        local opts = { silent = true, noremap = true }

        -- =================================================================
        -- PLUGIN CONFIGURATIONS
        -- =================================================================
        require("nvim-web-devicons").setup { default = true }
        require("nvim-tree").setup({
          sort_by = "name",
          view = { width = 30, side = "left" },
          renderer = { icons = { show = { git = true, folder = true, file = true, folder_arrow = true } } },
          hijack_netrw = true,
          update_focused_file = { enable = true, update_cwd = true },
        })
        require('lualine').setup {
          options = { theme = 'onedark' }
        }
        require'nvim-treesitter.configs'.setup {
          highlight = { enable = true },
          incremental_selection = { enable = true },
          indent = { enable = true },
        }

        -- =================================================================
        -- LAZY-LOADED LSP CONFIGURATION
        -- =================================================================
        vim.api.nvim_create_autocmd("FileType", {
          -- ADDED: All your languages are now in the pattern
          pattern = {
            "nix", "lua", "python", "bash", "json",
            "markdown", "javascript", "typescript", "dart"
          },
          callback = function(event)
            local buf = event.buf
            local filetype = vim.bo[buf].filetype
            local lspconfig = require('lspconfig')
            local map_buf = function(key, func)
              vim.keymap.set('n', key, func, { silent = true, noremap = true, buffer = buf })
            map_buf('K', vim.lsp.buf.hover)
            map_buf('gd', vim.lsp.buf.definition)
            map_buf('<leader>ca', vim.lsp.buf.code_action)
            end

            -- ADDED: Logic to set up the correct server for each filetype
            if filetype == "nix" then
              lspconfig.nil_ls.setup({})
            elseif filetype == "lua" then
              lspconfig.lua_ls.setup({})
            elseif filetype == "python" then
              lspconfig.pyright.setup({})
            elseif filetype == "bash" then
              lspconfig.bashls.setup({})
            elseif filetype == "json" then
              lspconfig.jsonls.setup({})
            elseif filetype == "markdown" then
              lspconfig.marksman.setup({})
            elseif filetype == "javascript" or filetype == "typescript" then
              lspconfig.tsserver.setup({})
            elseif filetype == "dart" then
              lspconfig.dartls.setup({})
            end
          end,
        })

        -- =================================================================
        -- KEYMAPS
        -- =================================================================
        map("n", "<leader>e", require("nvim-tree.api").tree.toggle, opts)
        map("n", "<leader>h", function() require("toggleterm").toggle() end, opts)
        map("t", "<Esc>", "<C-\\><C-n>", opts)
        map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, opts)
        map("n", "<leader>fw", function() require("telescope.builtin").live_grep() end, opts)
        map("n", "<leader>w", ":w<CR>", opts)
        map("n", "<leader>q", ":q<CR>", opts)
        map("n", "<leader>Q", ":qa!<CR>", opts)
      EOF
    '';
  };

  # ADDED: New language servers to support the languages from Treesitter
  home.packages = with pkgs; [
    # Core dependencies
    ripgrep
    fd
    fzf
    tree-sitter

    # Language Runtimes
    nodejs
    dart

    # Language Servers
    lua-language-server
    typescript-language-server # for tsserver
    bash-language-server
    pyright
    nil
    marksman                  # For Markdown
    vscode-langservers-extracted # For jsonls and others

    # Other tools
    vscode
    aider-chat
  ];
  
  nixpkgs.config.allowUnfree = true;
}
