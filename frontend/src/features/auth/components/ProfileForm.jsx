import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { User, Mail, Lock, Phone, Loader2, Type, AlertTriangle } from 'lucide-react';

const toProfileFormData = (user) => ({
  username: user?.username || '',
  email: user?.email || '',
  phone: user?.phone || '',
  displayName: user?.displayName || '',
  password: '',
});

export const ProfileForm = () => {
  const { user, updateProfile, deleteAccount, isLoading, error } = useAuth();
  const [formData, setFormData] = useState(() => toProfileFormData(user));
  const [localError, setLocalError] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.id]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLocalError(null);
    setSuccessMsg(null);
    
    // Only send fields that have been changed or are not empty
    const updateData = {};
    Object.keys(formData).forEach(key => {
      if (formData[key] !== '' && formData[key] !== user[key]) {
        updateData[key] = formData[key];
      }
    });

    if (Object.keys(updateData).length === 0) {
      setLocalError('Tidak ada perubahan untuk disimpan.');
      return;
    }

    try {
      await updateProfile(updateData);
      setSuccessMsg('Profil berhasil diperbarui!');
      setFormData(prev => ({ ...prev, password: '' })); // clear password field
    } catch {
      // Error handled by context
    }
  };

  const handleDelete = async () => {
    try {
      await deleteAccount();
      // Router will handle redirect via Auth check usually, or we can force it here
    } catch (err) {
      setLocalError(err.message);
    }
  };

  const displayError = localError || error;

  if (!user) return null;

  return (
    <div className="profile-container">
      <div className="profile-header">
        <div className="profile-avatar">
          {user.displayName ? user.displayName.charAt(0).toUpperCase() : 'U'}
        </div>
        <div className="profile-info">
          <h3>{user.displayName}</h3>
          <p>{user.role} • {user.email || user.username}</p>
        </div>
      </div>

      <form className="auth-form" onSubmit={handleSubmit}>
        {displayError && (
          <div className="alert alert-error">
            <span>{displayError}</span>
          </div>
        )}
        {successMsg && (
          <div className="alert alert-success">
            <span>{successMsg}</span>
          </div>
        )}
        
        <div className="form-group">
          <label className="form-label" htmlFor="username">Username</label>
          <div className="form-input-wrapper">
            <User className="form-input-icon" />
            <input
              id="username"
              type="text"
              className="form-input"
              value={formData.username}
              onChange={handleChange}
              disabled={isLoading}
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label" htmlFor="displayName">Nama Tampilan</label>
          <div className="form-input-wrapper">
            <Type className="form-input-icon" />
            <input
              id="displayName"
              type="text"
              className="form-input"
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
              value={formData.email}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="Tambahkan email (Opsional)"
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
              value={formData.phone}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="Tambahkan No HP (Opsional)"
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label" htmlFor="password">Ganti Password</label>
          <div className="form-input-wrapper">
            <Lock className="form-input-icon" />
            <input
              id="password"
              type="password"
              className="form-input"
              placeholder="Kosongkan jika tidak ingin mengganti"
              value={formData.password}
              onChange={handleChange}
              disabled={isLoading}
            />
          </div>
        </div>

        <button type="submit" className="btn-primary" disabled={isLoading}>
          {isLoading ? <Loader2 className="spin-icon" size={20} /> : null}
          {isLoading ? 'Menyimpan...' : 'Simpan Perubahan'}
        </button>
      </form>

      <div className="divider">ZONA BERBAHAYA</div>
      
      {!showDeleteConfirm ? (
        <button 
          type="button" 
          className="btn-danger" 
          onClick={() => setShowDeleteConfirm(true)}
        >
          Hapus Akun
        </button>
      ) : (
        <div className="alert alert-error" style={{flexDirection: 'column', alignItems: 'flex-start', gap: '1rem'}}>
          <div style={{display: 'flex', alignItems: 'center', gap: '0.5rem'}}>
            <AlertTriangle size={20} />
            <span>Apakah Anda yakin? Tindakan ini tidak dapat dibatalkan.</span>
          </div>
          <div style={{display: 'flex', gap: '1rem', width: '100%'}}>
            <button 
              type="button" 
              className="btn-danger" 
              style={{flex: 1, marginTop: 0}}
              onClick={handleDelete}
              disabled={isLoading}
            >
              Ya, Hapus
            </button>
            <button 
              type="button" 
              className="btn-primary" 
              style={{flex: 1, marginTop: 0, backgroundColor: 'var(--auth-surface)'}}
              onClick={() => setShowDeleteConfirm(false)}
            >
              Batal
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
