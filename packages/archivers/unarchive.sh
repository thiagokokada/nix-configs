#!/usr/bin/env bash
# Based on https://github.com/zimfw/archive

name="$(basename "$0")"

echoerr() { echo "$@" 1>&2; }

if [[ "$#" -lt 1 ]]; then
    echoerr "usage: $name <archive_name.ext>..."
    exit 2
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        (*.7z|*.001) 7zz x "$1" ;;
        (*.rar) unrar "$1" ;;
        (*.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar -xvjf "$1" ;;
        (*.tar.gz|*.tgz) tar -xvzf "$1" ;;
        (*.tar.lzma|*.tlz) env XZ_OPT=-T0 tar --lzma -xvf "$1" ;;
        (*.tar.xz|*.txz) env XZ_OPT=-T0 tar -xvJf "$1" ;;
        (*.tar) tar -xvf "$1" ;;
        (*.zip) unzip "$1";;
        (*.bz|*.bz2) pbunzip2 "$1" ;;
        (*.gz) unpigz "$1" ;;
        (*.lzma) unlzma -T0 "$1" ;;
        (*.xz) unxz -T0 "$1" ;;
        (*.zst) zstd -T0 -d "$1" ;;
        (*.Z) uncompress "$1" ;;
        (*) echoerr "$name: unknown archive type: $1" ;;
    esac
    shift
done
