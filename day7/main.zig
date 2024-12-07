const std = @import("std");
const input = @embedFile("input");
const allocator = std.heap.page_allocator;

fn canProduce2(current: u64, i: usize, target: u64, nums: []const u64) bool {
    if (current == target) {
        return true;
    }
    if (i == nums.len) {
        return false;
    }
    return canProduce2(current * nums[i], i + 1, target, nums) or canProduce2(current + nums[i], i + 1, target, nums);
}

fn canProduce(target: u64, nums: []const u64) bool {
    return canProduce2(nums[0] * nums[1], 2, target, nums) or canProduce2(nums[0] + nums[1], 2, target, nums);
}

pub fn main() !void {
    var part1: u64 = 0;
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

        if (canProduce(testValue, list.items)) {
            part1 += testValue;
        }
    }
    std.debug.print("{d}\n", .{part1});
}
