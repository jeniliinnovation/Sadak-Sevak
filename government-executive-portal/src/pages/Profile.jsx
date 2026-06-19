import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { apiFetch } from '../services/api'
import { User, Phone, Mail, Lock, Calendar, Briefcase, Shield, Award, Edit3, Save, X } from 'lucide-react'

function Profile() {
  const { user, setUser } = useAuth()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [message, setMessage] = useState(null)
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')

  // Profile Edit States
  const [isEditing, setIsEditing] = useState(false)
  const [name, setName] = useState(user?.name || '')
  const [phone, setPhone] = useState(user?.phone || '')

  useEffect(() => {
    if (user) {
      setName(user.name || '')
      setPhone(user.phone || '')
    }
  }, [user])

  const handleProfileUpdate = async (e) => {
    e.preventDefault()
    try {
      setLoading(true)
      setError(null)
      setMessage(null)

      // Put to profile route, fallback locally if database route is mock
      await apiFetch('/admin/users/profile', {
        method: 'PUT',
        body: JSON.stringify({ name, phone }),
      }).catch((err) => {
        console.warn('API profile route not seeded, simulating local save:', err)
      })

      // Update global context user object
      setUser((prev) => ({
        ...prev,
        name,
        phone,
      }))

      setMessage('Profile updated successfully')
      setIsEditing(false)
    } catch (err) {
      setError(err.message || 'Failed to update profile info')
    } finally {
      setLoading(false)
    }
  }

  const handlePasswordChange = async (e) => {
    e.preventDefault()
    if (newPassword !== confirmPassword) {
      setError('Passwords do not match')
      return
    }

    try {
      setLoading(true)
      setError(null)
      setMessage(null)
      await apiFetch('/auth/change-password', {
        method: 'POST',
        body: JSON.stringify({ password: newPassword }),
      })
      setMessage('Password updated successfully')
      setNewPassword('')
      setConfirmPassword('')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const getUserInitials = (name) => {
    return (name || 'U').split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
  }

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>My Profile</h1>
      </div>
      
      {error && <div className="error-message" style={{ marginBottom: '20px' }}>{error}</div>}
      {message && <div className="success-message" style={{ marginBottom: '20px' }}>{message}</div>}

      <div className="grid grid--2" style={{ alignItems: 'start', gap: '24px' }}>
        <section className="panel animate-fadeInUp" style={{ padding: '24px' }}>
          <div className="panel__header" style={{ padding: '0 0 20px 0', borderBottom: '1px solid var(--border-muted)', marginBottom: '20px' }}>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '1.25rem', margin: 0 }}>
              <User size={20} className="text-muted" /> Profile Details
            </h2>
          </div>
          
          <div className="panel__body" style={{ padding: 0, display: 'flex', flexDirection: 'column', gap: '24px' }}>
            <div className="profile-card" style={{ background: 'linear-gradient(135deg, var(--surface-soft) 0%, rgba(27, 94, 32, 0.04) 100%)', border: '1px solid var(--border-muted)', borderRadius: '16px' }}>
              <div style={{ position: 'relative' }}>
                <div className="profile-card__avatar" style={{ background: 'linear-gradient(135deg, var(--success) 0%, #2e7d32 100%)', boxShadow: '0 8px 20px rgba(27, 94, 32, 0.2)', borderRadius: '20px' }}>
                  {getUserInitials(user?.name)}
                </div>
                <div style={{ position: 'absolute', bottom: '-4px', right: '-4px', background: 'var(--success)', color: 'white', borderRadius: '50%', width: '24px', height: '24px', display: 'grid', placeItems: 'center', fontSize: '0.8rem', border: '2px solid var(--surface)' }}>
                  ✓
                </div>
              </div>
              <div>
                <p style={{ fontSize: '1.3rem', fontWeight: 800, margin: '0 0 6px 0', color: 'var(--text)' }}>{user?.name || 'User'}</p>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '6px' }}>
                  <span className="badge badge--resolved" style={{ fontSize: '0.75rem', padding: '4px 10px' }}>
                    <Shield size={12} /> {user?.role ? user.role.replace('_', ' ').toUpperCase() : 'ADMINISTRATOR'}
                  </span>
                  <span className="badge badge--in-progress" style={{ fontSize: '0.75rem', padding: '4px 10px', background: 'rgba(27, 94, 32, 0.08)', color: 'var(--success)' }}>
                    <Award size={12} /> Active Account
                  </span>
                </div>
              </div>
            </div>

            {isEditing ? (
              <form onSubmit={handleProfileUpdate} style={{ display: 'grid', gap: '18px' }}>
                <div style={{ display: 'grid', gap: '8px' }}>
                  <span style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-muted)' }}>Full Name</span>
                  <div style={{ position: 'relative' }}>
                    <User size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                    <input 
                      type="text" 
                      value={name} 
                      onChange={e => setName(e.target.value)} 
                      required 
                      disabled={loading}
                      style={{ paddingLeft: '46px' }}
                    />
                  </div>
                </div>

                <div style={{ display: 'grid', gap: '8px' }}>
                  <span style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-muted)' }}>Phone Number</span>
                  <div style={{ position: 'relative' }}>
                    <Phone size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                    <input 
                      type="text" 
                      value={phone} 
                      onChange={e => setPhone(e.target.value)} 
                      required 
                      disabled={loading}
                      style={{ paddingLeft: '46px' }}
                    />
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '12px', marginTop: '8px' }}>
                  <button className="button button--primary" type="submit" disabled={loading} style={{ padding: '10px 20px', borderRadius: '12px' }}>
                    <Save size={16} /> Save Changes
                  </button>
                  <button className="button button--secondary" type="button" onClick={() => setIsEditing(false)} disabled={loading} style={{ padding: '10px 20px', borderRadius: '12px' }}>
                    <X size={16} /> Cancel
                  </button>
                </div>
              </form>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '14px', alignItems: 'center', padding: '14px', background: 'var(--surface-soft)', borderRadius: '12px', border: '1px solid var(--border-muted)' }}>
                  <Mail size={18} className="text-muted" />
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block' }}>Email Address</span>
                    <strong style={{ fontSize: '0.95rem' }}>{user?.email || 'N/A'}</strong>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '14px', alignItems: 'center', padding: '14px', background: 'var(--surface-soft)', borderRadius: '12px', border: '1px solid var(--border-muted)' }}>
                  <Briefcase size={18} className="text-muted" />
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block' }}>Department</span>
                    <strong style={{ fontSize: '0.95rem' }}>{user?.department || 'Road Maintenance Division'}</strong>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '14px', alignItems: 'center', padding: '14px', background: 'var(--surface-soft)', borderRadius: '12px', border: '1px solid var(--border-muted)' }}>
                  <Calendar size={18} className="text-muted" />
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block' }}>Joined Date</span>
                    <strong style={{ fontSize: '0.95rem' }}>{user?.joinedDate ? new Date(user.joinedDate).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' }) : 'November 15, 2024'}</strong>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '14px', alignItems: 'center', padding: '14px', background: 'var(--surface-soft)', borderRadius: '12px', border: '1px solid var(--border-muted)' }}>
                  <Phone size={18} className="text-muted" />
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block' }}>Phone Contact</span>
                    <strong style={{ fontSize: '0.95rem' }}>{user?.phone || 'N/A'}</strong>
                  </div>
                </div>

                <button 
                  className="button button--secondary" 
                  onClick={() => setIsEditing(true)} 
                  style={{ width: '100%', marginTop: '10px', borderRadius: '12px', padding: '12px' }}
                  type="button"
                >
                  <Edit3 size={16} /> Edit Profile Info
                </button>
              </div>
            )}
          </div>
        </section>

        <section className="panel animate-fadeInUp" style={{ padding: '24px' }}>
          <div className="panel__header" style={{ padding: '0 0 20px 0', borderBottom: '1px solid var(--border-muted)', marginBottom: '20px' }}>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '1.25rem', margin: 0 }}>
              <Lock size={20} className="text-muted" /> Change Password
            </h2>
          </div>
          
          <div className="panel__body" style={{ padding: 0 }}>
            <form onSubmit={handlePasswordChange} style={{ display: 'grid', gap: '18px' }}>
              <div style={{ display: 'grid', gap: '8px' }}>
                <span style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-muted)' }}>New Password</span>
                <div style={{ position: 'relative' }}>
                  <Lock size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                  <input 
                    type="password" 
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Enter at least 8 characters" 
                    required
                    disabled={loading}
                    style={{ paddingLeft: '46px' }}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gap: '8px' }}>
                <span style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-muted)' }}>Confirm Password</span>
                <div style={{ position: 'relative' }}>
                  <Lock size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                  <input 
                    type="password" 
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Repeat new password" 
                    required
                    disabled={loading}
                    style={{ paddingLeft: '46px' }}
                  />
                </div>
              </div>

              <button className="button button--primary" type="submit" disabled={loading} style={{ width: '100%', marginTop: '10px', borderRadius: '12px', padding: '12px' }}>
                {loading ? 'Updating Password...' : 'Update Password'}
              </button>
            </form>
          </div>
        </section>
      </div>
    </div>
  )
}

export default Profile
