package id.ac.ui.cs.advprog.yomu.e2e.forum;

import id.ac.ui.cs.advprog.yomu.e2e.base.BaseTest;
import id.ac.ui.cs.advprog.yomu.e2e.pages.BacaanDetailPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.LearningPage;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Forum/comment tests — comments live on the BacaanDetailPage.
 *
 * Prerequisites:
 *   - At least one Bacaan seeded in the database
 *   - @BeforeAll auto-registers TEST_USERNAME / TEST_PASSWORD
 */
class ForumFlowTest extends BaseTest {

    private boolean navigateToFirstBacaan() {
        driver.get(APP_URL + "/learning");
        LearningPage listPage = new LearningPage(driver, wait);
        if (!listPage.hasBacaanCards()) return false;
        listPage.clickFirstBacaan();
        wait.until(ExpectedConditions.urlContains("/learning/"));
        return true;
    }

    @Test
    void commentSectionIsVisibleOnBacaanDetail() {
        loginAsTestUser();
        if (!navigateToFirstBacaan()) return;

        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        assertThat(detail.isLoaded()).isTrue();
        assertThat(detail.isCommentSectionVisible()).isTrue();
    }

    @Test
    void commentListIsDisplayed() {
        loginAsTestUser();
        if (!navigateToFirstBacaan()) return;

        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        assertThat(detail.isCommentSectionVisible()).isTrue();
    }

    @Test
    void canAddNewComment() {
        loginAsTestUser();
        if (!navigateToFirstBacaan()) return;

        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        int before = detail.getCommentCount();

        String text = "Selenium comment " + UUID.randomUUID().toString().substring(0, 8);
        detail.addComment(text);

        wait.until(d -> detail.getCommentCount() > before || d.getPageSource().contains(text));
        assertThat(driver.getPageSource()).contains(text);
    }

    @Test
    void canDeleteOwnComment() {
        loginAsTestUser();
        if (!navigateToFirstBacaan()) return;

        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        String text = "Delete me " + UUID.randomUUID().toString().substring(0, 8);
        detail.addComment(text);
        wait.until(d -> d.getPageSource().contains(text));

        int before = detail.getCommentCount();
        detail.deleteFirstComment();

        // Handle possible confirmation dialog
        dismissAlertIfPresent();
        try {
            By confirmBtn = By.xpath(
                "//button[normalize-space()='Ya' or normalize-space()='Hapus'" +
                " or normalize-space()='Konfirmasi' or normalize-space()='OK']"
            );
            driver.findElement(confirmBtn).click();
        } catch (org.openqa.selenium.NoSuchElementException ignored) {}

        wait.until(d -> detail.getCommentCount() < before || !d.getPageSource().contains(text));
        assertThat(driver.getPageSource()).doesNotContain(text);
    }

    @Test
    void unauthenticatedUserCannotSeeCommentForm() {
        driver.get(APP_URL + "/learning/1");
        wait.until(ExpectedConditions.or(
            ExpectedConditions.urlContains("/login"),
            ExpectedConditions.urlContains("/learning/")
        ));
        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        boolean onLoginPage  = driver.getCurrentUrl().contains("/login");
        boolean noCommentForm = !detail.isCommentSectionVisible();
        assertThat(onLoginPage || noCommentForm).isTrue();
    }

    @Test
    void adminCanSeeCommentModerationInAdminDashboard() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/admin");
        wait.until(ExpectedConditions.urlContains("/admin"));
        assertThat(driver.getPageSource()).containsAnyOf("Moderasi Forum", "Forum", "Komentar");
    }
}
