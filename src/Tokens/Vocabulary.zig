const std = @import("std");
const tokeniz = @import("./Tokenizer.zig");
const SpecialTokens = @import("./SpecialTokens.zig").SpecialTokens;

pub fn buildVocabulary(allocator: std.mem.Allocator, tokenizer: *tokeniz.Tokenizer) !std.ArrayList([]const u8) {
    var unique = std.StringHashMapUnmanaged(void){};
    defer unique.deinit(allocator);

    while (tokenizer.next()) |token| {
        try unique.put(allocator, token, {});
    }

    var tokens = std.ArrayList([]const u8){};
    errdefer tokens.deinit(allocator);
    var it = unique.keyIterator();
    while (it.next()) |key| {
        try tokens.append(allocator, key.*);
    }

    std.mem.sort([]const u8, tokens.items, {}, compareStrings);

    return tokens;
}

fn compareStrings(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}

pub fn buildVocabularyWithSpecialTokens(allocator: std.mem.Allocator, tokenizer: *tokeniz.Tokenizer) !std.ArrayList([]const u8) {
    var vocab = try buildVocabulary(allocator, tokenizer);
    errdefer vocab.deinit(allocator);

    var result = std.ArrayList([]const u8){};
    errdefer result.deinit(allocator);

    for (SpecialTokens.ALL) |special| {
        try result.append(allocator, special);
    }

    for (vocab.items) |token| {
        try result.append(allocator, token);
    }

    vocab.deinit(allocator);
    return result;
}

pub fn addSpecialTokens(allocator: std.mem.Allocator, vocab: []const []const u8) !std.ArrayList([]const u8) {
    var result = std.ArrayList([]const u8){};
    errdefer result.deinit(allocator);

    for (SpecialTokens.ALL) |special| {
        try result.append(allocator, special);
    }

    for (vocab) |token| {
        if (!SpecialTokens.isSpecial(token)) {
            try result.append(allocator, token);
        }
    }

    return result;
}

test "buildVocabulary returns unique sorted tokens" {
    const allocator = std.testing.allocator;
    var tokenizer = tokeniz.Tokenizer.init("hello world hello");

    var vocab = try buildVocabulary(allocator, &tokenizer);
    defer vocab.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 2), vocab.items.len);
    try std.testing.expectEqualStrings("hello", vocab.items[0]);
    try std.testing.expectEqualStrings("world", vocab.items[1]);
}

test "buildVocabulary handles empty input" {
    const allocator = std.testing.allocator;
    var tokenizer = tokeniz.Tokenizer.init("");

    var vocab = try buildVocabulary(allocator, &tokenizer);
    defer vocab.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 0), vocab.items.len);
}

test "buildVocabularyWithSpecialTokens prepends special tokens" {
    const allocator = std.testing.allocator;
    var tokenizer = tokeniz.Tokenizer.init("hello world");

    var vocab = try buildVocabularyWithSpecialTokens(allocator, &tokenizer);
    defer vocab.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 4), vocab.items.len);
    try std.testing.expectEqualStrings("<|unk|>", vocab.items[0]);
    try std.testing.expectEqualStrings("<|endoftext|>", vocab.items[1]);
    try std.testing.expectEqualStrings("hello", vocab.items[2]);
    try std.testing.expectEqualStrings("world", vocab.items[3]);
}

test "addSpecialTokens avoids duplicates" {
    const allocator = std.testing.allocator;
    const existing = [_][]const u8{ "hello", "<|unk|>", "world" };

    var vocab = try addSpecialTokens(allocator, &existing);
    defer vocab.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 4), vocab.items.len);
    try std.testing.expectEqualStrings("<|unk|>", vocab.items[0]);
    try std.testing.expectEqualStrings("<|endoftext|>", vocab.items[1]);
    try std.testing.expectEqualStrings("hello", vocab.items[2]);
    try std.testing.expectEqualStrings("world", vocab.items[3]);
}
