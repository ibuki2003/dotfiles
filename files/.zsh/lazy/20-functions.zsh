for file in ~/.zsh/functions/**/*(.); do
    autoload -Uz +X ${file:t}
done
