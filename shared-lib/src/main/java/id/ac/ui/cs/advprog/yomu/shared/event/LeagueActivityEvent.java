package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;
import java.util.UUID;

public record LeagueActivityEvent(
    UUID userId,
    UUID leagueId,
    UUID activityId,
    String activityType,
    Instant occurredAt
) {}
