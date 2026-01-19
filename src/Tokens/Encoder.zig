const std = @import("std");
const Tokenizer = @import("Tokenizer.zig").Tokenizer;
pub const Encoder = struct {
    token_to_id: std.StringHashMapUnmanaged(u32),
    id_to_token: std.AutoHashMapUnmanaged(u32, []const u8),
    unknown_id: ?u32,

    pub fn init(allocator: std.mem.Allocator, vocab: []const []const u8) !Encoder {
        var token_to_id = std.StringHashMapUnmanaged(u32){};
        var id_to_token = std.AutoHashMapUnmanaged(u32, []const u8){};

        for (vocab, 0..) |token, i| {
            const id: u32 = @intCast(i);
            try token_to_id.put(allocator, token, id);
            try id_to_token.put(allocator, id, token);
        }

        return .{
            .token_to_id = token_to_id,
            .id_to_token = id_to_token,
            .unknown_id = token_to_id.get("<UNK>"),
        };
    }

    pub fn deinit(self: *Encoder, allocator: std.mem.Allocator) void {
        self.token_to_id.deinit(allocator);
        self.id_to_token.deinit(allocator);
    }

    pub fn encode(self: *const Encoder, allocator: std.mem.Allocator, text: []const u8) !std.ArrayList(u32) {
        var ids = std.ArrayList(u32){};
        var tokenizer = Tokenizer.init(text);
        while (tokenizer.next()) |token| {
            if (self.token_to_id.get(token)) |id| {
                try ids.append(allocator, id);
            } else if (self.unknown_id) |unk| {
                try ids.append(allocator, unk);
            }
        }
        return ids;
    }

    pub fn decode(self: *const Encoder, allocator: std.mem.Allocator, ids: []const u32) !std.ArrayList(u8) {
        var text = std.ArrayList(u8){};
        for (ids, 0..) |id, i| {
            if (self.id_to_token.get(id)) |token| {
                if (i > 0) try text.append(allocator, ' ');
                try text.appendSlice(allocator, token);
            }
        }
        return text;
    }
};
