if type sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
else
    echo "sheldon not found" >&2
fi
