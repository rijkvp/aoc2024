const std = @import("std");
const input = @embedFile("input");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var left = std.ArrayList(i64).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i64).init(allocator);
    defer right.deinit();

    // read input
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |token| {
        var words = std.mem.tokenizeScalar(u8, token, ' ');
        const w1 = words.next() orelse "";
        const w2 = words.next() orelse ""; // I don't get how to do error handling here..
        const item1 = try std.fmt.parseInt(i64, w1, 10);
        const item2 = try std.fmt.parseInt(i64, w2, 10);
        try left.append(item1);
        try right.append(item2);
    }

    // sort lists
    const left_sorted = try left.toOwnedSlice();
    std.mem.sort(i64, left_sorted, {}, comptime std.sort.asc(i64));
    const right_sorted = try right.toOwnedSlice();
    std.mem.sort(i64, right_sorted, {}, comptime std.sort.asc(i64));

    // part one
    var total: usize = 0;
    for (left_sorted, right_sorted) |a, b| {
        const dist = @abs(a - b);
        total += dist;
    }
    std.debug.print("{d}\n", .{total});

    // part two
    var similarily_score: i64 = 0;
    for (left_sorted) |a| {
        var similar: i64 = 0;
        for (right_sorted) |b| {
            if (a == b) {
                similar += 1;
            }
        }
        similarily_score += a * similar;
    }
    std.debug.print("{d}\n", .{similarily_score});
}
