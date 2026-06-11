# Discord client, not patched version
# NOTE: using hacky solution; requires nix-ld to work

{ lib, pkgs, ... }:
let
  anchor = ''discord-stage-modules $out/opt/Discord/modules"'';
in
assert lib.assertMsg (lib.strings.hasInfix anchor pkgs.discord.installPhase)
  "discord overlay: stageModules patch failed";
pkgs.discord.overrideAttrs (prev:
  let
    relinkScript = pkgs.writeShellScript "discord-relink-modules" ''
      # $1 = 今ビルドの store 側 modules ディレクトリ（wrapper から $out/opt/Discord/modules を渡す）。
      # krisp だけ実体ディレクトリ化、他は丸ごと symlink を現行 store へ貼り替え。毎起動で $out 変更/GC に追従。
      # installed.json は stageModules 任せ。
      store_modules="$1"
      modules_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/discord/${prev.version}/modules"
      [ -d "$store_modules" ] || exit 0
      mkdir -p "$modules_dir"

      for s in "$store_modules"/*; do
        name=$(basename "$s")
        dest="$modules_dir/$name"

        case "$name" in
          *)
            if [ ! -d "$s" ]; then
              # if not a directory, something is wrong; fallback
              echo "Warning: expected $s to be a directory, skipping relink" >&2
              ln -sfn "$s" "$dest"
              continue
            fi
            [ -L "$dest" ] && rm "$dest"
            # 実ファイルにしないと動かない
            ${pkgs.rsync}/bin/rsync -a "$s/" "$dest/"
            ;;
          # *)
          #   # 丸ごと symlink で十分
          #   ln -sfn "$s" "$dest"
          #   ;;
        esac
      done
    '';

    # stageModules の --run のすぐ後ろに relink の --run を足す。
    # wrapProgramShell の出力ではなく公開フラグ --run に介入するので lib 仕様変更に強い。
    patched =
      # skip patch if relinkScript is already inserted
      if lib.strings.hasInfix "discord-relink-modules" prev.installPhase then prev.installPhase else
        builtins.replaceStrings
        [ anchor ]
        [ (anchor + " --run \"${relinkScript} $out/opt/Discord/modules\"") ]
        prev.installPhase;
  in
  {
    nativeBuildInputs = [
      pkgs.makeShellWrapper
      pkgs.brotli  # needed at build time: installPhase runs `brotli -d` to extract distro tarball
    ];

    # ~~finalAttrs pattern means overriding libPath here automatically propagates to installPhase~~
    # ^ no longer true, but we can still override libPath here to avoid patching installPhase
    libPath = prev.libPath + ":" + lib.makeLibraryPath (with pkgs; [
      libxshmfence  # used by Chromium/X11, not in upstream libPath (was patched via autoPatchelfHook)
      mesa          # GPU driver libs (libGL etc.) for hardware acceleration
    ]);

    dontPatchELF = true;
    dontStrip = true;

    installPhase = patched;
  })
