const std = @import("std");
const aoc = @import("aoc.zig");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

const grid_size: usize = aoc.gridSize(input);
const grid = aoc.readGrid(grid_size, input);

fn calcArea(region: aoc.Grid(bool, grid_size)) u64 {
    var area: u64 = 0;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (region[r][c]) {
                area += 1;
            }
        }
    }
    return area;
}

fn calcPerimeter(region_value: u8, region: aoc.Grid(bool, grid_size)) u64 {
    var perimeter: u64 = 0;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (region[r][c]) {
                for (0..4) |dir| {
                    if (aoc.dir4(dir, r, c, grid_size)) |neighbour| {
                        if (grid[neighbour[0]][neighbour[1]] != region_value) {
                            perimeter += 1;
                        }
                    } else {
                        perimeter += 1;
                    }
                }
            }
        }
    }
    return perimeter;
}

fn countRegions(comptime size: usize, regions: aoc.Grid(bool, size)) !u64 {
    var stack = std.ArrayList([2]usize).init(alloc);
    defer stack.deinit();
    var count: u64 = 0;
    var visited: aoc.Grid(bool, size) = std.mem.zeroes(aoc.Grid(bool, size));
    var region: aoc.Grid(bool, size) = undefined;
    for (0..size) |r| {
        for (0..size) |c| {
            if (visited[r][c] or !regions[r][c]) {
                continue;
            }
            region = std.mem.zeroes([size][size]bool);
            try stack.append(.{ r, c });
            while (stack.popOrNull()) |plot| {
                const row = plot[0];
                const col = plot[1];
                if (!regions[row][col] or region[row][col]) {
                    continue;
                }
                region[row][col] = true;
                visited[row][col] = true;
                for (0..4) |dir| {
                    if (aoc.dir4(dir, row, col, grid_size + 2)) |neighbour| {
                        try stack.append(neighbour);
                    }
                }
            }
            count += 1;
        }
    }
    return count;
}

fn calcSides(region_value: u8, region: aoc.Grid(bool, grid_size)) !u64 {
    var sides: u64 = 0;
    var edges: aoc.Grid(bool, grid_size + 2) = undefined;
    for (0..4) |dir| {
        edges = std.mem.zeroes(aoc.Grid(bool, grid_size + 2));
        for (0..grid_size) |r| {
            for (0..grid_size) |c| {
                if (region[r][c]) {
                    if (aoc.dir4(dir, r, c, grid_size)) |neighbour| {
                        if (grid[neighbour[0]][neighbour[1]] != region_value) {
                            edges[r + 1][c + 1] = true;
                        }
                    } else {
                        edges[r + 1][c + 1] = true;
                    }
                }
            }
        }
        const regions = try countRegions(grid_size + 2, edges);
        sides += regions;
    }
    return sides;
}

pub fn main() !void {
    var stack = std.ArrayList([2]usize).init(alloc);
    defer stack.deinit();

    var covered: aoc.Grid(bool, grid_size) = std.mem.zeroes(aoc.Grid(bool, grid_size));
    var region: aoc.Grid(bool, grid_size) = undefined;

    var part1: u64 = 0;
    var part2: u64 = 0;

    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (covered[r][c]) {
                continue;
            }
            stack.clearRetainingCapacity();
            region = std.mem.zeroes([grid_size][grid_size]bool);
            const region_value = grid[r][c];
            try stack.append(.{ r, c });
            while (stack.popOrNull()) |plot| {
                const row = plot[0];
                const col = plot[1];
                if (grid[row][col] != region_value or region[row][col]) {
                    continue;
                }
                region[row][col] = true;
                covered[row][col] = true;
                for (0..4) |dir| {
                    if (aoc.dir4(dir, row, col, grid_size)) |neighbour| {
                        try stack.append(neighbour);
                    }
                }
            }
            const area = calcArea(region);
            const perimeter = calcPerimeter(region_value, region);
            const sides = try calcSides(region_value, region);
            part1 += area * perimeter;
            part2 += area * sides;
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
