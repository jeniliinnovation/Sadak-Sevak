import { createContext, useContext } from 'react'
import { useApi, useComplaints } from '../hooks/useApi'

const DashboardDataContext = createContext(null)

export function DashboardDataProvider({ children }) {
  const {
    data: analyticsData,
    loading: analyticsLoading,
    error: analyticsError,
  } = useApi('/analytics/stats')

  const { data: complaintsData, loading: complaintsLoading, error: complaintsError } = useComplaints()

  const statsData = analyticsData?.stats || null

  return (
    <DashboardDataContext.Provider
      value={{
        statsData,
        statsLoading: analyticsLoading,
        statsError: analyticsError,
        analyticsData,
        analyticsLoading,
        analyticsError,
        complaintsData,
        complaintsLoading,
        complaintsError,
      }}
    >
      {children}
    </DashboardDataContext.Provider>
  )
}

export function useDashboardData() {
  const context = useContext(DashboardDataContext)
  if (!context) {
    throw new Error('useDashboardData must be used within DashboardDataProvider')
  }
  return context
}
