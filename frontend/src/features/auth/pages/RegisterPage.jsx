import { Link, Navigate } from 'react-router-dom';
import { RegisterForm } from '../components/RegisterForm';
import { GoogleSSOButton } from '../components/GoogleSSOButton';
import { useAuth } from '../hooks/useAuth';
import '../styles/auth.css';

export const RegisterPage = () => {
  const { user, isLoading } = useAuth();

  // If already logged in, redirect to profile or dashboard
  if (user && !isLoading) {
    return <Navigate to="/profile" replace />;
  }

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-header">
          <h1 className="auth-title">Buat Akun Yomu</h1>
          <p className="auth-subtitle">Bergabunglah untuk mulai berlatih literasi.</p>
        </div>
        
        <RegisterForm />
        
        <div className="divider">ATAU</div>
        
        <GoogleSSOButton isLogin={false} />
        
        <div className="auth-footer">
          Sudah punya akun? <Link to="/login" className="auth-link">Masuk di sini</Link>
        </div>
      </div>
    </div>
  );
};
