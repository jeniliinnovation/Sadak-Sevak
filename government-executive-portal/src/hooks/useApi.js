import { useState, useEffect } from 'react'
import { apiFetch } from '../services/api'

export function useApi(path, options = {}) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    let isMounted = true

    const fetchData = async () => {
      try {
        setLoading(true)
        setError(null)
        const result = await apiFetch(path, options)
        if (isMounted) {
          setData(result)
        }
      } catch (err) {
        if (isMounted) {
          setError(err.message)
        }
      } finally {
        if (isMounted) {
          setLoading(false)
        }
      }
    }

    fetchData()

    return () => {
      isMounted = false
    }
  }, [path])

  return { data, loading, error }
}

export function useComplaints() {
  return useApi('/complaints')
}

export function useUsers() {
  return useApi('/admin/users')
}

export function useStats() {
  const { data, loading, error } = useApi('/analytics/stats')
  return { data: data?.stats || null, loading, error }
}

export function useAnalytics() {
  return useApi('/analytics/stats')
}

export function useAuditLogs() {
  return useApi('/admin/audit-logs')
}

export function useNotifications() {
  return useApi('/notifications')
}

export function useRoles() {
  return useApi('/admin/roles')
}

export function useLiveTracking() {
  return useApi('/map/live')
}

export function useContractors() {
  return useApi('/admin/contractors')
}

export function useWorkOrders() {
  return useApi('/admin/work-orders')
}

// Form data hooks
export function useComplaintCategories() {
  return useApi('/analytics/categories')
}

export function useDepartments() {
  return useApi('/admin/departments')
}

export function useAreas() {
  return useApi('/map/areas')
}
