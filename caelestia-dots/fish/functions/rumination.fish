function rumination --description 'Inside ~/Dev/rumination'"'"'s direnv session, run the dev build via `cargo run` (always latest code); elsewhere, run the real installed command if any.'
    if test "$DIRENV_DIR" = "-$HOME/Dev/rumination"
        cargo run --quiet -- $argv
    else
        command rumination $argv
    end
end
