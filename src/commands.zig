//!the file that holds built in commands and the func that executes non-built in commands found in the file system
const std = @import("std");

const main = @import("main.zig");

///a struct to handle piped commands
pub const piped_command = struct {

    first_command: [][]const u8,
    second_command: [][]const u8,
};

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

        try exec_hack(init);

        return 0;

    } else if (std.mem.eql(u8, base_command, "green_text")) {

        try exec_green_text(init);

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

///just goes green text hacker style idk man larp as a hacker if you wish
fn exec_green_text(init: std.process.Init) !void {

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //stdin, obtain result from the user
    var stdin_buf: [512]u8 = undefined;
    var stdin_file = std.Io.File.reader(std.Io.File.stdin(), init.io, &stdin_buf);
    
    try out_file.interface.print("Every 1 million chars you can enter 'exit' or something else to continue\n", .{});
    try out_file.interface.flush();

    while (true) {
        const result = try stdin_file.interface.takeDelimiter('\n') orelse return;

        //checks if the user prompted to stop
        if (std.mem.eql(u8, result, "exit")) {
            break;
        }

        for (0..1000000) |i| {
            _ = i;

            try out_file.interface.print("436921874628374698713269847612987346912873468712683473259784612873649817623987461928734698172634987126984716328974612987436987", .{});
        }
        try out_file.interface.flush();
    }
}

///idk man "execute" hacking and by that i mean printing a bunch of text to larp
fn exec_hack(init: std.process.Init) !void {

    //make the output file interface for good measures
    var out_buf: [512]u8 = undefined;
    var out_file = std.Io.File.writer(std.Io.File.stdout(), init.io, &out_buf);

    //stdin, obtain result from the user
    var stdin_buf: [512]u8 = undefined;
    var stdin_file = std.Io.File.reader(std.Io.File.stdin(), init.io, &stdin_buf);

    //start
    try out_file.interface.print("H3llo wh0 do yoU w|sh to H#ck!?\n\n", .{});

    try out_file.interface.print("1 - l0c@l c0mputer\n", .{});
    try out_file.interface.print("2 - r3mote $erv3r\n", .{});
    try out_file.interface.print("3 - h@ack by Ip and |nj3ct malw@re\n", .{});
    try out_file.interface.print("4 - l3ave\n", .{});
    try out_file.interface.flush();

    //take in user input
    const result = try stdin_file.interface.takeDelimiter('\n');

    //make zig take all the bytes except the unused ones, so we can compare strings
    const trimmed_result = result orelse return;
    
    if (std.mem.eql(u8, trimmed_result, "1")) {

        try out_file.interface.print("l0ading into l0c@l c0mputer\n", .{});
        try out_file.interface.print("0bta1ning IP.. \n0bta1ning general information..\n0bta1ning m|sc info.. \n", .{});

        try out_file.interface.flush();

        //ok so the clock is weird
        //so std.Io.Clock.now(.awake. io) return the time it currently it
        //and .awake is some sort of stopwatch... i dont really understand
        try std.Io.sleep(init.io, .fromMilliseconds(2000), .awake);

        try out_file.interface.print("l0cal cOmputer pwn3d. injecting malware\n", .{});
        try out_file.interface.flush();

        try std.Io.sleep(init.io, .fromMilliseconds(5000), .awake);

        try out_file.interface.print("d0ne.\n", .{});
        try out_file.interface.flush();
    } else if (std.mem.eql(u8, trimmed_result, "2")) {

        try out_file.interface.print("l0ading tools to hack r3mote\n", .{});

        try out_file.interface.print("3nter target: ", .{});
        try out_file.interface.flush();

        const target_ip = try stdin_file.interface.takeDelimiter('\n') orelse return;

        try out_file.interface.print("@ttempt|ng pwning ip {s}\n", .{target_ip});
        try out_file.interface.flush();

        //pwn
        try std.Io.sleep(init.io, .fromMilliseconds(2500), .awake);

        try out_file.interface.print("r3mote s3rver h@cked, logged in.\n", .{});
        try out_file.interface.flush();
    }
    else if (std.mem.eql(u8, trimmed_result, "3")) {

        try out_file.interface.print("h@ck bY IP, 3nter t@rget:\n", .{});
        try out_file.interface.flush();

        //usr input
        const target_ip = try stdin_file.interface.takeDelimiter('\n') orelse return;

        try out_file.interface.print("t@rget: {s}. Attempting...\n", .{target_ip});
        try out_file.interface.flush();

        //pwn
        try std.Io.sleep(init.io, .fromMilliseconds(4000), .awake);

        try out_file.interface.print("t@rget: {s}. SUcCed3d. Injecting malware..\n", .{target_ip});
        try out_file.interface.flush();

        try std.Io.sleep(init.io, .fromMilliseconds(750), .awake);

        try out_file.interface.print("D0ne. t@rget sh0uld b3 w|ped.\n", .{});
        try out_file.interface.flush();

    } else {
        try out_file.interface.print("1nval|d opti0n\n", .{});
        try out_file.interface.flush();
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
///and if a pipe characted is detected, then run the parse_piped function
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

///splits the entire commmand line into before and after pipe commands
pub fn parse_piped(whole_line: []const u8) piped_command {
    //tokenize pipe

    //the string array we are gonna return
    var whole_command_separated: [64][]const u8 = undefined;

    var count: usize = 0;

    //tok the pipe
    var piper_iterator = std.mem.tokenizeScalar(u8, whole_line, '|');

    //and then go to the next occurance of whitespace and tokenize it
    while (piper_iterator.next()) |part| {
        if (count == whole_line.len) {
            break;
        }

        whole_command_separated[count] = part;
        count += 1;
    }
    //std.log.info("before pipe: {s}; after pipe: {s}\n", .{whole_command_separated[0], whole_command_separated[1]});


    //THE FIRST COMMAND PART
    var first_cmd: [64][]const u8 = undefined;

    var first_command_it = std.mem.tokenizeScalar(u8, whole_command_separated[0], ' ');

    while (first_command_it.next()) |part| {

        //get out when max lenght reached
        if (count == whole_command_separated[0].len) {
            break;
        }

        first_cmd[count] = part;
        count += 1;
    }

    //THE SECOND COMMAND
    var second_cmd: [64][]const u8 = undefined;

    var second_command_it = std.mem.tokenizeScalar(u8, whole_command_separated[0], ' ');

    while (second_command_it.next()) |part| {

        //get out when max lenght reached
        if (count == whole_command_separated[1].len) {
            break;
        }

        second_cmd[count] = part;
        count += 1;
    }

    //now return the all one command
    return .{
        //i dont think this will be a good idea, but ill see when i actually execute the piped command
        .first_command = &first_cmd,
        .second_command = &second_cmd,
    };
}
