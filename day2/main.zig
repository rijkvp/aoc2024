const std = @import("std");
const input = @embedFile("test");

pub fn main() !void {
    // read input
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var safe_count: usize = 0;
    while (lines.next()) |token| {
        var words = std.mem.tokenizeScalar(u8, token, ' ');

        const first = words.next().?;
        var prev = try std.fmt.parseInt(i64, first, 10);

        var increasing = false;
        var decreasing = false;
        var safe = true;
        while (words.next()) |word| {
            const level = try std.fmt.parseInt(i64, word, 10);
            const diff = level - prev;
            if (diff < 0) {
                decreasing = true;
            } else if (diff > 0) {
                increasing = true;
            }
            if (@abs(diff) < 1 and @abs(diff) > 3) {
                safe = false;
            }
            prev = level;
        }
        if (safe) {
            safe_count += 1;
        }
    }
    std.debug.print("{d}\n", .{safe_count});
}
