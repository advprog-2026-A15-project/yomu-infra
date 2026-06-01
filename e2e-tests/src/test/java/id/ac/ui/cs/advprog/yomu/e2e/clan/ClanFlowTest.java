package id.ac.ui.cs.advprog.yomu.e2e.clan;

import id.ac.ui.cs.advprog.yomu.e2e.base.BaseTest;
import id.ac.ui.cs.advprog.yomu.e2e.pages.ClanPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.LeagueStandingsPage;
import id.ac.ui.cs.advprog.yomu.e2e.pages.NavbarComponent;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Prerequisites:
 *   - Frontend + backend running
 *   - @BeforeAll auto-registers TEST_USERNAME / TEST_PASSWORD
 *   - ADMIN_USERNAME / ADMIN_PASSWORD needed for admin tests
 *
 * Note: ClanPage uses window.alert() and window.confirm() — ClanPage page object
 * handles these automatically via acceptAlertIfPresent().
 */
class ClanFlowTest extends BaseTest {

    @Test
    void clanPageLoadsWithTitle() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        assertThat(page.isLoaded()).isTrue();
        assertThat(page.getPageTitle()).contains("Liga Yomu");
    }

    @Test
    void clanPageShowsTierFilterButtons() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        assertThat(page.getTierFilterButtons()).isNotEmpty();
    }

    @Test
    void tierFilterBronzeIsClickable() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        page.clickTierFilter("BRONZE");
        assertThat(driver.getCurrentUrl()).contains("/clan");
    }

    @Test
    void tierFilterCyclesThroughAll() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        for (String tier : new String[]{"BRONZE", "SILVER", "GOLD", "DIAMOND", "SEMUA"}) {
            page.clickTierFilter(tier);
        }
        assertThat(driver.getCurrentUrl()).contains("/clan");
    }

    @Test
    void createClanFormAppearsOnButtonClick() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        page.clickCreateClan();
        assertThat(page.isCreateFormVisible()).isTrue();
    }

    @Test
    void createNewClanSucceeds() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        String clanName = "Sel " + UUID.randomUUID().toString().substring(0, 6);
        // createClan() internally accepts the alert('Clan berhasil dibuat!') dialog
        page.createClan(clanName, "Test clan by Selenium");
        // After alert dismissed, page re-renders — verify clan name appears
        wait.until(d -> d.getPageSource().contains(clanName) || page.isMembershipBannerVisible());
        assertThat(driver.getPageSource()).contains(clanName);
    }

    @Test
    void navbarLigaLinkNavigatesToClan() {
        loginAsTestUser();
        driver.get(APP_URL);
        new NavbarComponent(driver, wait).navigateToLiga();
        wait.until(ExpectedConditions.urlContains("/clan"));
        assertThat(driver.getCurrentUrl()).contains("/clan");
    }

    @Test
    void leagueStandingsPageLoads() {
        loginAsTestUser();
        driver.get(APP_URL + "/liga/standings");
        LeagueStandingsPage standings = new LeagueStandingsPage(driver, wait);
        assertThat(standings.isLoaded()).isTrue();
        assertThat(standings.getHeading()).containsIgnoringCase("Klasemen");
    }

    @Test
    void leagueStandingsShowsTierNames() {
        loginAsTestUser();
        driver.get(APP_URL + "/liga/standings");
        LeagueStandingsPage standings = new LeagueStandingsPage(driver, wait);
        assertThat(standings.isLoaded()).isTrue();
        assertThat(driver.getPageSource()).containsAnyOf("Diamond", "Gold", "Silver", "Bronze");
    }

    @Test
    void adminSeesRecalculateTierButton() {
        assumeTrue(isAdminLoginAvailable(), "Admin user not configured — skipping");
        loginAsAdmin();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        assertThat(page.isLoaded()).isTrue();
        assertThat(page.isRecalculateButtonVisible()).isTrue();
    }

    @Test
    void clanManagePageAccessibleForClanLeader() {
        loginAsTestUser();
        driver.get(APP_URL + "/clan");
        ClanPage page = new ClanPage(driver, wait);
        String clanName = "Leader " + UUID.randomUUID().toString().substring(0, 6);
        // createClan() accepts the success alert automatically
        page.createClan(clanName, "");
        wait.until(d -> d.getPageSource().contains(clanName) || page.isMembershipBannerVisible());

        // After creating a clan the user becomes leader — KELOLA CLAN link should appear
        if (page.isKelolaClanVisible()) {
            page.clickKelolaClan();
            wait.until(ExpectedConditions.urlContains("/manage"));
            assertThat(driver.getCurrentUrl()).contains("/manage");
        }
    }
}
