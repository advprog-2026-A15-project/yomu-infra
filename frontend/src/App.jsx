import { Routes, Route, Link } from 'react-router-dom'
import { LoginPage, RegisterPage, ProfilePage } from './features/auth'
import { AchievementAdminPage, AchievementsPage } from './features/achievements'
import { LearningPage } from './features/learning/pages/LearningPage'
import { BacaanDetailPage } from './features/learning/pages/BacaanDetailPage'
import { ClanPage } from './features/clan/pages/ClanPage'
import { Navbar } from './components/Navbar'

function Home() {
  return (
    <div className="page-container" style={{ textAlign: 'center', marginTop: '60px' }}>
      <h1 style={{ fontSize: '64px', color: 'var(--primary)', fontWeight: '900', letterSpacing: '-2px', marginBottom: '16px' }}>
        Yomu
      </h1>
      <h2 style={{ fontSize: '28px', color: 'var(--text-main)', marginBottom: '40px' }}>
        Tingkatkan literasimu, mulai hari ini.
      </h2>
      <p style={{ fontSize: '18px', color: 'var(--text-light)', maxWidth: '600px', margin: '0 auto 40px', lineHeight: '1.6' }}>
        Latih kemampuan membaca dan mengolah informasimu dengan gamifikasi yang seru. 
        Selesaikan misi, kumpulkan poin, dan bersainglah di Liga!
      </p>
      
      <div style={{ display: 'flex', gap: '20px', justifyContent: 'center' }}>
        <Link to="/learning" className="btn btn-primary" style={{ fontSize: '20px', padding: '16px 32px' }}>
          MULAI BELAJAR
        </Link>
        <Link to="/clan" className="btn btn-secondary" style={{ fontSize: '20px', padding: '16px 32px' }}>
          GABUNG LIGA
        </Link>
      </div>
    </div>
  );
}

function App() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Navbar />
      <main style={{ flex: 1 }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/achievements" element={<AchievementsPage />} />
          <Route path="/achievements/admin" element={<AchievementAdminPage />} />
          
          <Route path="/learning" element={<LearningPage />} />
          <Route path="/learning/:id" element={<BacaanDetailPage />} />
          
          <Route path="/clan" element={<ClanPage />} />
        </Routes>
      </main>
    </div>
  )
}

export default App
