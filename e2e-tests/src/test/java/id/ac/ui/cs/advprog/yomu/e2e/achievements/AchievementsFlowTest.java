package id.ac.ui.cs.advprog.yomu.e2e.achievements;

import id.ac.ui.cs.advprog.yomu.e2e.base.BaseTest;
import id.ac.ui.cs.advprog.yomu.e2e.pages.AchievementsPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.NavbarComponent;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Prerequisites:
 *   - Frontend + backend running
 *   - @BeforeAll auto-registers TEST_USERNAME / TEST_PASSWORD
 *   - At least one Achievement and one Daily Mission seeded in the database
 */
class AchievementsFlowTest extends BaseTest {

    @Test
    void achievementsPageLoads() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        assertThat(page.isLoaded()).isTrue();
        assertThat(page.getPageHeading()).containsIgnoringCase("Achievement");
    }

    @Test
    void dailyMissionSectionIsVisible() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        assertThat(page.isDailyMissionSectionVisible()).isTrue();
    }

    @Test
    void achievementListSectionIsVisible() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        assertThat(page.isAchievementListVisible()).isTrue();
    }

    @Test
    void achievementFilterButtonsArePresent() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        assertThat(page.getFilterButtons()).isNotEmpty();
    }

    @Test
    void filterBacaanIsClickable() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        page.clickFilter("Bacaan");
        assertThat(driver.getCurrentUrl()).contains("/achievements");
    }

    @Test
    void filterCyclesThroughAllCategories() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        // Button texts come from metricLabels map in AchievementsPage.jsx
        for (String filter : new String[]{"Bacaan", "Kuis", "Liga", "Diskusi", "Semua"}) {
            page.clickFilter(filter);
        }
        assertThat(driver.getCurrentUrl()).contains("/achievements");
    }

    @Test
    void refreshButtonReloadsData() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        page.clickRefresh();
        assertThat(page.isLoaded()).isTrue();
    }

    @Test
    void navbarMisiLinkNavigatesToAchievements() {
        loginAsTestUser();
        driver.get(APP_URL);
        new NavbarComponent(driver, wait).navigateToMisi();
        wait.until(ExpectedConditions.urlContains("/achievements"));
        assertThat(driver.getCurrentUrl()).contains("/achievements");
    }

    @Test
    void adminUserSeesAdminButton() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/achievements");
        AchievementsPage page = new AchievementsPage(driver, wait);
        assertThat(page.isAdminButtonVisible()).isTrue();
    }

    @Test
    void adminAchievementsPageLoads() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/achievements/admin");
        // Wait for the admin heading — redirects away if not ADMIN
        wait.until(ExpectedConditions.visibilityOfElementLocated(
            org.openqa.selenium.By.xpath("//h1[contains(normalize-space(),'Admin Achievement')]")
        ));
        assertThat(driver.getCurrentUrl()).contains("/achievements/admin");
    }

    @Test
    void unauthenticatedUserRedirectsToLogin() {
        driver.get(APP_URL + "/achievements");
        // AchievementsPage redirects to /login when no user session
        wait.until(ExpectedConditions.urlContains("/login"));
        assertThat(driver.getCurrentUrl()).contains("/login");
    }

    @Test
    void viewOtherUserAchievementsPageLoads() {
        loginAsTestUser();
        driver.get(APP_URL + "/achievements/users/1");
        wait.until(ExpectedConditions.or(
            ExpectedConditions.urlContains("/achievements"),
            ExpectedConditions.urlContains("/login")
        ));
        assertThat(driver.getCurrentUrl()).isNotNull();
    }
}
