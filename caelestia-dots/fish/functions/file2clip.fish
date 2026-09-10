function file2clip --description 'Copy files to the Wayland clipboard as file URIs (paste them as files)'
    if test (count $argv) -eq 0
        echo 'usage: file2clip FILE...' >&2
        return 2
    end
    for f in $argv
        test -e $f; or begin
            echo "file2clip: no such file: $f" >&2
            return 1
        end
    end
    printf 'file://%s\n' (string escape --style=url -- (path resolve -- $argv)) | wl-copy -t text/uri-list
end
