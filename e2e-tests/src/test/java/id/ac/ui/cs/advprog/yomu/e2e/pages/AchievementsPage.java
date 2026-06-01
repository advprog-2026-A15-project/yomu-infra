package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.List;

public class AchievementsPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By PAGE_HEADING         = By.xpath("//h1[contains(normalize-space(),'Achievement')]");
    private static final By DAILY_MISSION_HEADING = By.xpath("//h2[normalize-space()='Daily Mission']");
    private static final By ACHIEVEMENT_LIST_HEADING = By.xpath("//h2[contains(normalize-space(),'Achievement')]");
    private static final By CLAIM_BUTTONS        = By.cssSelector(".achievement-claim-button, button.claim-button");
    private static final By FILTER_BUTTONS       = By.xpath("//button[normalize-space()='Semua' or normalize-space()='Bacaan' or normalize-space()='Kuis' or normalize-space()='Liga' or normalize-space()='Diskusi']");
    private static final By ACHIEVEMENT_CARDS    = By.cssSelector(".achievement-card, [class*='achievement-item']");
    private static final By MISSION_ITEMS        = By.cssSelector(".mission-item, [class*='mission-card'], [class*='daily-mission']");
    private static final By REFRESH_BUTTON       = By.xpath("//button[contains(normalize-space(),'Refresh')]");
    private static final By ADMIN_BUTTON         = By.xpath("//button[normalize-space()='Admin'] | //a[normalize-space()='Admin']");
    private static final By BACK_LINK            = By.xpath("//a[normalize-space()='Beranda']");
    private static final By TOTAL_SCORE_BADGE    = By.cssSelector("[class*='score-badge'], [class*='total-score']");

    public AchievementsPage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    public boolean isLoaded() {
        try {
            wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_HEADING));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public String getPageHeading() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_HEADING)).getText();
    }

    public boolean isDailyMissionSectionVisible() {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(DAILY_MISSION_HEADING)).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isAchievementListVisible() {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(ACHIEVEMENT_LIST_HEADING)).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public List<WebElement> getFilterButtons() {
        return driver.findElements(FILTER_BUTTONS);
    }

    public void clickFilter(String filterName) {
        By filter = By.xpath("//button[normalize-space()='" + filterName + "']");
        wait.until(ExpectedConditions.elementToBeClickable(filter)).click();
    }

    public List<WebElement> getClaimButtons() {
        return driver.findElements(CLAIM_BUTTONS);
    }

    public List<WebElement> getMissionItems() {
        return driver.findElements(MISSION_ITEMS);
    }

    public List<WebElement> getAchievementCards() {
        return driver.findElements(ACHIEVEMENT_CARDS);
    }

    public boolean isAdminButtonVisible() {
        try {
            return driver.findElement(ADMIN_BUTTON).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void clickRefresh() {
        wait.until(ExpectedConditions.elementToBeClickable(REFRESH_BUTTON)).click();
    }

    public void clickAdminButton() {
        wait.until(ExpectedConditions.elementToBeClickable(ADMIN_BUTTON)).click();
    }
}
