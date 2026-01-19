const std = @import("std");

pub const TokenizerState = enum {
    scanning,
    in_word,
    in_run,
};

pub const Tokenizer = struct {
    text: []const u8,
    pos: usize,
    start: usize,
    state: TokenizerState,
    consumed: usize,

    pub fn init(text: []const u8) Tokenizer {
        return .{
            .text = text,
            .pos = 0,
            .start = 0,
            .state = .scanning,
            .consumed = 0,
        };
    }

    pub fn next(self: *Tokenizer) ?[]const u8 {
        while (self.pos < self.text.len) {
            const byte = self.text[self.pos];

            switch (self.state) {
                .scanning => {
                    if (isWhiteSpace(byte)) {
                        self.pos += 1;
                        self.consumed += 1;
                        continue;
                    }
                    if (isDelimiter(byte)) {
                        const token = self.text[self.pos .. self.pos + 1];
                        self.pos += 1;
                        self.consumed += 1;
                        return token;
                    }
                    if (isPossibleNonScalar(byte)) {
                        self.start = self.pos;
                        self.state = .in_run;
                        self.pos += 1;
                        continue;
                    }
                    // Start of word
                    self.start = self.pos;
                    self.state = .in_word;
                    self.pos += 1;
                },

                .in_word => {
                    if (isWhiteSpace(byte) or isDelimiter(byte) or isPossibleNonScalar(byte)) {
                        const token = self.text[self.start..self.pos];
                        self.consumed += token.len;
                        self.state = .scanning;
                        return token;
                    }
                    self.pos += 1;
                },

                .in_run => {
                    if (byte == self.text[self.start]) {
                        self.pos += 1;
                        continue;
                    }
                    const token = self.text[self.start..self.pos];
                    self.consumed += token.len;
                    self.state = .scanning;
                    return token;
                },
            }
        }

        // End of input - flush remaining token
        if (self.state == .in_word or self.state == .in_run) {
            const token = self.text[self.start..self.pos];
            self.consumed += token.len;
            self.state = .scanning;
            return token;
        }

        return null;
    }

    pub fn remaining(self: *const Tokenizer) usize {
        return self.text.len - self.pos;
    }

    pub fn reset(self: *Tokenizer) void {
        self.pos = 0;
        self.start = 0;
        self.state = .scanning;
        self.consumed = 0;
    }
};

fn isWhiteSpace(c: u8) bool {
    return switch (c) {
        ' ', '\t', '\n', '\r' => true,
        else => false,
    };
}

fn isDelimiter(c: u8) bool {
    return switch (c) {
        ',', '.', '?', '!', ':', ';' => true,
        else => false,
    };
}

fn isPossibleNonScalar(c: u8) bool {
    return switch (c) {
        '-', '=', '+', '*', '/', '\\', '|', '@', '#', '$', '%', '^', '&', '_', '~', '`' => true,
        else => false,
    };
}
