import { useState, useEffect } from 'react'
import { StatCard, StatusBadge } from '../components/Widgets'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { useAuth } from '../context/AuthContext'

function Dashboard() {
  const { user } = useAuth()
  const [loading, setLoading] = useState(true)
  const [dashboardData, setDashboardData] = useState({
    totalComplaints: 0,
    resolved: 0,
    pending: 0,
    inProgress: 0,
  })
  const [chartData, setChartData] = useState([])
  const [categoryData, setCategoryData] = useState([])
  const [recentComplaints, setRecentComplaints] = useState([])

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)
        const headers = {}
        if (user?.token) {
          headers['Authorization'] = `Bearer ${user.token}`
        }

        // Fetch analytics
        const analyticsRes = await fetch('/api/analytics', { headers })
        const analyticsData = await analyticsRes.json()

        if (analyticsRes.ok && analyticsData.stats) {
          setDashboardData({
            totalComplaints: analyticsData.stats.totalComplaints || 0,
            resolved: analyticsData.stats.resolved || 0,
            pending: analyticsData.stats.pending || 0,
            inProgress: analyticsData.stats.totalComplaints - (analyticsData.stats.resolved + analyticsData.stats.pending) || 0,
          })

          if (analyticsData.categoryBreakdown) {
            const catData = analyticsData.categoryBreakdown.labels.map((label, index) => ({
              name: label,
              value: analyticsData.categoryBreakdown.data[index] || 0
            }))
            setCategoryData(catData)
          }
        }

        // Fetch recent complaints
        const complaintsRes = await fetch('/api/complaints', { headers })
        if (complaintsRes.ok) {
          const complaints = await complaintsRes.json()
          setRecentComplaints(complaints.slice(0, 5)) // Get top 5 recent

          // Build chart data (last 6 months)
          const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
          const currentMonthIdx = new Date().getMonth()
          
          const last6Months = []
          for (let i = 5; i >= 0; i--) {
            let d = new Date()
            d.setMonth(currentMonthIdx - i)
            last6Months.push(monthNames[d.getMonth()])
          }

          const monthsMap = {}
          last6Months.forEach(m => {
            monthsMap[m] = { month: m, complaints: 0, resolved: 0 }
          })
          
          complaints.forEach(c => {
            const date = new Date(c.createdAt || c.date || Date.now())
            const month = monthNames[date.getMonth()]
            
            if (monthsMap[month]) {
              monthsMap[month].complaints += 1
              if (c.status === 'repair_completed' || c.status === 'verified_closed' || c.status === 'resolved') {
                monthsMap[month].resolved += 1
              }
            }
          })
          
          const sortedChartData = last6Months.map(m => monthsMap[m])
          setChartData(sortedChartData)
        }
      } catch (error) {
        console.error('Error fetching dashboard data:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [user])

  const COLORS = ['#9C27B0', '#BA68C8', '#7B1FA2', '#CE93D8', '#E1BEE7', '#8E24AA']

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%', minHeight: '400px' }}>
        <p>Loading Dashboard...</p>
      </div>
    )
  }

  return (
    <div>
      <div className="page-header">
        <p className="page-label">Overview</p>
        <h1>Executive Dashboard</h1>
      </div>

      <div className="grid grid--4">
        <StatCard title="Total Complaints" value={dashboardData.totalComplaints} description="All time" change="" accent="default" />
        <StatCard title="Resolved" value={dashboardData.resolved} description="Success rate" change="" accent="success" />
        <StatCard title="In Progress" value={dashboardData.inProgress} description="Being worked on" change="" accent="warning" />
        <StatCard title="Pending" value={dashboardData.pending} description="Needs action" change="" accent="danger" />
      </div>

      <div className="grid grid--2">
        <div className="panel">
          <div className="panel__header"><h2>Complaint Trends</h2></div>
          <div className="panel__body">
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="complaints" stroke="#9C27B0" name="Total Complaints" />
                <Line type="monotone" dataKey="resolved" stroke="#BA68C8" name="Resolved" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="panel">
          <div className="panel__header"><h2>Complaint Categories</h2></div>
          <div className="panel__body">
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie data={categoryData} cx="50%" cy="50%" labelLine={false} label={({ name, value }) => `${name}: ${value}`} outerRadius={100} fill="#8884d8" dataKey="value">
                  {categoryData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="panel">
        <div className="panel__header"><h2>Recent Complaints</h2></div>
        <div className="panel__body panel__table-wrap">
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Category</th>
                <th>Status</th>
                <th>Date</th>
                <th>Priority</th>
              </tr>
            </thead>
            <tbody>
              {recentComplaints.length > 0 ? recentComplaints.map(complaint => (
                <tr key={complaint.id}>
                  <td>#{String(complaint.id).padStart(4, '0')}</td>
                  <td>{complaint.title}</td>
                  <td>{complaint.category || 'General'}</td>
                  <td><StatusBadge status={complaint.status} /></td>
                  <td>{new Date(complaint.createdAt).toLocaleDateString()}</td>
                  <td>{complaint.priority || 'Medium'}</td>
                </tr>
              )) : (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center' }}>No recent complaints found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default Dashboard
