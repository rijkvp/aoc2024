const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

fn printDiskMap(diskMap: []?u64) void {
    for (diskMap) |item| {
        if (item) |i| {
            std.debug.print("{d}", .{i});
        } else {
            std.debug.print(".", .{});
        }
    }
    std.debug.print("\n", .{});
}

fn checksum(diskMap: []?u64) u64 {
    var sum: u64 = 0;
    for (diskMap, 0..) |value, i| {
        sum += value.? * i;
    }
    return sum;
}

pub fn main() !void {
    var diskMap = std.ArrayList(?u64).init(alloc);
    defer diskMap.deinit();

    var isFile: bool = true;
    var fileId: u64 = 0;
    for (input) |char| {
        if (!std.ascii.isDigit(char)) {
            break;
        }
        const size: u8 = char - '0';
        if (isFile) {
            try diskMap.appendNTimes(fileId, size);
            fileId += 1;
        } else {
            try diskMap.appendNTimes(null, size);
        }
        isFile = !isFile;
    }
    while (true) {
        const emptyIdx = std.mem.indexOfScalar(?u64, diskMap.items, null);
        if (emptyIdx) |idx| {
            const el = diskMap.pop();
            diskMap.items[idx] = el;
        } else {
            break;
        }
    }

    std.debug.print("{d}\n", .{checksum(diskMap.items)});
}
