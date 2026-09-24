const std = @import("std");
const c = @cImport(

    @cInclude("unistd.h")
);

//import files
const commands = @import("commands.zig");

pub fn main(init: std.process.Init) !void {
    //setup stdout file handler to print
    var out_buf: [512]u8 = undefined;
    var output_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //stdin, obtain result from the user
    var stdin_buf: [512]u8 = undefined;
    var stdin_file = std.Io.File.reader(std.Io.File.stdin(), init.io, &stdin_buf);

    //print very super polite message
    try output_file.interface.print("Welcome to larper_shell!\n", .{});
    try output_file.interface.print("You are free to express your larping here!\n", .{});
    try output_file.interface.print("Pro tip: there are built-in commands to help express your larp!\n", .{});

    try output_file.interface.flush();

    //while
    while (true) {

        try output_file.interface.print("$ ", .{});
        try output_file.flush();

        const result = try stdin_file.interface.takeDelimiter('\n');

        //make zig take all the bytes except the unused ones, so we can compare strings
        const trimmed_result = result orelse break;

        if (try commands.exec_buildin(trimmed_result, init) == 255) {

            break;
        }
    }
}
