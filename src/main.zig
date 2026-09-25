const std = @import("std");

//import files
const commands = @import("commands.zig");

//da alligator
var debug_allocator = std.heap.DebugAllocator(.{}){};
const gpa = debug_allocator.allocator();

//global constants
const MAX_FILEPATH = 4096;

///a func to print or return the current working dir (cwd)
pub fn give_cwd(init: std.process.Init, will_print: bool) ![]u8 {

    //setup stdout buf is required
    var out_buf: [4096]u8 = undefined;
    var output_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //alloc memory so that it lasts long enough so i can return it
    const cwd_buf: *[MAX_FILEPATH]u8 = try gpa.create([MAX_FILEPATH]u8);

    //and because of that problem, i will free it later
    defer gpa.destroy(cwd_buf);


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

///a func that trims in a way so that the first word until the char stays
///useful for defining the base command
///its also very useful to return the i var, so ill make an anonymous struct1
pub fn trimArgs(line: []const u8, prefix_char: u8) struct {trimmed_line: []const u8, iterator: usize} {

    var i: usize = 0;
    while (i < line.len) {

        if (line[i] == prefix_char) { 
            break; 
        }

        i = i + 1;
    }
    
    //return line[0..i];
    return .{ .trimmed_line = line[0..i], .iterator = i, };
}

///a func that trims in a way so that the first work until the char is deleted
///useful for defining arguments
///also to take an iterator as an argument will be helpful for making args
///put 0 as iterator if you dont have any value
pub fn trimBase_command(line: []const u8, prefix_char: u8, iterator: usize) []const u8 {

    var i: usize = undefined;
    
    if (iterator == 0) {

        i = line.len - 1;
    } else {
        i = iterator;
    }

    while (i <= line.len) {

        if (line[i] == prefix_char) {
            break;
        }
        i = i - 1;
    }

    return line[i+1..line.len];
}

pub fn main(init: std.process.Init) !void {

    //fun fact: i have to defer something
    defer std.debug.assert(debug_allocator.deinit() == .ok);

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

        const command_given = commands.parse_command(trimmed_result);


        //check if the given command was a buildin command, else exec external command
        if (try commands.exec_buildin(command_given, init) == 2 ) {

        }

    }
}
