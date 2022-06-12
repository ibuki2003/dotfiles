ZSHHOME="${ZDOTDIR}/.zsh"

if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then
    for i in $ZSHHOME/*; do
        if
            [[ ${i##*/} = *.zsh ]] &&
            [ \( -f "$i" -o -L "$i" \) -a -r "$i" ]; then
                . $i
        fi
    done
fi
