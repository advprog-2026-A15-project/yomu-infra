import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import { Mail, Lock, Loader2 } from 'lucide-react';

export const LoginForm = () => {
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [localError, setLocalError] = useState(null);
  
  const { login, isLoading, error } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLocalError(null);
    
    if (!identifier.trim() || !password) {
      setLocalError('Harap isi semua kolom');
      return;
    }

    try {
      await login(identifier, password);
      navigate('/profile');
    } catch {
      // Error is handled by context but we can do extra things if needed
    }
  };

  const displayError = localError || error;

  return (
    <form className="auth-form" onSubmit={handleSubmit}>
      {displayError && (
        <div className="alert alert-error">
          <span>{displayError}</span>
        </div>
      )}
      
      <div className="form-group">
        <label className="form-label" htmlFor="identifier">Username / Email</label>
        <div className="form-input-wrapper">
          <Mail className="form-input-icon" />
          <input
            id="identifier"
            type="text"
            className="form-input"
            placeholder="Masukkan username atau email"
            value={identifier}
            onChange={(e) => setIdentifier(e.target.value)}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="password">Password</label>
        <div className="form-input-wrapper">
          <Lock className="form-input-icon" />
          <input
            id="password"
            type="password"
            className="form-input"
            placeholder="Masukkan kata sandi"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={isLoading}
          />
        </div>
      </div>

      <button type="submit" className="btn-primary" disabled={isLoading}>
        {isLoading ? <Loader2 className="spin-icon" size={20} /> : null}
        {isLoading ? 'Memproses...' : 'Masuk'}
      </button>
    </form>
  );
};
