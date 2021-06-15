function fish_title
  if test -z $argv[1]
    echo "fish"
  else
    echo $argv[1]
  end
end
