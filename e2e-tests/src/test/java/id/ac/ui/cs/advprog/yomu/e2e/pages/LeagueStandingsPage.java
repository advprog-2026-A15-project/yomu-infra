package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.List;

public class LeagueStandingsPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By PAGE_HEADING      = By.xpath("//h1[contains(normalize-space(),'Klasemen')]");
    private static final By TIER_SECTION_HEADERS = By.xpath("//h2[contains(normalize-space(),'Divisi') or contains(normalize-space(),'Diamond') or contains(normalize-space(),'Gold') or contains(normalize-space(),'Silver') or contains(normalize-space(),'Bronze')]");
    private static final By TABLE_ROWS        = By.cssSelector("table tbody tr");
    private static final By TIER_INFO_CARDS   = By.cssSelector("[class*='tier-card'], [class*='tier-info']");

    public LeagueStandingsPage(WebDriver driver, WebDriverWait wait) {
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

    public String getHeading() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_HEADING)).getText();
    }

    public List<WebElement> getTierSectionHeaders() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_HEADING));
        return driver.findElements(TIER_SECTION_HEADERS);
    }

    public List<WebElement> getTableRows() {
        return driver.findElements(TABLE_ROWS);
    }

    public boolean hasStandingsTable() {
        return !driver.findElements(TABLE_ROWS).isEmpty();
    }
}
