ZSHHOME="${ZDOTDIR}/.zsh"

for i in $ZSHHOME/*.zsh(.); do
    if [ \( -f "$i" -o -L "$i" \) -a -r "$i" ]; then
        . $i
    fi
done
