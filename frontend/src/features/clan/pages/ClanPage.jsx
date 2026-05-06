import { useState, useEffect } from 'react';
import { clanService } from '../services/clanService';
import { useAuth } from '../../auth/hooks/useAuth';

export const ClanPage = () => {
  const { user } = useAuth();
  const [clans, setClans] = useState([]);
  const [tierFilter, setTierFilter] = useState('');
  const [loading, setLoading] = useState(true);

  const [showCreate, setShowCreate] = useState(false);
  const [newClanName, setNewClanName] = useState('');
  const [newClanDesc, setNewClanDesc] = useState('');

  useEffect(() => {
    loadLeaderboard();
  }, [tierFilter]);

  const loadLeaderboard = async () => {
    try {
      setLoading(true);
      const data = await clanService.getLeaderboard(tierFilter);
      setClans(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateClan = async (e) => {
    e.preventDefault();
    if (!newClanName.trim()) return;
    
    try {
      await clanService.createClan({
        name: newClanName,
        description: newClanDesc,
        leaderId: user.id
      });
      alert('Clan berhasil dibuat!');
      setShowCreate(false);
      loadLeaderboard();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleJoinClan = async (clanId) => {
    try {
      await clanService.joinClan(clanId, user.id);
      alert('Permintaan bergabung telah dikirim!');
    } catch (error) {
      alert(error.message);
    }
  };

  const getTierColor = (tier) => {
    switch(tier) {
      case 'BRONZE': return '#cd7f32';
      case 'SILVER': return '#c0c0c0';
      case 'GOLD': return '#ffd700';
      case 'DIAMOND': return '#b9f2ff';
      default: return 'var(--border-color)';
    }
  };

  return (
    <div className="page-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px' }}>
        <div>
          <h1 className="page-title">Liga Yomu</h1>
          <p className="page-subtitle">Berkompetisi bersama clanmu dan raih divisi tertinggi!</p>
        </div>
        <button onClick={() => setShowCreate(!showCreate)} className="btn btn-secondary">
          {showCreate ? 'BATAL' : '+ BUAT CLAN'}
        </button>
      </div>

      {showCreate && (
        <form onSubmit={handleCreateClan} className="card" style={{ marginBottom: '32px', backgroundColor: '#f0f9ff', borderColor: 'var(--secondary)' }}>
          <h2 style={{ marginTop: 0, marginBottom: '16px' }}>Buat Clan Baru</h2>
          <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', fontWeight: 'bold', marginBottom: '8px' }}>Nama Clan</label>
              <input value={newClanName} onChange={e => setNewClanName(e.target.value)} placeholder="Masukkan nama clan..." required />
            </div>
            <div style={{ flex: 2 }}>
              <label style={{ display: 'block', fontWeight: 'bold', marginBottom: '8px' }}>Deskripsi</label>
              <input value={newClanDesc} onChange={e => setNewClanDesc(e.target.value)} placeholder="Deskripsi singkat clan..." />
            </div>
          </div>
          <button type="submit" className="btn btn-primary">BUAT SEKARANG</button>
        </form>
      )}

      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <div style={{ display: 'flex', padding: '16px 24px', backgroundColor: 'var(--border-light)', borderBottom: '2px solid var(--border-color)', gap: '16px', alignItems: 'center' }}>
          <span style={{ fontWeight: 'bold', marginRight: 'auto' }}>Filter Divisi:</span>
          {['', 'BRONZE', 'SILVER', 'GOLD', 'DIAMOND'].map(t => (
            <button 
              key={t} 
              onClick={() => setTierFilter(t)}
              className={tierFilter === t ? 'btn btn-secondary' : 'btn btn-outline'}
              style={{ padding: '8px 16px', fontSize: '14px' }}
            >
              {t === '' ? 'SEMUA' : t}
            </button>
          ))}
        </div>

        {loading ? (
          <div style={{ padding: '48px', textAlign: 'center' }}>Memuat papan peringkat...</div>
        ) : clans.length === 0 ? (
          <div style={{ padding: '48px', textAlign: 'center', color: 'var(--text-light)' }}>
            Belum ada clan di divisi ini.
          </div>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ backgroundColor: 'var(--bg-page)' }}>
                <th style={{ padding: '16px 24px', borderBottom: '2px solid var(--border-color)', width: '60px' }}>Rank</th>
                <th style={{ padding: '16px 24px', borderBottom: '2px solid var(--border-color)' }}>Nama Clan</th>
                <th style={{ padding: '16px 24px', borderBottom: '2px solid var(--border-color)', width: '120px' }}>Divisi</th>
                <th style={{ padding: '16px 24px', borderBottom: '2px solid var(--border-color)', width: '120px', textAlign: 'right' }}>Total Skor</th>
                <th style={{ padding: '16px 24px', borderBottom: '2px solid var(--border-color)', width: '140px', textAlign: 'center' }}>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {clans.map((clan, idx) => (
                <tr key={clan.id} style={{ borderBottom: '1px solid var(--border-light)' }}>
                  <td style={{ padding: '16px 24px', fontWeight: '900', fontSize: '20px', color: idx < 3 ? 'var(--primary)' : 'inherit' }}>
                    {idx + 1}
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ fontWeight: 'bold', fontSize: '18px' }}>{clan.name}</div>
                    <div style={{ fontSize: '14px', color: 'var(--text-light)' }}>{clan.description}</div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <span style={{ 
                      padding: '4px 12px', 
                      borderRadius: '16px', 
                      backgroundColor: getTierColor(clan.tier),
                      color: clan.tier === 'DIAMOND' ? '#000' : '#fff',
                      fontWeight: 'bold',
                      fontSize: '12px'
                    }}>
                      {clan.tier}
                    </span>
                  </td>
                  <td style={{ padding: '16px 24px', textAlign: 'right', fontWeight: 'bold', fontSize: '18px' }}>
                    {clan.totalScore.toLocaleString()}
                  </td>
                  <td style={{ padding: '16px 24px', textAlign: 'center' }}>
                    <button onClick={() => handleJoinClan(clan.id)} className="btn btn-outline" style={{ padding: '8px 16px', fontSize: '12px' }}>
                      GABUNG
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};
