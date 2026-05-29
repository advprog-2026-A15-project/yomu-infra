package id.ac.ui.cs.advprog.yomu.notification.listener;

import id.ac.ui.cs.advprog.yomu.notification.controller.NotificationController;
import id.ac.ui.cs.advprog.yomu.shared.event.BacaanUpdatedEvent;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class NotificationEventListenerTest {

    @Test
    void handleBacaanUpdated_broadcastsSseEvent() {
        NotificationController controller = mock(NotificationController.class);
        NotificationEventListener listener = new NotificationEventListener(controller);
        BacaanUpdatedEvent event = new BacaanUpdatedEvent(
                UUID.randomUUID(),
                "Judul Baru",
                "UPDATED",
                Instant.now()
        );

        listener.handleBacaanUpdated(event);

        verify(controller).broadcastMessage("bacaan_updated", event);
    }
}
