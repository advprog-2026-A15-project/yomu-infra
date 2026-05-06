package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;
import java.util.UUID;

public record QuizCompletedEvent(
    UUID userId,
    UUID quizId,
    String quizSlug,
    int score,
    Instant occurredAt
) {}
