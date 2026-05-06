import { getAuthHeaders, readJsonOrThrow } from '../../../api/axios';

const API_URL = 'http://localhost:8080/api/clan';

export const clanService = {
  createClan: async (data) => {
    const res = await fetch(API_URL, {
      method: 'POST', headers: getAuthHeaders(), body: JSON.stringify(data),
    });
    return readJsonOrThrow(res, 'Gagal membuat clan.');
  },

  getClan: async (id) => {
    const res = await fetch(`${API_URL}/${id}`, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat clan.');
  },

  getLeaderboard: async (tier) => {
    const url = tier ? `${API_URL}/leaderboard?tier=${tier}` : `${API_URL}/leaderboard`;
    const res = await fetch(url, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat leaderboard.');
  },

  joinClan: async (clanId, userId) => {
    const res = await fetch(`${API_URL}/${clanId}/join?userId=${userId}`, {
      method: 'POST', headers: getAuthHeaders(),
    });
    if (!res.ok) throw new Error('Gagal bergabung clan.');
    return true;
  },

  getMembers: async (clanId) => {
    const res = await fetch(`${API_URL}/${clanId}/members`, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat anggota.');
  },

  endSeason: async () => {
    const res = await fetch(`${API_URL}/admin/end-season`, {
      method: 'POST', headers: getAuthHeaders(),
    });
    if (!res.ok) throw new Error('Gagal memproses end of season.');
    return true;
  },
};
