const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;
const width: usize = 101;
const height: usize = 103;
const steps: usize = 100;

const Robot = struct {
    x: i64,
    y: i64,
    vx: i64,
    vy: i64,
};

fn heuristic(grid: [height][width]u64) bool {
    for (0..width) |cell| {
        var consecutive: u64 = 0;
        for (0..height) |row| {
            if (grid[row][cell] > 0) {
                consecutive += 1;
            } else {
                consecutive = 0;
            }
            if (consecutive >= 8) {
                return true;
            }
        }
    }
    return false;
}

fn prrintGrid(grid: [height][width]u64) void {
    for (grid) |row| {
        for (row) |cell| {
            if (cell > 0) {
                std.debug.print("{d}", .{cell});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();
    while (lines.next()) |line| {
        var coords = std.mem.tokenizeAny(u8, line, " pv=,");
        const x = try std.fmt.parseInt(i64, coords.next().?, 10);
        const y = try std.fmt.parseInt(i64, coords.next().?, 10);
        const vx = try std.fmt.parseInt(i64, coords.next().?, 10);
        const vy = try std.fmt.parseInt(i64, coords.next().?, 10);
        try robots.append(Robot{ .x = x, .y = y, .vx = vx, .vy = vy });
        // std.debug.print("{d} {d} {d} {d}\n", .{ px, py, vx, vy });
    }
    for (1..101) |_| {
        for (0..robots.items.len) |i| {
            const robot = robots.items[i];
            robots.items[i].x = @mod(robot.x + robot.vx, width);
            robots.items[i].y = @mod(robot.y + robot.vy, height);
        }
    }
    var quadrants: [4]u64 = [_]u64{0} ** 4;
    for (robots.items) |robot| {
        if (robot.x < width / 2 and robot.y < height / 2) {
            quadrants[0] += 1;
        } else if (robot.x > width / 2 and robot.y < height / 2) {
            quadrants[1] += 1;
        } else if (robot.x < width / 2 and robot.y > height / 2) {
            quadrants[2] += 1;
        } else if (robot.x > width / 2 and robot.y > height / 2) {
            quadrants[3] += 1;
        }
    }
    var part1: u64 = 1;
    for (quadrants) |q| {
        part1 *= q;
    }
    std.debug.print("Part 1: {d}\n", .{part1});

    var grid: [height][width]u64 = undefined;
    for (101..10000000) |j| {
        for (0..robots.items.len) |i| {
            const robot = robots.items[i];
            robots.items[i].x = @mod(robot.x + robot.vx, width);
            robots.items[i].y = @mod(robot.y + robot.vy, height);
        }
        // part 2
        grid = std.mem.zeroes([height][width]u64);
        for (robots.items) |robot| {
            grid[@intCast(robot.y)][@intCast(robot.x)] += 1;
        }
        if (heuristic(grid)) {
            prrintGrid(grid);
            std.debug.print("Part 2: {d}\n", .{j});
            break;
        }
    }
}
