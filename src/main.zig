const std = @import("std");
const Tokenizer = @import("./Tokens/Tokenizer.zig").Tokenizer;
const Vocabulary = @import("./Tokens/Vocabulary.zig");
const Encoder = @import("Tokens/Encoder.zig").Encoder;
const SpecialTokens = @import("Tokens/SpecialTokens.zig").SpecialTokens;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const text = "Hello world my, name is Andres!";
    var tokenizer = Tokenizer.init(text);

    var main_vocab = try Vocabulary.buildVocabulary(allocator, &tokenizer);
    defer main_vocab.deinit(allocator);

    var encoder = try Encoder.init(allocator, main_vocab.items);
    defer encoder.deinit(allocator);

    const text2 = "Hello my name is Andres!";
    var ids = try encoder.encode(allocator, text2);
    defer ids.deinit(allocator);
    for (ids.items) |id| {
    std.debug.print("{d} ", .{id});
}
std.debug.print("\n", .{});
    const decoded_word = try encoder.decode(allocator, ids.items);
    defer allocator.free(decoded_word);


    std.debug.print("{s}", .{decoded_word});
}
