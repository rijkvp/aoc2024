const std = @import("std");
const input = @embedFile("input/09.txt");
const alloc = std.heap.page_allocator;

fn checksum(diskMap: []?u64) u64 {
    var sum: u64 = 0;
    for (diskMap, 0..) |value, i| {
        if (value) |v| {
            sum += v * i;
        }
    }
    return sum;
}

fn findEmptyFragment(diskMap: []?u64, size: usize, limit: usize) ?[2]usize {
    var i: usize = 0;
    while (i < limit) {
        if (diskMap[i] != null) {
            i += 1;
            continue;
        }
        var j = i + 1;
        while (j < diskMap.len and diskMap[j] == null) {
            j += 1;
        }
        if (j - i >= size) {
            return .{ i, j };
        }
        i = j;
    }
    return null;
}

pub fn main() !void {
    var diskMap = std.ArrayList(?u64).init(alloc);
    var sizes = std.ArrayList(u64).init(alloc);
    var starts = std.ArrayList(u64).init(alloc);
    defer diskMap.deinit();

    var isFile: bool = true;
    var fileId: u64 = 0;
    for (input) |char| {
        if (!std.ascii.isDigit(char)) {
            break;
        }
        const size: u8 = char - '0';
        if (isFile) {
            try sizes.append(size);
            try starts.append(diskMap.items.len);
            try diskMap.appendNTimes(fileId, size);
            fileId += 1;
        } else {
            try diskMap.appendNTimes(null, size);
        }
        isFile = !isFile;
    }

    // copy diskmap for part 2
    var diskMap2 = std.ArrayList(?u64).init(alloc);
    defer diskMap2.deinit();
    try diskMap2.resize(diskMap.items.len);
    std.mem.copyForwards(?u64, diskMap2.items, diskMap.items);

    // part one
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
    // part two
    for (1..fileId) |j| {
        const id = fileId - j;
        const fragmentSize = sizes.items[id];
        const fragmentStart = starts.items[id];
        if (findEmptyFragment(diskMap2.items, fragmentSize, fragmentStart)) |space| {
            for (fragmentStart..(fragmentStart + fragmentSize)) |i| {
                diskMap2.items[i] = null;
            }
            for (space[0]..(space[0] + fragmentSize)) |i| {
                diskMap2.items[i] = id;
            }
        }
    }
    std.debug.print("{d}\n", .{checksum(diskMap2.items)});
}
