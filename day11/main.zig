const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

fn countDigits(num: u64) u64 {
    var a = num;
    var b: u64 = 1;
    while (a >= 10) {
        a /= 10;
        b += 1;
    }
    return b;
}

fn splitNumber(num: u64, digits: u64) [2]u64 {
    var a = num;
    var b: u64 = 0;
    var c: u64 = 1;
    for (0..digits / 2) |_| {
        const d = a % 10;
        b += c * d;
        a /= 10;
        c *= 10;
    }

    return .{ a, b };
}

fn blink(stone: u64, count: u64, comptime limit: u64) u64 {
    if (count == limit) {
        return 1;
    }
    if (stone == 0) {
        return blink(1, count + 1, limit);
    }
    const numDigits = countDigits(stone);
    if (numDigits % 2 == 0) {
        const split = splitNumber(stone, numDigits);
        return blink(split[0], count + 1, limit) + blink(split[1], count + 1, limit);
    }
    return blink(stone * 2024, count + 1, limit);
}

pub fn main() !void {
    var stones = std.ArrayList(u64).init(alloc);
    defer stones.deinit();

    const trimmed = std.mem.trim(u8, input, "\n");
    var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
    while (it.next()) |token| {
        const num = try std.fmt.parseInt(u64, token, 10);
        try stones.append(num);
    }

    var part1: u64 = 0;
    for (stones.items) |stone| {
        part1 += blink(stone, 0, 25);
    }
    std.debug.print("{d}\n", .{part1});
}
