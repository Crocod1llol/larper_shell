///the file that holds built in commands and the func that executes non-built in commands found in the file system
const std = @import("std");

const main = @import("main.zig");

///executes a builtin command's function, or if its short, the command itself
pub fn exec_buildin(command: []const u8, init: std.process.Init) !void {

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //yes, we will have to do the funny if else snake again
    //fuck this
    if (std.mem.eql(u8, command, "")) {

    } else if (std.mem.eql(u8, command, "exit")) {

        std.process.exit(0);
    } else if (std.mem.eql(u8, command, "hack")) {

        //TEMP: it will just print this
        try out_file.interface.print("hack\n", .{});
        try out_file.interface.flush();

    } else if (std.mem.eql(u8, command, "clear")) {

        //insert funny chars to clear the screen
        try out_file.interface.print("{c}[2J{c}[1;1H", .{27, 27});
        try out_file.interface.flush();


    } else if (std.mem.eql(u8, command, "cd")) {


    } else if (std.mem.eql(u8, command, "pwd")) {

        _ = try main.print_cwd(init, true); 
    } else {
        //it completed with success ok bro?
        std.log.info("Command completed succesfully!", .{});
    }
}

