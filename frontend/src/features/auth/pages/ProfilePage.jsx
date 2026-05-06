import { Navigate, Link } from 'react-router-dom';
import { ProfileForm } from '../components/ProfileForm';
import { useAuth } from '../hooks/useAuth';
import { LogOut, Home, Trophy } from 'lucide-react';
import '../styles/auth.css';

export const ProfilePage = () => {
  const { user, isLoading, logout } = useAuth();

  // If not logged in and not loading, redirect to login
  if (!user && !isLoading) {
    return <Navigate to="/login" replace />;
  }

  if (isLoading && !user) {
    return (
      <div className="auth-container" style={{ justifyContent: 'center' }}>
        <div className="spin-icon">⏳</div>
      </div>
    );
  }

  return (
    <div className="auth-container">
      <div className="auth-card" style={{ maxWidth: '600px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <h1 className="auth-title" style={{ margin: 0, fontSize: '1.5rem' }}>Pengaturan Profil</h1>
          <div style={{ display: 'flex', gap: '1rem' }}>
            <Link to="/achievements" title="Achievement" style={{ color: 'var(--auth-text-muted)' }}>
              <Trophy size={24} />
            </Link>
            <Link to="/" title="Kembali ke Beranda" style={{ color: 'var(--auth-text-muted)' }}>
              <Home size={24} />
            </Link>
            <button 
              onClick={logout} 
              style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--auth-text-muted)' }}
              title="Keluar"
            >
              <LogOut size={24} />
            </button>
          </div>
        </div>
        
        <ProfileForm />
      </div>
    </div>
  );
};
