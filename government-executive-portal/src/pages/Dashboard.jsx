import { useState, useEffect } from 'react'
import { Line, Doughnut } from 'react-chartjs-2'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, ArcElement, Tooltip, Legend } from 'chart.js'
import StatCard from '../components/Widgets/StatCard'
import StatusBadge from '../components/Widgets/StatusBadge'
import { useDashboardData } from '../context/DashboardDataContext'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, ArcElement, Tooltip, Legend)

function Dashboard() {
  const {
    statsData,
    statsLoading,
    statsError,
    analyticsData,
    analyticsLoading,
    analyticsError,
    complaintsData,
    complaintsLoading,
    complaintsError,
  } = useDashboardData()

  const [lineData, setLineData] = useState({
    labels: [],
    datasets: [{
      label: 'Public Complaints Trend',
      data: [],
      borderColor: '#1B5E20',
      backgroundColor: 'rgba(27, 94, 32, 0.18)',
      tension: 0.35,
      fill: true,
    }],
  })

  const [doughnutData, setDoughnutData] = useState({
    labels: [],
    datasets: [{
      data: [],
      backgroundColor: ['#1B5E20', '#2E7D32', '#4CAF50', '#81C784', '#C8E6C9'],
    }],
  })

  useEffect(() => {
    if (analyticsData) {
      setLineData(prev => ({
        ...prev,
        labels: analyticsData.complaintsTrend?.labels || [],
        datasets: [{
          ...prev.datasets[0],
          data: analyticsData.complaintsTrend?.data || [],
        }],
      }))

      setDoughnutData(prev => ({
        ...prev,
        labels: analyticsData.categoryBreakdown?.labels || [],
        datasets: [{
          ...prev.datasets[0],
          data: analyticsData.categoryBreakdown?.data || [],
        }],
      }))
    }
  }, [analyticsData])

  return (
    <div className="dashboard-page">
      <div className="page-header">
        <div>
          <p className="page-label">Executive Overview</p>
          <h1>Executive Dashboard</h1>
        </div>
      </div>

      <div className="grid grid--4">
        <StatCard title="Public Complaints" value={statsData?.totalComplaints || 0} description="Monthly total" change="+8.3%" />
        <StatCard title="Resolution Rate" value={statsData?.totalComplaints ? `${Math.round((statsData.resolved / statsData.totalComplaints) * 100)}%` : '0%'} description="This month" change="+5.1%" accent="success" />
        <StatCard title="Pending Action" value={statsData?.pending || 0} description="Needs attention" change="-2.4%" accent="warning" />
        <StatCard title="Rejected Cases" value={statsData?.rejected || 0} description="Quality reviews" change="+0.6%" accent="danger" />
      </div>

      <div className="grid grid--2">
        <section className="panel">
          <div className="panel__header"><h2>Complaint Trends</h2></div>
          <div className="panel__body">
            {analyticsLoading ? <p>Loading...</p> : <Line data={lineData} options={{ responsive: true, plugins: { legend: { display: false } } }} />}
          </div>
        </section>

        <section className="panel panel--compact">
          <div className="panel__header"><h2>Complaint Categories</h2></div>
          <div className="panel__body">
            {analyticsLoading ? <p>Loading...</p> : <Doughnut data={doughnutData} options={{ responsive: true, plugins: { legend: { position: 'bottom' } } }} />}
          </div>
        </section>
      </div>

      <div className="grid grid--2">
        <section className="panel">
          <div className="panel__header"><h2>Service Coverage (SARA)</h2></div>
          <div className="panel__body">
            {analyticsLoading ? <p>Loading...</p> : (analyticsData?.saraCoverage || []).map((item) => (
              <div key={item.label} className="progress-item">
                <div className="progress-item__label"><span>{item.label}</span><strong>{item.value}%</strong></div>
                <div className="progress-bar"><div style={{ width: `${item.value}%` }} /></div>
              </div>
            ))}
          </div>
        </section>

        <section className="panel">
          <div className="panel__header"><h2>Recent Public Complaints</h2></div>
          <div className="panel__body panel__table-wrap">
            {complaintsLoading ? <p>Loading...</p> : (
              <table className="data-table">
                <thead>
                  <tr><th>ID</th><th>Title</th><th>Category</th><th>Status</th><th>Date</th></tr>
                </thead>
                <tbody>
                  {(complaintsData?.slice(0, 5) || []).map((complaint) => (
                    <tr key={complaint.id}>
                      <td>{complaint.id}</td>
                      <td>{complaint.title}</td>
                      <td>{complaint.category}</td>
                      <td><StatusBadge status={complaint.status} /></td>
                      <td>{complaint.createdAt ? new Date(complaint.createdAt).toLocaleDateString() : ''}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </section>
      </div>
    </div>
  )
}

export default Dashboard
