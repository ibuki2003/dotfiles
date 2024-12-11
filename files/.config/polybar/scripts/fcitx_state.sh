#!/usr/bin/env bash

case `fcitx-remote` in
  0 ) echo "-";;
  1 ) echo "Aa";;
  2 ) echo "あ";;
esac

