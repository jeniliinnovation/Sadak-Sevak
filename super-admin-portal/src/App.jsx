import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import Layout from './components/Layout/Layout'
import ProtectedRoute from './components/Layout/ProtectedRoute'

// Pages
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import ComplaintManagement from './pages/ComplaintManagement'
import LiveTracking from './pages/LiveTracking'
import StaffDirectory from './pages/StaffDirectory'
import DepartmentManagement from './pages/DepartmentManagement'
import InfrastructureProjects from './pages/InfrastructureProjects'
import PerformanceAnalytics from './pages/PerformanceAnalytics'
import AISARInsights from './pages/AISARInsights'
import SystemAuditLogs from './pages/SystemAuditLogs'
import RolePermissions from './pages/RolePermissions'
import SystemSettings from './pages/SystemSettings'
import UserManagement from './pages/UserManagement'
import ComplaintDetails from './pages/ComplaintDetails'

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route path="/" element={<Dashboard />} />
            <Route path="/complaints" element={<ComplaintManagement />} />
            <Route path="/complaints/:id" element={<ComplaintDetails />} />
            <Route path="/live-tracking" element={<LiveTracking />} />
            <Route path="/staff" element={<StaffDirectory />} />
            <Route path="/departments" element={<DepartmentManagement />} />
            <Route path="/infrastructure" element={<InfrastructureProjects />} />
            <Route path="/analytics" element={<PerformanceAnalytics />} />
            <Route path="/sara" element={<AISARInsights />} />
            <Route path="/audit-logs" element={<SystemAuditLogs />} />
            <Route path="/roles" element={<RolePermissions />} />
            <Route path="/settings" element={<SystemSettings />} />
            <Route path="/users" element={<UserManagement />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}

export default App
