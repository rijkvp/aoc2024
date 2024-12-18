day := `date +%d`
day_fmt := shell('printf $@', '%02d\n', day)
year := '2024'
cargo_bin := "[[bin]]\nname = \"" + day_fmt + "\"\npath = \"" + day_fmt + ".rs\"\n"

[script]
downloadall:
    for i in $(seq 1 {{day}}); do
      day_fmt=$(printf "%02d\n" $i)
      aoc download -y {{year}} -d $day_fmt -I -i input/$day_fmt.txt -o
    done

start:
    cp -n template.rs {{day_fmt}}.rs
    echo '{{cargo_bin}}' >> Cargo.toml
    aoc download -y {{year}} -I -i "input/{{day_fmt}}.txt" -o

run:
    cargo run --bin {{day_fmt}} < input/{{day_fmt}}.txt

[script]
runday day:
    day_fmt=$(printf '%02d' {{day}})
    cat ./input/$day_fmt.txt | cargo run --bin "$day_fmt"
