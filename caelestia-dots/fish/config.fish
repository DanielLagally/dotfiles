if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # fish computes its completion search path once at startup and never
    # rereads XDG_DATA_DIRS afterwards, so a Nix devShell entered via direnv
    # (which only updates XDG_DATA_DIRS, not fish's own state) never gets
    # its completions loaded in an already-running shell without this: on
    # every XDG_DATA_DIRS change, directly source any new
    # fish/vendor_completions.d/*.fish files it points at.
    function __direnv_load_vendor_completions --on-variable XDG_DATA_DIRS
        set -q __direnv_completions_seen; or set -g __direnv_completions_seen
        for dir in (string split : -- $XDG_DATA_DIRS)
            set -l c $dir/fish/vendor_completions.d
            if test -d $c; and not contains $c $__direnv_completions_seen
                set -a __direnv_completions_seen $c
                for f in $c/*.fish
                    source $f
                end
            end
        end
    end

    # rumination (~/Dev/rumination): reload completions from the local dev
    # build whenever that project's direnv session is entered/left. This is
    # personal/project-specific (unlike the generic hook above), since the
    # dev alias runs straight off a debug binary, not a Nix-packaged one.
    function __rumination_reload_completions --on-variable DIRENV_DIR
        if test "$DIRENV_DIR" = "-$HOME/Dev/rumination"; and test -x ~/Dev/rumination/target/debug/rumination
            ~/Dev/rumination/target/debug/rumination completions fish | source
        end
    end

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # lensy: screenshot tool dev build (result symlink repointed by each nix build)
    alias lensy '~/Dev/lensy/result/bin/lensy'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Custom fish config
    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
    source $cConf/user-config.fish 2> /dev/null
end
