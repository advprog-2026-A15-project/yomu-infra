const API_URL = 'http://localhost:8080/api/achievements';

const getAuthHeaders = () => {
  const storedUser = localStorage.getItem('yomu_user');
  const baseHeaders = {
    'Content-Type': 'application/json',
  };

  if (!storedUser) {
    return baseHeaders;
  }

  try {
    const user = JSON.parse(storedUser);
    return user.token
      ? { ...baseHeaders, Authorization: `Bearer ${user.token}` }
      : baseHeaders;
  } catch {
    return baseHeaders;
  }
};

const readJsonOrThrow = async (response, fallbackMessage) => {
  if (response.ok) {
    return response.json();
  }

  const errorData = await response.json().catch(() => null);
  throw new Error(errorData?.message || fallbackMessage);
};

export const achievementService = {
  listAchievements: async (userId) => {
    const response = await fetch(`${API_URL}?userId=${encodeURIComponent(userId)}`, {
      headers: getAuthHeaders(),
    });

    return readJsonOrThrow(response, 'Gagal memuat achievement.');
  },

  listDailyMissions: async (userId) => {
    const response = await fetch(`${API_URL}/daily-missions/active?userId=${encodeURIComponent(userId)}`, {
      headers: getAuthHeaders(),
    });

    return readJsonOrThrow(response, 'Gagal memuat daily mission.');
  },

  claimDailyMissionReward: async (missionId, userId) => {
    const response = await fetch(
      `${API_URL}/daily-missions/${encodeURIComponent(missionId)}/claim?userId=${encodeURIComponent(userId)}`,
      {
        method: 'POST',
        headers: getAuthHeaders(),
      },
    );

    return readJsonOrThrow(response, 'Gagal klaim reward.');
  },

  createAchievement: async (payload) => {
    const response = await fetch(`${API_URL}/admin`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(payload),
    });

    return readJsonOrThrow(response, 'Gagal membuat achievement.');
  },

  createDailyMission: async (payload) => {
    const response = await fetch(`${API_URL}/admin/daily-missions`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(payload),
    });

    return readJsonOrThrow(response, 'Gagal membuat daily mission.');
  },
};
