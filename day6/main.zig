const std = @import("std");
const input = @embedFile("input");
const GRID_SIZE: usize = 130;

fn readGrid() [GRID_SIZE][GRID_SIZE]u8 {
    var grid: [GRID_SIZE][GRID_SIZE]u8 = undefined;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= GRID_SIZE) {
            break;
        }
        for (line, 0..GRID_SIZE) |char, c| {
            grid[r][c] = char;
        }
        r += 1;
    }
    return grid;
}

fn calculateDir(dir: u3, row: usize, col: usize) ?[2]usize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    const coords: [2]isize = switch (dir) {
        0 => .{ r - 1, c }, // north
        1 => .{ r, c + 1 }, // east
        2 => .{ r + 1, c }, // south
        3 => .{ r, c - 1 }, // west
        else => unreachable,
    };
    if (coords[0] < 0 or coords[0] >= GRID_SIZE or coords[1] < 0 or coords[1] >= GRID_SIZE) {
        return null;
    }
    const r2: usize = @intCast(coords[0]);
    const c2: usize = @intCast(coords[1]);
    return .{ r2, c2 };
}

fn countVisisted(start_row: usize, start_col: usize, obstacles: *[GRID_SIZE][GRID_SIZE]bool) u64 {
    var visited: [GRID_SIZE][GRID_SIZE]bool = undefined;
    var row: usize = start_row;
    var col: usize = start_col;
    var dir: u3 = 0;
    while (true) {
        visited[row][col] = true;
        const next = calculateDir(dir, row, col) orelse break;
        var r = next[0];
        var c = next[1];
        while (obstacles[r][c]) {
            // switch direction
            dir = (dir + 1) % 4;
            const next2 = calculateDir(dir, row, col) orelse break;
            r = next2[0];
            c = next2[1];
        }
        row = r;
        col = c;
    }
    var count: u64 = 0;
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            if (visited[r][c]) {
                count += 1;
            }
        }
    }
    return count;
}

fn loops(start_row: usize, start_col: usize, obstacles: *[GRID_SIZE][GRID_SIZE]bool) bool {
    var visited: [GRID_SIZE][GRID_SIZE][4]bool = std.mem.zeroes([GRID_SIZE][GRID_SIZE][4]bool);
    var row: usize = start_row;
    var col: usize = start_col;
    var dir: u3 = 0;
    while (true) {
        if (visited[row][col][dir]) {
            // already visited in same direction = looping
            return true;
        }
        visited[row][col][dir] = true;
        const next = calculateDir(dir, row, col) orelse break;
        var r = next[0];
        var c = next[1];
        while (obstacles[r][c]) {
            // switch direction
            dir = (dir + 1) % 4;
            const next2 = calculateDir(dir, row, col) orelse break;
            r = next2[0];
            c = next2[1];
        }
        row = r;
        col = c;
    }
    return false;
}

pub fn main() !void {
    const grid = readGrid();
    var start_row: usize = 0;
    var start_col: usize = 0;
    var obstacles: [GRID_SIZE][GRID_SIZE]bool = undefined;
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            if (grid[r][c] == '#') {
                obstacles[r][c] = true;
                continue;
            }
            obstacles[r][c] = false;
            if (grid[r][c] == '^') {
                start_row = r;
                start_col = c;
            }
        }
    }

    const part1: u64 = countVisisted(start_row, start_col, &obstacles);
    std.debug.print("{d}\n", .{part1});

    var part2: u64 = 0;
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            if (obstacles[r][c] or (r == start_row and c == start_col)) {
                continue;
            }
            obstacles[r][c] = true;
            if (loops(start_row, start_col, &obstacles)) {
                part2 += 1;
            }
            obstacles[r][c] = false;
        }
    }
    std.debug.print("{d}\n", .{part2});
}
