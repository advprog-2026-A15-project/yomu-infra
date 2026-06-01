package id.ac.ui.cs.advprog.yomu.e2e.auth;

import id.ac.ui.cs.advprog.yomu.e2e.base.BaseTest;
import id.ac.ui.cs.advprog.yomu.e2e.pages.HomePage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.LoginPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.NavbarComponent;
import id.ac.ui.cs.advprog.yomu.e2e.pages.RegisterPage;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Prerequisites:
 *   - Frontend running at APP_URL (default: http://localhost:5173)
 *   - Backend running (api-gateway on port 8090)
 *   - @BeforeAll auto-registers TEST_USERNAME / TEST_PASSWORD
 *   - ADMIN_USERNAME / ADMIN_PASSWORD: set via -D flags for admin tests
 */
class AuthFlowTest extends BaseTest {

    @Test
    void homepageLoadsWithHeroContent() {
        driver.get(APP_URL);
        HomePage home = new HomePage(driver, wait);
        assertThat(home.getTitle()).isEqualTo("Yomu");
        assertThat(home.isStartLearningButtonVisible()).isTrue();
        assertThat(home.isJoinLeagueButtonVisible()).isTrue();
    }

    @Test
    void loginPageShowsFormElements() {
        driver.get(APP_URL + "/login");
        LoginPage loginPage = new LoginPage(driver, wait);
        assertThat(loginPage.isOnLoginPage()).isTrue();
        assertThat(loginPage.getPageTitle()).contains("Yomu");
        assertThat(loginPage.getIdentifierInput().isDisplayed()).isTrue();
        assertThat(loginPage.getPasswordInput().isDisplayed()).isTrue();
    }

    @Test
    void registerPageShowsFormElements() {
        driver.get(APP_URL + "/register");
        RegisterPage reg = new RegisterPage(driver, wait);
        assertThat(reg.isOnRegisterPage()).isTrue();
        assertThat(reg.getUsernameInput().isDisplayed()).isTrue();
        assertThat(reg.getDisplayNameInput().isDisplayed()).isTrue();
        assertThat(reg.getPasswordInput().isDisplayed()).isTrue();
    }

    @Test
    void loginWithInvalidCredentialsShowsError() {
        driver.get(APP_URL + "/login");
        LoginPage loginPage = new LoginPage(driver, wait);
        // login() properly waits for either redirect or error alert
        loginPage.login("nonexistent_user_" + System.currentTimeMillis(), "wrongpass999");
        // If credentials invalid, stays on /login with error alert visible
        assertThat(loginPage.isErrorDisplayed()).isTrue();
    }

    @Test
    void loginWithEmptyFieldsDoesNotSucceed() {
        driver.get(APP_URL + "/login");
        // HTML5 validation blocks submit when required fields empty — page stays at /login
        driver.findElement(By.xpath("//button[normalize-space()='Masuk']")).click();
        assertThat(driver.getCurrentUrl()).contains("/login");
    }

    @Test
    void navbarShowsAuthLinksAfterLogin() {
        loginAsTestUser();
        NavbarComponent navbar = new NavbarComponent(driver, wait);
        assertThat(navbar.isLoggedIn()).isTrue();
        assertThat(navbar.getBelajarLink().isDisplayed()).isTrue();
        assertThat(navbar.getLigaLink().isDisplayed()).isTrue();
        assertThat(navbar.getMisiLink().isDisplayed()).isTrue();
    }

    @Test
    void navbarShowsLoginLinkWhenNotAuthenticated() {
        driver.get(APP_URL);
        NavbarComponent navbar = new NavbarComponent(driver, wait);
        assertThat(navbar.isLoggedIn()).isFalse();
        assertThat(navbar.isLoginLinkVisible()).isTrue();
    }

    @Test
    void logoutClearsSessionAndShowsLoginLink() {
        loginAsTestUser();
        NavbarComponent navbar = new NavbarComponent(driver, wait);
        assertThat(navbar.isLoggedIn()).isTrue();
        navbar.logout();
        // Navbar.jsx calls navigate('/login') after logout — NOT navigate('/')
        wait.until(ExpectedConditions.urlContains("/login"));
        assertThat(navbar.isLoggedIn()).isFalse();
        assertThat(navbar.isLoginLinkVisible()).isTrue();
    }

    @Test
    void registerNewUserWithValidDataSucceeds() {
        String uid = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        driver.get(APP_URL + "/register");
        RegisterPage reg = new RegisterPage(driver, wait);
        reg.register(
            "sel_" + uid,
            "Selenium " + uid,
            "sel_" + uid + "@test.com",
            "",
            "Password123!",
            "Password123!"
        );
        wait.until(ExpectedConditions.not(ExpectedConditions.urlContains("/register")));
        assertThat(driver.getCurrentUrl()).doesNotContain("/register");
    }

    @Test
    void registerWithMismatchedPasswordsShowsError() {
        driver.get(APP_URL + "/register");
        RegisterPage reg = new RegisterPage(driver, wait);
        reg.register("anyuser", "Any User", "", "", "Password123!", "DifferentPass!");
        assertThat(reg.isOnRegisterPage() || reg.isErrorDisplayed()).isTrue();
    }

    @Test
    void loginPageHasLinkToRegister() {
        driver.get(APP_URL + "/login");
        By registerLink = By.xpath("//a[contains(normalize-space(),'Daftar')]");
        wait.until(ExpectedConditions.visibilityOfElementLocated(registerLink)).click();
        assertThat(driver.getCurrentUrl()).contains("/register");
    }

    @Test
    void registerPageHasLinkToLogin() {
        driver.get(APP_URL + "/register");
        By loginLink = By.xpath("//a[contains(normalize-space(),'Masuk')]");
        wait.until(ExpectedConditions.visibilityOfElementLocated(loginLink)).click();
        assertThat(driver.getCurrentUrl()).contains("/login");
    }

    @Test
    void adminUserSeesAdminNavLink() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        NavbarComponent navbar = new NavbarComponent(driver, wait);
        assertThat(navbar.isLoggedIn()).isTrue();
        assertThat(navbar.isAdminLinkVisible()).isTrue();
    }
}
