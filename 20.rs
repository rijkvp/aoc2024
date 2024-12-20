use std::cmp::Reverse;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::io::{stdin, BufRead, BufReader};

const DIRS: [(i64, i64); 4] = [(-1, 0), (0, 1), (1, 0), (0, -1)];

fn pos_in_dir(
    (start_r, start_c): (usize, usize),
    dir: u8,
    amount: i64,
    height: usize,
    width: usize,
) -> Option<(usize, usize)> {
    let (dr, dc) = DIRS[dir as usize];
    let (r, c) = (start_r as i64 + amount * dr, start_c as i64 + amount * dc);
    if r >= 0 && r < height as i64 && c >= 0 && c < width as i64 {
        Some((r as usize, c as usize))
    } else {
        None
    }
}

fn neighbours(
    (r, c): (usize, usize),
    height: usize,
    width: usize,
) -> impl Iterator<Item = (usize, usize)> {
    DIRS.into_iter()
        .map(move |(r_offset, c_offset)| (r as i64 + r_offset, c as i64 + c_offset))
        .filter(move |(r, c)| *r >= 0 && *r < height as i64 && *c >= 0 && *c < width as i64)
        .map(|(r, c)| (r as usize, c as usize))
}

fn find_path(
    start: (usize, usize),
    end: (usize, usize),
    grid: &Vec<Vec<char>>,
) -> Option<(u64, Vec<(usize, usize)>)> {
    let mut distance = HashMap::<(usize, usize), u64>::new();
    let mut visited = HashSet::new();
    let mut parent = HashMap::<(usize, usize), (usize, usize)>::new();
    let mut to_visit = BinaryHeap::new();
    distance.insert(start, 0);
    to_visit.push(Reverse((0, start)));

    while let Some(Reverse((dist, pos))) = to_visit.pop() {
        if pos == end {
            break;
        } else if !visited.insert(pos) {
            continue;
        }
        for nb @ (nb_r, nb_c) in neighbours(pos, grid.len(), grid[0].len()) {
            if grid[nb_r][nb_c] == '#' {
                continue;
            }
            let new_dist = dist + 1;
            if distance.get(&nb).is_none() || new_dist < distance[&nb] {
                distance.insert(nb, new_dist);
                parent.insert(nb, pos);
                to_visit.push(Reverse((new_dist, (nb_r, nb_c))));
            }
        }
    }
    distance.get(&end).map(|dist| {
        let mut cur = end;
        let mut path = Vec::new();
        while cur != start {
            path.push(cur);
            cur = parent[&cur];
        }
        path.push(start);
        path.reverse();
        (*dist, path)
    })
}

fn print_map(grid: &Vec<Vec<char>>) {
    for row in grid.iter() {
        for cell in row.iter() {
            print!("{cell}");
        }
        println!();
    }
}

fn print_track(grid: &Vec<Vec<char>>, track: &HashMap<(usize, usize), usize>) {
    for (r, row) in grid.iter().enumerate() {
        for (c, cell) in row.iter().enumerate() {
            if let Some(t) = track.get(&(r, c)) {
                print!("{t:<3}");
            } else {
                print!("{cell:<3}");
            }
        }
        println!();
    }
}

fn main() {
    let grid = BufReader::new(stdin())
        .lines()
        .map(|l| l.unwrap().chars().collect())
        .collect::<Vec<Vec<char>>>();
    let mut start = None;
    let mut end = None;
    for (r, row) in grid.iter().enumerate() {
        for (c, cell) in row.iter().enumerate() {
            match cell {
                'S' => start = Some((r, c)),
                'E' => end = Some((r, c)),
                _ => {}
            }
        }
    }
    let start = start.unwrap();
    let end = end.unwrap();
    let (_, track) = find_path(start, end, &grid).unwrap();

    let track_pos: HashMap<(usize, usize), usize> =
        track.iter().enumerate().map(|(n, p)| (*p, n)).collect();

    let mut part1 = 0;
    for pos in track {
        let start_score = track_pos.get(&pos).unwrap();
        for dir in 0..4 {
            let pos1 = pos_in_dir(pos, dir, 1, grid.len(), grid[0].len());
            let pos2 = pos_in_dir(pos, dir, 2, grid.len(), grid[0].len());
            if let (Some(pos1), Some(pos2)) = (pos1, pos2) {
                if let Some(end_score) = track_pos.get(&pos2) {
                    if grid[pos1.0][pos1.1] == '#' && end_score > start_score {
                        let saved = end_score - start_score - 2;
                        if saved >= 100 {
                            part1 += 1;
                        }
                    }
                }
            }
        }
    }
    println!("{part1}");
}
