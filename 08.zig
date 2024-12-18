const std = @import("std");
const input = @embedFile("input/08.txt");
const allocator = std.heap.page_allocator;
const GRID_SIZE: usize = 50;
const FREQS: usize = 62; // 0-9, A-Z, a-z

fn mapChar(ch: u8) ?u8 {
    return switch (ch) {
        '0'...'9' => ch - '0',
        'A'...'Z' => ch - 'A' + 10,
        'a'...'z' => ch - 'a' + 36,
        else => null,
    };
}

const Point = struct {
    x: i64,
    y: i64,
};

fn inBounds(p: Point) bool {
    return p.x >= 0 and p.x < GRID_SIZE and p.y >= 0 and p.y < GRID_SIZE;
}

fn parseInput(antennas: *[FREQS]std.ArrayList(Point)) !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= GRID_SIZE) {
            break;
        }
        for (line, 0..GRID_SIZE) |char, c| {
            if (mapChar(char)) |idx| {
                const point = Point{ .x = @intCast(c), .y = @intCast(r) };
                try antennas[idx].append(point);
            }
        }
        r += 1;
    }
}
pub fn main() !void {
    var antennas: [FREQS]std.ArrayList(Point) = undefined;
    for (0..FREQS) |idx| {
        antennas[idx] = std.ArrayList(Point).init(allocator);
    }

    try parseInput(&antennas);

    var part1: u64 = 0;
    var part2: u64 = 0;
    var antinodes: [GRID_SIZE][GRID_SIZE]bool = std.mem.zeroes([GRID_SIZE][GRID_SIZE]bool);
    var antinodes2: [GRID_SIZE][GRID_SIZE]bool = std.mem.zeroes([GRID_SIZE][GRID_SIZE]bool);
    for (0..FREQS) |idx| {
        const list = antennas[idx];
        for (0..list.items.len) |i| {
            for (i + 1..list.items.len) |j| {
                var a = list.items[i];
                var b = list.items[j];
                const dx = b.x - a.x;
                const dy = b.y - a.y;
                // part 1
                const c = Point{ .x = a.x - dx, .y = a.y - dy };
                const d = Point{ .x = b.x + dx, .y = b.y + dy };
                if (inBounds(c)) {
                    antinodes[@intCast(c.y)][@intCast(c.x)] = true;
                }
                if (inBounds(d)) {
                    antinodes[@intCast(d.y)][@intCast(d.x)] = true;
                }
                // part 2
                while (inBounds(a)) {
                    antinodes2[@intCast(a.y)][@intCast(a.x)] = true;
                    a.x -= dx;
                    a.y -= dy;
                }
                while (inBounds(b)) {
                    antinodes2[@intCast(b.y)][@intCast(b.x)] = true;
                    b.x += dx;
                    b.y += dy;
                }
            }
        }
    }

    for (0..GRID_SIZE) |y| {
        for (0..GRID_SIZE) |x| {
            if (antinodes[y][x]) {
                part1 += 1;
            }
            if (antinodes2[y][x]) {
                part2 += 1;
            }
        }
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});

    for (0..FREQS) |idx| {
        defer antennas[idx].deinit();
    }
}
