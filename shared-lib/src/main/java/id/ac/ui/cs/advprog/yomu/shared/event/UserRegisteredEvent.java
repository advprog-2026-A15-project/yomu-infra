package id.ac.ui.cs.advprog.yomu.shared.event;

import java.time.Instant;
import java.util.UUID;

public record UserRegisteredEvent(
    UUID userId,
    String username,
    String email,
    Instant occurredAt
) {}
