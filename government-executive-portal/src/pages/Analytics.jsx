import { useState, useEffect } from 'react'
import { Line, Doughnut } from 'react-chartjs-2'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, ArcElement, Tooltip, Legend } from 'chart.js'
import StatCard from '../components/Widgets/StatCard'
import { useStats, useAnalytics } from '../hooks/useApi'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, ArcElement, Tooltip, Legend)

function Analytics() {
  const { data: statsData, loading: statsLoading } = useStats()
  const { data: analyticsData, loading: analyticsLoading } = useAnalytics()

  const [trendData, setTrendData] = useState({
    labels: [],
    datasets: [{ label: 'Trend', data: [], borderColor: '#1B5E20', backgroundColor: 'rgba(27, 94, 32, 0.18)', tension: 0.35, fill: true }],
  })

  const [breakdownData, setBreakdownData] = useState({
    labels: [],
    datasets: [{ data: [], backgroundColor: ['#1B5E20', '#2E7D32', '#4CAF50', '#81C784'] }],
  })

  useEffect(() => {
    if (analyticsData) {
      setTrendData(prev => ({
        ...prev,
        labels: analyticsData.complaintsTrend?.labels || [],
        datasets: [{
          ...prev.datasets[0],
          data: analyticsData.complaintsTrend?.data || [],
        }],
      }))

      setBreakdownData(prev => ({
        ...prev,
        labels: analyticsData.contractorBreakdown?.labels || [],
        datasets: [{
          ...prev.datasets[0],
          data: analyticsData.contractorBreakdown?.data || [],
        }],
      }))
    }
  }, [analyticsData])

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Performance Analytics</h1></div>
      <div className="grid grid--4">
        <StatCard title="Total Complaints" value={statsData?.totalComplaints || 0} description="AI tracked" />
        <StatCard title="Resolved" value={statsData?.resolved || 0} description="Through analytics" accent="success" />
        <StatCard title="Resolution Rate" value={statsData?.totalComplaints ? `${Math.round((statsData.resolved / statsData.totalComplaints) * 100)}%` : '0%'} description="Across all cases" accent="success" />
        <StatCard title="Avg Resolution Time" value={statsData?.avgResolutionTime || 'N/A'} description="Time to close" />
      </div>

      <div className="grid grid--2">
        <section className="panel">
          <div className="panel__header"><h2>Complaints Trend</h2></div>
          <div className="panel__body">
            {analyticsLoading ? <p>Loading...</p> : <Line data={trendData} options={{ plugins: { legend: { display: false } } }} />}
          </div>
        </section>
        <section className="panel panel--compact">
          <div className="panel__header"><h2>By Contractor</h2></div>
          <div className="panel__body">
            {analyticsLoading ? <p>Loading...</p> : <Doughnut data={breakdownData} options={{ plugins: { legend: { position: 'bottom' } } }} />}
          </div>
        </section>
      </div>
    </div>
  )
}

export default Analytics
