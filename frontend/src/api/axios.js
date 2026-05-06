const API_URL = 'http://localhost:8080/api';

export const getAuthHeaders = () => {
  const storedUser = localStorage.getItem('yomu_user');
  const baseHeaders = { 'Content-Type': 'application/json' };
  if (!storedUser) return baseHeaders;
  try {
    const user = JSON.parse(storedUser);
    return user.token
      ? { ...baseHeaders, Authorization: `Bearer ${user.token}` }
      : baseHeaders;
  } catch {
    return baseHeaders;
  }
};

export const readJsonOrThrow = async (response, fallbackMessage) => {
  if (response.ok) return response.json();
  const errorData = await response.json().catch(() => null);
  throw new Error(errorData?.message || fallbackMessage);
};

export default API_URL;
