import { createContext, useContext, useEffect, useState } from 'react'

const AuthContext = createContext(null)

// Role-based permissions matrix
const ROLE_PERMISSIONS = {
  admin: {
    dashboard: true,
    complaints: true,
    liveTracking: true,
    notifications: true,
    users: true,
    roles: true,
    contractors: true,
    workOrders: true,
    analytics: true,
    sara: true,
    auditLogs: true,
    settings: true,
    profile: true,
    canManageUsers: true,
    canManageRoles: true,
    canManageSettings: true,
    canViewAnalytics: true,
    canViewAuditLogs: true,
    allAccess: true,
  },
  government: {
    dashboard: true,
    complaints: true,
    liveTracking: true,
    notifications: true,
    analytics: true,
    sara: true,
    profile: true,
    allAccess: true,
  },
  department_head: {
    dashboard: true,
    complaints: true,
    liveTracking: true,
    notifications: true,
    users: true,
    analytics: true,
    profile: true,
  },
  team_member: {
    complaints: true,
    notifications: true,
    profile: true,
  },
  citizen: {
    complaints: true,
    profile: true,
  }
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('admin_user')
    return stored ? JSON.parse(stored) : null
  })

  useEffect(() => {
    if (user) {
      localStorage.setItem('admin_user', JSON.stringify(user))
    } else {
      localStorage.removeItem('admin_user')
    }
  }, [user])

  // Check if user has permission for a specific feature
  const hasPermission = (permission) => {
    if (!user) return false
    const userPermissions = ROLE_PERMISSIONS[user.role] || {}
    return userPermissions[permission] === true || userPermissions.allAccess === true
  }

  // Check if user is super admin
  const isSuperAdmin = () => {
    return user?.role === 'admin' && user?.email === 'superadmin@citygovernment.gov'
  }

  const login = async (email, password) => {
    // Super Admin credentials
    const superAdminFallback = {
      email: 'superadmin@citygovernment.gov',
      name: 'Super Admin',
      role: 'admin',
      token: 'super-admin-token',
    }

    const adminFallback = {
      email: 'admin@sadaksevak.org',
      name: 'Sadak Admin',
      role: 'admin',
      token: 'mock-admin-token',
    }

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (!response.ok) {
        // Fallback to demo accounts
        if (email === 'superadmin@citygovernment.gov' && password === 'superadmin@123') {
          setUser(superAdminFallback)
          return { success: true }
        }
        if (email === 'admin@sadaksevak.org' && password === 'admin123') {
          setUser(adminFallback)
          return { success: true }
        }
        const error = await response.json()
        return { success: false, message: error.message || 'Login failed' }
      }

      const data = await response.json()
      const userData = {
        email,
        name: data.name || 'Admin User',
        role: data.role || 'admin',
        token: data.token || 'admin-token',
      }
      setUser(userData)
      return { success: true }
    } catch (error) {
      // Fallback to demo accounts
      if (email === 'superadmin@citygovernment.gov' && password === 'superadmin@123') {
        setUser(superAdminFallback)
        return { success: true }
      }
      if (email === 'admin@sadaksevak.org' && password === 'admin123') {
        setUser(adminFallback)
        return { success: true }
      }
      return { success: false, message: error.message || 'Network error' }
    }
  }

  const logout = () => setUser(null)

  return (
    <AuthContext.Provider value={{ user, setUser, login, logout, hasPermission, isSuperAdmin }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  return useContext(AuthContext)
}
