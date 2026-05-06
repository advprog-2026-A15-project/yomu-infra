import { useEffect, useMemo, useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  Gift,
  Loader2,
  Lock,
  Medal,
  RefreshCw,
  ShieldCheck,
  Target,
  Trophy,
} from 'lucide-react';
import { useAuth } from '../../auth';
import { achievementService } from '../services/achievementService';
import '../styles/achievements.css';

const metricLabels = {
  READING_COMPLETED: 'Bacaan',
  QUIZ_COMPLETED: 'Kuis',
  LEAGUE_ACTIVITY: 'Liga',
};

const formatDate = (value) => {
  if (!value) {
    return '-';
  }
  return new Intl.DateTimeFormat('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value));
};

const progressPercent = (progress, target) => {
  if (!target) {
    return 0;
  }
  return Math.min(100, Math.round((progress / target) * 100));
};

const fetchDashboard = async (targetUserId) => {
  const [achievementData, missionData] = await Promise.all([
    achievementService.listAchievements(targetUserId),
    achievementService.listDailyMissions(targetUserId),
  ]);
  return { achievementData, missionData };
};

export const AchievementsPage = () => {
  const { user, isLoading: authLoading } = useAuth();
  const [achievements, setAchievements] = useState([]);
  const [dailyMissions, setDailyMissions] = useState([]);
  const [selectedMetric, setSelectedMetric] = useState('ALL');
  const [isLoading, setIsLoading] = useState(true);
  const [claimingMissionId, setClaimingMissionId] = useState(null);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState(null);
  const userId = user?.id;

  const loadDashboard = async () => {
    if (!userId) {
      return;
    }

    setIsLoading(true);
    setError(null);
    try {
      const dashboardData = await fetchDashboard(userId);
      setAchievements(dashboardData.achievementData);
      setDailyMissions(dashboardData.missionData);
    } catch (loadError) {
      setError(loadError.message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    let shouldIgnore = false;

    const loadInitialDashboard = async () => {
      if (!userId) {
        return;
      }

      try {
        const dashboardData = await fetchDashboard(userId);
        if (!shouldIgnore) {
          setAchievements(dashboardData.achievementData);
          setDailyMissions(dashboardData.missionData);
          setError(null);
        }
      } catch (loadError) {
        if (!shouldIgnore) {
          setError(loadError.message);
        }
      } finally {
        if (!shouldIgnore) {
          setIsLoading(false);
        }
      }
    };

    loadInitialDashboard();

    return () => {
      shouldIgnore = true;
    };
  }, [userId]);

  const filteredAchievements = useMemo(() => {
    if (selectedMetric === 'ALL') {
      return achievements;
    }
    return achievements.filter((achievement) => achievement.metric === selectedMetric);
  }, [achievements, selectedMetric]);

  const summary = useMemo(() => {
    const unlockedCount = achievements.filter((achievement) => achievement.unlocked).length;
    const completedMissions = dailyMissions.filter((mission) => mission.completed).length;
    const claimableMissions = dailyMissions.filter((mission) => mission.completed && !mission.claimed).length;

    return {
      unlockedCount,
      achievementCount: achievements.length,
      completedMissions,
      missionCount: dailyMissions.length,
      claimableMissions,
    };
  }, [achievements, dailyMissions]);

  const handleClaim = async (missionId) => {
    if (!userId) {
      return;
    }

    setClaimingMissionId(missionId);
    setError(null);
    setSuccessMessage(null);
    try {
      const result = await achievementService.claimDailyMissionReward(missionId, userId);
      setSuccessMessage(`Reward ${result.rewardPoints} poin berhasil diklaim.`);
      await loadDashboard();
    } catch (claimError) {
      setError(claimError.message);
    } finally {
      setClaimingMissionId(null);
    }
  };

  if (!user && !authLoading) {
    return <Navigate to="/login" replace />;
  }

  return (
    <main className="achievement-shell">
      <header className="achievement-topbar">
        <div>
          <Link to="/" className="achievement-back-link">
            <ArrowLeft size={18} />
            Beranda
          </Link>
          <h1>Achievement</h1>
          <p>{user?.displayName || user?.username || 'Pelajar'}</p>
        </div>
        <div className="achievement-actions">
          {user?.role === 'ADMIN' && (
            <Link to="/achievements/admin" className="achievement-icon-button">
              <ShieldCheck size={18} />
              Admin
            </Link>
          )}
          <button className="achievement-icon-button" type="button" onClick={loadDashboard} disabled={isLoading}>
            {isLoading ? <Loader2 className="achievement-spin" size={18} /> : <RefreshCw size={18} />}
            Refresh
          </button>
        </div>
      </header>

      {(error || successMessage) && (
        <div className={error ? 'achievement-alert achievement-alert-error' : 'achievement-alert achievement-alert-success'}>
          {error || successMessage}
        </div>
      )}

      <section className="achievement-summary-grid">
        <div className="achievement-summary-item">
          <Trophy size={22} />
          <span>{summary.unlockedCount}/{summary.achievementCount}</span>
          <p>Achievement terbuka</p>
        </div>
        <div className="achievement-summary-item">
          <Target size={22} />
          <span>{summary.completedMissions}/{summary.missionCount}</span>
          <p>Daily mission selesai</p>
        </div>
        <div className="achievement-summary-item">
          <Gift size={22} />
          <span>{summary.claimableMissions}</span>
          <p>Reward siap klaim</p>
        </div>
      </section>

      <section className="achievement-section">
        <div className="achievement-section-heading">
          <h2>Daily Mission</h2>
        </div>

        {isLoading && dailyMissions.length === 0 ? (
          <div className="achievement-empty-state">
            <Loader2 className="achievement-spin" size={22} />
            Memuat daily mission
          </div>
        ) : dailyMissions.length === 0 ? (
          <div className="achievement-empty-state">Belum ada daily mission aktif.</div>
        ) : (
          <div className="daily-mission-list">
            {dailyMissions.map((mission) => {
              const percent = progressPercent(mission.progress, mission.targetCount);
              return (
                <article className="daily-mission-item" key={mission.missionId}>
                  <div className="mission-icon">
                    {mission.claimed ? <CheckCircle2 size={22} /> : <Target size={22} />}
                  </div>
                  <div className="mission-content">
                    <div className="mission-title-row">
                      <h3>{mission.name}</h3>
                      <span>{metricLabels[mission.metric] || mission.metric}</span>
                    </div>
                    {mission.description && <p>{mission.description}</p>}
                    <div className="achievement-progress-track">
                      <span style={{ width: `${percent}%` }} />
                    </div>
                    <div className="mission-meta">
                      <span>{mission.progress}/{mission.targetCount}</span>
                      <span>{mission.rewardPoints} poin</span>
                      <span>{formatDate(mission.activeUntil)}</span>
                    </div>
                  </div>
                  <button
                    className="achievement-claim-button"
                    type="button"
                    disabled={!mission.completed || mission.claimed || claimingMissionId === mission.missionId}
                    onClick={() => handleClaim(mission.missionId)}
                  >
                    {claimingMissionId === mission.missionId ? (
                      <Loader2 className="achievement-spin" size={18} />
                    ) : (
                      <Gift size={18} />
                    )}
                    {mission.claimed ? 'Diklaim' : 'Klaim'}
                  </button>
                </article>
              );
            })}
          </div>
        )}
      </section>

      <section className="achievement-section">
        <div className="achievement-section-heading">
          <h2>Daftar Achievement</h2>
          <div className="achievement-filter" aria-label="Filter achievement">
            {['ALL', 'READING_COMPLETED', 'QUIZ_COMPLETED', 'LEAGUE_ACTIVITY'].map((metric) => (
              <button
                key={metric}
                type="button"
                className={selectedMetric === metric ? 'is-active' : ''}
                onClick={() => setSelectedMetric(metric)}
              >
                {metric === 'ALL' ? 'Semua' : metricLabels[metric]}
              </button>
            ))}
          </div>
        </div>

        {isLoading && achievements.length === 0 ? (
          <div className="achievement-empty-state">
            <Loader2 className="achievement-spin" size={22} />
            Memuat achievement
          </div>
        ) : filteredAchievements.length === 0 ? (
          <div className="achievement-empty-state">Achievement belum tersedia.</div>
        ) : (
          <div className="achievement-grid">
            {filteredAchievements.map((achievement) => {
              const percent = progressPercent(achievement.progress, achievement.milestone);
              return (
                <article
                  className={achievement.unlocked ? 'achievement-card is-unlocked' : 'achievement-card'}
                  key={achievement.achievementId}
                >
                  <div className="achievement-card-icon">
                    {achievement.unlocked ? <Medal size={22} /> : <Lock size={22} />}
                  </div>
                  <div>
                    <div className="achievement-card-title">
                      <h3>{achievement.name}</h3>
                      <span>{metricLabels[achievement.metric] || achievement.metric}</span>
                    </div>
                    {achievement.description && <p>{achievement.description}</p>}
                    <div className="achievement-progress-track">
                      <span style={{ width: `${percent}%` }} />
                    </div>
                    <div className="achievement-card-meta">
                      <span>{achievement.progress}/{achievement.milestone}</span>
                      <span>{achievement.unlocked ? formatDate(achievement.unlockedAt) : 'Terkunci'}</span>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
};
