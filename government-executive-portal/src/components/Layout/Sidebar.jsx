import { NavLink } from 'react-router-dom'
import { Home, Users, ClipboardList, ShieldCheck, HardDrive, Activity, MapPin, Bell, FileText, Key, Settings, User, Briefcase, TrendingUp } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'

const navItems = [
  { label: 'Executive Dashboard', to: '/', icon: Home, permission: 'dashboard' },
  
  // City Operations
  { label: 'Complaint Resolution', to: '/complaints', icon: ClipboardList, permission: 'complaints' },
  { label: 'Live City Tracking', to: '/live-tracking', icon: MapPin, permission: 'liveTracking' },
  { label: 'Public Alerts', to: '/notifications', icon: Bell, permission: 'notifications' },
  
  // Management
  { label: 'Staff Directory', to: '/users', icon: Users, permission: 'users' },
  { label: 'Departments & Roles', to: '/roles', icon: Briefcase, permission: 'roles' },
  { label: 'Infrastructure Projects', to: '/contractors', icon: HardDrive, permission: 'contractors' },
  { label: 'Work Orders', to: '/work-orders', icon: ShieldCheck, permission: 'workOrders' },
  
  // Analytics & Reporting
  { label: 'Performance Analytics', to: '/analytics', icon: TrendingUp, permission: 'analytics' },
  { label: 'AI Insights (SARA)', to: '/sara', icon: Activity, permission: 'sara' },
  { label: 'System Audit Logs', to: '/audit-logs', icon: FileText, permission: 'auditLogs' },
  
  // Administration
  { label: 'System Settings', to: '/settings', icon: Settings, permission: 'settings' },
  { label: 'My Profile', to: '/profile', icon: User, permission: 'profile' },
]

function Sidebar() {
  const { user, hasPermission, isSuperAdmin } = useAuth()
  
  // Filter nav items based on user permissions
  const visibleItems = navItems.filter(item => hasPermission(item.permission))

  return (
    <aside className="sidebar">
      <div className="sidebar__brand">
        <div className="sidebar__logo">{isSuperAdmin() ? '👑' : 'CG'}</div>
        <div>
          <p className="sidebar__title">City Government</p>
          <p className="sidebar__subtitle">{isSuperAdmin() ? '🔒 Super Admin' : 'Executive Portal'}</p>
        </div>
      </div>

      <nav className="sidebar__nav">
        {visibleItems.map((item) => {
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
