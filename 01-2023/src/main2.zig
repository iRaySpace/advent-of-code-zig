const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const file = try std.fs.cwd().openFile("./res/input.txt", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    const reader = buffered.reader();

    var sigma_calibration_value: u32 = 0;
    while (true) {
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const calibration_value = try getCalibrationValue(line.items);
        sigma_calibration_value = sigma_calibration_value + calibration_value;
        line.clearRetainingCapacity();
    }

    try stdout.print("{}\n", .{sigma_calibration_value});
}

fn getCalibrationValue(items: []const u8) !u8 {
    var numbers: [2]u8 = .{ 0, 0 };
    for (items, 0..) |item, idx| {
        var number = item;
        const number_parsed = parseNumber(items[idx..items.len]);
        if (number_parsed != 0) {
            number = number_parsed;
        }
        if (!std.ascii.isDigit(number)) {
            continue;
        }
        if (numbers[0] == 0) {
            numbers[0] = number;
        }
        numbers[1] = number;
    }
    return try std.fmt.parseInt(u8, &numbers, 10);
}

fn parseNumber(items: []const u8) u8 {
    var count: u8 = 0;
    if (std.mem.indexOf(u8, items, "one") == 0) {
        count = '1';
    } else if (std.mem.indexOf(u8, items, "two") == 0) {
        count = '2';
    } else if (std.mem.indexOf(u8, items, "three") == 0) {
        count = '3';
    } else if (std.mem.indexOf(u8, items, "four") == 0) {
        count = '4';
    } else if (std.mem.indexOf(u8, items, "five") == 0) {
        count = '5';
    } else if (std.mem.indexOf(u8, items, "six") == 0) {
        count = '6';
    } else if (std.mem.indexOf(u8, items, "seven") == 0) {
        count = '7';
    } else if (std.mem.indexOf(u8, items, "eight") == 0) {
        count = '8';
    } else if (std.mem.indexOf(u8, items, "nine") == 0) {
        count = '9';
    }
    return count;
}
