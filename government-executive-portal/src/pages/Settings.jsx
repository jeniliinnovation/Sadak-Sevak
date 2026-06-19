import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, Search, Bell, Settings as SettingsIcon } from 'lucide-react'

function Settings() {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState(null)
  const [saveMessage, setSaveMessage] = useState(null)

  // System States
  const [orgName, setOrgName] = useState('Sadak Sevak Executive Board')
  const [primaryColor, setPrimaryColor] = useState('green')
  const [itemsPerPage, setItemsPerPage] = useState('10')

  const [emailAlerts, setEmailAlerts] = useState(true)
  const [smsAlerts, setSmsAlerts] = useState(true)
  const [pushNotifications, setPushNotifications] = useState(true)
  const [severityThreshold, setSeverityThreshold] = useState('all')

  const [confidenceThreshold, setConfidenceThreshold] = useState(85)
  const [samplingRate, setSamplingRate] = useState('5')
  const [scanSchedule, setScanSchedule] = useState('continuous')

  const [backupInterval, setBackupInterval] = useState('daily')
  const [retentionWindow, setRetentionWindow] = useState('30')

  const [passwordLength, setPasswordLength] = useState('8')
  const [sessionTimeout, setSessionTimeout] = useState('30')
  const [enforceMfa, setEnforceMfa] = useState(false)

  const [apiUrl, setApiUrl] = useState('http://localhost:5000/api')
  const [showToken, setShowToken] = useState(false)

  const categories = [
    {
      id: 'general',
      title: 'General',
      description: 'Update organization details, branding, and dashboard preferences.',
      icon: '⚙️',
    },
    {
      id: 'notification',
      title: 'Notification',
      description: 'Configure email, SMS, and in-app alert settings for admins.',
      icon: '🔔',
    },
    {
      id: 'sara',
      title: 'SARA',
      description: 'Manage SARA model thresholds, scan schedules, and data sources.',
      icon: '🤖',
    },
    {
      id: 'backup',
      title: 'Backup & Restore',
      description: 'Review backup frequency and restore settings for database snapshots.',
      icon: '💾',
    },
    {
      id: 'security',
      title: 'Security',
      description: 'Manage password complexity policies, session timeouts, and MFA.',
      icon: '🔒',
    },
    {
      id: 'api',
      title: 'API Settings',
      description: 'Configure API keys, endpoints, and integration access controls.',
      icon: '🔌',
    },
  ]

  const handleSave = (e) => {
    e.preventDefault()
    setSaveMessage('Configuration saved successfully!')
    setTimeout(() => {
      setSaveMessage(null)
    }, 3000)
  }

  const PillSelector = ({ options, value, onChange }) => (
    <div className="jobie-pill-container">
      {options.map((opt) => (
        <button
          key={opt.value}
          type="button"
          className={`jobie-pill-option ${value === opt.value ? 'active' : ''}`}
          onClick={() => onChange(opt.value)}
        >
          {opt.label}
        </button>
      ))}
    </div>
  )

  const ToggleSwitch = ({ label, checked, onChange }) => (
    <label className="jobie-switch-label">
      <span className="jobie-switch-text">{label}</span>
      <span className="jobie-switch">
        <input 
          type="checkbox" 
          checked={checked} 
          onChange={(e) => onChange(e.target.checked)} 
        />
        <span className="jobie-slider"></span>
      </span>
    </label>
  )

  const renderSettingsForm = () => {
    if (activeTab === 'general') {
      return (
        <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
          <label className="jobie-label">
            Organization Name
            <input 
              type="text" 
              className="jobie-input" 
              value={orgName} 
              onChange={(e) => setOrgName(e.target.value)} 
              required 
            />
          </label>
          <div className="jobie-label">
            System Primary Color
            <PillSelector
              options={[
                { value: 'green', label: 'Forest Green (Sadak Sevak Default)' },
                { value: 'blue', label: 'Ocean Blue' },
                { value: 'indigo', label: 'Corporate Indigo' }
              ]}
              value={primaryColor}
              onChange={setPrimaryColor}
            />
          </div>
          <div className="jobie-label">
            Items Per Page (Tables)
            <PillSelector
              options={[
                { value: '5', label: '5 records' },
                { value: '10', label: '10 records' },
                { value: '25', label: '25 records' }
              ]}
              value={itemsPerPage}
              onChange={setItemsPerPage}
            />
          </div>
          <div className="jobie-btn-group">
            <button className="jobie-btn-primary" type="submit">Save Settings</button>
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Cancel</button>
          </div>
        </form>
      )
    }
    if (activeTab === 'notification') {
      return (
        <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
          <ToggleSwitch 
            label="Enable Email Alerts" 
            checked={emailAlerts} 
            onChange={setEmailAlerts} 
          />
          <ToggleSwitch 
            label="Enable SMS Dispatch alerts" 
            checked={smsAlerts} 
            onChange={setSmsAlerts} 
          />
          <ToggleSwitch 
            label="Enable Real-time Browser Push Notifications" 
            checked={pushNotifications} 
            onChange={setPushNotifications} 
          />
          <div className="jobie-label">
            Notification Severity Threshold
            <PillSelector
              options={[
                { value: 'all', label: 'Low, Medium & High Anomalies' },
                { value: 'medium', label: 'Medium & High Anomalies Only' },
                { value: 'high', label: 'Critical High Anomalies Only' }
              ]}
              value={severityThreshold}
              onChange={setSeverityThreshold}
            />
          </div>
          <div className="jobie-btn-group">
            <button className="jobie-btn-primary" type="submit">Save Settings</button>
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Cancel</button>
          </div>
        </form>
      )
    }
    if (activeTab === 'sara') {
      return (
        <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
          <div className="jobie-label">
            ML Detection Confidence Threshold (Min: {confidenceThreshold}%)
            <input 
              type="range" 
              min="50" 
              max="100" 
              value={confidenceThreshold} 
              className="jobie-range-slider"
              onChange={(e) => setConfidenceThreshold(Number(e.target.value))} 
            />
          </div>
          <div className="jobie-label">
            Camera Sampling Rate (Frames/Second)
            <PillSelector
              options={[
                { value: '1', label: '1 Frame/Sec (Optimized Storage)' },
                { value: '5', label: '5 Frames/Sec (Medium Traffic)' },
                { value: '10', label: '10 Frames/Sec (High-speed Highway)' }
              ]}
              value={samplingRate}
              onChange={setSamplingRate}
            />
          </div>
          <div className="jobie-label">
            Scan Schedule
            <PillSelector
              options={[
                { value: 'hourly', label: 'Hourly Automated Scan' },
                { value: 'daily', label: 'Daily Cron Summary' },
                { value: 'continuous', label: 'Continuous Feed Stream' }
              ]}
              value={scanSchedule}
              onChange={setScanSchedule}
            />
          </div>
          <div className="jobie-btn-group">
            <button className="jobie-btn-primary" type="submit">Save Settings</button>
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Cancel</button>
          </div>
        </form>
      )
    }
    if (activeTab === 'backup') {
      return (
        <div style={{ display: 'grid', gap: '20px' }}>
          <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
            <div className="jobie-label">
              Backup Interval
              <PillSelector
                options={[
                  { value: 'daily', label: 'Daily Auto-Backup' },
                  { value: 'weekly', label: 'Weekly Auto-Backup' }
                ]}
                value={backupInterval}
                onChange={setBackupInterval}
              />
            </div>
            <div className="jobie-label">
              Retention Window
              <PillSelector
                options={[
                  { value: '30', label: 'Retain for 30 Days' },
                  { value: '90', label: 'Retain for 90 Days' }
                ]}
                value={retentionWindow}
                onChange={setRetentionWindow}
              />
            </div>
            <button className="jobie-btn-primary" type="submit" style={{ width: 'fit-content' }}>Save Backup Rules</button>
          </form>
          <hr style={{ borderColor: 'var(--sevak-border)', margin: '10px 0' }} />
          <div>
            <p style={{ fontWeight: 700, margin: '0 0 10px', fontSize: '0.95rem', color: 'var(--sevak-text)' }}>Instant Database Snapshot</p>
            <button className="jobie-btn-secondary" type="button" onClick={() => alert('Database snapshot created successfully!')}>
              💾 Create Manual Backup Now
            </button>
          </div>
          <div className="jobie-btn-group">
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Back to Overview</button>
          </div>
        </div>
      )
    }
    if (activeTab === 'security') {
      return (
        <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
          <div className="jobie-label">
            Minimum Password Complexity Length
            <PillSelector
              options={[
                { value: '8', label: '8 Characters minimum' },
                { value: '12', label: '12 Characters minimum (High Security)' }
              ]}
              value={passwordLength}
              onChange={setPasswordLength}
            />
          </div>
          <div className="jobie-label">
            Session Expiration Timeout
            <PillSelector
              options={[
                { value: '15', label: '15 Minutes idle' },
                { value: '30', label: '30 Minutes idle' },
                { value: '60', label: '60 Minutes idle' }
              ]}
              value={sessionTimeout}
              onChange={setSessionTimeout}
            />
          </div>
          <ToggleSwitch 
            label="Enforce Admin Multi-factor Authentication (MFA)" 
            checked={enforceMfa} 
            onChange={setEnforceMfa} 
          />
          <div className="jobie-btn-group">
            <button className="jobie-btn-primary" type="submit">Save Settings</button>
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Cancel</button>
          </div>
        </form>
      )
    }
    if (activeTab === 'api') {
      return (
        <form onSubmit={handleSave} style={{ display: 'grid', gap: '20px' }}>
          <label className="jobie-label">
            API Endpoint Server Base URL
            <input 
              type="text" 
              className="jobie-input" 
              value={apiUrl} 
              onChange={(e) => setApiUrl(e.target.value)} 
              required 
            />
          </label>
          <label className="jobie-label">
            Executive Portal Client Token
            <div style={{ display: 'flex', gap: '10px', width: '100%' }}>
              <input 
                type={showToken ? 'text' : 'password'} 
                defaultValue="sadaksevak_exec_api_key_zY8xW7vU6tS5" 
                readOnly 
                className="jobie-input"
                style={{ fontFamily: 'monospace', flex: 1 }} 
              />
              <button 
                className="jobie-btn-secondary" 
                type="button" 
                style={{ borderRadius: '999px', whiteSpace: 'nowrap' }} 
                onClick={() => setShowToken(!showToken)}
              >
                {showToken ? 'Hide' : 'Show'}
              </button>
            </div>
          </label>
          <button 
            className="jobie-btn-secondary" 
            type="button" 
            style={{ width: 'fit-content' }} 
            onClick={() => alert('New client token generated! Remember to update your .env files.')}
          >
            🔌 Regenerate API Tokens
          </button>
          <div className="jobie-btn-group">
            <button className="jobie-btn-primary" type="submit">Save Endpoint</button>
            <button className="jobie-btn-secondary" type="button" onClick={() => setActiveTab(null)}>Cancel</button>
          </div>
        </form>
      )
    }
    return null
  }

  const activeCategory = categories.find(c => c.id === activeTab)

  return (
    <div className="jobie-settings-container">
      {/* Sidebar Navigation */}
      <aside className="jobie-sidebar">
        <div>
          <div className="jobie-sidebar-brand">
            <div className="jobie-logo-circle">S</div>
            <span className="jobie-logo-text">Sevak Config</span>
          </div>
          <nav className="jobie-nav">
            <button
              className={`jobie-nav-item ${activeTab === null ? 'active' : ''}`}
              onClick={() => setActiveTab(null)}
            >
              <span className="jobie-nav-icon"><SettingsIcon size={18} /></span>
              <span>Overview</span>
            </button>
            {categories.map((cat) => (
              <button
                key={cat.id}
                className={`jobie-nav-item ${activeTab === cat.id ? 'active' : ''}`}
                onClick={() => setActiveTab(cat.id)}
              >
                <span className="jobie-nav-icon">{cat.icon}</span>
                <span>{cat.title}</span>
              </button>
            ))}
          </nav>
        </div>
        <div className="jobie-sidebar-footer">
          <p>Sadak Sevak Admin Settings</p>
          <span>System Version 2.4.1</span>
        </div>
      </aside>

      {/* Main Settings Panel Content */}
      <main className="jobie-main">
        {/* Mock Top Header bar */}
        <header className="jobie-header">
          <div className="jobie-header-left">
            <h1 className="jobie-header-title">
              {activeCategory ? `${activeCategory.title} Settings` : 'System Settings'}
            </h1>
          </div>
          <div className="jobie-header-right">
            <div className="jobie-search-bar">
              <Search size={16} style={{ color: 'var(--sevak-text-muted)', marginRight: '8px' }} />
              <input type="text" placeholder="Search system settings..." />
            </div>
            <div className="jobie-profile-badge">
              <div className="jobie-avatar">SS</div>
              <div className="jobie-avatar-info">
                <span className="jobie-avatar-name">Gov Exec</span>
                <span className="jobie-avatar-role">Super Admin</span>
              </div>
            </div>
          </div>
        </header>

        {/* Setting details content container */}
        <div className="jobie-card">
          {saveMessage && (
            <div className="jobie-success-alert animate-fadeIn">
              <span>✅</span>
              <span>{saveMessage}</span>
            </div>
          )}

          {activeTab ? (
            <div className="jobie-form-container animate-fadeIn">
              <div className="jobie-form-header">
                <h2>Configure {activeCategory?.title} Options</h2>
                <p>{activeCategory?.description}</p>
              </div>
              <div className="jobie-form-body">
                {renderSettingsForm()}
              </div>
            </div>
          ) : (
            <div className="jobie-welcome-panel animate-fadeIn">
              <div className="jobie-welcome-icon">⚙️</div>
              <h2>Welcome to System Settings</h2>
              <p>Configure organizational parameters, security regulations, alert notification targets, scan schedules, and integration tokens here.</p>
              <div className="jobie-welcome-grid">
                {categories.map((item) => (
                  <div
                    key={item.id}
                    className="jobie-welcome-card"
                    onClick={() => setActiveTab(item.id)}
                  >
                    <span className="jobie-welcome-card-icon">{item.icon}</span>
                    <h3>{item.title}</h3>
                    <p>{item.description}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

export default Settings
