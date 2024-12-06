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

fn calculateDir(dir: usize, row: usize, col: usize) ?[2]usize {
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

pub fn main() !void {
    const grid = readGrid();
    var row: usize = 0;
    var col: usize = 0;
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            if (grid[r][c] == '^') {
                row = r;
                col = c;
                break;
            }
        }
    }

    var visited: [GRID_SIZE][GRID_SIZE]bool = undefined;
    var dir: usize = 0;
    while (true) {
        visited[row][col] = true;
        const next = calculateDir(dir, row, col) orelse break;
        var r = next[0];
        var c = next[1];
        if (grid[r][c] == '#') {
            // switch direction
            dir = (dir + 1) % 4;
            const next2 = calculateDir(dir, row, col) orelse break;
            r = next2[0];
            c = next2[1];
        }
        row = r;
        col = c;
    }
    var part1: u63 = 0;
    for (0..GRID_SIZE) |r| {
        for (0..GRID_SIZE) |c| {
            if (visited[r][c]) {
                part1 += 1;
            }
        }
    }
    std.debug.print("{d}\n", .{part1});
    // std.debug.print("{d}\n", .{part2});
}
