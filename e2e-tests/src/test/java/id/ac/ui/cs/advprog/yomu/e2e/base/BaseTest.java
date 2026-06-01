package id.ac.ui.cs.advprog.yomu.e2e.base;

import id.ac.ui.cs.advprog.yomu.e2e.pages.LoginPage;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;

public abstract class BaseTest {

    protected WebDriver driver;
    protected WebDriverWait wait;

    protected static final String APP_URL       = System.getProperty("APP_URL",        "http://localhost:5173");
    protected static final String API_URL        = System.getProperty("API_URL",        "http://localhost:8090");
    protected static final String TEST_USERNAME  = System.getProperty("TEST_USERNAME",  "testuser");
    protected static final String TEST_PASSWORD  = System.getProperty("TEST_PASSWORD",  "testpassword123");
    protected static final String ADMIN_USERNAME = System.getProperty("ADMIN_USERNAME", "adminuser");
    protected static final String ADMIN_PASSWORD = System.getProperty("ADMIN_PASSWORD", "adminpassword123");
    /**
     * Optional: pre-generated admin JWT token from localStorage.
     * Get it: login via Google in browser → DevTools → Application →
     *   Local Storage → yomu_user → copy the "token" field value.
     * Pass as: -DADMIN_TOKEN=eyJ...
     */
    protected static final String ADMIN_TOKEN    = System.getProperty("ADMIN_TOKEN");

    @BeforeAll
    static void ensureTestUsersExist() {
        registerUser(TEST_USERNAME, "Test User", TEST_PASSWORD);
    }

    private static void registerUser(String username, String displayName, String password) {
        try {
            HttpClient client = HttpClient.newHttpClient();
            String body = String.format(
                "{\"username\":\"%s\",\"displayName\":\"%s\",\"password\":\"%s\"}",
                username, displayName, password
            );
            HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(API_URL + "/api/auth/register"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .timeout(Duration.ofSeconds(10))
                .build();
            client.send(req, HttpResponse.BodyHandlers.discarding());
        } catch (Exception ignored) {}
    }

    /**
     * Returns true when admin access is available, either via:
     *   1) -DADMIN_TOKEN=<jwt>  (Google SSO admin — preferred)
     *   2) -DADMIN_USERNAME + -DADMIN_PASSWORD  (password-based admin account)
     */
    protected boolean isAdminLoginAvailable() {
        if (ADMIN_TOKEN != null && !ADMIN_TOKEN.isBlank()) return true;
        try {
            HttpClient client = HttpClient.newHttpClient();
            String body = String.format(
                "{\"identifier\":\"%s\",\"password\":\"%s\"}",
                ADMIN_USERNAME, ADMIN_PASSWORD
            );
            HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(API_URL + "/api/auth/login"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .timeout(Duration.ofSeconds(10))
                .build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            return resp.statusCode() == 200 && resp.body().contains("ADMIN");
        } catch (Exception e) {
            return false;
        }
    }

    protected void dismissAlertIfPresent() {
        try {
            driver.switchTo().alert().accept();
        } catch (NoAlertPresentException ignored) {}
    }

    @BeforeEach
    void setUp() {
        WebDriverManager.chromedriver().setup();
        ChromeOptions options = new ChromeOptions();
        if (!"false".equalsIgnoreCase(System.getProperty("HEADLESS", "true"))) {
            options.addArguments("--headless=new");
        }
        options.addArguments(
            "--no-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu",
            "--window-size=1280,800"
        );
        driver = new ChromeDriver(options);
        wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    @AfterEach
    void tearDown() {
        dismissAlertIfPresent();
        if (driver != null) driver.quit();
    }

    protected void loginAsTestUser() {
        driver.get(APP_URL + "/login");
        new LoginPage(driver, wait).login(TEST_USERNAME, TEST_PASSWORD);
    }

    /**
     * Login as admin. If -DADMIN_TOKEN is set, injects the JWT directly into
     * localStorage (bypasses Google OAuth entirely). Otherwise falls back to
     * username/password login.
     */
    protected void loginAsAdmin() {
        if (ADMIN_TOKEN != null && !ADMIN_TOKEN.isBlank()) {
            injectAdminToken(ADMIN_TOKEN);
        } else {
            driver.get(APP_URL + "/login");
            new LoginPage(driver, wait).login(ADMIN_USERNAME, ADMIN_PASSWORD);
        }
    }

    /**
     * Injects a JWT directly into localStorage under the 'yomu_user' key so that
     * the React app treats the browser session as logged-in ADMIN without going
     * through any OAuth flow.
     *
     * Usage: get the token from DevTools → Application → Local Storage →
     *   site → yomu_user → copy the "token" field (the JWT string).
     */
    private void injectAdminToken(String jwt) {
        driver.get(APP_URL);
        String script =
            "const payload = JSON.parse(atob(arguments[0].split('.')[1]));" +
            "localStorage.setItem('yomu_user', JSON.stringify({" +
            "  token: arguments[0]," +
            "  refreshToken: ''," +
            "  expiresAt: new Date(payload.exp * 1000).toISOString()," +
            "  id: String(payload.id || payload.sub || '')," +
            "  username: payload.sub || payload.username || arguments[1]," +
            "  displayName: payload.displayName || payload.sub || arguments[1]," +
            "  email: payload.email || ''," +
            "  role: 'ADMIN'" +
            "}));";
        ((JavascriptExecutor) driver).executeScript(script, jwt, ADMIN_USERNAME);
        driver.navigate().refresh();
        // wait for React to restore session from localStorage
        try { Thread.sleep(800); } catch (InterruptedException ignored) {}
    }
}
