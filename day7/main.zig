const std = @import("std");
const input = @embedFile("input");
const allocator = std.heap.page_allocator;

fn concat(a: u64, b: u64) u64 {
    var c = a;
    var d = b;
    while (d > 0) {
        d /= 10;
        c *= 10;
    }
    return c + b;
}

fn canProduceInner(current: u64, i: usize, target: u64, nums: []const u64, comptime allowConcat: bool) bool {
    if (i == nums.len) {
        return current == target;
    }
    return canProduceInner(current * nums[i], i + 1, target, nums, allowConcat)
        or canProduceInner(current + nums[i], i + 1, target, nums, allowConcat)
        or (allowConcat and canProduceInner(concat(current, nums[i]), i + 1, target, nums, allowConcat));
}

fn canProduce(target: u64, nums: []const u64, comptime allowConcat: bool) bool {
    return canProduceInner(nums[0] * nums[1], 2, target, nums, allowConcat)
        or canProduceInner(nums[0] + nums[1], 2, target, nums, allowConcat)
        or (allowConcat and canProduceInner(concat(nums[0], nums[1]), 2, target, nums, allowConcat));
}

pub fn main() !void {
    var part1: u64 = 0;
    var part2: u64 = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ':');
        const testValue = try std.fmt.parseInt(u64, split.next().?, 10);

        var nums = std.mem.tokenizeScalar(u8, split.next().?, ' ');
        var list = std.ArrayList(u64).init(allocator);
        defer list.deinit();

        while (nums.next()) |num| {
            try list.append(try std.fmt.parseInt(u64, num, 10));
        }

        if (canProduce(testValue, list.items, false)) {
            part1 += testValue;
        }
        if (canProduce(testValue, list.items, true)) {
            part2 += testValue;
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
