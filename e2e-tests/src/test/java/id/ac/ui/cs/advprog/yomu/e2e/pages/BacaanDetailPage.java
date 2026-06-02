package id.ac.ui.cs.advprog.yomu.e2e.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.List;

public class BacaanDetailPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    // Title: <h1 className="page-title">{bacaan.title}</h1>
    private static final By PAGE_HEADING  = By.cssSelector("h1.page-title");
    // Content: <div className="card"> wrapping title + content div
    private static final By CONTENT_CARD  = By.cssSelector(".card");

    // Quiz button text: "Selesai Membaca, Mulai Kuis" (READING mode, not completed)
    private static final By QUIZ_BUTTON   = By.xpath(
        "//button[contains(normalize-space(),'Mulai Kuis')" +
        " or contains(normalize-space(),'KIRIM JAWABAN')]"
    );
    // Quiz questions: rendered as .card divs with h3 inside (quiz mode)
    private static final By QUIZ_QUESTIONS = By.xpath("//div[contains(@class,'card')]//h3");
    private static final By QUIZ_SUBMIT    = By.xpath("//button[normalize-space()='KIRIM JAWABAN']");
    private static final By QUIZ_RESULT    = By.xpath("//h1[contains(normalize-space(),'Sempurna')" +
        " or contains(normalize-space(),'Bagus') or contains(normalize-space(),'Selesai')" +
        " or contains(normalize-space(),'Berlatih')]");

    // Comment section: <h2>Diskusi</h2>
    private static final By COMMENT_SECTION  = By.xpath("//h2[normalize-space()='Diskusi']");
    // Textarea: placeholder="Tulis komentar atau pertanyaan..."
    private static final By COMMENT_TEXTAREA = By.cssSelector("textarea");
    // Submit button: <button>KIRIM</button>
    private static final By COMMENT_SUBMIT   = By.xpath("//button[normalize-space()='KIRIM']");
    // Comment items rendered by CommentItem component
    private static final By COMMENT_ITEMS    = By.cssSelector(".comment-item, [class*='comment-card'], [class*='CommentItem']");
    private static final By DELETE_BUTTONS   = By.xpath(
        "//button[contains(normalize-space(),'Hapus') or contains(normalize-space(),'Delete')]"
    );

    public BacaanDetailPage(WebDriver driver, WebDriverWait wait) {
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

    public String getTitle() {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(PAGE_HEADING)).getText();
    }

    /** Content is visible if the .card wrapper (containing title + body) is present. */
    public boolean isContentVisible() {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(CONTENT_CARD)).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public boolean hasQuizButton() {
        try {
            return driver.findElement(QUIZ_BUTTON).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void clickQuizButton() {
        wait.until(ExpectedConditions.elementToBeClickable(QUIZ_BUTTON)).click();
    }

    public List<WebElement> getQuizQuestions() {
        return driver.findElements(QUIZ_QUESTIONS);
    }

    public void submitQuiz() {
        wait.until(ExpectedConditions.elementToBeClickable(QUIZ_SUBMIT)).click();
    }

    public boolean isQuizResultVisible() {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(QUIZ_RESULT)).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isCommentSectionVisible() {
        try {
            return driver.findElement(COMMENT_SECTION).isDisplayed();
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    public void addComment(String text) {
        WebElement textarea = wait.until(ExpectedConditions.visibilityOfElementLocated(COMMENT_TEXTAREA));
        textarea.clear();
        textarea.sendKeys(text);
        wait.until(ExpectedConditions.elementToBeClickable(COMMENT_SUBMIT)).click();
    }

    public List<WebElement> getCommentItems() {
        return driver.findElements(COMMENT_ITEMS);
    }

    public int getCommentCount() {
        return driver.findElements(COMMENT_ITEMS).size();
    }

    public void deleteFirstComment() {
        List<WebElement> btns = wait.until(
            ExpectedConditions.presenceOfAllElementsLocatedBy(DELETE_BUTTONS));
        if (!btns.isEmpty()) btns.get(0).click();
    }
}
