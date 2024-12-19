use std::io::{stdin, BufRead, BufReader};

fn main() {
    let mut lines = BufReader::new(stdin()).lines();
    let patterns = lines
        .next()
        .unwrap()
        .unwrap()
        .split(", ")
        .map(|s| s.chars().collect())
        .collect::<Vec<Vec<char>>>();
    let mut possible = 0;
    let mut total = 0;
    for line in lines {
        let design = line.unwrap().chars().collect::<Vec<char>>();
        if design.len() == 0 {
            continue;
        }
        let mut dp = vec![0u64; design.len() + 1]; // contains ways of creating each sub-pattern
        for pattern in &patterns {
            if pattern.len() <= design.len() && *pattern == design[0..pattern.len()] {
                dp[pattern.len()] += 1; // initialize with starting pattern
            }
        }
        for i in 1..=design.len() {
            for pattern in &patterns {
                if i < pattern.len() {
                    continue;
                }
                let prev = i - pattern.len();
                if *pattern == design[prev..i] {
                    dp[i] += dp[prev]; // construct dp array from bottom-up
                }
            }
        }
        let ways = dp[design.len()];
        possible += if ways > 0 { 1 } else { 0 };
        total += ways;
    }
    println!("{possible}");
    println!("{total}");
}
