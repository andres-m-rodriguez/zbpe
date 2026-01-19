const std = @import("std");
const Tokenizer = @import("./Tokens/Tokenizer.zig").Tokenizer;
const Vocabulary = @import("./Tokens/Vocabulary.zig");
const Encoder = @import("Tokens/Encoder.zig").Encoder;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    
    const text = "IdeaWeaver-- a comprehensive CLI tool for AI model training and evaluation?";
    
    // 1. Tokenize
    var tokenizer = Tokenizer.init(text);
    
    // 2. Build vocabulary
    var vocab = try Vocabulary.buildVocabulary(allocator, &tokenizer);
    defer vocab.deinit(allocator);
    
    // 3. Create encoder from vocab
    var encoder = try Encoder.init(allocator, vocab.items);
    defer encoder.deinit(allocator);
    
    // 4. Encode tokens → ids
    var ids = try encoder.encode(allocator, text);
    defer ids.deinit(allocator);
    
    std.debug.print("Encoded: ", .{});
    for (ids.items) |id| {
        std.debug.print("{d} ", .{id});
    }
    std.debug.print("\n", .{});
    
    // 5. Decode ids → text
    var decoded = try encoder.decode(allocator, ids.items);
    defer decoded.deinit(allocator);
    
    std.debug.print("Decoded: {s}\n", .{decoded.items});
}
