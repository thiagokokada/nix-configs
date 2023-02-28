#!/usr/bin/env bash
# Based on https://github.com/zimfw/archive

readonly name="$(basename "$0")"

echoerr() { echo "$@" 1>&2; }

if [[ "$#" -lt 2 ]]; then
    echoerr "usage: $name <archive_name.ext> <file>..."
    exit 2
fi

case "$1" in
    (*.7z) 7zz a "$@" ;;
    (*.rar) rar a "$@" ;;
    (*.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar -cvjf "$@" ;;
    (*.tar.gz|*.tgz) tar -cvzf "$@" ;;
    (*.tar.lzma|*.tlz) env XZ_OPT=-T0 tar --lzma -cvf "$@" ;;
    (*.tar.xz|*.txz) env XZ_OPT=-T0 tar -cvJf "$@" ;;
    (*.tar) tar -cvf "$@" ;;
    (*.zip) zip -r "$@" ;;
    (*.zst) zstd -c -T0 "${@:2}" -o "$1" ;;
    (*.bz|*.bz2) echoerr "$0: .bzip2 is only useful for single files, and does not capture permissions. Use .tar.bz2" ;;
    (*.gz) echoerr "$0: .gz is only useful for single files, and does not capture permissions. Use .tar.gz" ;;
    (*.lzma) echoerr "$0: .lzma is only useful for single files, and does not capture permissions. Use .tar.lzma" ;;
    (*.xz) echoerr "$0: .xz is only useful for single files, and does not capture permissions. Use .tar.xz" ;;
    (*.Z) echoerr "$0: .Z is only useful for single files, and does not capture permissions." ;;
    (*) echoerr "$name: unknown archive type: $1" ;;
esac
