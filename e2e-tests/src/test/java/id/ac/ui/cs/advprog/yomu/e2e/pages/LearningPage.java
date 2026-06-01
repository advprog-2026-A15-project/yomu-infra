package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.List;

public class LearningPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By PAGE_TITLE         = By.cssSelector(".page-title");
    private static final By SEARCH_INPUT       = By.cssSelector("input[placeholder*='Cari']");
    private static final By SEARCH_BUTTON      = By.xpath("//button[normalize-space()='Cari']");
    // Category buttons: JSX uses cat.replace('_', ' '), so "NON_FIKSI" → "NON FIKSI"
    private static final By CATEGORY_BUTTONS   = By.xpath(
        "//button[normalize-space()='Semua'" +
        " or normalize-space()='FIKSI'" +
        " or normalize-space()='NON FIKSI'" +
        " or normalize-space()='SAINS'" +
        " or normalize-space()='SEJARAH'" +
        " or normalize-space()='TEKNOLOGI'" +
        " or normalize-space()='BUDAYA']"
    );
    private static final By MULAI_BACA_BUTTONS = By.xpath("//a[normalize-space()='MULAI BACA']");
    private static final By KELOLA_BUTTON      = By.xpath(
        "//a[contains(normalize-space(),'KELOLA KONTEN')]" +
        " | //button[contains(normalize-space(),'KELOLA KONTEN')]"
    );
    private static final By RESET_FILTER_BUTTON = By.xpath("//button[normalize-space()='Reset Filter']");

    public LearningPage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    public String getPageTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE)).getText();
    }

    public List<WebElement> getCategoryButtons() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE));
        return driver.findElements(CATEGORY_BUTTONS);
    }

    public void clickCategoryFilter(String displayText) {
        // displayText should use the rendered form, e.g. "NON FIKSI" not "NON_FIKSI"
        By btn = By.xpath("//button[normalize-space()='" + displayText + "']");
        wait.until(ExpectedConditions.elementToBeClickable(btn)).click();
    }

    public boolean isFilterActive(String displayText) {
        By btn = By.xpath("//button[normalize-space()='" + displayText + "']");
        try {
            String cls = driver.findElement(btn).getAttribute("class");
            return cls != null && cls.contains("btn-primary");
        } catch (Exception e) {
            return false;
        }
    }

    public void search(String keyword) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(SEARCH_INPUT)).clear();
        driver.findElement(SEARCH_INPUT).sendKeys(keyword);
        driver.findElement(SEARCH_BUTTON).click();
    }

    public boolean hasBacaanCards() {
        try {
            return !driver.findElements(MULAI_BACA_BUTTONS).isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    public void clickFirstBacaan() {
        List<WebElement> buttons = wait.until(
            ExpectedConditions.presenceOfAllElementsLocatedBy(MULAI_BACA_BUTTONS));
        if (!buttons.isEmpty()) buttons.get(0).click();
    }

    public boolean isKelolaKontenVisible() {
        try {
            return driver.findElement(KELOLA_BUTTON).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public void clickResetFilter() {
        wait.until(ExpectedConditions.elementToBeClickable(RESET_FILTER_BUTTON)).click();
    }
}
