const std = @import("std");
const tokeniz = @import("./Tokens/Tokenizer.zig");

pub fn main() !void {
    var tokenizer = tokeniz.Tokenizer.init("IdeaWeaver---,-a comprehensive CLI tool for AI model training and evaluation?");
    
    while (tokenizer.next()) |token| {
        std.debug.print("[{s}] ", .{token});
    }
    std.debug.print("\nConsumed: {d} bytes\n", .{tokenizer.consumed});
}
