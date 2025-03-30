{ pkgs, ... }: {

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      # language servers, etc.
      ripgrep
      fd
      nixd
      gopls
      vscode-langservers-extracted
      nil # nix LSP
      nixfmt-classic
      lua-language-server
      yaml-language-server
      helm-ls
      terraform-ls
      tflint
      rust-analyzer
    ];

    plugins = with pkgs.vimPlugins; [

      telescope-nvim
      monokai-pro-nvim
      mini-ai
      mini-surround
      mini-statusline

      neo-tree-nvim
      bufferline-nvim
      vim-tmux-navigator
      gitsigns-nvim
      nvim-lspconfig
      alpha-nvim
      leap-nvim
      vim-helm

      vim-terraform
      render-markdown-nvim
      markdown-preview-nvim
      neoscroll-nvim
      # codecompanion-nvim
      copilot-vim

      blink-cmp
      blink-compat
      nvim-cmp # https://github.com/hrsh7th/nvim-cmp
      luasnip
      cmp_luasnip # snippets autocompletion extension for nvim-cmp | https://github.com/saadparwaiz1/cmp_luasnip/
      cmp-buffer # current buffer as completion source | https://github.com/hrsh7th/cmp-buffer/
      cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
      cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/
      cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
      cmp-cmdline # cmp command line suggestions
      cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
      cmp-cmdline-history # cmp command line history suggestions
      lspkind-nvim
      # ^ nvim-cmp extensions
      # git integration plugins
      diffview-nvim # https://github.com/sindrets/diffview.nvim/
      # neogit # https://github.com/TimUntersberger/neogit/
      vim-fugitive # https://github.com/tpope/vim-fugitive/
      # ^ git integration plugins
      # telescope and extensions
      telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
      # telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
      # UI
      lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/

      # libraries that other plugins depend on
      plenary-nvim
      nvim-web-devicons

      nvim-treesitter-textobjects # https://github.com/nvim-treesitter/nvim-treesitter-textobjects/
      nvim-treesitter.withAllGrammars

    ];

    extraLuaConfig = ''
      			-- Core
            ${builtins.readFile ./lua/core/options.lua}
            ${builtins.readFile ./lua/core/remap.lua}

            -- Plugins
            ${builtins.readFile ./lua/plugins/bufferline.lua}
            ${builtins.readFile ./lua/plugins/blink-cmp.lua}
            ${builtins.readFile ./lua/plugins/colorscheme.lua}

            ${builtins.readFile ./lua/plugins/lsp.lua}
            ${builtins.readFile ./lua/plugins/gitsigns.lua}
            ${builtins.readFile ./lua/plugins/neoscroll.lua}
            ${builtins.readFile ./lua/plugins/leap.lua}
            ${builtins.readFile ./lua/plugins/lualine.lua}
            ${builtins.readFile ./lua/plugins/neotree.lua}


            ${builtins.readFile ./lua/plugins/telescope.lua}
            ${builtins.readFile ./lua/plugins/treesitter.lua}
            ${builtins.readFile ./lua/plugins/mini.lua}
    '';
    # ${builtins.readFile ./lua/plugins/lsp-on_attach.lua}
  };
  # xdg.configFile = {
  #   "nvim".source = ./lua;
  # };
}
