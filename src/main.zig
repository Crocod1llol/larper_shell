const std = @import("std");

//import files
const commands = @import("commands.zig");

//nothing on this planet works 
//dfughkdfgksdlfhlgjdsfhlksghdlkfj sbh7g98rno,p9mvtc bm.o9<F7><F4>
//ce <F4>cghu\y6gbnhu<F7><F6>8<F5><F8><F4>57gnuo9-0<F8>=<F9><F7><F6>gthujo9<F6>8<F7><F8>yujoi<F10>\9<F7>6b vbhjytvmnuyc
//nj7thvnhjiohtvmloytghb
var debug_allocator = std.heap.DebugAllocator(.{}){};

const gpa = debug_allocator.allocator();

//const u32_ptr = try gpa.create(u32);
//_ = u32_ptr; // silences unused variable error

//global constants
const MAX_FILEPATH = 4096;

///a func to print or return the current working dir (cwd)
pub fn print_cwd(init: std.process.Init, will_print: bool) ![]u8 {

    //setup stdout buf is required
    var out_buf: [4096]u8 = undefined;
    var output_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //alloc memory so that it lasts long enough so i can return it
    const cwd_buf: *[MAX_FILEPATH]u8 = try gpa.create([MAX_FILEPATH]u8);

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

    //and because of that problem, i will free it later
    defer gpa.destroy(cwd_buf);

    return "";
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

        try output_file.interface.print("$ ", .{});
        try output_file.flush();

        const result = try stdin_file.interface.takeDelimiter('\n');

        //make zig take all the bytes except the unused ones, so we can compare strings
        const trimmed_result = result orelse break;

        //check if the shell has been asked to exit
        try commands.exec_buildin(trimmed_result, init);

    }
}
