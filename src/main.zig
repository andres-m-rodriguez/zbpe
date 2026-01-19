const std = @import("std");
const Tokenizer = @import("./Tokens/Tokenizer.zig").Tokenizer;
const Vocabulary = @import("./Tokens/Vocabulary.zig");
const Encoder = @import("Tokens/Encoder.zig").Encoder;
const SpecialTokens = @import("Tokens/SpecialTokens.zig").SpecialTokens;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const text = "Hello world, name is andres!";
    var tokenizer = Tokenizer.init(text);

    var main_vocab = try Vocabulary.buildVocabulary(allocator, &tokenizer);
    defer main_vocab.deinit(allocator);

    var encoder = try Encoder.init(allocator, main_vocab.items);
    defer encoder.deinit(allocator);

    const text2 = "Hello my name is Andres!";
    var ids = try encoder.encode(allocator, text2);
    defer ids.deinit(allocator);

    var decoded_words = try encoder.decode(allocator, ids.items);
    defer decoded_words.denit(allocator);
    
    for(decoded_words.items) |word|{
        std.debug.print("{s},", .{word});
    }
}
