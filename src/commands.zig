//!the file that holds built in commands and the func that executes non-built in commands found in the file system
const std = @import("std");

const main = @import("main.zig");

///executes a builtin command's function, or if its short, the command itself
///returns a u8, 0 means sucess, 1 means failure of a builtin command, 
///and 2 will be command not found (and will be using 1 to then check with the system binary command)
pub fn exec_buildin(cmd: [] []const u8, init: std.process.Init) !u8 {

    //firstly check if the command given isnt an empty one so we exit before crashing :D
    //and because indexing crashes, just compare the string lenght
    if (cmd.len == 0) {
        return 0;
    }

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //alias
    const base_command = cmd[0];

    //yes, we will have to do the funny if else snake 
    //fuck this
    if (std.mem.eql(u8, base_command, "exit")) {

        std.process.exit(0);
        return 0;
    } else if (std.mem.eql(u8, base_command, "hack")) {

        //TEMP: it will just print this
        try out_file.interface.print("hack\n", .{});
        try out_file.interface.flush();

        return 0;
    } else if (std.mem.eql(u8, base_command, "clear")) {

        //insert funny chars to clear the screen
        try out_file.interface.print("{c}[2J{c}[1;1H", .{27, 27});
        try out_file.interface.flush();

        return 0;
    } else if (std.mem.eql(u8, base_command, "cd")) {
        //change dir
        std.process.setCurrentPath(init.io, cmd[1]) catch |err| {

            //if its a blank space, then ignore the error
            if (std.mem.eql(u8, cmd[1], "")) {

                return 0;
            }

            std.log.err("{}, had arguments: {s}", .{err, cmd[1]});

            return 1;
        };

        return 0;
    } else if (std.mem.eql(u8, base_command, "pwd")) {

        _ = try main.give_cwd(init, true); 

        return 0;
    } else {
        //if no built-in command was found, instruct to try to execute a binary on disk
        
        return 2;
    }
}

///execute the command on system (ex. /usr/bin/which)
pub fn exec_syscommand(cmd: [] []const u8, init: std.process.Init) !void {

    //spawn the child and let it rip (also inherit the standard output/input/err from parent to child so it writed to stdout directly)
    //also catch the error and return it so the program doesnt stop cause try ussualy kills a program from a error
    var child = std.process.spawn(init.io, .{ .argv = cmd, .stdout = .inherit, .stdin = .inherit, .stderr = .inherit}) catch |err| {

        std.log.err("{}, tried to run: {s}", .{err, cmd[0]});

        return;
    };

    //now wait for child to finish
    const wait = try child.wait(init.io);
    _ = wait;
}

///functio to tokenize a long string into smaller array of strings to be the base command and args
pub fn parse_command(whole_line: []const u8) [] []const u8 {

    //the string array we are gonna return
    var whole_command: [64][]const u8 = undefined;

    var count: usize = 0;

    //found out that zig has a func for tokenizing yayyyy
    //i dont have to build one myself :DDDD
    var iterator = std.mem.tokenizeScalar(u8, whole_line, ' ');

    //and then go to the next occurance of whitespace and tokenize it
    while (iterator.next()) |part| {
        //get out when max lenght reached
        if (count == whole_line.len) {
            break;
        }

        whole_command[count] = part;
        count += 1;
    }

    //and just retunr the spots in the array that are used
    return whole_command[0..count];
}
