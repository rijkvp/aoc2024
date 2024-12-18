const std = @import("std");
const input = @embedFile("input/15.txt");
const map_size = calcMapSize();
const alloc = std.heap.page_allocator;

const Cell = enum {
    Empty,
    Wall,
    Box,
    Robot,
    BoxL,
    BoxR,
};

const Move = enum {
    Up,
    Down,
    Left,
    Right,
};

fn calcMapSize() usize {
    @setEvalBranchQuota(100000);
    var parts = std.mem.tokenizeSequence(u8, input, "\n\n");
    const map_input2 = parts.next().?;
    return std.mem.indexOfScalar(u8, map_input2, '\n').?;
}

fn readMap(
    map_input: []const u8,
) [map_size][map_size]Cell {
    var map: [map_size][map_size]Cell = std.mem.zeroes([map_size][map_size]Cell);
    var lines = std.mem.tokenizeScalar(u8, map_input, '\n');
    var r: usize = 0;
    while (lines.next()) |line| {
        if (r >= map_size) {
            break;
        }
        for (line, 0..) |char, c| {
            const cell = switch (char) {
                '.' => Cell.Empty,
                '#' => Cell.Wall,
                'O' => Cell.Box,
                '@' => Cell.Robot,
                else => unreachable,
            };
            map[r][c] = cell;
        }
        r += 1;
    }
    return map;
}

fn printMap(map: [map_size][map_size]Cell) void {
    for (0..map_size) |r| {
        for (0..map_size) |c| {
            const cell: Cell = map[r][c];
            const char: u8 = switch (cell) {
                .Empty => '.',
                .Wall => '#',
                .Box => 'O',
                .Robot => '@',
                else => return,
            };
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
}

fn printEnlargedMap(map: [map_size][map_size * 2]Cell) void {
    for (0..map_size) |r| {
        for (0..map_size * 2) |c| {
            const cell: Cell = map[r][c];
            const char: u8 = switch (cell) {
                .Empty => '.',
                .Wall => '#',
                .Robot => '@',
                .BoxL => '[',
                .BoxR => ']',
                else => unreachable,
            };
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
}

fn readMoves(moves_input: []const u8) !std.ArrayList(Move) {
    var moves = std.ArrayList(Move).init(alloc);
    for (moves_input) |char| {
        if (char == '\n') {
            continue;
        }
        const move = switch (char) {
            '^' => Move.Up,
            'v' => Move.Down,
            '<' => Move.Left,
            '>' => Move.Right,
            else => unreachable,
        };
        try moves.append(move);
    }
    return moves;
}

pub fn movePos(move: Move, row: usize, col: usize, comptime height: usize, comptime width: usize) ?[2]usize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    const pos: [2]isize = switch (move) {
        Move.Up => .{ r - 1, c },
        Move.Right => .{ r, c + 1 },
        Move.Down => .{ r + 1, c },
        Move.Left => .{ r, c - 1 },
    };
    if (pos[0] < 0 or pos[0] >= height or pos[1] < 0 or pos[1] >= width) {
        return null;
    }
    return .{ @intCast(pos[0]), @intCast(pos[1]) };
}

fn simulate(map: *[map_size][map_size]Cell, moves: []Move) void {
    var robot_r: usize = 0;
    var robot_c: usize = 0;
    for (0..map_size) |r| {
        for (0..map_size) |c| {
            if (map[r][c] == Cell.Robot) {
                robot_r = r;
                robot_c = c;
                break;
            }
        }
    }

    for (moves) |move| {
        if (movePos(move, robot_r, robot_c, map_size, map_size)) |start| {
            var current: [2]usize = start;
            var possible = false;
            var end: [2]usize = undefined;
            while (true) {
                const cell = map[current[0]][current[1]];
                if (cell == Cell.Wall) {
                    break;
                } else if (cell == Cell.Empty) {
                    end = current;
                    possible = true;
                    break;
                }

                // next cell
                current = movePos(move, current[0], current[1], map_size, map_size) orelse break;
            }
            if (possible) {
                if (start[0] != end[0] or start[1] != end[1]) {
                    // move boxes
                    current = start;
                    while (true) {
                        current = movePos(move, current[0], current[1], map_size, map_size).?;
                        map[current[0]][current[1]] = Cell.Box;
                        if (current[0] == end[0] and current[1] == end[1]) {
                            break;
                        }
                    }
                }
                // move robot
                map[robot_r][robot_c] = Cell.Empty;
                robot_r = start[0];
                robot_c = start[1];
                map[robot_r][robot_c] = Cell.Robot;
            }
        }
    }
}

fn enlarge(map: [map_size][map_size]Cell) [map_size][2 * map_size]Cell {
    var new_map: [map_size][2 * map_size]Cell = undefined;
    for (0..map_size) |r| {
        for (0..map_size) |c| {
            const replacement = switch (map[r][c]) {
                Cell.Empty => .{ Cell.Empty, Cell.Empty },
                Cell.Wall => .{ Cell.Wall, Cell.Wall },
                Cell.Box => .{ Cell.BoxL, Cell.BoxR },
                Cell.Robot => .{ Cell.Robot, Cell.Empty },
                else => unreachable,
            };
            new_map[r][c * 2] = replacement[0];
            new_map[r][c * 2 + 1] = replacement[1];
        }
    }
    return new_map;
}

fn printAffected(affected: [map_size][2 * map_size]bool) void {
    for (0..map_size) |r| {
        for (0..map_size * 2) |c| {
            const char: u8 = if (affected[r][c]) 'X' else '.';
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
}

fn overlaps(map: *[map_size][2 * map_size]Cell, affected: [map_size][2 * map_size]bool, offset: [2]isize) bool {
    for (0..map_size) |r| {
        for (0..map_size * 2) |c| {
            var r2: isize = @intCast(r);
            var c2: isize = @intCast(c);
            r2 += offset[0];
            c2 += offset[1];
            if (r2 < 0 or r2 >= map_size or c2 < 0 or c2 >= map_size * 2) {
                std.debug.print("Out of bounds at {d} {d}\n", .{ r, c });
                return true;
            }
            if (affected[r][c] and !affected[@intCast(r2)][@intCast(c2)] and map[@intCast(r2)][@intCast(c2)] == Cell.Wall) {
                std.debug.print("Overlap at {d} {d}\n", .{ r, c });
                return true;
            }
        }
    }
    return false;
}

fn simulate2(map: *[map_size][2 * map_size]Cell, moves: []Move) !void {
    var robot_r: usize = 0;
    var robot_c: usize = 0;
    for (0..map_size) |r| {
        for (0..map_size * 2) |c| {
            if (map[r][c] == Cell.Robot) {
                robot_r = r;
                robot_c = c;
                break;
            }
        }
    }

    var affected: [map_size][2 * map_size]bool = undefined;
    printEnlargedMap(map.*);
    for (moves) |move| {
        if (movePos(move, robot_r, robot_c, map_size, 2 * map_size)) |start| {
            affected = std.mem.zeroes([map_size][2 * map_size]bool);
            var stack = std.ArrayList([2]usize).init(alloc);
            try stack.append(start);
            const offset: [2]isize = switch (move) {
                Move.Up => .{ -1, 0 },
                Move.Right => .{ 0, 1 },
                Move.Down => .{ 1, 0 },
                Move.Left => .{ 0, -1 },
            };
            while (stack.popOrNull()) |pos| {
                if (affected[pos[0]][pos[1]]) {
                    continue;
                }
                const cell = map[pos[0]][pos[1]];
                if (cell == Cell.Wall) {
                    continue;
                } else if (cell == Cell.BoxL or cell == Cell.BoxR) {
                    affected[pos[0]][pos[1]] = true;
                    if (move == Move.Left or move == Move.Right) {
                        if (movePos(move, pos[0], pos[1], map_size, 2 * map_size)) |next| {
                            try stack.append(next);
                        }
                    }
                }
            }
            std.debug.print("Move {any}\n", .{move});
            printAffected(affected);
            if (!overlaps(map, affected, offset)) {
                std.debug.print("No overlap!\n", .{});
                // move all effected cells with offset
                for (0..map_size) |r| {
                    for (0..map_size * 2) |c| {
                        if (affected[r][c]) {
                            const cell = map[r][c];
                            map[r][c] = Cell.Empty;
                            var r2: isize = @intCast(r);
                            var c2: isize = @intCast(c);
                            r2 += offset[0];
                            c2 += offset[1];
                            map[@intCast(r2)][@intCast(c2)] = cell;
                        }
                    }
                }
                // move robot
                map[robot_r][robot_c] = Cell.Empty;
                robot_r = start[0];
                robot_c = start[1];
                map[robot_r][robot_c] = Cell.Robot;
                printEnlargedMap(map.*);
            }
        }
    }
}

fn sumGps(map: [map_size][map_size]Cell) usize {
    var sum: usize = 0;
    for (0..map_size) |r| {
        for (0..map_size) |c| {
            if (map[r][c] == Cell.Box) {
                sum += 100 * r + c;
            }
        }
    }
    return sum;
}

pub fn main() !void {
    var parts = std.mem.tokenizeSequence(u8, input, "\n\n");
    const map_input = parts.next().?;
    var map = readMap(map_input);
    var enlarged_map = enlarge(map);
    const moves_input = parts.next().?;
    const moves = try readMoves(moves_input);
    defer moves.deinit();

    simulate(&map, moves.items);
    printMap(map);
    const part1 = sumGps(map);
    std.debug.print("{d}\n", .{part1});
    try simulate2(&enlarged_map, moves.items);
    const part2 = sumGps(map);
    std.debug.print("{d}\n", .{part2});
}
