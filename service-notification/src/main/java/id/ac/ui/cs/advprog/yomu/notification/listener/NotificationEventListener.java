package id.ac.ui.cs.advprog.yomu.notification.listener;

import id.ac.ui.cs.advprog.yomu.notification.controller.NotificationController;
import id.ac.ui.cs.advprog.yomu.shared.event.BacaanUpdatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.Exchange;
import org.springframework.amqp.rabbit.annotation.Queue;
import org.springframework.amqp.rabbit.annotation.QueueBinding;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationEventListener {

    private final NotificationController notificationController;

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.bacaan.updated", durable = "true"),
            exchange = @Exchange(value = "yomu.events", type = "topic"),
            key = "yomu.learning.bacaan.updated"
    ))
    public void handleBacaanUpdated(BacaanUpdatedEvent event) {
        log.info("Received BacaanUpdatedEvent: {}", event);
        notificationController.broadcastMessage("bacaan_updated", event);
    }
}
