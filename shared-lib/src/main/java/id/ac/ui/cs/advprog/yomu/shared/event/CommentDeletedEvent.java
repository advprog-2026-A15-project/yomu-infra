package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;

public record CommentDeletedEvent(
    String userId,
    String bacaanId,
    String parentComment,
    String commentId,
    String commentContent,
    Instant timestamp
) {}

