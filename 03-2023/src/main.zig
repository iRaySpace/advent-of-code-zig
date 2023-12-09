const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var line = std.ArrayList(u8).init(gpa.allocator());
    defer line.deinit();

    const file = try std.fs.cwd().openFile("./res/input.txt", .{});
    defer file.close();

    var line_count: usize = 0;
    var buffered = std.io.bufferedReader(file.reader());
    const reader = buffered.reader();
    while (true) {
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (line_count == 0) {
            line_count = line.items.len;
        }
    }

    const total_part_numbers = try getTotalPartNumbers(line.items, line_count);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{total_part_numbers});
}

fn getTotalPartNumbers(items: []const u8, line_count: usize) !u32 {
    var total_part_numbers: u32 = 0;
    var digits: u8 = 0;
    var is_part_number = false;
    for (items, 0..) |item, idx| {
        const row = idx / line_count;
        const col = idx % line_count;
        if (std.ascii.isDigit(item)) {
            digits = digits + 1;
            if (!is_part_number) {
                is_part_number = is_part_number or isPartNumberTop(row, idx, line_count, items);
                is_part_number = is_part_number or isPartNumberRight(col, line_count, idx, items);
                is_part_number = is_part_number or isPartNumberBottom(row, line_count, items.len, idx, items);
                is_part_number = is_part_number or isPartNumberLeft(col, idx, items);
                is_part_number = is_part_number or isPartNumberTopRight(row, col, line_count, idx, items);
                is_part_number = is_part_number or isPartNumberBottomRight(row, line_count, items.len, col, idx, items);
                is_part_number = is_part_number or isPartNumberBottomLeft(row, line_count, items.len, col, idx, items);
                is_part_number = is_part_number or isPartNumberTopLeft(row, col, idx, line_count, items);
            }
        } else if (digits > 0 and !std.ascii.isDigit(item)) {
            if (is_part_number) {
                const part_number = try std.fmt.parseInt(u32, items[idx - digits .. idx], 10);
                total_part_numbers = total_part_numbers + part_number;
            }
            digits = 0;
            is_part_number = false;
        }
        if (digits > 0 and col == line_count - 1) {
            if (is_part_number) {
                const offset = 1;
                const part_number = try std.fmt.parseInt(u32, items[idx - digits + offset .. idx + offset], 10);
                total_part_numbers = total_part_numbers + part_number;
            }
            digits = 0;
            is_part_number = false;
        }
    }
    return total_part_numbers;
}

fn isPartNumberLeft(col: usize, idx: usize, items: []const u8) bool {
    if (col == 0) {
        return false;
    }
    const prev_item = items[idx - 1];
    return isPart(prev_item);
}

fn isPartNumberRight(col: usize, line_count: usize, idx: usize, items: []const u8) bool {
    if (col == line_count - 1) {
        return false;
    }
    const next_item = items[idx + 1];
    return isPart(next_item);
}

fn isPartNumberTop(row: usize, idx: usize, line_count: usize, items: []const u8) bool {
    if (row == 0) {
        return false;
    }
    const prev_item = items[idx - line_count];
    return isPart(prev_item);
}

fn isPartNumberTopLeft(row: usize, col: usize, idx: usize, line_count: usize, items: []const u8) bool {
    if (row == 0) {
        return false;
    }
    if (col == 0) {
        return false;
    }
    const prev_item = items[idx - line_count - 1];
    return isPart(prev_item);
}

fn isPartNumberTopRight(row: usize, col: usize, line_count: usize, idx: usize, items: []const u8) bool {
    if (row == 0) {
        return false;
    }
    if (col == line_count - 1) {
        return false;
    }
    const next_item = items[idx - line_count + 1];
    return isPart(next_item);
}

fn isPartNumberBottom(row: usize, line_count: usize, items_len: usize, idx: usize, items: []const u8) bool {
    if (row * line_count == items_len - line_count) {
        return false;
    }
    const next_item = items[idx + line_count];
    return isPart(next_item);
}

fn isPartNumberBottomLeft(row: usize, line_count: usize, items_len: usize, col: usize, idx: usize, items: []const u8) bool {
    if (row * line_count == items_len - line_count) {
        return false;
    }
    if (col == 0) {
        return false;
    }
    const prev_item = items[idx + line_count - 1];
    return isPart(prev_item);
}

fn isPartNumberBottomRight(row: usize, line_count: usize, items_len: usize, col: usize, idx: usize, items: []const u8) bool {
    if (row * line_count == items_len - line_count) {
        return false;
    }
    if (col == line_count - 1) {
        return false;
    }
    const next_item = items[idx + line_count + 1];
    return isPart(next_item);
}

fn isPart(item: u8) bool {
    return !std.ascii.isDigit(item) and item != '.';
}
