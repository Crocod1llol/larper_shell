const std = @import("std");

//import files
const commands = @import("commands.zig");

//da alligator
var allocator = std.heap.page_allocator;

//global constants
const MAX_FILEPATH = 4096;

///a func to print or return the current working dir (cwd)
pub fn give_cwd(init: std.process.Init, will_print: bool) ![]u8 {

    //setup stdout buf is required
    var out_buf: [4096]u8 = undefined;
    var output_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //alloc memory so that it lasts long enough so i can return it
    const cwd_buf: *[MAX_FILEPATH]u8 = try allocator.create([MAX_FILEPATH]u8);

    //and because of that problem, i will free it later
    defer allocator.destroy(cwd_buf);


    const status = std.os.linux.getcwd(cwd_buf, MAX_FILEPATH);

    //check if it failed
    if (status == 0) {

        std.log.err("getcwd linux sys call failed", .{});
    }

    //apperently status returns how many chars does a filepath have, so cool ig
    const trimmed_cwd_buf = cwd_buf.*[0..status];

    if (will_print) {

        try output_file.interface.print("{s}\n", .{trimmed_cwd_buf});
        try output_file.interface.flush();

        return "";
    } else {

        return trimmed_cwd_buf;
    }

    return "";
}


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

        try output_file.interface.print("# ", .{});
        try output_file.flush();

        const result = try stdin_file.interface.takeDelimiter('\n');

        //make zig take all the bytes except the unused ones, so we can compare strings
        const trimmed_result = result orelse break;

        //make vars for 
        var command_given_piped: commands.piped_command = undefined;
        var command_given: [][]const u8 = undefined;

        var is_pipe: bool = false;
        //also check if theres a pipe
        for (0..trimmed_result.len) |i| {
            if (trimmed_result[i] == '|') {
                is_pipe = true;
            }
        }

        if (is_pipe) {

            command_given_piped = commands.parse_piped(trimmed_result);
        } else {

            command_given = commands.parse_command(trimmed_result);
        }

        if (is_pipe) {
            //TEMP:: WIL HAVE A FUNC TO EXEC PIPED COMMANDS
        } else {
            //check if the given command was a buildin command, else exec external command
            if (try commands.exec_buildin(command_given, init) == 2 ) {

                try commands.exec_syscommand(command_given, init);
            }
        }

    }
}
