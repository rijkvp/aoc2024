const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

fn readCoords(line: []const u8) ![2]u64 {
    var split = std.mem.tokenizeScalar(u8, line, ':');
    _ = split.next().?;
    var coords = std.mem.tokenizeAny(u8, split.next().?, " XY,+=");
    const x = try std.fmt.parseInt(u64, coords.next().?, 10);
    const y = try std.fmt.parseInt(u64, coords.next().?, 10);
    return .{ x, y };
}

pub fn main() !void {
    var it = std.mem.tokenizeSequence(u8, input, "\n\n");
    var part1: u64 = 0;
    while (it.next()) |group| {
        var lines = std.mem.tokenizeScalar(u8, group, '\n');
        const a_offset = try readCoords(lines.next().?);
        const b_offset = try readCoords(lines.next().?);
        const prize = try readCoords(lines.next().?);
        var minCost: ?u64 = null;
        for (0..101) |a| {
            for (0..101) |b| {
                const x = a * a_offset[0] + b * b_offset[0];
                const y = a * a_offset[1] + b * b_offset[1];
                const cost = 3 * a + 1 * b;
                if (x == prize[0] and y == prize[1]) {
                    if (minCost) |min| {
                        if (cost < min) minCost = cost;
                    } else {
                        minCost = cost;
                    }
                }
            }
        }
        if (minCost) |min| {
            part1 += min;
        }
    }
    std.debug.print("{d}\n", .{part1});
}
