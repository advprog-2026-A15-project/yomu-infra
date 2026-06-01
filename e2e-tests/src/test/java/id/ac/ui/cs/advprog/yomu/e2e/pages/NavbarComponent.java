package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class NavbarComponent {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By BRAND_LINK    = By.cssSelector("a.nav-brand, .nav-brand");
    private static final By BELAJAR_LINK  = By.xpath("//a[normalize-space()='Belajar']");
    private static final By LIGA_LINK     = By.xpath("//a[normalize-space()='Liga']");
    private static final By KLASEMEN_LINK = By.xpath("//a[normalize-space()='Klasemen']");
    private static final By MISI_LINK     = By.xpath("//a[normalize-space()='Misi']");
    private static final By ADMIN_LINK    = By.xpath("//a[normalize-space()='Admin']");
    private static final By LOGOUT_BUTTON = By.xpath("//button[normalize-space()='Keluar']");
    private static final By PROFILE_LINK  = By.xpath("//a[contains(normalize-space(),'Profil')]");
    private static final By LOGIN_LINK    = By.xpath("//a[normalize-space()='Masuk']");
    private static final By REGISTER_LINK = By.xpath("//a[normalize-space()='Daftar']");

    public NavbarComponent(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    public boolean isLoggedIn() {
        try {
            return driver.findElement(LOGOUT_BUTTON).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public WebElement getBelajarLink() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(BELAJAR_LINK));
    }

    public WebElement getLigaLink() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(LIGA_LINK));
    }

    public WebElement getMisiLink() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(MISI_LINK));
    }

    public boolean isAdminLinkVisible() {
        try {
            return driver.findElement(ADMIN_LINK).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void logout() {
        wait.until(ExpectedConditions.elementToBeClickable(LOGOUT_BUTTON)).click();
    }

    public void navigateToBelajar() {
        getBelajarLink().click();
    }

    public void navigateToLiga() {
        getLigaLink().click();
    }

    public void navigateToMisi() {
        getMisiLink().click();
    }

    public void navigateToAdmin() {
        wait.until(ExpectedConditions.elementToBeClickable(ADMIN_LINK)).click();
    }

    public void navigateToProfile() {
        wait.until(ExpectedConditions.elementToBeClickable(PROFILE_LINK)).click();
    }

    public boolean isLoginLinkVisible() {
        try {
            return driver.findElement(LOGIN_LINK).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }
}
