use std::cmp::Reverse;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::io::{stdin, BufRead, BufReader};

const DIR_OFFSETS: &[(i64, i64)] = &[(-1, 0), (0, 1), (1, 0), (0, -1)];

fn moves(
    pos: (usize, usize),
    dir: u8,
    height: usize,
    width: usize,
) -> impl Iterator<Item = ((usize, usize), u8)> {
    let offset = DIR_OFFSETS[dir as usize];
    let (r, c) = ((pos.0 as i64 + offset.0), (pos.1 as i64 + offset.1));
    if r >= 0 && r < height as i64 && c >= 0 && c < width as i64 {
        let pos = (r as usize, c as usize);
        vec![(pos, dir)]
    } else {
        vec![]
    }
    .into_iter()
    .chain(vec![(pos, (dir + 1) % 4), (pos, (dir + 3) % 4)].into_iter())
}

fn find_path(
    start: (usize, usize),
    end: (usize, usize),
    grid: &Vec<Vec<char>>,
) -> Option<(u64, HashSet<(usize, usize)>)> {
    let mut distance = HashMap::<((usize, usize), u8), u64>::new();
    let mut parent = HashMap::<((usize, usize), u8), Vec<((usize, usize), u8)>>::new();
    let mut to_visit = BinaryHeap::new();
    distance.insert((start, 1), 0);
    to_visit.push(Reverse((0, start, 1)));

    while let Some(Reverse((dist, pos, dir))) = to_visit.pop() {
        for next @ (next_pos, next_dir) in moves(pos, dir, grid.len(), grid[0].len()) {
            if grid[next_pos.0][next_pos.1] == '#' {
                continue;
            }
            let new_dist = if next_dir == dir {
                dist + 1
            } else {
                dist + 1000
            };
            if distance.get(&next).is_none() || new_dist < distance[&next] {
                distance.insert(next, new_dist);
                to_visit.push(Reverse((new_dist, next_pos, next_dir)));
                parent.insert((next_pos, next_dir), vec![(pos, dir)]);
            } else if distance.get(&next) == Some(&new_dist) {
                parent
                    .entry((next_pos, next_dir))
                    .or_default()
                    .push((pos, dir));
            }
        }
    }
    let mut path_tiles = HashSet::new();
    let min_dist = (0..4)
        .into_iter()
        .filter_map(|dir| distance.get(&(end, dir)))
        .min()
        .unwrap();
    for dir in 0..4 {
        if let Some(dist) = distance.get(&(end, dir)) {
            if dist != min_dist {
                continue;
            }
            let mut stack = vec![(end, dir)];
            while let Some(cur @ (pos, _)) = stack.pop() {
                if let Some(parents) = parent.get(&cur) {
                    path_tiles.insert(pos);
                    stack.extend(parents);
                };
            }
        }
    }
    Some((*min_dist, path_tiles))
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
            if *cell == 'S' {
                start = Some((r, c));
            } else if *cell == 'E' {
                end = Some((r, c));
            }
        }
    }
    let start = start.unwrap();
    let end = end.unwrap();

    let (dist, tiles) = find_path(start, end, &grid).unwrap();
    println!("{dist}");
    println!("{}", tiles.len());
}
