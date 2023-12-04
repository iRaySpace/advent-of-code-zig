const std = @import("std");
const print = std.debug.print;

const red_index = 0;
const red_max = 12;

const green_index = 1;
const green_max = 13;

const blue_index = 2;
const blue_max = 14;

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

    var sigma_game_no: u32 = 0;
    while (true) {
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        var game_no: u8 = 0;
        var game_items = std.mem.split(u8, line.items, ": ");
        while (game_items.next()) |x| {
            if (game_no == 0) {
                game_no = try getGameNo(x);
                continue;
            }
            const rgbCubes = try getRgbCubes(x);
            if (rgbCubes[red_index] <= red_max and rgbCubes[green_index] <= green_max and rgbCubes[blue_index] <= blue_max) {
                sigma_game_no += game_no;
            }
        }
        line.clearRetainingCapacity();
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{sigma_game_no});
}

fn getGameNo(items: []const u8) !u8 {
    const gameIndex = std.mem.indexOfDiff(u8, items, "Game ");
    var gameNo = items[gameIndex.?..items.len];
    return try std.fmt.parseInt(u8, gameNo, 10);
}

fn getRgbCubes(items: []const u8) ![3]u8 {
    var rgb = [_]u8{ 0, 0, 0 };
    var digits = [_]u8{ 0, 0, 0 };
    var digitIndex: u8 = 0;
    for (items) |item| {
        if (item == ' ') {
            continue;
        }
        if (std.ascii.isDigit(item)) {
            digits[digitIndex] = item;
            digitIndex += 1;
        } else if (!std.ascii.isDigit(item) and digitIndex > 0) {
            const number = try std.fmt.parseInt(u8, digits[0..digitIndex], 10);
            if (item == 'r' and number > rgb[0]) {
                rgb[0] = number;
            } else if (item == 'g' and number > rgb[1]) {
                rgb[1] = number;
            } else if (item == 'b' and number > rgb[2]) {
                rgb[2] = number;
            }
            digitIndex = 0;
        }
    }
    return rgb;
}
