{
  pkgs,
  config,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.stateVersion = "25.11";

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  fonts.fontconfig.enable = true;

  home.packages =
    with pkgs;
    [
      awscli2
      eza
      fd
      gh
      jetbrains-mono
      jq
      lazygit
      neovim
      nerd-fonts.jetbrains-mono
      nil
      nixd
      ripgrep
      tree
      tree-sitter
    ]
    ++ (lib.optionals isDarwin [
      pinentry_mac
    ])
    ++ (lib.optionals isLinux [
      gcc
      pinentry-curses
      zsh
    ]);

  #---------------------------------------------------------------------
  # Environment variables & dotfiles
  #---------------------------------------------------------------------

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    GOPATH = "${config.xdg.dataHome}/go";
    PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    INPUTRC = "${config.xdg.configHome}/readline/inputrc";
  };

  #---------------------------------------------------------------------
  # Programs & services
  #---------------------------------------------------------------------

  programs.mise = {
    enable = true;

    globalConfig = {
      tools = {
        bun = "latest";
        deno = "latest";
        go = "latest";
        node = "24";
        python = "latest";
      };
    };
  };

  programs.oh-my-posh = {
    enable = true;
    useTheme = "gruvbox";
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --grid --icons --sort=type";
      rebuild =
        if isDarwin then
          "sudo darwin-rebuild switch --flake ~/.config/nix/#mac"
        else
          "home-manager switch --flake ~/.config/nix/#wsl";
    };
    initContent = builtins.readFile ./config.zsh;
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
    defaultKeymap = "emacs";
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "225949B2D581DEA5";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Faizan Abbas";
        email = "faizan@faizanabbas.com";
        useConfigOnly = true;
      };
      init.defaultBranch = "main";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };

    includes = [
      {
        condition =
          if isDarwin then
            "gitdir:~/Developer/Repositories/github.com/harkerapp/"
          else
            "gitdir:~/Repositories/github.com/harkerapp/";
        contents = {
          user = {
            email = "faizan@harkerapp.com";
          };
          signing = {
            key = "CE58DE2247AADB29";
            signByDefault = true;
          };
        };
      }
    ];
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentry.package = if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
  };

  programs.home-manager.enable = true;
}
