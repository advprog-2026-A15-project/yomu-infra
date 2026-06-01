package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class HomePage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By HERO_TITLE           = By.xpath("//h1[normalize-space()='Yomu']");
    private static final By START_LEARNING_BUTTON = By.xpath("//a[contains(normalize-space(),'MULAI BELAJAR')] | //button[contains(normalize-space(),'MULAI BELAJAR')]");
    private static final By JOIN_LEAGUE_BUTTON    = By.xpath("//a[contains(normalize-space(),'GABUNG LIGA')] | //button[contains(normalize-space(),'GABUNG LIGA')]");

    public HomePage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    public String getTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(HERO_TITLE)).getText();
    }

    public boolean isStartLearningButtonVisible() {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(START_LEARNING_BUTTON)).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isJoinLeagueButtonVisible() {
        try {
            return driver.findElement(JOIN_LEAGUE_BUTTON).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public void clickStartLearning() {
        wait.until(ExpectedConditions.elementToBeClickable(START_LEARNING_BUTTON)).click();
    }

    public void clickJoinLeague() {
        wait.until(ExpectedConditions.elementToBeClickable(JOIN_LEAGUE_BUTTON)).click();
    }
}
