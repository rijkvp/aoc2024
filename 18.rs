use std::cmp::Reverse;
use std::collections::BinaryHeap;
use std::io::{stdin, BufRead, BufReader};

const GRID_SIZE: usize = 71;
const FIRST_N: usize = 1024;

fn neighbours(r: usize, c: usize) -> impl Iterator<Item = (usize, usize)> {
    [(-1, 0), (1, 0), (0, -1), (0, 1)]
        .into_iter()
        .map(move |(r_offset, c_offset)| (r as i64 + r_offset, c as i64 + c_offset))
        .filter(|(r, c)| *r >= 0 && *r < GRID_SIZE as i64 && *c >= 0 && *c < GRID_SIZE as i64)
        .map(|(r, c)| (r as usize, c as usize))
}

fn find_path(
    start: (usize, usize),
    end: (usize, usize),
    grid: &[[bool; GRID_SIZE]; GRID_SIZE],
) -> Option<u64> {
    let mut distance = [[None; GRID_SIZE]; GRID_SIZE];
    let mut visited = [[false; GRID_SIZE]; GRID_SIZE];
    let mut to_visit = BinaryHeap::new();
    distance[start.0][start.1] = Some(0);
    to_visit.push(Reverse((0, start)));

    while let Some(Reverse((dist, (r, c)))) = to_visit.pop() {
        if visited[r][c] {
            continue;
        }
        visited[r][c] = true;
        for (nb_r, nb_c) in neighbours(r, c) {
            if grid[nb_r][nb_c] {
                continue;
            }
            let nb_dist = distance[nb_r][nb_c];
            let new_dist = dist + 1;
            if nb_dist.is_none() || Some(new_dist) < distance[nb_r][nb_c] {
                distance[nb_r][nb_c] = Some(new_dist);
                to_visit.push(Reverse((new_dist, (nb_r, nb_c))));
            }
        }
    }
    distance[end.0][end.1]
}

fn main() {
    let coords = BufReader::new(stdin())
        .lines()
        .map(|line| {
            let line = line.unwrap();
            let mut nums = line
                .split(",")
                .into_iter()
                .map(|x| x.parse::<usize>().unwrap());
            let x = nums.next().unwrap();
            let y = nums.next().unwrap();
            (x, y)
        })
        .collect::<Vec<_>>();

    let mut grid_part1 = [[false; GRID_SIZE]; GRID_SIZE];
    for (r, c) in coords.iter().take(FIRST_N).copied() {
        grid_part1[r][c] = true;
    }
    let dist = find_path((0, 0), (GRID_SIZE - 1, GRID_SIZE - 1), &grid_part1).unwrap();
    println!("{dist}");

    let mut grid_part2 = [[false; GRID_SIZE]; GRID_SIZE];
    for (r, c) in coords.iter().copied() {
        grid_part2[r][c] = true;
        if find_path((0, 0), (GRID_SIZE - 1, GRID_SIZE - 1), &grid_part2).is_none() {
            println!("{r},{c}");
            break;
        }
    }
}
