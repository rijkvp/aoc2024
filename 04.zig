const std = @import("std");
const input = @embedFile("input/04.txt");
const GRID_SIZE: usize = 140;

fn readGrid() [GRID_SIZE][GRID_SIZE]u8 {
    var grid: [GRID_SIZE][GRID_SIZE]u8 = undefined;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        for (line, 0..GRID_SIZE) |char, c| {
            grid[r][c] = char;
        }
        r += 1;
    }
    return grid;
}

fn calculateDir(dir: usize, row: usize, col: usize) [2]isize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    switch (dir) {
        0 => return .{ r - 1, c }, // north
        1 => return .{ r - 1, c + 1 }, // north-east
        2 => return .{ r, c + 1 }, // east
        3 => return .{ r + 1, c + 1 }, // south-east
        4 => return .{ r + 1, c }, // south
        5 => return .{ r + 1, c - 1 }, // south-west
        6 => return .{ r, c - 1 }, // west
        7 => return .{ r - 1, c - 1 }, // north-west
        else => unreachable,
    }
}

fn readGridWordLetter(grid: [GRID_SIZE][GRID_SIZE]u8, word: []const u8, pos: usize, row: usize, col: usize, dir: usize) bool {
    if (grid[row][col] == word[pos]) {
        if (pos == word.len - 1) {
            return true; // found last letter
        }
        const coords = calculateDir(dir, row, col);
        if (coords[0] >= 0 and coords[0] < GRID_SIZE and coords[1] >= 0 and coords[1] < GRID_SIZE) {
            const r2: usize = @intCast(coords[0]);
            const c2: usize = @intCast(coords[1]);
            if (readGridWordLetter(grid, word, pos + 1, r2, c2, dir)) {
                return true;
            }
        }
    }
    return false;
}

fn readGridWord(grid: [GRID_SIZE][GRID_SIZE]u8, word: []const u8, row: usize, col: usize) usize {
    var count: usize = 0;
    if (grid[row][col] == word[0]) {
        for (0..8) |dir| {
            const coords = calculateDir(dir, row, col);
            if (coords[0] >= 0 and coords[0] < GRID_SIZE and coords[1] >= 0 and coords[1] < GRID_SIZE) {
                const r2: usize = @intCast(coords[0]);
                const c2: usize = @intCast(coords[1]);
                if (readGridWordLetter(grid, word, 1, r2, c2, dir)) {
                    count += 1;
                }
            }
        }
    }
    return count;
}

pub fn main() !void {
    const grid = readGrid();
    var part1: usize = 0;
    var part2: usize = 0;
    // part 1
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            part1 += readGridWord(grid, "XMAS", r, c);
        }
    }
    // part 2
    for (1..GRID_SIZE - 1) |r| {
        for (1..GRID_SIZE - 1) |c| {
            if (grid[r][c] == 'A') {
                if (((grid[r - 1][c - 1] == 'M' and grid[r + 1][c + 1] == 'S') or (grid[r - 1][c - 1] == 'S' and grid[r + 1][c + 1] == 'M')) and ((grid[r - 1][c + 1] == 'M' and grid[r + 1][c - 1] == 'S') or (grid[r - 1][c + 1] == 'S' and grid[r + 1][c - 1] == 'M'))) {
                    part2 += 1;
                }
            }
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
