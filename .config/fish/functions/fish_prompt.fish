function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings insert
    bind \cr 'peco_select_history (commandline -b)'
end

function fish_mode_prompt
end

function fish_prompt
    set -l last_status $status
    if test $last_status -eq 0
        set laststatus ''
    else
        set laststatus (echo -n (set_color brred)'err'$status':')
    end

    function _git_branch_name
        echo (git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
    end
    function _is_git_dirty
        echo (git status -s --ignore-submodules=dirty ^/dev/null)
    end
    function _git_info
        if [ (_git_branch_name) ]
            set -l git_branch (set_color -o blue)(_git_branch_name)
            if [ (_is_git_dirty) ]
                for i in (git branch -qv --no-color | string match -r '\*' | cut -d' ' -f4- | cut -d] -f1 | tr , \n)\
                (git status --porcelain | cut -c 1-2 | uniq)
                    switch $i
                        case "*[ahead *"
                            set git_status "$git_status"(set_color red)↑
                        case "*behind *"
                            set git_status "$git_status"(set_color red)↓
                        case "."
                            set git_status "$git_status"(set_color green)＋
                        case " D"
                            set git_status "$git_status"(set_color red)×
                        case "*M*"
                            set git_status "$git_status"(set_color green)＊
                        case "*R*"
                            set git_status "$git_status"(set_color purple)→
                        case "*U*"
                            set git_status "$git_status"(set_color brown)＝
                        case "??"
                            set git_status "$git_status"(set_color red)≠
                    end
                end
            else
                set git_status (set_color green):
            end
            echo "(git$git_status$git_branch"(set_color white)")"
        end
    end

    function _kubectx
        if type kubectl > /dev/null 2>&1
            echo (kubectl config current-context)
        else
            echo '-'
        end
    end

    # Main
    echo -n $laststatus(set_color brpurple)'['(date "+%H:%M:%S")']' (set_color brcyan)(prompt_pwd)(set_color brwhite) (_git_info)(set_color brcyan) '[kubectx:'(_kubectx)']' \n(set_color brred)'>'(set_color bryellow)'>'(set_color brgreen)'> '
end

