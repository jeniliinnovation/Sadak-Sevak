import { useState, useEffect } from 'react'
import { StatCard } from '../components/Widgets'
import { useAuth } from '../context/AuthContext'
import { Brain, Sliders, ShieldCheck, PlayCircle, Terminal, AlertTriangle, Check, RefreshCw } from 'lucide-react'

// Mock AI detections registry data
const initialMockDetections = [
  { id: 'det-501', type: 'Pothole (Severe)', location: 'Kalawad Road, Ward 12', gps: '22.3024° N, 70.8021° E', confidence: 96.5, severity: 'High', status: 'Auto-Dispatched' },
  { id: 'det-502', type: 'Alligator Cracks', location: 'Mavdi Chowk, Ward 8', gps: '22.2845° N, 70.7891° E', confidence: 89.2, severity: 'Medium', status: 'Under Review' },
  { id: 'det-503', type: 'Debris Blocking', location: 'Pushkar Dham, Ward 5', gps: '22.3112° N, 70.8142° E', confidence: 94.1, severity: 'High', status: 'Auto-Dispatched' },
  { id: 'det-504', type: 'Pothole (Minor)', location: 'Ring Road Phase 2, Ward 11', gps: '22.2901° N, 70.8256° E', confidence: 86.8, severity: 'Low', status: 'Under Review' },
  { id: 'det-505', type: 'Raveling Surface', location: 'Amin Marg, Ward 3', gps: '22.2982° N, 70.7915° E', confidence: 78.5, severity: 'Low', status: 'Unassigned' }
]

function AISARInsights() {
  const { user } = useAuth()
  const [accuracy, setAccuracy] = useState({ overall: 94.2, potholeDetection: 96.5, objectClassification: 93.2, priorityPrediction: 91.8 })
  const [detections, setDetections] = useState(initialMockDetections)
  const [loading, setLoading] = useState(true)

  // AI Configuration hyperparameters
  const [confidenceThreshold, setConfidenceThreshold] = useState(85)
  
  // Simulator telemetry states
  const [isScanning, setIsScanning] = useState(false)
  const [scanProgress, setScanProgress] = useState(0)
  const [telemetryLogs, setTelemetryLogs] = useState([])
  const [detectedTargets, setDetectedTargets] = useState([])

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)
        const headers = {}
        if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
        
        const resAnalytics = await fetch('/api/analytics', { headers })
        const dataAnalytics = await resAnalytics.json()
        if (resAnalytics.ok && dataAnalytics.aiAccuracy) {
          setAccuracy({
            overall: parseFloat(dataAnalytics.aiAccuracy.overall) || 94.2,
            potholeDetection: parseFloat(dataAnalytics.aiAccuracy.potholeDetection) || 96.5,
            objectClassification: 93.2,
            priorityPrediction: parseFloat(dataAnalytics.aiAccuracy.severityScoring) || 91.8
          })
        }
        
        const resComplaints = await fetch('/api/complaints', { headers })
        const dataComplaints = await resComplaints.json()
        if (resComplaints.ok && Array.isArray(dataComplaints) && dataComplaints.length > 0) {
          // Adapt backend complaints into detections layout if available
          const formatted = [...dataComplaints.slice(0, 3).map(c => {
            let locText = 'Municipal Highway'
            if (c.location) {
              if (typeof c.location === 'string') {
                locText = c.location
              } else if (typeof c.location === 'object') {
                locText = c.location.address || c.location.area || `${c.location.lat || ''}, ${c.location.lng || ''}` || 'Municipal Highway'
              }
            }
            return {
              id: `det-${c.id}`,
              type: c.category || 'Pothole (Severe)',
              location: locText,
              gps: `${(22.3 + Math.random() * 0.05).toFixed(4)}° N, ${(70.8 + Math.random() * 0.05).toFixed(4)}° E`,
              confidence: Math.floor(Math.random() * 10) + 88.5,
              severity: c.priority || 'High',
              status: 'Under Review'
            }
          }), ...initialMockDetections]
          setDetections(formatted)
        } else {
          setDetections(initialMockDetections)
        }
      } catch (error) {
        console.error('Error fetching AI insights:', error)
        setDetections(initialMockDetections)
      } finally {
        setLoading(false)
      }
    }
    fetchData()
  }, [user])

  // Recalculate AI metrics dynamically based on slider threshold
  const adjustedDetectionsCount = Math.round(1450 * (1 - (confidenceThreshold - 50) / 150))
  const adjustedFalsePositive = Math.round((4.8 - (confidenceThreshold - 50) * 0.07) * 10) / 10
  const adjustedAccuracy = Math.round((accuracy.overall + (confidenceThreshold - 85) * 0.1) * 10) / 10

  // Live Camera Scanning Telemetry simulator loop
  const triggerTelemetryScan = () => {
    if (isScanning) return
    setIsScanning(true)
    setScanProgress(0)
    setDetectedTargets([])
    setTelemetryLogs(['[SARA ENGINE] Connecting to Sat-Telemetric Optical Grid...'])

    const script = [
      { delay: 800, log: '[SARA ENGINE] Optical Link Established. Calibrating camera stream...', target: null },
      { delay: 1600, log: '[SCANNING] Analyzing Ward 12 road grid coordinates...', target: null },
      { delay: 2400, log: '[DETECTION] Pothole cluster identified at 22.3024° N, 70.8021° E.', target: 'pothole-1' },
      { delay: 3200, log: '[SARA ENGINE] Damage Severity classified as HIGH. Dispatched SLA ticket.', target: 'pothole-1-verify' },
      { delay: 4000, log: '[DETECTION] Severe alligator fatigue cracking detected at 22.3055° N, 70.8099° E.', target: 'crack-1' },
      { delay: 4800, log: '[SCANNING] Diagnostic check completed. 2 anomalies registered.', target: 'complete' }
    ]

    script.forEach((step, index) => {
      setTimeout(() => {
        setTelemetryLogs(prev => [...prev, step.log])
        setScanProgress(Math.round(((index + 1) / script.length) * 100))
        
        if (step.target) {
          if (step.target === 'complete') {
            setIsScanning(false)
          } else {
            setDetectedTargets(prev => [...prev, step.target])
          }
        }
      }, step.delay)
    })
  }

  // Verification Audit action toggle
  const handleVerifyDetection = (id) => {
    setDetections(detections.map(d => {
      if (d.id === id) {
        return { ...d, status: 'Verified & Dispatched' }
      }
      return d
    }))
  }

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
            SARA AUTONOMOUS TELEMETRY • SMART ASPHALT ROAD ANALYZER
          </p>
          <h1 style={{ fontSize: '26px', fontWeight: '800', margin: '4px 0 2px 0', color: '#0A2F7E', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Brain size={24} style={{ color: '#0A2F7E' }} />
            AI Insights (SARA System)
          </h1>
          <p style={{ fontSize: '12px', color: '#666', fontStyle: 'italic' }}>
            Satellite imaging, mobile phone accelerometer parsing, and computer vision classification nodes.
          </p>
        </div>
      </div>

      {/* Dynamic Stats Row */}
      <div className="grid grid--3" style={{ marginTop: '20px' }}>
        <div className="stat-card" style={{ borderLeft: '5px solid #9C27B0' }}>
          <div className="stat-card__title">Adjusted AI Accuracy</div>
          <div className="stat-card__value" style={{ color: '#9C27B0' }}>{adjustedAccuracy}%</div>
          <div className="stat-card__description">At {confidenceThreshold}% threshold</div>
        </div>
        <div className="stat-card" style={{ borderLeft: '5px solid #2E7D32' }}>
          <div className="stat-card__title">Projected Detections</div>
          <div className="stat-card__value" style={{ color: '#2E7D32' }}>{adjustedDetectionsCount}</div>
          <div className="stat-card__description">Estimated scans this month</div>
        </div>
        <div className="stat-card" style={{ borderLeft: '5px solid #C62828' }}>
          <div className="stat-card__title">False Positive Rate</div>
          <div className="stat-card__value" style={{ color: '#C62828' }}>{adjustedFalsePositive}%</div>
          <div className="stat-card__description">System validation margin</div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '320px 1fr', gap: '20px', marginTop: '20px' }}>
        
        {/* Left Side: Hyperparameter sliders */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
            <div className="panel__header" style={{ background: '#F8F9FA' }}>
              <h2 style={{ fontSize: '14px', fontWeight: '700', color: '#37474F', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Sliders size={16} /> Model Parameters
              </h2>
            </div>
            
            <div className="panel__body" style={{ padding: '20px' }}>
              <div style={{ marginBottom: '25px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '12px', fontWeight: '700' }}>
                  <span>Confidence Threshold</span>
                  <span style={{ color: '#9C27B0' }}>{confidenceThreshold}%</span>
                </div>
                <input 
                  type="range" 
                  min="50" 
                  max="99" 
                  value={confidenceThreshold} 
                  onChange={(e) => setConfidenceThreshold(Number(e.target.value))}
                  style={{ width: '100%', accentColor: '#9C27B0', cursor: 'pointer' }}
                />
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: '#78909C', marginTop: '4px' }}>
                  <span>Loose (50%)</span>
                  <span>Strict (99%)</span>
                </div>
              </div>

              {/* Individual Model accuracies */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '4px', fontWeight: '600' }}>
                    <span>Pothole Segmentation</span>
                    <span>{accuracy.potholeDetection}%</span>
                  </div>
                  <div style={{ height: '6px', background: '#ECEFF1', borderRadius: '3px', overflow: 'hidden' }}>
                    <div style={{ height: '100%', background: '#9C27B0', width: `${accuracy.potholeDetection}%` }}></div>
                  </div>
                </div>

                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '4px', fontWeight: '600' }}>
                    <span>Debris Classification</span>
                    <span>{accuracy.objectClassification}%</span>
                  </div>
                  <div style={{ height: '6px', background: '#ECEFF1', borderRadius: '3px', overflow: 'hidden' }}>
                    <div style={{ height: '100%', background: '#BA68C8', width: `${accuracy.objectClassification}%` }}></div>
                  </div>
                </div>

                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '4px', fontWeight: '600' }}>
                    <span>Severity Rank Prediction</span>
                    <span>{accuracy.priorityPrediction}%</span>
                  </div>
                  <div style={{ height: '6px', background: '#ECEFF1', borderRadius: '3px', overflow: 'hidden' }}>
                    <div style={{ height: '100%', background: '#CE93D8', width: `${accuracy.priorityPrediction}%` }}></div>
                  </div>
                </div>
              </div>

            </div>
          </div>

          {/* AI Info details box */}
          <div className="panel" style={{ background: '#FFF8E1', border: '1px solid #FFE082', padding: '15px' }}>
            <div style={{ display: 'flex', gap: '8px', color: '#EF6C00' }}>
              <AlertTriangle size={20} style={{ flexShrink: 0 }} />
              <div>
                <h4 style={{ margin: '0 0 4px 0', fontSize: '13px', fontWeight: '700' }}>Confidence Filter Active</h4>
                <p style={{ margin: '0', fontSize: '11px', lineHeight: '1.4', color: '#5D4037' }}>
                  Increasing the threshold filters noise (e.g. shadows and puddle reflections) but might skip early cracks. Set to <strong>85%</strong> for optimal municipal operations.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Right Side: Telemetric Camera feed scanner simulator */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          
          <div className="panel" style={{ border: '1px solid #37474F', background: '#263238', overflow: 'hidden' }}>
            <div className="panel__header" style={{ background: '#212121', borderBottom: '1px solid #37474F', display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 20px' }}>
              <h2 style={{ color: '#ECEFF1', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px' }}>
                <Terminal size={16} style={{ color: '#00E676' }} />
                SARA Live Camera Inspection Console
              </h2>
              <button 
                onClick={triggerTelemetryScan}
                disabled={isScanning}
                className="button button--primary"
                style={{ 
                  padding: '6px 14px', 
                  fontSize: '12px', 
                  display: 'flex', 
                  alignItems: 'center', 
                  gap: '6px', 
                  background: isScanning ? '#78909C' : '#00E676', 
                  boxShadow: 'none',
                  color: '#1a1a1a'
                }}
              >
                {isScanning ? <RefreshCw className="animate-spin" size={14} /> : <PlayCircle size={14} />}
                Trigger Live Video Scan Feed
              </button>
            </div>
            
            <div className="panel__body" style={{ padding: '0', display: 'grid', gridTemplateColumns: '1fr 250px', height: '240px' }}>
              
              {/* Simulated Camera Viewport */}
              <div style={{ position: 'relative', background: '#1A1A1A', overflow: 'hidden', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                
                {/* Simulated Road Graphics */}
                <svg width="100%" height="100%" viewBox="0 0 400 240" style={{ position: 'absolute', top: 0, left: 0 }}>
                  {/* Perspective Road lines */}
                  <line x1="150" y1="0" x2="50" y2="240" stroke="#455A64" strokeWidth="2" />
                  <line x1="250" y1="0" x2="350" y2="240" stroke="#455A64" strokeWidth="2" />
                  <line x1="200" y1="0" x2="200" y2="240" stroke="#ECEFF1" strokeWidth="4" strokeDasharray="15 15" />
                  
                  {/* Pothole 1 Overlay bounding box */}
                  {detectedTargets.includes('pothole-1') && (
                    <g>
                      <ellipse cx="140" cy="130" rx="30" ry="15" fill="#37474F" stroke="#FF1744" strokeWidth="2" opacity="0.8" />
                      <rect x="100" y="105" width="80" height="50" fill="none" stroke="#FF1744" strokeWidth="1" strokeDasharray="3 3" />
                      <text x="100" y="100" fill="#FF1744" fontSize="10" fontWeight="bold" fontFamily="monospace">POTHOLE 96.5%</text>
                    </g>
                  )}

                  {/* Crack 1 Overlay bounding box */}
                  {detectedTargets.includes('crack-1') && (
                    <g>
                      <path d="M 230 60 Q 240 70 235 80 T 250 90" fill="none" stroke="#FFB300" strokeWidth="2" />
                      <rect x="215" y="50" width="45" height="50" fill="none" stroke="#FFB300" strokeWidth="1" strokeDasharray="3 3" />
                      <text x="215" y="45" fill="#FFB300" fontSize="10" fontWeight="bold" fontFamily="monospace">CRACKS 89.2%</text>
                    </g>
                  )}
                </svg>

                {/* AI Laser Scanner sweep overlay line */}
                {isScanning && (
                  <div style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    width: '100%',
                    height: '2px',
                    background: 'rgba(0, 230, 118, 0.8)',
                    boxShadow: '0 0 8px #00E676',
                    animation: 'scanLineSweep 2.5s infinite linear'
                  }} />
                )}

                {/* Status Indicator text overlay */}
                <div style={{ position: 'absolute', top: '10px', left: '10px', background: 'rgba(0,0,0,0.7)', padding: '4px 8px', borderRadius: '4px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <div style={{
                    width: '8px',
                    height: '8px',
                    borderRadius: '50%',
                    background: isScanning ? '#00E676' : '#FF1744',
                    boxShadow: isScanning ? '0 0 6px #00E676' : 'none',
                    animation: isScanning ? 'pulse 1s infinite' : 'none'
                  }} />
                  <span style={{ fontSize: '10px', color: '#ECEFF1', fontWeight: 'bold', fontFamily: 'monospace' }}>
                    {isScanning ? 'LIVE SATELLITE TELEMETRY FEED' : 'GRID FEED STANDBY'}
                  </span>
                </div>

                {isScanning && (
                  <span style={{ position: 'absolute', bottom: '10px', right: '10px', fontSize: '11px', color: '#00E676', fontFamily: 'monospace', fontWeight: 'bold' }}>
                    Sync: {scanProgress}%
                  </span>
                )}
              </div>

              {/* Simulated Output Terminal Console log */}
              <div style={{ background: '#111', borderLeft: '1px solid #37474F', padding: '12px', fontFamily: 'monospace', fontSize: '10.5px', color: '#00E676', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                {telemetryLogs.length === 0 ? (
                  <span style={{ color: '#555' }}>Terminal logs waiting for telemetry scan trigger...</span>
                ) : (
                  telemetryLogs.map((log, idx) => <span key={idx}>{log}</span>)
                )}
              </div>

            </div>
          </div>

          {/* Detections Registry Log Table */}
          <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
            <div className="panel__header">
              <h2>Recent AI Damage Identifications</h2>
            </div>
            <div className="panel__body panel__table-wrap" style={{ padding: '0' }}>
              <table className="data-table">
                <thead>
                  <tr style={{ background: '#F8F9FA' }}>
                    <th style={{ padding: '14px 12px' }}>Anomalous Category</th>
                    <th>Zone Location</th>
                    <th>Telemetry GPS Coordinates</th>
                    <th>Severity Score</th>
                    <th>Confidence Rate</th>
                    <th>Audit Status</th>
                    <th>Operator Audit</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? (
                    <tr><td colSpan="7" style={{ textAlign: 'center', padding: '20px' }}>Loading telemetry database...</td></tr>
                  ) : detections.map((d) => {
                    const isVerified = d.status.startsWith('Verified')
                    return (
                      <tr key={d.id}>
                        <td style={{ padding: '14px 12px' }}>
                          <strong style={{ color: '#0A2F7E' }}>{d.type}</strong>
                        </td>
                        <td>{d.location}</td>
                        <td style={{ fontFamily: 'monospace', fontSize: '11.5px' }}>{d.gps}</td>
                        <td>
                          <span style={{
                            padding: '3px 8px',
                            borderRadius: '4px',
                            fontSize: '11px',
                            fontWeight: '700',
                            background: d.severity === 'High' ? '#FFEBEE' : d.severity === 'Medium' ? '#FFF3E0' : '#ECEFF1',
                            color: d.severity === 'High' ? '#C62828' : d.severity === 'Medium' ? '#E65100' : '#37474F'
                          }}>
                            {d.severity}
                          </span>
                        </td>
                        <td style={{ fontWeight: '700' }}>{d.confidence}%</td>
                        <td>
                          <span style={{
                            padding: '3px 8px',
                            borderRadius: '12px',
                            fontSize: '11px',
                            fontWeight: '600',
                            background: isVerified ? '#E8F5E9' : '#ECEFF1',
                            color: isVerified ? '#2E7D32' : '#37474F'
                          }}>
                            {d.status}
                          </span>
                        </td>
                        <td>
                          <button
                            disabled={isVerified}
                            onClick={() => handleVerifyDetection(d.id)}
                            style={{
                              border: '1px solid #B0BEC5',
                              background: 'white',
                              cursor: isVerified ? 'default' : 'pointer',
                              padding: '4px 8px',
                              borderRadius: '4px',
                              fontSize: '11px',
                              fontWeight: '600',
                              color: isVerified ? '#9E9E9E' : '#0A2F7E',
                              display: 'flex',
                              alignItems: 'center',
                              gap: '4px',
                              opacity: isVerified ? 0.7 : 1
                            }}
                          >
                            <Check size={12} />
                            {isVerified ? 'Verified' : 'Verify'}
                          </button>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>

        </div>

      </div>

      {/* Simulator Scan Animation styles */}
      <style>{`
        @keyframes scanLineSweep {
          0% { top: 0%; }
          50% { top: 100%; }
          100% { top: 0%; }
        }
        @keyframes pulse {
          0% { transform: scale(1); opacity: 1; }
          50% { transform: scale(1.1); opacity: 0.8; }
          100% { transform: scale(1); opacity: 1; }
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .animate-spin {
          animation: spin 1s linear infinite;
        }
      `}</style>
    </div>
  )
}

export default AISARInsights

