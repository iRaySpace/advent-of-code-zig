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

    processItems(line.items, line_count);
}

fn processItems(items: []const u8, line_count: usize) void {
    var is_digit = false;
    var digits: u8 = 0;
    for (items, 0..) |item, idx| {
        if (std.ascii.isDigit(item)) {
            is_digit = true;
            digits = digits + 1;
        }
        if (is_digit and !std.ascii.isDigit(item)) {
            is_digit = false;
            _ = isPartNumber(idx, digits, items, line_count);
            digits = 0;
        }
    }
}

fn isPartNumber(idx: usize, digits: u8, items: []const u8, line_count: usize) bool {
    // TODO: top and bottom
    var is_part_number = false;
    const first_digit_idx = idx - digits;
    // left
    if (first_digit_idx > 0 and items[first_digit_idx - 1] != '.') {
        is_part_number = true;
    }
    // right
    if (items[idx] != '.') {
        is_part_number = true;
    }
    // top
    const row_idx = idx / line_count;
    if (row_idx > 0) {
        var digit_idx: u8 = 0;
        while (digit_idx <= digits + 1) {
            const item_idx = idx - digit_idx;
            if (item_idx < (line_count * row_idx)) {
                break;
            }
            const top_idx = item_idx - line_count;
            if (items[top_idx] != '.') {
                is_part_number = true;
                break;
            }
            digit_idx = digit_idx + 1;
        }
    }
    // bottom
    print("{}", .{is_part_number});
    return is_part_number;
}
