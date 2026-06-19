import { useMemo, useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Search, Bell, ChevronDown, LogOut } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { apiFetch } from '../../services/api'

function Header() {
  const { user, logout, isSuperAdmin } = useAuth()
  const navigate = useNavigate()
  const [unreadCount, setUnreadCount] = useState(0)
  const lastCountRef = useRef(0)

  const initials = useMemo(() => {
    if (!user?.name) return 'AD'
    return user.name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
  }, [user])

  // Request browser permission for HTML5 Notifications
  useEffect(() => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      if (Notification.permission === 'default') {
        Notification.requestPermission()
      }
    }
  }, [])

  // Poll for notifications in the background to simulate real-time notifications
  useEffect(() => {
    const fetchUnreadCount = async () => {
      try {
        const result = await apiFetch('/notifications')
        if (result && Array.isArray(result)) {
          const unreadItems = result.filter(item => item.unread === true || item.read === false)
          const unread = unreadItems.length

          // If count increased, trigger a browser push notification for the newest unread message
          if (unread > lastCountRef.current && lastCountRef.current > 0) {
            const newest = unreadItems[0]
            if (newest && typeof window !== 'undefined' && 'Notification' in window && Notification.permission === 'granted') {
              new Notification('Sadak Sevak Update', {
                body: newest.message,
                icon: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png'
              })
            }
          }

          lastCountRef.current = unread
          setUnreadCount(unread)
        }
      } catch (err) {
        console.warn('Failed to fetch live notifications:', err)
      }
    }

    fetchUnreadCount()

    // Poll every 10 seconds
    const interval = setInterval(fetchUnreadCount, 10000)
    return () => clearInterval(interval)
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="topbar">
      <div className="topbar__search">
        <Search size={18} className="topbar__search-icon" />
        <input type="search" placeholder="Search complaints, staff, projects, reports..." />
      </div>
      <div className="topbar__actions">
        <button 
          className="topbar__icon-btn" 
          type="button" 
          aria-label="Notifications"
          onClick={() => navigate('/notifications')}
          style={{ position: 'relative' }}
        >
          <Bell size={20} />
          {unreadCount > 0 && (
            <span style={{
              position: 'absolute',
              top: '4px',
              right: '4px',
              background: 'var(--danger)',
              color: 'white',
              borderRadius: '50%',
              width: '18px',
              height: '18px',
              fontSize: '0.7rem',
              fontWeight: 'bold',
              display: 'grid',
              placeItems: 'center',
              boxShadow: '0 0 0 2px var(--surface)'
            }}>
              {unreadCount}
            </span>
          )}
        </button>
        <div className="topbar__profile">
          <div className="topbar__avatar">{initials}</div>
          <div>
            <p className="topbar__username">{user?.name || 'Admin User'}</p>
            <p className="topbar__role">{isSuperAdmin() ? '🔒 Super Admin' : (user?.role || 'Administrator')}</p>
          </div>
          <ChevronDown size={16} />
        </div>
        <button className="topbar__icon-btn" type="button" onClick={handleLogout} aria-label="Logout">
          <LogOut size={18} />
        </button>
      </div>
    </header>
  )
}

export default Header
