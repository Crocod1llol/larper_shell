///the file that holds built in commands and the func that executes non-built in commands found in the file system

const std = @import("std");

///checks if a command is builtin or not, by comparing the string
pub fn check_builtin(command: []const u8) bool {

    //unfortunately we cant use switch, so the good ol 
    //unefficient if else if snake will be here

    if (std.mem.eql(u8, command, "hack")) {

        return true;
    } else if (std.mem.eql(u8, command, "exit")) {

        return true;
    } else {
        //if nothing matches, then it isnt a builtin command

        return false;
    }

}

//executes a builtin command
//^^^ make doc commment

//pub fn exec_buildin() !void {

//}

