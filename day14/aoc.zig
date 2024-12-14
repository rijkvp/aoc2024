const std = @import("std");

pub fn Grid(
    comptime T: type,
    comptime size: usize,
) type {
    return [size][size]T;
}

pub fn gridSize(input: []const u8) usize {
    return std.mem.indexOfScalar(u8, input, '\n').?;
}

fn noParsing(x: u8) u8 {
    return x;
}

pub fn readGrid(comptime size: usize, input: []const u8) Grid(u8, size) {
    return parseGrid(u8, size, input, noParsing);
}

pub fn parseGrid(
    comptime Cell: type,
    comptime size: usize,
    input: []const u8,
    parse: fn (x: u8) Cell,
) Grid(Cell, size) {
    @setEvalBranchQuota(size * size * 10);
    var grid2: Grid(Cell, size) = std.mem.zeroes(Grid(Cell, size));
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= size) {
            break;
        }
        for (line, 0..) |char, c| {
            grid2[r][c] = parse(char);
        }
        r += 1;
    }
    return grid2;
}

pub fn dir4(dir: usize, row: usize, col: usize, comptime size: usize) ?[2]usize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    const coords: [2]isize = switch (dir) {
        0 => .{ r - 1, c }, // north
        1 => .{ r, c + 1 }, // east
        2 => .{ r + 1, c }, // south
        3 => .{ r, c - 1 }, // west
        else => unreachable,
    };
    if (coords[0] < 0 or coords[0] >= size or coords[1] < 0 or coords[1] >= size) {
        return null;
    }
    return .{ @intCast(coords[0]), @intCast(coords[1]) };
}
