import { getAuthHeaders, readJsonOrThrow } from '../../../api/axios';

const API_URL = 'http://localhost:8080/api/forum/comments';

export const forumService = {
  getComments: async (bacaanId) => {
    const url = bacaanId ? `${API_URL}?bacaanId=${bacaanId}` : API_URL;
    const res = await fetch(url, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat komentar.');
  },

  getCommentsTree: async (bacaanId) => {
    const url = bacaanId ? `${API_URL}/tree?bacaanId=${bacaanId}` : `${API_URL}/tree`;
    const res = await fetch(url, { headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal memuat diskusi.');
  },

  createComment: async (data) => {
    const res = await fetch(API_URL, {
      method: 'POST', headers: getAuthHeaders(), body: JSON.stringify(data),
    });
    return readJsonOrThrow(res, 'Gagal mengirim komentar.');
  },

  updateComment: async (commentId, content) => {
    const res = await fetch(`${API_URL}/${commentId}`, {
      method: 'PUT', headers: getAuthHeaders(), body: JSON.stringify({ commentContent: content }),
    });
    return readJsonOrThrow(res, 'Gagal mengedit komentar.');
  },

  deleteComment: async (commentId) => {
    const res = await fetch(`${API_URL}/${commentId}`, { method: 'DELETE', headers: getAuthHeaders() });
    return readJsonOrThrow(res, 'Gagal menghapus komentar.');
  },
};
