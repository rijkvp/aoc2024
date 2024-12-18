fn neighbours(r: usize, c: usize, height: usize, width: usize) -> impl Iterator<Item = (usize, usize)> {
    [(-1, 0), (1, 0), (0, -1), (0, 1)]
        .into_iter()
        .map(move |(r_offset, c_offset)| (r as i64 + r_offset, c as i64 + c_offset))
        .filter(|(r, c)| *r >= 0 && *r < height as i64 && *c >= 0 && *c < width as i64)
        .map(|(r, c)| (r as usize, c as usize))
}

fn main() {
    let grid = BufReader::new(stdin())
        .lines()
        .map(|l| l.unwrap().chars().collect())
        .collect::<Vec<Vec<char>>>();
}
