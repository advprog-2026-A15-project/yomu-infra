import { getAuthHeaders, readJsonOrThrow } from '../../../api/axios';

const API_URL = 'http://localhost:8080/api/learning';

export const learningService = {
  listBacaan: async (category) => {
    const url = category ? `${API_URL}/bacaan?category=${encodeURIComponent(category)}` : `${API_URL}/bacaan`;
    const res = await fetch(url, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat daftar bacaan.');
  },

  getBacaan: async (id) => {
    const res = await fetch(`${API_URL}/bacaan/${id}`, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat bacaan.');
  },

  createBacaan: async (data) => {
    const res = await fetch(`${API_URL}/bacaan`, {
      method: 'POST', headers: getAuthHeaders(), body: JSON.stringify(data),
    });
    return readJsonOrThrow(res, 'Gagal membuat bacaan.');
  },

  deleteBacaan: async (id) => {
    const res = await fetch(`${API_URL}/bacaan/${id}`, { method: 'DELETE', headers: getAuthHeaders() });
    if (!res.ok) throw new Error('Gagal menghapus bacaan.');
    return true;
  },

  getQuestions: async (bacaanId) => {
    const res = await fetch(`${API_URL}/bacaan/${bacaanId}/questions`, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat soal.');
  },

  addQuestion: async (data) => {
    const res = await fetch(`${API_URL}/questions`, {
      method: 'POST', headers: getAuthHeaders(), body: JSON.stringify(data),
    });
    return readJsonOrThrow(res, 'Gagal menambah soal.');
  },

  submitQuiz: async (bacaanId, data) => {
    const res = await fetch(`${API_URL}/bacaan/${bacaanId}/quiz`, {
      method: 'POST', headers: getAuthHeaders(), body: JSON.stringify(data),
    });
    return readJsonOrThrow(res, 'Gagal mengirim jawaban kuis.');
  },

  checkQuizStatus: async (bacaanId, userId) => {
    const res = await fetch(`${API_URL}/bacaan/${bacaanId}/quiz/status?userId=${userId}`, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal mengecek status kuis.');
  },
};
