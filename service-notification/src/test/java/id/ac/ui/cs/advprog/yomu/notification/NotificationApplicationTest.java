package id.ac.ui.cs.advprog.yomu.notification;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
        "spring.rabbitmq.listener.simple.auto-startup=false",
        "spring.rabbitmq.listener.direct.auto-startup=false"
})
class NotificationApplicationTest {

    @Test
    void contextLoads() {
    }
}
