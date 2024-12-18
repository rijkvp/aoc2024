const std = @import("std");
const input = @embedFile("input/05.txt");
const allocator = std.heap.page_allocator;

fn checkOrder(updateNumbers: []const u64, orderingRules: []const [2]u64) bool {
    for (orderingRules) |rule| {
        const idx1 = std.mem.indexOfScalar(u64, updateNumbers, rule[0]) orelse continue;
        const idx2 = std.mem.indexOfScalar(u64, updateNumbers, rule[1]) orelse continue;
        if (idx2 < idx1) {
            return false;
        }
    }
    return true;
}

fn fixOrder(updateNumbers: *std.ArrayList(u64), orderingRules: []const [2]u64) !void {
    for (orderingRules) |rule| {
        const idx1 = std.mem.indexOfScalar(u64, updateNumbers.items, rule[0]) orelse continue;
        const idx2 = std.mem.indexOfScalar(u64, updateNumbers.items, rule[1]) orelse continue;
        if (idx2 < idx1) {
            const rem = updateNumbers.orderedRemove(idx2);
            try updateNumbers.insert(idx1, rem);
        }
    }
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
    var part2: u64 = 0;
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
        } else {
            // I know, very stupid but it works :-)
            while (!checkOrder(updateNumbers.items, orderingRules.items)) {
                try fixOrder(&updateNumbers, orderingRules.items);
            }
            const mid = updateNumbers.items[updateNumbers.items.len / 2];
            part2 += mid;
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
