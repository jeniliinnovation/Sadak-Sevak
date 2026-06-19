import { NavLink } from 'react-router-dom'
import {
  Home, ClipboardList, MapPin, Users, Building2, Zap, BarChart3,
  Brain, FileText, Lock, Settings, Shield
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'

const navItems = [
  { label: 'Dashboard', to: '/', icon: Home },
  { label: 'Complaint Management', to: '/complaints', icon: ClipboardList },
  { label: 'Live City Tracking', to: '/live-tracking', icon: MapPin },
  { label: 'Staff Directory', to: '/staff', icon: Users },
  { label: 'Department Management', to: '/departments', icon: Building2 },
  { label: 'Infrastructure Projects', to: '/infrastructure', icon: Zap },
  { label: 'Performance Analytics', to: '/analytics', icon: BarChart3 },
  { label: 'AI Insights (SARA)', to: '/sara', icon: Brain },
  { label: 'System Audit Logs', to: '/audit-logs', icon: FileText },
  { label: 'Role & Permissions', to: '/roles', icon: Lock },
  { label: 'User Management', to: '/users', icon: Shield },
  { label: 'System Settings', to: '/settings', icon: Settings },
]

function Sidebar() {
  const { user, isSuperAdmin } = useAuth()

  return (
    <aside className="sidebar">
      <div className="sidebar__brand">
        <div className="sidebar__logo">👑</div>
        <div>
          <p className="sidebar__title">Super Admin</p>
          <p className="sidebar__subtitle">Full Access Portal</p>
        </div>
      </div>

      <nav className="sidebar__nav">
        {navItems.map((item) => {
          const Icon = item.icon
          return (
            <NavLink key={item.to} to={item.to} className={({ isActive }) => isActive ? 'sidebar__link sidebar__link--active' : 'sidebar__link'}>
              <Icon className="sidebar__icon" size={18} />
              <span>{item.label}</span>
            </NavLink>
          )
        })}
      </nav>
    </aside>
  )
}

export default Sidebar
