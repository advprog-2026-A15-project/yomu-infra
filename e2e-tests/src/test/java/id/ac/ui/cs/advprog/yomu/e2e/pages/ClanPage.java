package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

public class ClanPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private static final By PAGE_TITLE        = By.cssSelector(".page-title");
    private static final By CREATE_CLAN_BUTTON = By.xpath("//button[contains(normalize-space(),'BUAT CLAN')]");
    private static final By CLAN_NAME_INPUT    = By.cssSelector("input[placeholder*='nama clan' i]");
    private static final By CLAN_DESC_INPUT    = By.cssSelector("input[placeholder*='Deskripsi' i]");
    private static final By BUAT_SEKARANG_BTN  = By.xpath("//button[normalize-space()='BUAT SEKARANG']");
    private static final By TIER_FILTER_BTNS   = By.xpath(
        "//button[normalize-space()='SEMUA'" +
        " or normalize-space()='BRONZE'" +
        " or normalize-space()='SILVER'" +
        " or normalize-space()='GOLD'" +
        " or normalize-space()='DIAMOND']"
    );
    private static final By JOIN_BUTTONS      = By.xpath("//button[normalize-space()='GABUNG']");
    private static final By MEMBERSHIP_BANNER = By.cssSelector(".card");
    private static final By KELOLA_CLAN_LINK  = By.xpath(
        "//a[contains(normalize-space(),'KELOLA CLAN')]" +
        " | //button[contains(normalize-space(),'KELOLA CLAN')]"
    );
    private static final By RECALCULATE_BUTTON = By.xpath(
        "//button[contains(normalize-space(),'RECALCULATE')]"
    );
    private static final By LEAVE_BUTTON      = By.xpath(
        "//button[normalize-space()='KELUAR' or normalize-space()='BATALKAN']"
    );

    public ClanPage(WebDriver driver, WebDriverWait wait) {
        this.driver = driver;
        this.wait = wait;
    }

    /** Accept a browser alert/confirm if one is present. */
    private void acceptAlertIfPresent() {
        try {
            new WebDriverWait(driver, Duration.ofSeconds(4))
                .until(ExpectedConditions.alertIsPresent());
            driver.switchTo().alert().accept();
        } catch (Exception ignored) {}
    }

    public String getPageTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE)).getText();
    }

    public boolean isLoaded() {
        try {
            wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public void clickCreateClan() {
        wait.until(ExpectedConditions.elementToBeClickable(CREATE_CLAN_BUTTON)).click();
    }

    public boolean isCreateFormVisible() {
        try {
            return driver.findElement(CLAN_NAME_INPUT).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void fillClanForm(String name, String description) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(CLAN_NAME_INPUT)).sendKeys(name);
        try {
            driver.findElement(CLAN_DESC_INPUT).sendKeys(description);
        } catch (NoSuchElementException ignored) {}
    }

    public void submitClanForm() {
        wait.until(ExpectedConditions.elementToBeClickable(BUAT_SEKARANG_BTN)).click();
        // ClanPage calls alert('Clan berhasil dibuat!') or alert(error.message) after submit
        acceptAlertIfPresent();
    }

    public void createClan(String name, String description) {
        clickCreateClan();
        fillClanForm(name, description);
        submitClanForm();
    }

    public void clickTierFilter(String tier) {
        By btn = By.xpath("//button[normalize-space()='" + tier + "']");
        wait.until(ExpectedConditions.elementToBeClickable(btn)).click();
    }

    public List<WebElement> getTierFilterButtons() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_TITLE));
        return driver.findElements(TIER_FILTER_BTNS);
    }

    public boolean hasClanRows() {
        By rows = By.cssSelector("table tbody tr");
        return !driver.findElements(rows).isEmpty();
    }

    public void joinFirstAvailableClan() {
        List<WebElement> joins = wait.until(
            ExpectedConditions.presenceOfAllElementsLocatedBy(JOIN_BUTTONS));
        if (!joins.isEmpty()) {
            joins.get(0).click();
            // ClanPage calls alert('Permintaan bergabung telah dikirim!') after join
            acceptAlertIfPresent();
        }
    }

    public boolean isMembershipBannerVisible() {
        // Look for the membership banner which shows "Anggota" or "Menunggu"
        try {
            return driver.getPageSource().contains("Anggota") ||
                   driver.getPageSource().contains("Menunggu Persetujuan");
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isRecalculateButtonVisible() {
        try {
            return driver.findElement(RECALCULATE_BUTTON).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public boolean isKelolaClanVisible() {
        try {
            return driver.findElement(KELOLA_CLAN_LINK).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void clickKelolaClan() {
        wait.until(ExpectedConditions.elementToBeClickable(KELOLA_CLAN_LINK)).click();
    }

    public void leaveClan() {
        wait.until(ExpectedConditions.elementToBeClickable(LEAVE_BUTTON)).click();
        // handleLeaveClan uses window.confirm — accept it
        acceptAlertIfPresent();
    }
}
