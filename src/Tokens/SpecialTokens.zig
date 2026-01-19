const std = @import("std");

pub const SpecialTokens = struct {
    pub const UNK = "<|unk|>";
    pub const ENDOFTEXT = "<|endoftext|>";

    pub const ALL = [_][]const u8{
        UNK,
        ENDOFTEXT,
    };

    pub fn isSpecial(token: []const u8) bool {
        inline for (ALL) |special| {
            if (std.mem.eql(u8, token, special)) return true;
        }
        return false;
    }

    pub fn indexOf(token: []const u8) ?usize {
        inline for (ALL, 0..) |special, i| {
            if (std.mem.eql(u8, token, special)) return i;
        }
        return null;
    }
};

test "isSpecial identifies special tokens" {
    try std.testing.expect(SpecialTokens.isSpecial("<|unk|>"));
    try std.testing.expect(SpecialTokens.isSpecial("<|endoftext|>"));
    try std.testing.expect(!SpecialTokens.isSpecial("hello"));
    try std.testing.expect(!SpecialTokens.isSpecial("<unk>"));
}

test "indexOf returns correct indices" {
    try std.testing.expectEqual(@as(?usize, 0), SpecialTokens.indexOf("<|unk|>"));
    try std.testing.expectEqual(@as(?usize, 1), SpecialTokens.indexOf("<|endoftext|>"));
    try std.testing.expectEqual(@as(?usize, null), SpecialTokens.indexOf("hello"));
}
