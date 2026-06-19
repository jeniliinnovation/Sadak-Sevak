import { createContext, useContext, useEffect, useState } from 'react'

const AuthContext = createContext(null)

// Super Admin has FULL ACCESS to all features
const SUPER_ADMIN_PERMISSIONS = {
  dashboard: true,
  complaints: true,
  liveTracking: true,
  staff: true,
  departments: true,
  infrastructure: true,
  analytics: true,
  sara: true,
  auditLogs: true,
  roles: true,
  settings: true,
  users: true,
  canManageUsers: true,
  canManageRoles: true,
  canManageSettings: true,
  canViewAnalytics: true,
  canViewAuditLogs: true,
  allAccess: true,
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('super_admin_user')
    if (stored) {
      const parsed = JSON.parse(stored)
      // Auto-fix stale tokens from previous sessions
      if (parsed.token === 'super-admin-token-12345' || parsed.token === 'super-admin-token-12345 ') {
        parsed.token = 'super-admin-token'
        localStorage.setItem('super_admin_user', JSON.stringify(parsed))
      }
      return parsed
    }
    return null
  })

  useEffect(() => {
    if (user) {
      localStorage.setItem('super_admin_user', JSON.stringify(user))
    } else {
      localStorage.removeItem('super_admin_user')
    }
  }, [user])

  const hasPermission = (permission) => {
    if (!user) return false
    return SUPER_ADMIN_PERMISSIONS[permission] === true || SUPER_ADMIN_PERMISSIONS.allAccess === true
  }

  const isSuperAdmin = () => {
    return user?.role === 'super_admin'
  }

  const login = async (email, password) => {
    const superAdminFallback = {
      id: '1',
      email: 'superadmin@citygovernment.gov',
      name: 'Super Admin',
      role: 'super_admin',
      token: 'super-admin-token',
    }

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (response.ok) {
        const data = await response.json()
        const userData = {
          id: data.id,
          email,
          name: data.name || 'Admin',
          role: data.role || 'super_admin',
          token: data.token,
        }
        setUser(userData)
        return { success: true }
      }
    } catch (error) {
      console.log('Using fallback auth')
    }

    // Fallback: Demo super admin credentials
    if (email === 'superadmin@citygovernment.gov' && password === 'superadmin@123') {
      setUser(superAdminFallback)
      return { success: true }
    }

    return { success: false, message: 'Invalid credentials' }
  }

  const logout = () => setUser(null)

  return (
    <AuthContext.Provider value={{ user, login, logout, hasPermission, isSuperAdmin }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  return useContext(AuthContext)
}
