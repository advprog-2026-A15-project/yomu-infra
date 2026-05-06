import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../features/auth/hooks/useAuth';

export const Navbar = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <nav className="navbar">
      <Link to="/" className="nav-brand">Yomu</Link>
      
      {user ? (
        <div className="nav-links">
          <Link to="/learning" className="nav-item">Belajar</Link>
          <Link to="/clan" className="nav-item">Liga</Link>
          <Link to="/achievements" className="nav-item">Misi</Link>
          <div className="nav-user">
            <Link to="/profile" className="btn btn-outline" style={{ padding: '8px 16px', fontSize: '14px' }}>
              Profil ({user.username})
            </Link>
            <button onClick={handleLogout} className="btn btn-danger" style={{ padding: '8px 16px', fontSize: '14px' }}>
              Keluar
            </button>
          </div>
        </div>
      ) : (
        <div className="nav-links">
          <Link to="/login" className="btn btn-outline" style={{ padding: '8px 16px', fontSize: '14px' }}>Masuk</Link>
          <Link to="/register" className="btn btn-primary" style={{ padding: '8px 16px', fontSize: '14px' }}>Daftar</Link>
        </div>
      )}
    </nav>
  );
};
