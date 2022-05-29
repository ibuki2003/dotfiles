append_path () {
  for p in "$@"; do
    case ":$PATH:" in
      *:"$p":*)
        ;;
      *)
        export PATH="${PATH:+$PATH:}$p"
    esac
  done
}

append_path ~/.local/bin
