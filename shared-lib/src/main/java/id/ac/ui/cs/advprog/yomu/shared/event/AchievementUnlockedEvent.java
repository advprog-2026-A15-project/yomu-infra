package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;
import java.util.UUID;

public record AchievementUnlockedEvent(
    UUID userId,
    String achievementCode,
    String achievementName,
    Instant occurredAt
) {}
