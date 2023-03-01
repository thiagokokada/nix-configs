#!/usr/bin/env bash
# Based on https://github.com/zimfw/archive

readonly name="$(basename "$0")"

echoerr() { echo "$@" 1>&2; }

if [[ "$#" -lt 1 ]]; then
    echoerr "usage: $name <archive_name.ext>..."
    exit 2
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        (*.7z|*.001) 7zz l "$1" ;;
        (*.rar) unrar l "$1" ;;
        (*.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar -tvjf "$1" ;;
        (*.tar.gz|*.tgz) tar -tvzf "$1" ;;
        (*.tar.lzma|*.tlz) env XZ_OPT=-T0 tar --lzma -tvf "$1" ;;
        (*.tar.xz|*.txz) env XZ_OPT=-T0 tar -tvJf "$1" ;;
        (*.tar) tar tvf "$1" ;;
        (*.zip) unzip -l "$1" ;;
        (*.gz) unpigz -l "$1" ;;
        (*.xz) unxz -T0 -l "$1" ;;
        (*.zst) zstd -T0 -l "$1" ;;
        (*) echoerr "$name: unknown archive type: $1" ;;
    esac
    shift
done
