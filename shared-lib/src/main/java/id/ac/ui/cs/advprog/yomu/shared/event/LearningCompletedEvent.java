package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;
import java.util.UUID;

public record LearningCompletedEvent(
    UUID userId,
    UUID bacaanId,
    String bacaanSlug,
    Instant occurredAt
) {}
