const std = @import("std");
const tokeniz = @import("./Tokenizer.zig");

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
        try tokens.append(allocator,key.*);
    }

    std.mem.sort([]const u8, tokens.items, {}, compareStrings);

    return tokens;
}

fn compareStrings(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
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
