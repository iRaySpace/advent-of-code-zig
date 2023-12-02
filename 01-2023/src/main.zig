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
    for (items) |item| {
        if (!std.ascii.isDigit(item)) {
            continue;
        }
        if (numbers[0] == 0) {
            numbers[0] = item;
        }
        numbers[1] = item;
    }
    return try std.fmt.parseInt(u8, &numbers, 10);
}
