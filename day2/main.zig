const std = @import("std");
const input = @embedFile("input");
const allocator = std.heap.page_allocator;

fn isSafe(levels: []const i64, skip: bool, skip_idx: usize) bool {
    var incr = false;
    var decr = false;
    var adj = true;
    var prev: i64 = -1;
    for (levels, 0..) |level, i| {
        if (skip and i == skip_idx) {
            continue;
        }
        if (prev != -1) {
            const diff = level - prev;
            if (diff < 0) {
                decr = true;
            } else if (diff > 0) {
                incr = true;
            }
            if (@abs(diff) < 1 or @abs(diff) > 3) {
                adj = false;
            }
        }
        prev = level;
    }
    return adj and !(incr and decr);
}

pub fn main() !void {
    var safe_count: usize = 0;
    var safe_count_2: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        var levels = std.ArrayList(i64).init(allocator);
        while (words.next()) |word| {
            const level = try std.fmt.parseInt(i64, word, 10);
            try levels.append(level);
        }

        // part 1
        if (isSafe(levels.items, false, 0)) {
            safe_count += 1;
        }

        // part 2
        for (0..levels.items.len) |i| {
            if (isSafe(levels.items, true, i)) {
                safe_count_2 += 1;
                break;
            }
        }
    }
    std.debug.print("{d}\n", .{safe_count});
    std.debug.print("{d}\n", .{safe_count_2});
}
