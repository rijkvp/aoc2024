const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

const Cell = u8;
const Grid = [grid_size][grid_size]Cell;

const grid_size: usize = gridSize();
const grid = readGrid();

fn gridSize() usize {
    return std.mem.indexOfScalar(u8, input, '\n').?;
}

fn readGrid() Grid {
    @setEvalBranchQuota(grid_size * grid_size * 10);
    var grid2: Grid = std.mem.zeroes(Grid);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= grid_size) {
            break;
        }
        for (line, 0..) |char, c| {
            grid2[r][c] = char;
        }
        r += 1;
    }
    return grid2;
}

fn neighbourningPlot(dir: usize, row: usize, col: usize, comptime rows: usize, comptime cols: usize) ?[2]usize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    const coords: [2]isize = switch (dir) {
        0 => .{ r - 1, c }, // north
        1 => .{ r, c + 1 }, // east
        2 => .{ r + 1, c }, // south
        3 => .{ r, c - 1 }, // west
        else => unreachable,
    };
    if (coords[0] < 0 or coords[0] >= rows or coords[1] < 0 or coords[1] >= cols) {
        return null;
    }
    return .{ @intCast(coords[0]), @intCast(coords[1]) };
}

fn calcArea(region: [grid_size][grid_size]bool) u64 {
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

fn calcPerimeter(region_value: u8, region: [grid_size][grid_size]bool) u64 {
    var perimeter: u64 = 0;
    for (0..grid_size) |r| {
        for (0..grid_size) |c| {
            if (region[r][c]) {
                for (0..4) |dir| {
                    if (neighbourningPlot(dir, r, c, grid_size, grid_size)) |neighbour| {
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

fn printGrid(comptime rows: usize, comptime cols: usize, values: [rows][cols]bool) void {
    for (0..rows) |r| {
        for (0..cols) |c| {
            if (values[r][c]) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn countRegions(comptime rows: usize, comptime cols: usize, edges: [rows][cols]bool) !u64 {
    var stack = std.ArrayList([2]usize).init(alloc);
    defer stack.deinit();
    var count: u64 = 0;
    var covered: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);
    var region: [rows][cols]bool = undefined;
    for (0..rows) |r| {
        for (0..cols) |c| {
            if (covered[r][c] or !edges[r][c]) {
                continue;
            }
            region = std.mem.zeroes([rows][cols]bool);
            try stack.append(.{ r, c });
            while (stack.popOrNull()) |plot| {
                const row = plot[0];
                const col = plot[1];
                if (!edges[row][col] or region[row][col]) {
                    continue;
                }
                region[row][col] = true;
                covered[row][col] = true;
                for (0..4) |dir| {
                    if (neighbourningPlot(dir, row, col, grid_size + 2, grid_size + 2)) |neighbour| {
                        try stack.append(neighbour);
                    }
                }
            }
            count += 1;
        }
    }
    return count;
}

fn calcSides(region_value: u8, region: [grid_size][grid_size]bool) !u64 {
    var sides: u64 = 0;
    var edges: [grid_size + 2][grid_size + 2]bool = undefined;
    // std.debug.print("Region {c}\n", .{region_value});
    // printGrid(grid_size, grid_size, region);
    for (0..4) |dir| {
        edges = std.mem.zeroes([grid_size + 2][grid_size + 2]bool);
        for (0..grid_size) |r| {
            for (0..grid_size) |c| {
                if (region[r][c]) {
                    if (neighbourningPlot(dir, r, c, grid_size, grid_size)) |neighbour| {
                        if (grid[neighbour[0]][neighbour[1]] != region_value) {
                            edges[r + 1][c + 1] = true;
                        }
                    } else {
                        edges[r + 1][c + 1] = true;
                    }
                }
            }
        }
        // std.debug.print("Edges {d}\n", .{dir});
        // printGrid(grid_size + 2, grid_size + 2, edges);
        const regions = try countRegions(grid_size + 2, grid_size + 2, edges);
        // std.debug.print("Regions {d}\n", .{regions});
        sides += regions;
    }
    return sides;
}

pub fn main() !void {
    var stack = std.ArrayList([2]usize).init(alloc);
    defer stack.deinit();

    var covered: [grid_size][grid_size]bool = std.mem.zeroes([grid_size][grid_size]bool);
    var region: [grid_size][grid_size]bool = undefined;

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
                    if (neighbourningPlot(dir, row, col, grid_size, grid_size)) |neighbour| {
                        try stack.append(neighbour);
                    }
                }
            }
            const area = calcArea(region);
            const perimeter = calcPerimeter(region_value, region);
            const sides = try calcSides(region_value, region);
            // std.debug.print("Region {c} sides {d}\n", .{ region_value, sides });
            part1 += area * perimeter;
            part2 += area * sides;
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}
