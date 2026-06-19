import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { DashboardDataProvider } from './context/DashboardDataContext'
import Layout from './components/Layout/Layout'
import ProtectedRoute from './components/Layout/ProtectedRoute'
import Dashboard from './pages/Dashboard'
import Users from './pages/Users'
import Complaints from './pages/Complaints'
import ComplaintDetails from './pages/ComplaintDetails'
import AddComplaint from './pages/AddComplaint'
import AddUser from './pages/AddUser'
import Sara from './pages/SARA'
import Analytics from './pages/Analytics'
import LiveTracking from './pages/LiveTracking'
import Notifications from './pages/Notifications'
import AuditLogs from './pages/AuditLogs'
import Roles from './pages/Roles'
import Settings from './pages/Settings'
import Profile from './pages/Profile'
import Contractors from './pages/Contractors'
import ContractorForm from './pages/ContractorForm'
import WorkOrders from './pages/WorkOrders'
import WorkOrderForm from './pages/WorkOrderForm'
import Login from './pages/Login'

function App() {
  return (
    <AuthProvider>
      <DashboardDataProvider>
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
              <Route path="/users" element={<Users />} />
              <Route path="/complaints" element={<Complaints />} />
              <Route path="/complaints/:id" element={<ComplaintDetails />} />
              <Route path="/add-complaint" element={<AddComplaint />} />
              <Route path="/add-user" element={<AddUser />} />
              <Route path="/sara" element={<Sara />} />
              <Route path="/analytics" element={<Analytics />} />
              <Route path="/live-tracking" element={<LiveTracking />} />
              <Route path="/notifications" element={<Notifications />} />
              <Route path="/audit-logs" element={<AuditLogs />} />
              <Route path="/roles" element={<Roles />} />
              <Route path="/settings" element={<Settings />} />
              <Route path="/profile" element={<Profile />} />
              <Route path="/contractors" element={<Contractors />} />
              <Route path="/contractor-form" element={<ContractorForm />} />
              <Route path="/work-orders" element={<WorkOrders />} />
              <Route path="/work-orders/new" element={<WorkOrderForm />} />
              <Route path="/work-orders/:id" element={<WorkOrderForm />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </DashboardDataProvider>
    </AuthProvider>
  )
}

export default App
