function clip2file --description 'Save clipboard contents to a temp file and copy that file to the clipboard'
    set -l ext txt
    if set -q argv[1]
        set ext (string replace -r '^\.' '' -- $argv[1])
    end
    set -l tmp (mktemp --suffix=.$ext)
    wl-paste --no-newline > $tmp
    or begin
        rm -f $tmp
        echo 'clip2file: no text on the clipboard' >&2
        return 1
    end
    printf 'file://%s\n' (string escape --style=url -- $tmp) | wl-copy -t text/uri-list
    and echo $tmp
end
