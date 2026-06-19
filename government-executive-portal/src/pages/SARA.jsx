import { useState, useEffect } from 'react'
import { Line, Bar } from 'react-chartjs-2'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Tooltip, Legend } from 'chart.js'
import StatCard from '../components/Widgets/StatCard'
import { useAnalytics } from '../hooks/useApi'
import { Brain, Cpu, Loader } from 'lucide-react'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, BarElement, Tooltip, Legend)

function Sara() {
  const { data: analyticsData, loading } = useAnalytics()
  const [scanning, setScanning] = useState(false)
  const [scanResult, setScanResult] = useState(null)
  const [cameraSource, setCameraSource] = useState('feed1')

  const defaultHealthScoreTrend = {
    labels: ['Zone 1', 'Zone 2', 'Zone 3'],
    data: [85, 72, 68]
  }

  const defaultIssueDetection = {
    labels: ['Potholes', 'Cracks', 'Water Logging', 'Street Lights'],
    data: [620, 340, 185, 320]
  }

  const [trendData, setTrendData] = useState({
    labels: defaultHealthScoreTrend.labels,
    datasets: [{ label: 'Zone Road Score (%)', data: defaultHealthScoreTrend.data, borderColor: '#1B5E20', backgroundColor: 'rgba(27, 94, 32, 0.12)', tension: 0.3, fill: true }],
  })

  const [issueData, setIssueData] = useState({
    labels: defaultIssueDetection.labels,
    datasets: [{ label: 'Issues', data: defaultIssueDetection.data, backgroundColor: ['#1B5E20', '#2E7D32', '#4CAF50', '#81C784'] }],
  })

  useEffect(() => {
    if (analyticsData) {
      // 1. Zone Health Score (SARA coverage by zone) from live database data
      const zoneLabels = analyticsData.saraCoverage?.map(z => z.label) || defaultHealthScoreTrend.labels
      const zoneData = analyticsData.saraCoverage?.map(z => z.value) || defaultHealthScoreTrend.data

      setTrendData(prev => ({
        ...prev,
        labels: zoneLabels,
        datasets: [{
          ...prev.datasets[0],
          data: zoneData,
        }],
      }))

      // 2. Issue Category Breakdown from live database data
      const rawLabels = analyticsData.categoryBreakdown?.labels || defaultIssueDetection.labels
      const categoryLabels = rawLabels.map(l => l ? l.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase()) : '')
      const categoryData = analyticsData.categoryBreakdown?.data || defaultIssueDetection.data

      setIssueData(prev => ({
        ...prev,
        labels: categoryLabels,
        datasets: [{
          ...prev.datasets[0],
          data: categoryData,
        }],
      }))
    }
  }, [analyticsData])

  const triggerScan = () => {
    setScanning(true)
    setScanResult(null)
    setTimeout(() => {
      setScanning(false)
      if (cameraSource === 'feed1') {
        setScanResult({
          detected: 'Pothole (Severe)',
          confidence: '97.2%',
          location: 'Civic Centre Road, Sector 5',
          recommendedAction: 'Deploy Work Order (WO-2699)',
          healthImpact: '-18pts Road Score'
        })
      } else if (cameraSource === 'feed2') {
        setScanResult({
          detected: 'Lateral Cracks (Medium)',
          confidence: '89.4%',
          location: 'Junction 3, Sector 8',
          recommendedAction: 'Schedule routine repair in 14 days',
          healthImpact: '-5pts Road Score'
        })
      } else {
        setScanResult({
          detected: 'Severe Road Raveling',
          confidence: '91.8%',
          location: 'Uploaded Frame coordinates',
          recommendedAction: 'Schedule resurfacing',
          healthImpact: '-12pts Road Score'
        })
      }
    }, 1500)
  }

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>AI Insights (SARA)</h1>
      </div>
      
      <div className="grid grid--4" style={{ marginBottom: '24px' }}>
        <StatCard 
          title="Total Feeds Analyzed" 
          value={analyticsData?.stats?.totalComplaints || '3,812'} 
          description="Total detected complaints" 
          icon={<Cpu size={18} />} 
        />
        <StatCard 
          title="Issues Detected" 
          value={analyticsData?.stats?.pending || '1,465'} 
          description="Pending resolution" 
          accent="warning" 
          icon={<Brain size={18} />} 
        />
        <StatCard 
          title="Avg Health Score" 
          value={analyticsData?.repairs?.rate || '83%'} 
          description="System confidence" 
          accent="success" 
        />
        <StatCard 
          title="Detection Accuracy" 
          value={analyticsData?.aiAccuracy?.overall || '94.2%'} 
          description="Model reliability" 
          accent="success" 
        />
      </div>

      <div className="grid grid--2">
        <section className="panel">
          <div className="panel__header"><h2>Health Score Trend</h2></div>
          <div className="panel__body">
            {loading ? <p>Loading...</p> : <Line data={trendData} options={{ plugins: { legend: { display: false } } }} />}
          </div>
        </section>
        <section className="panel">
          <div className="panel__header"><h2>Issue Detection</h2></div>
          <div className="panel__body">
            {loading ? <p>Loading...</p> : <Bar data={issueData} options={{ plugins: { legend: { display: false } } }} />}
          </div>
        </section>
      </div>

      {/* SARA Live feed scanner Simulation */}
      <section className="panel" style={{ marginTop: '24px', padding: '20px' }}>
        <div className="panel__header" style={{ padding: '0 0 10px 0' }}>
          <h2>SARA Real-time AI Feed Scanner</h2>
        </div>
        <div className="panel__body" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px', padding: 0, alignItems: 'start' }}>
          <div>
            <p className="text-muted" style={{ marginBottom: '16px' }}>
              Simulate SARA ML model inference on live city camera feeds or uploaded road snapshots.
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <label style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontWeight: 600 }}>
                Select Feed Source
                <select 
                  className="filter-select" 
                  value={cameraSource} 
                  onChange={(e) => {
                    setCameraSource(e.target.value)
                    setScanResult(null)
                  }}
                  style={{ width: '100%', minWidth: 'auto' }}
                >
                  <option value="feed1">📹 Live Camera Feed #1 (Civic Centre Road)</option>
                  <option value="feed2">📹 Live Camera Feed #2 (Sector 8 Junction)</option>
                  <option value="upload">📤 Upload Custom Road Snapshot</option>
                </select>
              </label>

              <button 
                className="button button--primary" 
                type="button" 
                onClick={triggerScan}
                disabled={scanning || loading}
                style={{ width: 'fit-content', padding: '10px 20px' }}
              >
                {scanning ? 'Running AI Model Inference...' : '🚀 Trigger Instant SARA Scan'}
              </button>
            </div>
          </div>

          <div style={{ background: 'var(--surface-soft)', padding: '20px', borderRadius: '14px', minHeight: '160px', display: 'grid', placeItems: scanResult || scanning ? 'stretch' : 'center' }}>
            {scanning ? (
              <div style={{ textAlign: 'center', padding: '20px' }}>
                <Loader className="spinner" size={40} style={{ color: 'var(--success)', margin: '0 auto 12px' }} />
                <p style={{ fontWeight: 600, margin: 0 }}>Processing frame feeds...</p>
                <span className="text-muted" style={{ fontSize: '0.85rem' }}>Comparing against 14 classification classes</span>
              </div>
            ) : scanResult ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <h3 style={{ margin: '0 0 6px 0', color: 'var(--success)', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1.1rem' }}>
                  ✅ Scan Complete
                </h3>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.9rem' }}>
                  <tbody>
                    <tr style={{ borderBottom: '1px solid var(--border-muted)' }}><td style={{ padding: '8px 0', fontWeight: 600 }}>Anomaly Detected</td><td style={{ padding: '8px 0', textAlign: 'right', color: 'var(--danger)', fontWeight: 700 }}>{scanResult.detected}</td></tr>
                    <tr style={{ borderBottom: '1px solid var(--border-muted)' }}><td style={{ padding: '8px 0', fontWeight: 600 }}>Confidence Score</td><td style={{ padding: '8px 0', textAlign: 'right', fontWeight: 700 }}>{scanResult.confidence}</td></tr>
                    <tr style={{ borderBottom: '1px solid var(--border-muted)' }}><td style={{ padding: '8px 0', fontWeight: 600 }}>Location</td><td style={{ padding: '8px 0', textAlign: 'right' }}>{scanResult.location}</td></tr>
                    <tr style={{ borderBottom: '1px solid var(--border-muted)' }}><td style={{ padding: '8px 0', fontWeight: 600 }}>Suggested Action</td><td style={{ padding: '8px 0', textAlign: 'right', fontWeight: 600, color: 'var(--success)' }}>{scanResult.recommendedAction}</td></tr>
                    <tr><td style={{ padding: '8px 0', fontWeight: 600 }}>Road Health Impact</td><td style={{ padding: '8px 0', textAlign: 'right', color: '#b91c1c', fontWeight: 600 }}>{scanResult.healthImpact}</td></tr>
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="text-muted text-center" style={{ margin: 0 }}>Select a feed source and trigger a scan to see SARA classification analysis.</p>
            )}
          </div>
        </div>
      </section>
    </div>
  )
}

export default Sara
