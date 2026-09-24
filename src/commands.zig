///the file that holds built in commands and the func that executes non-built in commands found in the file system

const std = @import("std");

///executes a builtin command's function, or if its short, the command itself
///return a u8 of the state that the command sent 
///0 - completed with success, 1 - exited with failure, 255 - it requested to exit
pub fn exec_buildin(command: []const u8, init: std.process.Init) !u8 {

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //yes, we will have to do the funny if else snake again
    //fuck this
    if (std.mem.eql(u8, command, "")) {

        return 0;
    } else if (std.mem.eql(u8, command, "exit")) {

        //req to exit
        return 255;
    } else if (std.mem.eql(u8, command, "hack")) {

        //TEMP: it will just print this
        try out_file.interface.print("hack\n", .{});
        try out_file.interface.flush();

        return 0;
    } else if (std.mem.eql(u8, command, "clear")) {

        //insert funny chars to clear the screen
        try out_file.interface.print("{c}[2J{c}[1;1H", .{27, 27});
        try out_file.interface.flush();

        return 0;

    } else if (std.mem.eql(u8, command, "cd")) {

        return 0;
    } else {

        std.log.err("Unknown built-in command: {s}", .{command});

        //if nothing is matching, return 1
        return 1;
    }
}

