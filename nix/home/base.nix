{
  pkgs,
  ...
}: let
  username = "fuwa";
in {
  imports = [
    ./modules
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  nix.package = pkgs.nix;

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    # avoid warning
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [

      # nix tools
      nixfmt-rfc-style

      # man pages
      man-pages
      man-pages-posix

      # libraries
      qt5.qtbase
      qt6.qtbase

      # tools
      android-tools
      atop
      bat
      bottom
      clang-tools
      cmake
      deno
      dex
      delta
      dig
      dogdns
      edir
      exiftool
      eza
      fd
      ffmpeg
      file
      fzf
      gh
      ghq
      gnumake
      gnupg
      gnuplot_qt
      googleearth-pro
      httpie
      htop
      imagemagick
      jq
      libqalculate
      minicom
      mold
      moreutils
      ncdu
      nodejs
      ocaml
      ocamlPackages.utop
      ocamlPackages.ocamlformat
      opam
      openssl
      p7zip
      pciutils
      picotool
      pnpm
      poppler_utils
      procs
      ranger
      ripgrep
      rustup
      sheldon
      skktools
      socat
      pdftk
      tig
      tmux
      typst
      unzipNLS
      usbutils
      vim
      xxd
      zathura

      # cargo tools
      cargo-binutils
      cargo-bloat
      cargo-edit
      cargo-expand
      probe-rs-tools

      # lsp servers
      efm-langserver
      emmet-ls
      lua-language-server
      nil # nix lsp
      tinymist
      typescript-language-server
      vscode-langservers-extracted
      pyright
      verible
      intelephense
      ocamlPackages.ocaml-lsp

      # python
      (python312.withPackages (ps: with ps; [
        pip
        numpy
        (matplotlib.override { enableQt = true; })
        scipy
        python-lsp-server
      ]))

    ];
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
    };
    neovim = {
      package = pkgs.neovim;
      enable = true;
      defaultEditor = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };


  };

  services = {
    syncthing = {
      enable = true;
    };
    gpg-agent = {
      enable = true;
      enableSshSupport = false;
      pinentryPackage = pkgs.pinentry-all;
      maxCacheTtl = 8640000; # 100 days
      defaultCacheTtl = 8640000; # 100 days
    };
    ssh-agent.enable = true;
  };

  home.file.".profile".text = ''
    . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
  home.file.".xprofile".text = ". ~/.profile";


  systemd.user.services.tmptmp = {
    Unit.Description = "mkdir /tmp/tmp/";
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/mkdir -p /tmp/tmp/";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.home-manager.enable = true;
}
