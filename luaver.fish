function luaver
    set -l luaver_dir "$HOME/.luaver"
    set -l luaver_script "$luaver_dir/luaver"

    # If luaver script exists, use it
    if test -f "$luaver_script"
        bash -c "source '$luaver_script' && luaver $argv"
    else
        echo "luaver not found at $luaver_script"
        return 1
    end

    # Handle PATH updates for specific commands
    switch "$argv[1]"
        case 'use' 'use-luajit' 'use-luarocks' 'load'
            # Update PATH from the bash environment
            set -l new_path (bash -c "source '$luaver_script' && luaver $argv[1] $argv[2..] 1>&2 && printf '%s' \"\$PATH\"")
            set -gx PATH (string split ':' "$new_path")
            
            # For luarocks, also set LUA_PATH and LUA_CPATH
            if string match -qr '^use-luarocks|use$' -- "$argv[1]"
                if command -v luarocks >/dev/null
                    eval (luarocks path --fish)
                end
            end
    end
end