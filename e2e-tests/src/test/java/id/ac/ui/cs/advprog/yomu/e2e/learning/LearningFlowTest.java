package id.ac.ui.cs.advprog.yomu.e2e.learning;

import id.ac.ui.cs.advprog.yomu.e2e.base.BaseTest;
import id.ac.ui.cs.advprog.yomu.e2e.pages.BacaanDetailPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.LearningPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.NavbarComponent;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Prerequisites:
 *   - Frontend + backend running
 *   - At least one Bacaan seeded in the database
 *   - @BeforeAll auto-registers TEST_USERNAME / TEST_PASSWORD
 */
class LearningFlowTest extends BaseTest {

    @Test
    void learningPageShowsTitleAndCategoryFilters() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage page = new LearningPage(driver, wait);
        assertThat(page.getPageTitle()).isEqualTo("Modul Belajar");
        assertThat(page.getCategoryButtons()).isNotEmpty();
    }

    @Test
    void categoryFilterFiksiIsClickable() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage page = new LearningPage(driver, wait);
        page.clickCategoryFilter("FIKSI");
        assertThat(driver.getCurrentUrl()).contains("/learning");
    }

    @Test
    void categoryFilterCyclesThroughAll() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage page = new LearningPage(driver, wait);
        // NOTE: JSX does cat.replace('_',' ') — "NON_FIKSI" renders as "NON FIKSI"
        String[] categories = {"FIKSI", "NON FIKSI", "SAINS", "SEJARAH", "TEKNOLOGI", "BUDAYA", "Semua"};
        for (String cat : categories) {
            page.clickCategoryFilter(cat);
        }
        assertThat(driver.getCurrentUrl()).contains("/learning");
    }

    @Test
    void searchBacaanDoesNotCrash() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage page = new LearningPage(driver, wait);
        page.search("a");
        assertThat(driver.getCurrentUrl()).contains("/learning");
    }

    @Test
    void bacaanDetailPageLoadsOnClickMulaiBaca() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage listPage = new LearningPage(driver, wait);
        if (!listPage.hasBacaanCards()) return;

        listPage.clickFirstBacaan();
        wait.until(ExpectedConditions.urlContains("/learning/"));
        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        assertThat(detail.isLoaded()).isTrue();
        assertThat(detail.isContentVisible()).isTrue();
    }

    @Test
    void bacaanDetailPageHasTitle() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage listPage = new LearningPage(driver, wait);
        if (!listPage.hasBacaanCards()) return;

        listPage.clickFirstBacaan();
        wait.until(ExpectedConditions.urlContains("/learning/"));
        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        assertThat(detail.getTitle()).isNotBlank();
    }

    @Test
    void bacaanDetailHasQuizButton() {
        loginAsTestUser();
        driver.get(APP_URL + "/learning");
        LearningPage listPage = new LearningPage(driver, wait);
        if (!listPage.hasBacaanCards()) return;

        listPage.clickFirstBacaan();
        wait.until(ExpectedConditions.urlContains("/learning/"));
        BacaanDetailPage detail = new BacaanDetailPage(driver, wait);
        assertThat(detail.hasQuizButton()).isTrue();
    }

    @Test
    void adminSeesKelolaKontenButton() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/learning");
        LearningPage page = new LearningPage(driver, wait);
        assertThat(page.isKelolaKontenVisible()).isTrue();
    }

    @Test
    void adminLearningPageLoads() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/learning/admin");
        // Wait for the admin page heading — redirects away if not ADMIN
        wait.until(ExpectedConditions.visibilityOfElementLocated(
            org.openqa.selenium.By.xpath("//h1[contains(normalize-space(),'Kelola Bacaan')]")
        ));
        assertThat(driver.getCurrentUrl()).contains("/learning/admin");
    }

    @Test
    void navbarBelajarLinkNavigatesToLearning() {
        loginAsTestUser();
        driver.get(APP_URL);
        new NavbarComponent(driver, wait).navigateToBelajar();
        wait.until(ExpectedConditions.urlContains("/learning"));
        assertThat(driver.getCurrentUrl()).contains("/learning");
    }
}
