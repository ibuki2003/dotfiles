fpath=(~/.zsh/functions ~/.zsh/functions/*(N-/) $fpath)

for file in ~/.zsh/functions/**/*(.); do
    autoload -Uz ${file:t}
done
compinit
