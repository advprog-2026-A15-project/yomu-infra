package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class LoginPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By IDENTIFIER_INPUT = By.id("identifier");
    private static final By PASSWORD_INPUT   = By.id("password");
    private static final By SUBMIT_BUTTON    = By.xpath("//button[normalize-space()='Masuk']");
    private static final By ERROR_ALERT      = By.cssSelector(".alert.alert-error");
    private static final By PAGE_TITLE       = By.cssSelector(".auth-title");

    public LoginPage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    /** Fill credentials and submit; waits for redirect OR error alert. */
    public void login(String identifier, String password) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(IDENTIFIER_INPUT));
        driver.findElement(IDENTIFIER_INPUT).clear();
        driver.findElement(IDENTIFIER_INPUT).sendKeys(identifier);
        driver.findElement(PASSWORD_INPUT).clear();
        driver.findElement(PASSWORD_INPUT).sendKeys(password);
        driver.findElement(SUBMIT_BUTTON).click();
        String base = System.getProperty("APP_URL", "http://localhost:5173");
        wait.until(ExpectedConditions.or(
            ExpectedConditions.urlToBe(base + "/"),
            ExpectedConditions.urlToBe(base),
            ExpectedConditions.visibilityOfElementLocated(ERROR_ALERT)
        ));
    }

    /** Fill fields without submitting — useful for HTML-validation tests. */
    public void fillCredentials(String identifier, String password) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(IDENTIFIER_INPUT));
        driver.findElement(IDENTIFIER_INPUT).sendKeys(identifier);
        driver.findElement(PASSWORD_INPUT).sendKeys(password);
    }

    /**
     * Click submit and wait for error alert (use only when expecting failure).
     * Does NOT wait for redirect to home.
     */
    public void clickSubmitExpectError() {
        String base = System.getProperty("APP_URL", "http://localhost:5173");
        driver.findElement(SUBMIT_BUTTON).click();
        wait.until(ExpectedConditions.or(
            ExpectedConditions.urlToBe(base + "/"),
            ExpectedConditions.urlToBe(base),
            ExpectedConditions.visibilityOfElementLocated(ERROR_ALERT)
        ));
    }

    public boolean isErrorDisplayed() {
        try {
            return driver.findElement(ERROR_ALERT).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public String getErrorMessage() {
        return driver.findElement(ERROR_ALERT).getText();
    }

    public WebElement getIdentifierInput() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(IDENTIFIER_INPUT));
    }

    public WebElement getPasswordInput() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PASSWORD_INPUT));
    }

    public String getPageTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE)).getText();
    }

    public boolean isOnLoginPage() {
        return driver.getCurrentUrl().contains("/login");
    }
}
