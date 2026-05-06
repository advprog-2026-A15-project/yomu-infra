/**
 * authService.js
 * 
 * Implementation of Auth Service connecting to the Spring Boot backend.
 */

const API_URL = 'http://localhost:8080/api/auth';

const getAuthHeaders = () => {
  const userStr = localStorage.getItem('yomu_user');
  if (userStr) {
    const user = JSON.parse(userStr);
    if (user.token) {
      return {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user.token}`
      };
    }
  }
  return {
    'Content-Type': 'application/json'
  };
};

export const authService = {
  login: async (identifier, password) => {
    const response = await fetch(`${API_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ identifier, password }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => null);
      throw new Error(errorData?.message || 'Gagal login. Periksa username dan password.');
    }

    const data = await response.json();
    // data contains { token: "...", user: { id, username, ... } }
    return {
      token: data.token,
      ...data.user
    };
  },

  register: async (userData) => {
    const response = await fetch(`${API_URL}/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => null);
      throw new Error(errorData?.message || 'Pendaftaran gagal. Pastikan data valid atau email/username belum terpakai.');
    }

    const data = await response.json();
    return {
      token: data.token,
      ...data.user
    };
  },

  updateProfile: async (updateData) => {
    const response = await fetch(`${API_URL}/profile`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(updateData),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => null);
      throw new Error(errorData?.message || 'Gagal memperbarui profil.');
    }

    const data = await response.json();
    return {
      token: data.token,
      ...data.user
    };
  },

  deleteAccount: async () => {
    const response = await fetch(`${API_URL}/profile`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => null);
      throw new Error(errorData?.message || 'Gagal menghapus akun.');
    }
    
    return true;
  },

  googleLogin: async () => {
    // This is a simplified mock of Google SSO flow to match the prompt's simplicity.
    // In a real application, you'd use Google's client SDK to get a token and send it.
    const mockGoogleData = {
      email: 'user' + Math.floor(Math.random() * 1000) + '@gmail.com',
      username: 'google_user_' + Math.floor(Math.random() * 1000),
      displayName: 'Google User'
    };

    const response = await fetch(`${API_URL}/google`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(mockGoogleData),
    });

    if (!response.ok) {
      throw new Error('Gagal login dengan Google.');
    }

    const data = await response.json();
    return {
      token: data.token,
      ...data.user
    };
  }
};
