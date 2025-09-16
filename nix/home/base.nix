{
  pkgs,
  sources,
  ...
}: let
  username = "fuwa";
  mypkgs = pkgs.callPackage ../packages { inherit sources; };
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

      # libs
      (lib.getLib sqlite)

      # tools
      android-tools
      atop
      bat
      bottom
      clang-tools
      cmake
      delta
      deno
      dex
      dig
      dogdns
      edir
      exiftool
      eza
      fd
      ffmpeg
      file
      fq
      fzf
      gdb
      gh
      ghq
      git git-lfs
      gnumake
      gnupg
      gnuplot_qt
      go
      htop
      httpie
      hyperfine
      imagemagick
      jq
      libqalculate
      linuxPackages.cpupower
      lm_sensors
      lsof
      mbuffer
      minicom
      mold
      moreutils
      ncdu
      nkf
      nodejs
      ocaml
      ocamlPackages.ocamlformat
      ocamlPackages.utop
      opam
      openssl
      p7zip
      patchelf
      pciutils
      pdftk
      picotool
      pnpm
      poppler_utils
      procs
      pv
      ripgrep
      rustup
      sheldon
      socat
      tig
      tmux
      typst
      unzipNLS
      usbutils
      verilator
      vim
      xxd
      zip

      # cargo tools
      cargo-binutils
      cargo-bloat
      cargo-edit
      cargo-expand
      cargo-generate
      probe-rs-tools

      mypkgs.cargo_pkgs.memvis
      mypkgs.cargo_pkgs.slice
      mypkgs.cargo_pkgs.cargo-asm
      mypkgs.cargo_pkgs.cargo-call-stack
      mypkgs.cargo_pkgs.cargo-disasm
      # mypkgs.cargo_pkgs.defmt-print  # disabled: upstream repo lacks top-level Cargo.lock
      mypkgs.cargo_pkgs.ccsum

      # lsp servers
      astro-language-server
      efm-langserver
      emmet-ls
      intelephense
      lua-language-server
      nil # nix lsp
      nixd
      pyright
      tinymist
      typescript-language-server
      verible
      intelephense
      ocamlPackages.ocaml-lsp
      intelephense
      vscode-langservers-extracted

      # python
      (python3.withPackages (ps: with ps; [
        pip
        numpy
        (matplotlib.override { enableQt = true; })
        scipy
        python-lsp-server
        pillow
      ]))
      uv

    ];
  };

  programs = {
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
      pinentry.package = pkgs.pinentry-all;
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
