const std = @import("std");
const input = @embedFile("input");
const allocator = std.heap.page_allocator;

fn checkOrder(updateNumbers: []u64, orderingRules: [][2]u64) bool {
    for (orderingRules) |rule| {
        const result = std.mem.indexOfScalar(u64, updateNumbers, rule[0]);
        if (result) |idx| {
            // rule[1] should not occur before that index
            for (0..idx) |i| {
                if (updateNumbers[i] == rule[1]) {
                    return false;
                }
            }
        }
    }
    return true;
}

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var orderingRules = std.ArrayList([2]u64).init(allocator);
    defer orderingRules.deinit();
    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, '|');
        const w1 = words.next() orelse break;
        const w2 = words.next().?;
        const left = try std.fmt.parseInt(u64, w1, 10);
        const right = try std.fmt.parseInt(u64, w2, 10);
        try orderingRules.append(.{ left, right });
    }
    var part1: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var words = std.mem.tokenizeScalar(u8, line, ',');
        var updateNumbers = std.ArrayList(u64).init(allocator);
        defer updateNumbers.deinit();
        while (words.next()) |word| {
            const num = try std.fmt.parseInt(u64, word, 10);
            try updateNumbers.append(num);
        }

        if (checkOrder(updateNumbers.items, orderingRules.items)) {
            const mid = updateNumbers.items[updateNumbers.items.len / 2];
            part1 += mid;
        }
    }
    std.debug.print("{d}", .{part1});
}
