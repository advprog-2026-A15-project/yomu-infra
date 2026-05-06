import { Link, Navigate } from 'react-router-dom';
import { LoginForm } from '../components/LoginForm';
import { GoogleSSOButton } from '../components/GoogleSSOButton';
import { useAuth } from '../hooks/useAuth';
import '../styles/auth.css';

export const LoginPage = () => {
  const { user, isLoading } = useAuth();

  // If already logged in, redirect to profile or dashboard
  if (user && !isLoading) {
    return <Navigate to="/profile" replace />;
  }

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-header">
          <h1 className="auth-title">Selamat Datang di Yomu</h1>
          <p className="auth-subtitle">Tingkatkan literasimu mulai hari ini.</p>
        </div>
        
        <LoginForm />
        
        <div className="divider">ATAU</div>
        
        <GoogleSSOButton isLogin={true} />
        
        <div className="auth-footer">
          Belum punya akun? <Link to="/register" className="auth-link">Daftar sekarang</Link>
        </div>
      </div>
    </div>
  );
};
