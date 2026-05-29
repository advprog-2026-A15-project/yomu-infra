package id.ac.ui.cs.advprog.yomu.notification;

import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.test.context.SpringBootTest;

import static org.mockito.Mockito.mockStatic;

@SpringBootTest(properties = {
        "spring.rabbitmq.listener.simple.auto-startup=false",
        "spring.rabbitmq.listener.direct.auto-startup=false"
})
class NotificationApplicationTest {

    @Test
    void contextLoads() {
    }

    @Test
    void mainDelegatesToSpringApplication() {
        String[] args = {"--server.port=0"};

        try (MockedStatic<SpringApplication> springApplication = mockStatic(SpringApplication.class)) {
            NotificationApplication.main(args);

            springApplication.verify(() -> SpringApplication.run(NotificationApplication.class, args));
        }
    }
}
