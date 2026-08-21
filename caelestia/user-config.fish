# Personal fish customizations, kept outside caelestia-dots so subtree
# re-imports can't wipe them. Autoloads functions/ and sources any other
# .fish file dropped in caelestia/fish/ (e.g. secrets.fish).
set -l cFishDir (dirname (status --current-filename))/fish

if test -d $cFishDir/functions
    if not contains $cFishDir/functions $fish_function_path
        set -p fish_function_path $cFishDir/functions
    end
end

for f in $cFishDir/*.fish
    source $f
end
