const std = @import("std");
const Tokenizer = @import("./Tokens/Tokenizer.zig").Tokenizer;
const Vocabulary = @import("./Tokens/Vocabulary.zig");
const Encoder = @import("Tokens/Encoder.zig").Encoder;
const SpecialTokens = @import("Tokens/SpecialTokens.zig").SpecialTokens;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const text1 = "Hello world";
    const text2 = "Goodbye world";

    var tokenizer = Tokenizer.init(text1 ++ " " ++ text2);

    var vocab = try Vocabulary.buildVocabularyWithSpecialTokens(allocator, &tokenizer);
    defer vocab.deinit(allocator);

    std.debug.print("Vocabulary ({d} tokens):\n", .{vocab.items.len});
    for (vocab.items, 0..) |token, i| {
        std.debug.print("  {d}: {s}\n", .{ i, token });
    }

    var encoder = try Encoder.init(allocator, vocab.items);
    defer encoder.deinit(allocator);

    std.debug.print("\nSpecial token IDs:\n", .{});
    std.debug.print("  <|unk|>: {?d}\n", .{encoder.unk_id});
    std.debug.print("  <|endoftext|>: {?d}\n", .{encoder.endoftext_id});

    const texts = [_][]const u8{ text1, text2 };
    var ids = try encoder.encodeWithEndOfText(allocator, &texts);
    defer ids.deinit(allocator);

    std.debug.print("\nEncoded with <|endoftext|> separator:\n  ", .{});
    for (ids.items) |id| {
        std.debug.print("{d} ", .{id});
    }
    std.debug.print("\n", .{});

    var decoded = try encoder.decode(allocator, ids.items);
    defer decoded.deinit(allocator);

    std.debug.print("\nDecoded: {s}\n", .{decoded.items});

    std.debug.print("\nUnknown word handling:\n", .{});
    var unknown_ids = try encoder.encode(allocator, "Hello unknown_word world");
    defer unknown_ids.deinit(allocator);
    std.debug.print("  Input: \"Hello unknown_word world\"\n", .{});
    std.debug.print("  IDs: ", .{});
    for (unknown_ids.items) |id| {
        std.debug.print("{d} ", .{id});
    }
    std.debug.print("\n", .{});
}
