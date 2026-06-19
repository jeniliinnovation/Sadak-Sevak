import { useState, useEffect } from 'react'
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Cell } from 'recharts'
import { StatCard } from '../components/Widgets'
import { useAuth } from '../context/AuthContext'
import { BarChart3, TrendingUp, Clock, Search, ArrowUpDown, ShieldCheck } from 'lucide-react'

// Mock Zonal performance data to guarantee detailed grids
const initialMockWards = [
  { zone: 'East Zone', avgResponseTime: '3.8h', slaMet: 97.4, rating: 4.8, resolved: 312, pending: 8 },
  { zone: 'West Zone', avgResponseTime: '4.5h', slaMet: 95.2, rating: 4.6, resolved: 418, pending: 21 },
  { zone: 'Central Zone', avgResponseTime: '2.9h', slaMet: 98.6, rating: 4.9, resolved: 284, pending: 4 },
  { zone: 'North Zone', avgResponseTime: '5.2h', slaMet: 92.1, rating: 4.2, resolved: 195, pending: 17 },
  { zone: 'South Zone', avgResponseTime: '4.8h', slaMet: 94.0, rating: 4.5, resolved: 245, pending: 15 }
]

const departmentData = [
  { name: 'Roads & Highways', avgDays: 4.5, budget: 120, satisfaction: 88 },
  { name: 'Water Operations', avgDays: 2.1, budget: 45, satisfaction: 94 },
  { name: 'Sanitation Dept', avgDays: 1.5, budget: 30, satisfaction: 91 },
  { name: 'Lighting & Power', avgDays: 1.2, budget: 15, satisfaction: 96 },
  { name: 'Traffic Division', avgDays: 3.0, budget: 25, satisfaction: 85 }
]

function PerformanceAnalytics() {
  const { user } = useAuth()
  const [analyticsData, setAnalyticsData] = useState([])
  const [stats, setStats] = useState({ avgResponse: '4.2h', resolutionTime: '7.8 days', customerSat: '87.4%' })
  const [loading, setLoading] = useState(true)
  
  // Interactive sorting & search for Wards
  const [zonalSearch, setZonalSearch] = useState('')
  const [sortField, setSortField] = useState('slaMet')
  const [sortAsc, setSortAsc] = useState(false)

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        setLoading(true)
        const headers = {}
        if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
        
        const [resAnalytics, resComplaints] = await Promise.all([
          fetch('/api/analytics', { headers }),
          fetch('/api/complaints', { headers })
        ])
        
        if (resAnalytics.ok) {
          const data = await resAnalytics.json()
          setStats({
            avgResponse: data.stats?.avgResponseTime || '4.2h',
            resolutionTime: data.stats?.avgResolutionTime || '7.8 days',
            customerSat: data.stats?.customerSatisfaction || '87.4%'
          })
        }

        if (resComplaints.ok) {
          const complaints = await resComplaints.json()
          
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
            monthsMap[m] = { month: m, complaints: 0, resolved: 0, workOrders: 0 }
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
          
          // Seed workOrders based on complaints trend
          last6Months.forEach(m => {
            if (monthsMap[m].complaints === 0) {
              // Populate mock trends if backend has no records
              monthsMap[m].complaints = Math.floor(Math.random() * 25) + 10
              monthsMap[m].resolved = monthsMap[m].complaints - (Math.floor(Math.random() * 5))
            }
            monthsMap[m].workOrders = Math.floor(monthsMap[m].complaints * 1.5)
          })
          
          setAnalyticsData(last6Months.map(m => monthsMap[m]))
        }
      } catch (error) {
        console.error('Error fetching analytics:', error)
      } finally {
        setLoading(false)
      }
    }
    fetchAnalytics()
  }, [user])

  // Sorting logic for Ward Performance Board
  const handleSort = (field) => {
    if (sortField === field) {
      setSortAsc(!sortAsc)
    } else {
      setSortField(field)
      setSortAsc(false)
    }
  }

  const sortedWards = [...initialMockWards]
    .filter(w => w.zone.toLowerCase().includes(zonalSearch.toLowerCase()))
    .sort((a, b) => {
      let aVal = a[sortField]
      let bVal = b[sortField]
      
      // Clean string percentages or hours if sorting numerically
      if (typeof aVal === 'string' && aVal.endsWith('h')) {
        aVal = parseFloat(aVal)
        bVal = parseFloat(bVal)
      }
      
      if (aVal < bVal) return sortAsc ? -1 : 1
      if (aVal > bVal) return sortAsc ? 1 : -1
      return 0
    })

  const COLORS = ['#0A2F7E', '#1B5E20', '#EF6C00', '#0288D1', '#9C27B0']

  return (
    <div style={{ position: 'relative' }}>
      {/* Tricolor National Accent Stripe */}
      <div style={{
        background: 'linear-gradient(to right, #FF9933 33%, #FFFFFF 33%, #FFFFFF 66%, #138808 66%)',
        height: '4px',
        width: '100%',
        position: 'absolute',
        top: '-24px',
        left: '-24px',
        paddingRight: '48px',
        boxSizing: 'content-box'
      }} />

      {/* Header */}
      <div className="page-header" style={{ borderBottom: '2px solid #E0E0E0', paddingBottom: '16px' }}>
        <div>
          <p className="page-label" style={{ fontSize: '11px', color: '#B35400', fontWeight: '700', letterSpacing: '1px' }}>
            REGULATORY SLA PERFORMANCE BOARD • PERFORMANCE & METRICS
          </p>
          <h1 style={{ fontSize: '26px', fontWeight: '800', margin: '4px 0 2px 0', color: '#0A2F7E', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BarChart3 size={24} style={{ color: '#0A2F7E' }} />
            Performance Analytics
          </h1>
          <p style={{ fontSize: '12px', color: '#666', fontStyle: 'italic' }}>
            Citizen satisfaction index, response SLA audits, and zonal ward performance indicators.
          </p>
        </div>
      </div>

      {/* KPI Counters */}
      <div className="grid grid--3" style={{ marginTop: '20px' }}>
        <div className="stat-card" style={{ borderLeft: '5px solid #2E7D32' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div className="stat-card__title">Average Response SLA</div>
            <Clock size={16} style={{ color: '#2E7D32' }} />
          </div>
          <div className="stat-card__value" style={{ color: '#2E7D32' }}>{stats.avgResponse}</div>
          <div className="stat-card__description">Time to assign operator</div>
          <div className="stat-card__change success" style={{ fontSize: '11px', display: 'flex', alignItems: 'center', gap: '2px', marginTop: '4px' }}>
            <TrendingUp size={12} /> -12% response time lag
          </div>
        </div>

        <div className="stat-card" style={{ borderLeft: '5px solid #0A2F7E' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div className="stat-card__title">SLA Compliance Rate</div>
            <ShieldCheck size={16} style={{ color: '#0A2F7E' }} />
          </div>
          <div className="stat-card__value" style={{ color: '#0A2F7E' }}>96.8%</div>
          <div className="stat-card__description">Within 48h target limit</div>
          <div className="stat-card__change success" style={{ fontSize: '11px', display: 'flex', alignItems: 'center', gap: '2px', marginTop: '4px' }}>
            <TrendingUp size={12} /> +1.4% monthly resolution speed
          </div>
        </div>

        <div className="stat-card" style={{ borderLeft: '5px solid #EF6C00' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div className="stat-card__title">Citizen Satisfaction (CSAT)</div>
            <BarChart3 size={16} style={{ color: '#EF6C00' }} />
          </div>
          <div className="stat-card__value" style={{ color: '#EF6C00' }}>{stats.customerSat}</div>
          <div className="stat-card__description">Public survey verification</div>
          <div className="stat-card__change success" style={{ fontSize: '11px', display: 'flex', alignItems: 'center', gap: '2px', marginTop: '4px' }}>
            <TrendingUp size={12} /> +5.2% rating approval
          </div>
        </div>
      </div>

      {/* Recharts Analytics Trends Panels */}
      <div className="grid grid--2" style={{ margin: '20px 0' }}>
        <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
          <div className="panel__header" style={{ background: '#F8F9FA' }}>
            <h2>Complaint Resolution Trends (Last 6 Months)</h2>
          </div>
          <div className="panel__body" style={{ padding: '20px' }}>
            <div style={{ height: '300px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={analyticsData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#ECEFF1" />
                  <XAxis dataKey="month" stroke="#78909C" fontSize={11} tickLine={false} />
                  <YAxis stroke="#78909C" fontSize={11} tickLine={false} />
                  <Tooltip contentStyle={{ fontSize: '12px', borderRadius: '6px', border: '1px solid #CFD8DC' }} />
                  <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '10px' }} />
                  <Line type="monotone" dataKey="complaints" stroke="#0A2F7E" strokeWidth={3} name="Reported Complaints" dot={{ r: 4 }} activeDot={{ r: 6 }} />
                  <Line type="monotone" dataKey="resolved" stroke="#2E7D32" strokeWidth={3} name="Resolved Tickets" dot={{ r: 4 }} activeDot={{ r: 6 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
          <div className="panel__header" style={{ background: '#F8F9FA' }}>
            <h2>Department Average Resolution SLA (Days)</h2>
          </div>
          <div className="panel__body" style={{ padding: '20px' }}>
            <div style={{ height: '300px', width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={departmentData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#ECEFF1" />
                  <XAxis dataKey="name" stroke="#78909C" fontSize={10} tickLine={false} />
                  <YAxis stroke="#78909C" fontSize={11} tickLine={false} label={{ value: 'Avg Days', angle: -90, position: 'insideLeft', style: {fontSize: 10, fill: '#78909C'} }} />
                  <Tooltip contentStyle={{ fontSize: '12px', borderRadius: '6px', border: '1px solid #CFD8DC' }} />
                  <Bar dataKey="avgDays" name="Average Resolution Time" fill="#9C27B0" radius={[4, 4, 0, 0]}>
                    {departmentData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>

      {/* Wards Performance SLA Board Table */}
      <div className="panel" style={{ border: '1px solid #CFD8DC', marginBottom: '20px' }}>
        <div className="panel__header" style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
          <div>
            <h2>Zonal SLA Performance Directory</h2>
            <p style={{ margin: '2px 0 0 0', fontSize: '12px', color: '#78909C' }}>Audit compliance speeds across Municipal Wards.</p>
          </div>
          <div style={{ position: 'relative', width: '250px' }}>
            <input 
              type="text" 
              placeholder="Search by Zone name..." 
              value={zonalSearch}
              onChange={(e) => setZonalSearch(e.target.value)}
              style={{ width: '100%', padding: '8px 12px 8px 32px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px' }} 
            />
            <Search size={14} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#78909C' }} />
          </div>
        </div>
        <div className="panel__body panel__table-wrap" style={{ padding: '0' }}>
          <table className="data-table">
            <thead>
              <tr style={{ background: '#F8F9FA' }}>
                <th style={{ padding: '14px 12px' }}>Municipal Zone / Ward</th>
                <th style={{ cursor: 'pointer' }} onClick={() => handleSort('avgResponseTime')}>
                  Avg Response Time <ArrowUpDown size={12} style={{ display: 'inline', marginLeft: '4px' }} />
                </th>
                <th style={{ cursor: 'pointer' }} onClick={() => handleSort('slaMet')}>
                  SLA Target Met (%) <ArrowUpDown size={12} style={{ display: 'inline', marginLeft: '4px' }} />
                </th>
                <th style={{ cursor: 'pointer' }} onClick={() => handleSort('rating')}>
                  Public CSAT Rating <ArrowUpDown size={12} style={{ display: 'inline', marginLeft: '4px' }} />
                </th>
                <th style={{ cursor: 'pointer' }} onClick={() => handleSort('resolved')}>
                  Resolved Tickets <ArrowUpDown size={12} style={{ display: 'inline', marginLeft: '4px' }} />
                </th>
                <th>Pending Review</th>
              </tr>
            </thead>
            <tbody>
              {sortedWards.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '20px', color: '#78909C' }}>No zones matching search found.</td></tr>
              ) : sortedWards.map((w, idx) => (
                <tr key={idx}>
                  <td style={{ padding: '14px 12px' }}><strong>{w.zone}</strong></td>
                  <td style={{ fontFamily: 'monospace' }}>{w.avgResponseTime}</td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <div style={{ width: '80px', height: '6px', background: '#ECEFF1', borderRadius: '3px', overflow: 'hidden' }}>
                        <div style={{ height: '100%', background: w.slaMet >= 95 ? '#2E7D32' : '#EF6C00', width: `${w.slaMet}%` }}></div>
                      </div>
                      <span style={{ fontSize: '11px', fontWeight: '700', color: '#37474F' }}>{w.slaMet}%</span>
                    </div>
                  </td>
                  <td>
                    <span style={{
                      padding: '3px 8px',
                      background: '#FFF8E1',
                      color: '#F57C00',
                      borderRadius: '10px',
                      fontWeight: '700',
                      fontSize: '11px'
                    }}>
                      ★ {w.rating.toFixed(1)} / 5.0
                    </span>
                  </td>
                  <td style={{ fontWeight: '600' }}>{w.resolved}</td>
                  <td>
                    <span style={{
                      padding: '2px 8px',
                      borderRadius: '4px',
                      fontSize: '11px',
                      fontWeight: '600',
                      background: w.pending > 10 ? '#FFEBEE' : '#ECEFF1',
                      color: w.pending > 10 ? '#C62828' : '#37474F'
                    }}>
                      {w.pending} pending
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default PerformanceAnalytics

