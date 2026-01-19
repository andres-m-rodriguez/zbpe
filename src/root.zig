//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
pub const Vocabulary = @import("./Tokens/Vocabulary.zig");

test {
    _ = Vocabulary;  // runs Vocabulary.zig tests
}
