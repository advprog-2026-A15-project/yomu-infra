package id.ac.ui.cs.advprog.yomu.notification.controller;

import org.junit.jupiter.api.Test;
import org.mockito.MockedConstruction;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mockConstruction;

class NotificationControllerTest {

    @Test
    void streamNotifications_registersEmitter() {
        NotificationController controller = new NotificationController();

        SseEmitter emitter = controller.streamNotifications();

        assertThat(emitter).isNotNull();
        assertThat(emitters(controller)).contains(emitter);
    }

    @Test
    void broadcastMessage_sendsToActiveEmittersAndRemovesDeadOnes() {
        NotificationController controller = new NotificationController();
        CapturingEmitter active = new CapturingEmitter();
        FailingEmitter dead = new FailingEmitter();
        emitters(controller).add(active);
        emitters(controller).add(dead);

        controller.broadcastMessage("bacaan_updated", "payload");

        assertThat(active.sendCount).isEqualTo(1);
        assertThat(emitters(controller)).containsExactly(active);
    }

    @Test
    void streamNotifications_removesEmitterWhenInitialSendFails() {
        try (MockedConstruction<SseEmitter> ignored = mockConstruction(
                SseEmitter.class,
                (mock, context) -> doThrow(new IOException("disconnected"))
                        .when(mock).send(any(SseEmitter.SseEventBuilder.class)))) {
            NotificationController controller = new NotificationController();

            SseEmitter emitter = controller.streamNotifications();

            assertThat(emitter).isNotNull();
            assertThat(emitters(controller)).isEmpty();
        }
    }

    @SuppressWarnings("unchecked")
    private List<SseEmitter> emitters(NotificationController controller) {
        return (List<SseEmitter>) ReflectionTestUtils.getField(controller, "emitters");
    }

    private static class CapturingEmitter extends SseEmitter {
        private int sendCount;

        @Override
        public synchronized void send(SseEventBuilder builder) throws IOException {
            sendCount++;
        }
    }

    private static class FailingEmitter extends SseEmitter {
        @Override
        public synchronized void send(SseEventBuilder builder) throws IOException {
            throw new IOException("client disconnected");
        }
    }
}
