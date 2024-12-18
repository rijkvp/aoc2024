const std = @import("std");
const input = @embedFile("input");
const alloc = std.heap.page_allocator;

fn readRegisters(register_input: []const u8) ![3]i64 {
    var lines = std.mem.tokenizeScalar(u8, register_input, '\n');
    var idx: usize = 0;
    var registers: [3]i64 = undefined;
    while (lines.next()) |line| {
        var it = std.mem.tokenizeSequence(u8, line, ": ");
        _ = it.next().?;
        const str = it.next().?;
        const value = try std.fmt.parseInt(i64, str, 10);
        registers[idx] = value;
        idx += 1;
    }
    return registers;
}

fn readInstructions(instruction_input: []const u8) !std.ArrayList(u3) {
    var instructions = std.ArrayList(u3).init(alloc);
    var sep = std.mem.tokenizeSequence(u8, instruction_input, ": ");
    _ = sep.next().?;
    const str = sep.next().?;
    var it = std.mem.tokenizeAny(u8, str, ",\n");
    while (it.next()) |num_str| {
        const num = try std.fmt.parseInt(u3, num_str, 10);
        try instructions.append(num);
    }
    return instructions;
}

// calculates a / (2^b)
inline fn divpow2(a: i64, b: i64) i64 {
    if (b > 63) {
        return 0;
    }
    return a >> @intCast(b);
}

fn emulate(instructions: []const u3, register_values: [3]i64) !std.ArrayList(u3) {
    var ip: usize = 0;
    var output = std.ArrayList(u3).init(alloc);
    var registers: [3]i64 = register_values;
    while (ip < instructions.len) {
        const opcode = instructions[ip];
        const literal_operand = instructions[ip + 1];
        const combo_operand: ?i64 = switch (literal_operand) {
            0...3 => literal_operand,
            4 => registers[0],
            5 => registers[1],
            6 => registers[2],
            7 => null,
        };
        var jumped = false;
        switch (opcode) {
            0 => registers[0] = divpow2(registers[0], combo_operand.?),
            1 => registers[1] ^= literal_operand,
            2 => registers[1] = @mod(combo_operand.?, 8),
            3 => if (registers[0] != 0) {
                ip = @intCast(literal_operand);
                jumped = true;
            },
            4 => registers[1] ^= registers[2],
            5 => try output.append(@intCast(@mod(combo_operand.?, 8))),
            6 => registers[1] = divpow2(registers[0], combo_operand.?),
            7 => registers[2] = divpow2(registers[0], combo_operand.?),
        }
        if (!jumped) {
            ip += 2;
        }
    }
    return output;
}

fn printOutput(output: []const u3) void {
    for (output, 0..) |out, i| {
        std.debug.print("{d}", .{out});
        if (i < output.len - 1) {
            std.debug.print(",", .{});
        }
    }
    std.debug.print("\n", .{});
}

// Recursively finds the value of register A that will make the program
// output the last instruction
// The program depends on A mod 8, and devides by 8 each iteration:
// we try all offsets of 8 * A + k that produce the desired output
fn find_rega_value(i: usize, current: u64, instructions: []const u3) !?u64 {
    if (i == instructions.len) {
        return current;
    }
    for (0..8) |k| {
        const reg_a = 8 * current + @as(u64, k);
        const output = try emulate(instructions, .{ @intCast(reg_a), 0, 0 });
        defer output.deinit();
        if (output.items[0] == instructions[instructions.len - i - 1]) {
            return try find_rega_value(i + 1, reg_a, instructions) orelse continue;
        }
    }
    return null;
}

pub fn main() !void {
    var parts = std.mem.tokenizeSequence(u8, input, "\n\n");
    const register_input = parts.next().?;
    const registers = try readRegisters(register_input);
    const instruction_input = parts.next().?;
    const instructions = try readInstructions(instruction_input);
    defer instructions.deinit();

    // part 1
    const output = try emulate(instructions.items, registers);
    defer output.deinit();
    printOutput(output.items);
    // part 2
    const reg_a = try find_rega_value(0, 0, instructions.items);
    std.debug.print("{d}\n", .{reg_a.?});
}
