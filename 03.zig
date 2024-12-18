const std = @import("std");
const input = @embedFile("input/03.txt");

fn paseOperands(string: []const u8, i: *usize) ?[2]u64 {
    while (std.ascii.isDigit(string[i.*])) {
        i.* += 1;
    }
    const first = std.fmt.parseInt(u64, string[0..i.*], 10) catch return null;
    if (string[i.*] != ',') {
        return null;
    }
    i.* += 1;
    const split = i.*;
    while (std.ascii.isDigit(string[i.*])) {
        i.* += 1;
    }
    if (string[i.*] != ')') {
        return null;
    }
    const second = std.fmt.parseInt(u64, string[split..i.*], 10) catch return null;
    return .{ first, second };
}

pub fn main() !void {
    var part1: u64 = 0;
    var part2: u64 = 0;
    var i: usize = 0;
    var enabled: bool = true;
    while (i < input.len - 6) {
        if (std.mem.eql(u8, input[i..(i + 4)], "mul(")) {
            var n: usize = 0;
            if (paseOperands(input[(i + 4)..], &n)) |ops| {
                const result = ops[0] * ops[1];
                part1 += result;
                if (enabled) {
                    part2 += result;
                }
            }
            i += n;
        } else {
            if (std.mem.eql(u8, input[i..(i + 4)], "do()")) {
                enabled = true;
            } else if (std.mem.eql(u8, input[i..(i + 7)], "don't()")) {
                enabled = false;
            }
            i += 1;
        }
    }
    std.debug.print("{d}\n{d}\n", .{ part1, part2 });
}
