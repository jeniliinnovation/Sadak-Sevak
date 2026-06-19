import { useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { Search, Bell, ChevronDown, LogOut } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'

function Header() {
  const { user, logout, isSuperAdmin } = useAuth()
  const navigate = useNavigate()

  const initials = useMemo(() => {
    if (!user?.name) return 'SA'
    return user.name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
  }, [user])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="topbar">
      <div className="topbar__search">
        <Search size={18} className="topbar__search-icon" />
        <input type="search" placeholder="Search complaints, staff, departments, projects..." />
      </div>
      <div className="topbar__actions">
        <button className="topbar__icon-btn" type="button" aria-label="Notifications">
          <Bell size={20} />
        </button>
        <div className="topbar__profile">
          <div className="topbar__avatar">{initials}</div>
          <div>
            <p className="topbar__username">{user?.name || 'Administrator'}</p>
            <p className="topbar__role">👑 Super Admin - Full Access</p>
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
