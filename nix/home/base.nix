{
  config,
  lib,
  pkgs,
  sources,
  ...
}:
let
  username = "fuwa";
  mypkgs = pkgs.callPackage ../packages { inherit sources; };

  # nixpkgs' rustup patches installed toolchains to reference /nix/store paths
  # (ELF interpreter, rpath, ld.lld wrapper) without registering GC roots.
  # Root everything they reference so `nix-collect-garbage` cannot break them.
  rustupGcroots = pkgs.writeShellApplication {
    name = "rustup-gcroots";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gnugrep
      nix
    ];
    text = ''
      shopt -s nullglob
      toolchains=("$HOME"/.rustup/toolchains/*/)
      roots="$HOME/.rustup/gcroots"
      rm -rf "$roots"
      mkdir -p "$roots"

      targets=()
      for tc in "''${toolchains[@]}"; do
        targets+=("$tc"bin "$tc"lib "$tc"lib/rustlib/*/bin)
      done
      [ ''${#targets[@]} -gt 0 ] || exit 0

      find -L "''${targets[@]}" -maxdepth 2 -type f -print0 \
        | xargs -0 grep -aohE '/nix/store/[a-z0-9]{32}-[^/:"[:space:]]+' \
        | sort -u \
        | while read -r path; do
            nix-store --add-root "$roots/''${path#/nix/store/}" --realise "$path" >/dev/null \
              || echo "rustup-gcroots: cannot keep $path" >&2
          done
    '';
  };
in
{
  imports = [
    ./modules
  ];

  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    max-jobs = "auto";
  };

  xdg.enable = true;
  xdg.stateFile."nvim/lsp.log".source = config.lib.file.mkOutOfStoreSymlink "/tmp/nvim-lsp.log";

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "26.05";

    # avoid warning
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [
      # same as nixos; install them even in non-nixos system
      vim
      wget
      gcc
      cachix

      # nix tools
      nixfmt

      # man pages
      man-pages
      man-pages-posix

      # libs
      (lib.getLib sqlite)
      pkg-config

      # tools
      android-tools
      atop
      bottom
      bubblewrap
      clang-tools
      cmake
      delta
      deno
      dex
      dig
      doggo
      dotslash
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
      git
      git-lfs
      gnumake
      gnupg
      gnuplot_qt
      go
      htop
      httpie
      hyperfine
      imagemagick
      jless
      jq
      libqalculate
      linuxPackages.cpupower
      lm_sensors
      lsof
      mbuffer
      lua
      luarocks
      minicom
      mold
      moreutils
      ncdu
      nkf
      nodejs
      openssl
      p7zip
      parallel # GNU parallel. moreutils also has `parallel`, but has lower priority :)
      patchelf
      pciutils
      pdftk
      picotool
      pnpm
      poppler-utils
      procs
      pv
      ripgrep
      rtk
      rustowl
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

      mypkgs.cargo_pkgs.memvis
      mypkgs.cargo_pkgs.slice
      mypkgs.cargo_pkgs.cargo-asm
      mypkgs.cargo_pkgs.cargo-call-stack
      mypkgs.cargo_pkgs.cargo-disasm
      # mypkgs.cargo_pkgs.defmt-print  # disabled: upstream repo lacks top-level Cargo.lock
      mypkgs.cargo_pkgs.ccsum

      # lsp servers
      nixd
      pyright
      tinymist
      typescript-language-server
      ty
      verible
      vscode-langservers-extracted

      tree-sitter # for neovim-treesitter

      # python
      (python3.withPackages (
        ps: with ps; [
          pip
          # pipx
          numpy
          (matplotlib.override { enableQt = true; })
          scipy
          python-lsp-server
          pillow
        ]
      ))
      uv

    ];
  };

  # defer instantiation rarely used apps
  programs.deferredApps = {
    enable = true;
    gcRoot = true;
    packages = [ ];
    cliPackages = with pkgs; [

      ocaml
      ocamlPackages.ocamlformat
      ocamlPackages.utop
      opam

      # cargo tools
      cargo-binutils
      cargo-bloat
      cargo-edit
      cargo-expand
      cargo-generate
      probe-rs-tools

      # lsp servers
      astro-language-server
      efm-langserver
      emmet-ls
      gopls
      intelephense
      kdePackages.qtdeclarative
      lua-language-server
      ocamlPackages.ocaml-lsp
      openscad-lsp
      tombi
    ];
  };

  programs = {
    neovim = {
      package = pkgs.neovim;
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nushell = {
      enable = false;
      loadSessionVariables = true;
      configFile.text = "source ~/.config/nushell/conf.d/init.nu";
      plugins = [
        pkgs.nushellPlugins.gstat
        # mypkgs.cargo_pkgs.nu-plugin-bexpand
      ];
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    bat = {
      enable = true;
      syntaxes = {
        # nushell = {
        #   src = sources.sublime-text-nushell.src;
        #   file = "nushell.sublime-syntax";
        # };
      };
    };

    nh = {
      enable = true;
      flake = "/home/fuwa/dotfiles";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 3 --no-gcroots"; # keep 3 generations and ignore gcroots (to keep direnv caches)
      };
    };

    nix-index-database.comma.enable = true;
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

  home.activation.rustupGcroots = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${rustupGcroots}/bin/rustup-gcroots
  '';
  # rustup rewrites update-hashes/<toolchain> on every install/update/uninstall
  systemd.user.paths.rustup-gcroots = {
    Unit.Description = "Watch rustup toolchain changes";
    Path.PathChanged = "%h/.rustup/update-hashes";
    Install.WantedBy = [ "paths.target" ];
  };
  systemd.user.services.rustup-gcroots = {
    Unit.Description = "Register GC roots for rustup toolchains";
    Service = {
      Type = "oneshot";
      ExecStart = "${rustupGcroots}/bin/rustup-gcroots";
    };
  };

  home.sessionVariables = {
    # nix-ld libraries, mainly for python gui.
    # Keep the inherited value (NixOS' programs.nix-ld.libraries) after these.
    NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
      dbus
      fontconfig
      freetype
      glib
      libGL
      libx11
      libxcb
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libxcomposite
      libxext
      libxkbcommon
      wayland
      zlib
    ]
    + "\${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}";
  };
}
