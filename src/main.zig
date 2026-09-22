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

    //while
    while (true) {

        const result = try stdin_file.interface.takeDelimiter('\n');

        //make zig take all the bytes except the unused ones, so we can compare strings
        const trimmed_result = result orelse break;

        //check if its "exit" so we exit
        //TEMP: will have a special func to execute builtin commands
        if (std.mem.eql(u8, trimmed_result, "exit")) {
            break;
        }

        //TEMP: we just print the text
        //handle the null case cause zig compiler tells me to
        if (result) |resultV2| {

            //if its not, then print the normal value
            try output_file.interface.print("{s}\n", .{resultV2});
        } else {

            //if it is, then handle it
            try output_file.interface.print("Error: somehow you tricked the program into not taking even the newline char, good job\n", .{});
            try output_file.interface.flush();
            
            std.process.exit(1);
        }
    
        try output_file.interface.flush();
    }
}
