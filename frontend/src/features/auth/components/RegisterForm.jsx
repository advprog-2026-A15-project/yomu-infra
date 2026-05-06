import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import { User, Mail, Lock, Phone, Loader2, Type } from 'lucide-react';

export const RegisterForm = () => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone: '',
    displayName: '',
    password: '',
    confirmPassword: ''
  });
  const [localError, setLocalError] = useState(null);
  
  const { register, isLoading, error } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.id]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLocalError(null);
    
    if (!formData.username || (!formData.email && !formData.phone) || !formData.displayName || !formData.password) {
      setLocalError('Harap isi semua kolom wajib (Email atau No. HP diperlukan)');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setLocalError('Konfirmasi password tidak cocok');
      return;
    }

    try {
      const submitData = { ...formData };
      delete submitData.confirmPassword;
      await register(submitData);
      navigate('/profile');
    } catch {
      // Error handled by context
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
        <label className="form-label" htmlFor="username">Username *</label>
        <div className="form-input-wrapper">
          <User className="form-input-icon" />
          <input
            id="username"
            type="text"
            className="form-input"
            placeholder="Pilih username unik"
            value={formData.username}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="displayName">Nama Tampilan (Display Name) *</label>
        <div className="form-input-wrapper">
          <Type className="form-input-icon" />
          <input
            id="displayName"
            type="text"
            className="form-input"
            placeholder="Nama yang akan tampil di forum"
            value={formData.displayName}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="email">Email</label>
        <div className="form-input-wrapper">
          <Mail className="form-input-icon" />
          <input
            id="email"
            type="email"
            className="form-input"
            placeholder="nama@email.com"
            value={formData.email}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="phone">Nomor HP</label>
        <div className="form-input-wrapper">
          <Phone className="form-input-icon" />
          <input
            id="phone"
            type="tel"
            className="form-input"
            placeholder="08xxxxxxxxxx"
            value={formData.phone}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="password">Password *</label>
        <div className="form-input-wrapper">
          <Lock className="form-input-icon" />
          <input
            id="password"
            type="password"
            className="form-input"
            placeholder="Minimal 8 karakter"
            value={formData.password}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="form-group">
        <label className="form-label" htmlFor="confirmPassword">Konfirmasi Password *</label>
        <div className="form-input-wrapper">
          <Lock className="form-input-icon" />
          <input
            id="confirmPassword"
            type="password"
            className="form-input"
            placeholder="Ulangi password"
            value={formData.confirmPassword}
            onChange={handleChange}
            disabled={isLoading}
          />
        </div>
      </div>

      <button type="submit" className="btn-primary" disabled={isLoading}>
        {isLoading ? <Loader2 className="spin-icon" size={20} /> : null}
        {isLoading ? 'Mendaftarkan...' : 'Daftar Akun'}
      </button>
    </form>
  );
};
