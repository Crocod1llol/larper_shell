///the file that holds built in commands and the func that executes non-built in commands found in the file system
const std = @import("std");

const main = @import("main.zig");

///struct to bundle the args and the base command togheter
pub const command = struct {

    base_command: []const u8,
    args: []const u8,
};

///executes a builtin command's function, or if its short, the command itself
///returns a u8, 0 means sucess, 1 means failure of a builtin command, 
///and 2 will be command not found (and will be using 1 to then check with the system binary command)
pub fn exec_buildin(cmd: command, init: std.process.Init) !u8 {

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //yes, we will have to do the funny if else snake again
    //fuck this
    if (std.mem.eql(u8, cmd.base_command, "")) {

        return 0;
    } else if (std.mem.eql(u8, cmd.base_command, "exit")) {

        std.process.exit(0);
        return 0;
    } else if (std.mem.eql(u8, cmd.base_command, "hack")) {

        //TEMP: it will just print this
        try out_file.interface.print("hack\n", .{});
        try out_file.interface.flush();

        return 0;
    } else if (std.mem.eql(u8, cmd.base_command, "clear")) {

        //insert funny chars to clear the screen
        try out_file.interface.print("{c}[2J{c}[1;1H", .{27, 27});
        try out_file.interface.flush();

        return 0;
    } else if (std.mem.eql(u8, cmd.base_command, "cd")) {
        //change dir
        std.process.setCurrentPath(init.io, cmd.args) catch |err| {

            //if its a blank space, then ignore the error
            if (std.mem.eql(u8, cmd.args, "")) {

                return 0;
            }

            std.log.err("{}, had arguments: {s}", .{err, cmd.args});

            return 1;
        };

        return 0;
    } else if (std.mem.eql(u8, cmd.base_command, "pwd")) {

        _ = try main.give_cwd(init, true); 

        return 0;
    } else {
        //it completed with success ok bro?
        std.log.info("Command completed succesfully!", .{});

        return 2;
    }
}

///function to differentiate the base cmd and the args and combine them into a struct
pub fn parse_command(whole_line: []const u8) command {

    //create a struct that we are gonna return
    var ret_command: command = .{

        .base_command = "",
        .args = ",",
    };

    //first get the base command, and then extract the return types
    const trimArgs_return = main.trimArgs(whole_line, ' ');

    ret_command.base_command = trimArgs_return.trimmed_line;

    //if the base command is the same as the entire line, then just dont include args and your good
    if (std.mem.eql(u8, ret_command.base_command, whole_line)) {

        ret_command.args = "";
        return ret_command;
    }

    //now lemme get the iterator
    const iter1: usize =  trimArgs_return.iterator;

    ret_command.args = main.trimBase_command(whole_line, ' ', iter1);

    return ret_command;
}
