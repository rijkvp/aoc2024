const std = @import("std");
const input = @embedFile("input");

fn readCoords(line: []const u8) ![2]i64 {
    var split = std.mem.tokenizeScalar(u8, line, ':');
    _ = split.next().?;
    var coords = std.mem.tokenizeAny(u8, split.next().?, " XY,+=");
    const x = try std.fmt.parseInt(i64, coords.next().?, 10);
    const y = try std.fmt.parseInt(i64, coords.next().?, 10);
    return .{ x, y };
}

fn solve(a_offset: [2]i64, b_offset: [2]i64, prize: [2]i64) i64 {
    const det = a_offset[0] * b_offset[1] - a_offset[1] * b_offset[0];
    const a = @divFloor(b_offset[1] * prize[0] - b_offset[0] * prize[1], det);
    const b = @divFloor(a_offset[0] * prize[1] - a_offset[1] * prize[0], det);
    if ((a * a_offset[0] + b * b_offset[0] == prize[0]) and (a * a_offset[1] + b * b_offset[1] == prize[1])) {
        return 3 * a + b;
    }
    return 0;
}

pub fn main() !void {
    var it = std.mem.tokenizeSequence(u8, input, "\n\n");
    var part1: i64 = 0;
    var part2: i64 = 0;
    while (it.next()) |group| {
        var lines = std.mem.tokenizeScalar(u8, group, '\n');
        const a_offset = try readCoords(lines.next().?);
        const b_offset = try readCoords(lines.next().?);
        const prize = try readCoords(lines.next().?);
        part1 += solve(a_offset, b_offset, prize);
        part2 += solve(a_offset, b_offset, .{ prize[0] + 10000000000000, prize[1] + 10000000000000 });
    }
    std.debug.print("{d}\n{d}\n", .{ part1, part2 });
}
