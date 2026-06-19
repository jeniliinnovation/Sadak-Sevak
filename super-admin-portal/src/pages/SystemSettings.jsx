import { useState } from 'react'
import { 
  Settings, Key, AlertOctagon, CloudLightning, ShieldCheck, 
  Save, RefreshCw, Upload, Mail, CheckCircle2, Languages 
} from 'lucide-react'

function SystemSettings() {
  const [activeTab, setActiveTab] = useState('general') // general, api, sms, backup
  const [saveStatus, setSaveStatus] = useState('idle') // idle, saving, success
  const [signaturePreview, setSignaturePreview] = useState(null)
  
  // Settings Form State
  const [generalSettings, setGeneralSettings] = useState({
    cityName: 'Rajkot Municipal Corporation',
    nodalName: 'Dr. Amit Sharma, IAS',
    supportEmail: 'nodal.officer@rajkot.gov.in',
    slaHours: '24',
    language: 'hindi_english',
    enableEmail: true,
    enableSMS: true
  })

  const [apiSettings, setApiSettings] = useState({
    mapboxToken: 'pk.eyJ1IjoicmFqa290LXJvYWRzIiwiYSI6ImNrczh2...',
    googleMapsKey: 'AIzaSyA4QzZ0M3BfT1RfeUlfUklD...',
    ekycEndpoint: 'https://uidai.gov.in/api/v2/ekyc/rmc-auth',
    weatherToken: 'wt_81a04d29f8cc4190ba...'
  })

  const [smsSettings, setSmsSettings] = useState({
    gatewayUrl: 'https://smsgw.sms.gov.in/api/v1/send',
    senderId: 'RMCSVK',
    sandesWebhook: 'https://sandes.gov.in/webhook/rmc-sadak-sevak',
    adminPhone: '+91 98765 43210'
  })

  const [securitySettings, setSecuritySettings] = useState({
    sessionTimeout: '30',
    require2fa: true,
    backupFreq: 'daily',
    cloudStorage: 'nic_cloud'
  })

  // Simulated uploader for official nodal signature seal
  const handleSignatureUpload = (e) => {
    const file = e.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onloadend = () => {
        setSignaturePreview(reader.result)
      }
      reader.readAsDataURL(file)
    }
  }

  // Settings Save Trigger Simulation
  const handleSaveSettings = (e) => {
    e.preventDefault()
    setSaveStatus('saving')
    
    // Simulate API save communication
    setTimeout(() => {
      setSaveStatus('success')
      setTimeout(() => {
        setSaveStatus('idle')
      }, 3000)
    }, 1500)
  }

  return (
    <div style={{ position: 'relative' }}>
      {/* Tricolor National Accent Line */}
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

      {/* Bilingual Title Header */}
      <div className="page-header" style={{ borderBottom: '2px solid #E0E0E0', paddingBottom: '16px' }}>
        <div>
          <p className="page-label" style={{ fontSize: '11px', color: '#B35400', fontWeight: '700', letterSpacing: '1px' }}>
            CENTRAL PORTAL INFRASTRUCTURE RULES
          </p>
          <h1 style={{ fontSize: '26px', fontWeight: '800', margin: '4px 0 2px 0', color: '#0A2F7E', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Settings size={24} style={{ color: '#0A2F7E' }} />
            System Settings
          </h1>
          <p style={{ fontSize: '12px', color: '#666', fontStyle: 'italic' }}>
            Central administration hub for API credentials, SMS gateways, and secure backup operations.
          </p>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '250px 1fr', gap: '20px', marginTop: '20px' }}>
        
        {/* Left Side: Settings Navigation Panels */}
        <div className="panel" style={{ border: '1px solid #CFD8DC', height: 'fit-content' }}>
          <div style={{ display: 'flex', flexDirection: 'column', padding: '8px' }}>
            <button
              onClick={() => setActiveTab('general')}
              style={{
                textAlign: 'left',
                padding: '12px 14px',
                border: 'none',
                borderRadius: '6px',
                background: activeTab === 'general' ? 'rgba(10, 47, 126, 0.05)' : 'transparent',
                color: activeTab === 'general' ? '#0A2F7E' : '#37474F',
                fontWeight: activeTab === 'general' ? '700' : '500',
                fontSize: '13px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}
            >
              <Settings size={16} /> General Portal
            </button>
            
            <button
              onClick={() => setActiveTab('api')}
              style={{
                textAlign: 'left',
                padding: '12px 14px',
                border: 'none',
                borderRadius: '6px',
                background: activeTab === 'api' ? 'rgba(10, 47, 126, 0.05)' : 'transparent',
                color: activeTab === 'api' ? '#0A2F7E' : '#37474F',
                fontWeight: activeTab === 'api' ? '700' : '500',
                fontSize: '13px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}
            >
              <Key size={16} /> API & Integrations
            </button>
            
            <button
              onClick={() => setActiveTab('sms')}
              style={{
                textAlign: 'left',
                padding: '12px 14px',
                border: 'none',
                borderRadius: '6px',
                background: activeTab === 'sms' ? 'rgba(10, 47, 126, 0.05)' : 'transparent',
                color: activeTab === 'sms' ? '#0A2F7E' : '#37474F',
                fontWeight: activeTab === 'sms' ? '700' : '500',
                fontSize: '13px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}
            >
              <Mail size={16} /> SMS & sandes Alerts
            </button>
            
            <button
              onClick={() => setActiveTab('backup')}
              style={{
                textAlign: 'left',
                padding: '12px 14px',
                border: 'none',
                borderRadius: '6px',
                background: activeTab === 'backup' ? 'rgba(10, 47, 126, 0.05)' : 'transparent',
                color: activeTab === 'backup' ? '#0A2F7E' : '#37474F',
                fontWeight: activeTab === 'backup' ? '700' : '500',
                fontSize: '13px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}
            >
              <CloudLightning size={16} /> Backups & Security
            </button>
          </div>
        </div>

        {/* Right Side: Tab Forms */}
        <div className="panel" style={{ border: '1px solid #B0BEC5' }}>
          
          <form onSubmit={handleSaveSettings}>
            <div className="panel__body" style={{ padding: '24px' }}>
              
              {/* SAVING SUCCESS STATE TOAST */}
              {saveStatus === 'success' && (
                <div style={{
                  background: '#E8F5E9',
                  border: '1px solid #A5D6A7',
                  padding: '12px 16px',
                  borderRadius: '8px',
                  marginBottom: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  color: '#2E7D32',
                  fontSize: '13px',
                  fontWeight: '600'
                }}>
                  <CheckCircle2 size={18} />
                  <span>NIC Cloud sync complete! Portal infrastructure parameters saved successfully.</span>
                </div>
              )}

              {/* TAB 1: General Portal Configuration */}
              {activeTab === 'general' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  <h3 style={{ fontSize: '15px', color: '#0A2F7E', borderBottom: '1px solid #CFD8DC', paddingBottom: '8px', fontWeight: '700' }}>
                    General Portal Information
                  </h3>
                  
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>City Administration Municipality Name</label>
                      <input 
                        type="text" 
                        value={generalSettings.cityName}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, cityName: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Appointed Nodal Officer Name (IAS)</label>
                      <input 
                        type="text" 
                        value={generalSettings.nodalName}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, nodalName: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Support Email Address</label>
                      <input 
                        type="email" 
                        value={generalSettings.supportEmail}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, supportEmail: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>SLA Target Response Limit (Hours)</label>
                      <input 
                        type="number" 
                        value={generalSettings.slaHours}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, slaHours: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                  </div>

                  <div>
                    <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Languages size={15} /> System Default Localisation Language
                    </label>
                    <select
                      value={generalSettings.language}
                      onChange={(e) => setGeneralSettings({ ...generalSettings, language: e.target.value })}
                      style={{ width: '100%', maxStyle: '400px', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px', background: 'white' }}
                    >
                      <option value="english">English (Official System Logs)</option>
                      <option value="hindi">Hindi localization</option>
                      <option value="gujarati">Gujarati regional default</option>
                      <option value="hindi_english">Bilingual Toggle (Hindi / English)</option>
                    </select>
                  </div>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginTop: '5px' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', cursor: 'pointer' }}>
                      <input 
                        type="checkbox" 
                        checked={generalSettings.enableEmail}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, enableEmail: e.target.checked })}
                        style={{ width: '16px', height: '16px' }}
                      />
                      Enable automated email notifications to citizen registries
                    </label>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', cursor: 'pointer' }}>
                      <input 
                        type="checkbox" 
                        checked={generalSettings.enableSMS}
                        onChange={(e) => setGeneralSettings({ ...generalSettings, enableSMS: e.target.checked })}
                        style={{ width: '16px', height: '16px' }}
                      />
                      Enable automated SMS push updates via NIC SMS portal
                    </label>
                  </div>

                  {/* Nodal Officer Seal signature Uploader */}
                  <div style={{
                    marginTop: '15px',
                    border: '1px dashed #B0BEC5',
                    borderRadius: '8px',
                    padding: '20px',
                    textAlign: 'center',
                    background: '#FAFAFA'
                  }}>
                    <h4 style={{ margin: '0 0 6px 0', fontSize: '13px', color: '#37474F', fontWeight: '700' }}>Official Nodal Signature Seal Approval</h4>
                    <p style={{ margin: '0 0 15px 0', fontSize: '11px', color: '#78909C' }}>
                      Upload the Nodal Officer Signature seal image. Applied automatically onto municipal PDF tenders & work certificates.
                    </p>
                    
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px' }}>
                      {signaturePreview ? (
                        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
                          <img 
                            src={signaturePreview} 
                            alt="Nodal Seal Signature preview" 
                            style={{ maxHeight: '80px', border: '1px solid #ECEFF1', borderRadius: '4px', padding: '5px', background: 'white' }}
                          />
                          <button 
                            type="button" 
                            onClick={() => setSignaturePreview(null)}
                            style={{ background: 'none', border: 'none', color: '#C62828', textDecoration: 'underline', fontSize: '11px', cursor: 'pointer' }}
                          >
                            Remove signature seal
                          </button>
                        </div>
                      ) : (
                        <label style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '6px',
                          padding: '10px 16px',
                          background: 'white',
                          border: '1px solid #CFD8DC',
                          borderRadius: '6px',
                          fontSize: '12px',
                          fontWeight: '600',
                          color: '#37474F',
                          cursor: 'pointer',
                          boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
                        }}>
                          <Upload size={14} />
                          Upload Signature Image (PNG)
                          <input type="file" accept="image/png, image/jpeg" onChange={handleSignatureUpload} style={{ display: 'none' }} />
                        </label>
                      )}
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 2: API Keys and integration parameters */}
              {activeTab === 'api' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  <h3 style={{ fontSize: '15px', color: '#0A2F7E', borderBottom: '1px solid #CFD8DC', paddingBottom: '8px', fontWeight: '700' }}>
                    API & Service Integrations
                  </h3>
                  
                  <div>
                    <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Mapbox Web GL Map Access Token</label>
                    <input 
                      type="text" 
                      value={apiSettings.mapboxToken}
                      onChange={(e) => setApiSettings({ ...apiSettings, mapboxToken: e.target.value })}
                      style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                    />
                    <p style={{ margin: '4px 0 0 0', fontSize: '11px', color: '#78909C' }}>Used for live tracking dashboard map render loops.</p>
                  </div>

                  <div>
                    <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Google Maps Directions API Access Key</label>
                    <input 
                      type="text" 
                      value={apiSettings.googleMapsKey}
                      onChange={(e) => setApiSettings({ ...apiSettings, googleMapsKey: e.target.value })}
                      style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                    />
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>UIDAI Aadhaar e-KYC API Hook</label>
                      <input 
                        type="text" 
                        value={apiSettings.ekycEndpoint}
                        onChange={(e) => setApiSettings({ ...apiSettings, ekycEndpoint: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                      />
                    </div>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>RMC OpenWeather API Secret</label>
                      <input 
                        type="text" 
                        value={apiSettings.weatherToken}
                        onChange={(e) => setApiSettings({ ...apiSettings, weatherToken: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                      />
                    </div>
                  </div>

                  <div style={{ background: '#FFF8E1', border: '1px solid #FFE082', padding: '12px', borderRadius: '6px', display: 'flex', gap: '8px', color: '#EF6C00' }}>
                    <AlertOctagon size={20} style={{ flexShrink: 0 }} />
                    <span style={{ fontSize: '11px', lineHeight: '1.4', color: '#5D4037' }}>
                      API keys are cryptographically hashed using SHA-256 on the government server. Do not share raw console logs containing credentials.
                    </span>
                  </div>
                </div>
              )}

              {/* TAB 3: SMS Gateway and alert configuration */}
              {activeTab === 'sms' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  <h3 style={{ fontSize: '15px', color: '#0A2F7E', borderBottom: '1px solid #CFD8DC', paddingBottom: '8px', fontWeight: '700' }}>
                    National SMS & Sandes Webhook Gateway
                  </h3>

                  <div>
                    <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>National e-Governance SMS Portal Base API Endpoint</label>
                    <input 
                      type="text" 
                      value={smsSettings.gatewayUrl}
                      onChange={(e) => setSmsSettings({ ...smsSettings, gatewayUrl: e.target.value })}
                      style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                    />
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>NIC Registered Sender ID (6-Letters)</label>
                      <input 
                        type="text" 
                        maxLength="6"
                        value={smsSettings.senderId}
                        onChange={(e) => setSmsSettings({ ...smsSettings, senderId: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px', fontWeight: '700', letterSpacing: '1px' }} 
                      />
                    </div>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Nodal Administrator Emergency Mobile</label>
                      <input 
                        type="text" 
                        value={smsSettings.adminPhone}
                        onChange={(e) => setSmsSettings({ ...smsSettings, adminPhone: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                  </div>

                  <div>
                    <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>NIC Sandes App Instant Messenger Webhook Web-service</label>
                    <input 
                      type="text" 
                      value={smsSettings.sandesWebhook}
                      onChange={(e) => setSmsSettings({ ...smsSettings, sandesWebhook: e.target.value })}
                      style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '12px', fontFamily: 'monospace' }} 
                    />
                    <p style={{ margin: '4px 0 0 0', fontSize: '11px', color: '#78909C' }}>Streams critical city road emergency alerts directly into Nodal Officers Sandes channels.</p>
                  </div>
                </div>
              )}

              {/* TAB 4: Backups & Security Configuration */}
              {activeTab === 'backup' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  <h3 style={{ fontSize: '15px', color: '#0A2F7E', borderBottom: '1px solid #CFD8DC', paddingBottom: '8px', fontWeight: '700' }}>
                    Backup Schedules & CERT-In Protocols
                  </h3>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Database Backup Schedule Frequency</label>
                      <select
                        value={securitySettings.backupFreq}
                        onChange={(e) => setSecuritySettings({ ...securitySettings, backupFreq: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px', background: 'white' }}
                      >
                        <option value="hourly">Hourly Incrementals</option>
                        <option value="daily">Daily Cron Replica (02:00 AM IST)</option>
                        <option value="weekly">Weekly Core Tarball</option>
                        <option value="monthly">Monthly Master Archive</option>
                      </select>
                    </div>

                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Backup Cloud Replication Storage target</label>
                      <select
                        value={securitySettings.cloudStorage}
                        onChange={(e) => setSecuritySettings({ ...securitySettings, cloudStorage: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px', background: 'white' }}
                      >
                        <option value="nic_cloud">NIC National Cloud (Meghraj)</option>
                        <option value="aws_mumbai">Amazon Web Services (GovCloud Mumbai)</option>
                        <option value="local_rmc">RMC Dedicated Local Datacenter Replica</option>
                      </select>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                      <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Session Automatic Inactivity Timeout (Minutes)</label>
                      <input 
                        type="number" 
                        value={securitySettings.sessionTimeout}
                        onChange={(e) => setSecuritySettings({ ...securitySettings, sessionTimeout: e.target.value })}
                        style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                      />
                    </div>
                    
                    <div style={{ display: 'flex', alignItems: 'center', height: '100%', paddingTop: '22px' }}>
                      <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', cursor: 'pointer', fontWeight: '700' }}>
                        <input 
                          type="checkbox" 
                          checked={securitySettings.require2fa}
                          onChange={(e) => setSecuritySettings({ ...securitySettings, require2fa: e.target.checked })}
                          style={{ width: '16px', height: '16px' }}
                        />
                        Require Nodal Two-Factor (Aadhaar-OTP / SMS)
                      </label>
                    </div>
                  </div>

                  <div style={{
                    background: '#E8F5E9',
                    border: '1px solid #A5D6A7',
                    borderRadius: '8px',
                    padding: '15px',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <div>
                      <h4 style={{ margin: '0', fontSize: '13px', color: '#2E7D32', fontWeight: '700' }}>Database Redundancy OK</h4>
                      <p style={{ margin: '2px 0 0 0', fontSize: '11px', color: '#4CAF50' }}>Last backup replica successfully uploaded to Meghraj NIC Cloud on 18/06/2026 at 02:00 AM.</p>
                    </div>
                    <button 
                      type="button"
                      onClick={() => alert('Manually triggering system snapshot backup to NIC Cloud server. Please hold...')} 
                      className="button button--secondary" 
                      style={{ background: 'white', padding: '6px 12px', fontSize: '12px' }}
                    >
                      Back Up Now
                    </button>
                  </div>
                </div>
              )}

            </div>

            {/* Panel Save Footer */}
            <div style={{
              background: '#ECEFF1',
              borderTop: '1px solid #CFD8DC',
              padding: '16px 24px',
              display: 'flex',
              justifyContent: 'flex-end',
              alignItems: 'center',
              gap: '15px'
            }}>
              <span style={{ fontSize: '11px', color: '#78909C', display: 'flex', alignItems: 'center', gap: '4px' }}>
                <ShieldCheck size={14} style={{ color: '#2E7D32' }} />
                Changes are logged to CERT-In compliance audit.
              </span>
              
              <button 
                type="submit" 
                disabled={saveStatus === 'saving'}
                className="button button--primary"
                style={{ padding: '10px 20px', display: 'flex', alignItems: 'center', gap: '8px' }}
              >
                {saveStatus === 'saving' ? (
                  <>
                    <RefreshCw className="animate-spin" size={16} />
                    Syncing Configuration...
                  </>
                ) : (
                  <>
                    <Save size={16} />
                    Save Configuration
                  </>
                )}
              </button>
            </div>
          </form>

        </div>

      </div>

      <style>{`
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

export default SystemSettings

