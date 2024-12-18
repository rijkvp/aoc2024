const std = @import("std");
const input = @embedFile("input/10.txt");
const alloc = std.heap.page_allocator;
const grid_size: usize = 57;

fn readGrid() [grid_size][grid_size]u8 {
    var grid: [grid_size][grid_size]u8 = undefined;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= grid_size) {
            break;
        }
        for (line, 0..) |char, c| {
            grid[r][c] = char - '0';
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
    if (coords[0] < 0 or coords[0] >= grid_size or coords[1] < 0 or coords[1] >= grid_size) {
        return null;
    }
    return .{ @intCast(coords[0]), @intCast(coords[1]) };
}

fn findTrails(height: u8, row: usize, col: usize, grid: *const [grid_size][grid_size]u8, results: *std.ArrayList([2]usize)) !void {
    if (height == 9) {
        const coords = .{ row, col };
        for (results.items) |item| {
            if (item[0] == coords[0] and item[1] == coords[1]) {
                return;
            }
        }
        try results.append(coords);
        return;
    }
    for (0..4) |dir| {
        if (calculateDir(dir, row, col)) |coords| {
            if (grid[coords[0]][coords[1]] == height + 1) {
                try findTrails(height + 1, coords[0], coords[1], grid, results);
            }
        }
    }
}

fn trailRating(height: u8, row: usize, col: usize, grid: *const [grid_size][grid_size]u8) u64 {
    var total: u64 = 0;
    if (height == 9) {
        return 1;
    }
    for (0..4) |dir| {
        if (calculateDir(dir, row, col)) |coords| {
            if (grid[coords[0]][coords[1]] == height + 1) {
                total += trailRating(height + 1, coords[0], coords[1], grid);
            }
        }
    }
    return total;
}

pub fn main() !void {
    const grid = readGrid();

    var results = std.ArrayList([2]usize).init(alloc);
    defer results.deinit();

    var part1: u64 = 0;
    var part2: u64 = 0;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (grid[r][c] == 0) {
                results.clearRetainingCapacity();
                try findTrails(0, r, c, &grid, &results);
                part1 += results.items.len;
                part2 += trailRating(0, r, c, &grid);
            }
        }
    }

    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
