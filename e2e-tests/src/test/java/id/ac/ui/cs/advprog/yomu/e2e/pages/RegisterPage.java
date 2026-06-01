package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class RegisterPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By USERNAME_INPUT         = By.id("username");
    private static final By DISPLAY_NAME_INPUT     = By.id("displayName");
    private static final By EMAIL_INPUT            = By.id("email");
    private static final By PHONE_INPUT            = By.id("phone");
    private static final By PASSWORD_INPUT         = By.id("password");
    private static final By CONFIRM_PASSWORD_INPUT = By.id("confirmPassword");
    private static final By SUBMIT_BUTTON          = By.xpath("//button[normalize-space()='Daftar Akun']");
    private static final By ERROR_ALERT            = By.cssSelector(".alert.alert-error, .alert-error");
    private static final By PAGE_TITLE             = By.cssSelector(".auth-title");

    public RegisterPage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    public void register(String username, String displayName, String email,
                         String phone, String password, String confirmPassword) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(USERNAME_INPUT));
        sendIfNotEmpty(USERNAME_INPUT, username);
        sendIfNotEmpty(DISPLAY_NAME_INPUT, displayName);
        sendIfNotEmpty(EMAIL_INPUT, email);
        sendIfNotEmpty(PHONE_INPUT, phone);
        sendIfNotEmpty(PASSWORD_INPUT, password);
        sendIfNotEmpty(CONFIRM_PASSWORD_INPUT, confirmPassword);
        driver.findElement(SUBMIT_BUTTON).click();
    }

    private void sendIfNotEmpty(By locator, String value) {
        if (value != null && !value.isEmpty()) {
            driver.findElement(locator).clear();
            driver.findElement(locator).sendKeys(value);
        }
    }

    public boolean isErrorDisplayed() {
        try {
            return driver.findElement(ERROR_ALERT).isDisplayed();
        } catch (org.openqa.selenium.NoSuchElementException e) {
            return false;
        }
    }

    public String getErrorMessage() {
        return driver.findElement(ERROR_ALERT).getText();
    }

    public WebElement getUsernameInput() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(USERNAME_INPUT));
    }

    public WebElement getDisplayNameInput() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(DISPLAY_NAME_INPUT));
    }

    public WebElement getPasswordInput() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PASSWORD_INPUT));
    }

    public String getPageTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE)).getText();
    }

    public boolean isOnRegisterPage() {
        return driver.getCurrentUrl().contains("/register");
    }
}
