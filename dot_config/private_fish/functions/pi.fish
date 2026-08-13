function pi --wraps=pi
    if contains -- -p $argv; or contains -- --print $argv
        command pi --model gpt-5.6-luna $argv
    else
        command pi $argv
    end
end
