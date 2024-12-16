const std = @import("std");
const input = @embedFile("example1");
const grid_size = gridSize();
const grid = parseGrid();

fn gridSize() usize {
    return std.mem.indexOfScalar(u8, input, '\n').?;
}

fn parseGrid() [grid_size][grid_size]u8 {
    @setEvalBranchQuota(grid_size * grid_size * 10);
    var grid2: [grid_size][grid_size]u8 = std.mem.zeroes([grid_size][grid_size]u8);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= grid_size) {
            break;
        }
        for (line, 0..) |char, c| {
            grid2[r][c] = char;
        }
        r += 1;
    }
    return grid2;
}

fn dir4(dir: usize, row: usize, col: usize) ?[2]usize {
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

fn printDirs(directions: [grid_size][grid_size]u8) void {
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            const dir = directions[r][c];
            if (dir == 5) {
                std.debug.print(".", .{});
            } else {
                switch (dir) {
                    0 => std.debug.print("^", .{}),
                    1 => std.debug.print(">", .{}),
                    2 => std.debug.print("v", .{}),
                    3 => std.debug.print("<", .{}),
                    else => unreachable,
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    var start_row: usize = 0;
    var start_col: usize = 0;
    var end_row: usize = 0;
    var end_col: usize = 0;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (grid[r][c] == 'S') {
                start_row = r;
                start_col = c;
            } else if (grid[r][c] == 'E') {
                end_row = r;
                end_col = c;
            }
        }
    }
    // 'Slow' version of Dijkstra, Zig has no priority queue data structure :(
    var visited: [grid_size][grid_size]bool = std.mem.zeroes([grid_size][grid_size]bool);
    var score: [grid_size][grid_size]u64 = undefined;
    var direction: [grid_size][grid_size]u8 = undefined;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (start_row == r and start_col == c) {
                score[r][c] = 0;
            } else {
                score[r][c] = std.math.maxInt(u64);
                if (grid[r][c] == '#')
                    visited[r][c] = true;
            }
            direction[r][c] = 5; // none
        }
    }
    direction[start_row][start_col] = 1; // east
    while (true) {
        // find min
        var min_row: usize = 0;
        var min_col: usize = 0;
        var min_score: u64 = std.math.maxInt(u64);
        var found: bool = false;
        for (0..grid_size) |r| {
            for (0..grid_size) |c| {
                if (score[r][c] < min_score and !visited[r][c]) {
                    min_row = r;
                    min_col = c;
                    min_score = score[r][c];
                    found = true;
                }
            }
        }
        if (!found) {
            break;
        }
        const current_score = score[min_row][min_col];
        const current_dir = direction[min_row][min_col];
        // update neighbours
        for (0..4) |dir| {
            if (dir4(dir, min_row, min_col)) |nb| {
                if (visited[nb[0]][nb[1]]) {
                    continue;
                }
                if (dir == current_dir) {
                    score[nb[0]][nb[1]] = current_score + 1;
                } else {
                    score[nb[0]][nb[1]] = current_score + 1001;
                }
                direction[nb[0]][nb[1]] = @intCast(dir);
            }
        }
        // visitted
        visited[min_row][min_col] = true;
    }
    printDirs(direction);
    std.debug.print("{}\n", .{score[end_row][end_col]});
}
