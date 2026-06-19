import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

function Login() {
  const [email, setEmail] = useState('superadmin@citygovernment.gov')
  const [password, setPassword] = useState('superadmin@123')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [view, setView] = useState('login') // 'login' | 'forgot-password' | 'forgot-password-success'
  const [resetEmail, setResetEmail] = useState('')
  const navigate = useNavigate()
  const { login } = useAuth()

  const handleSubmit = async (event) => {
    event.preventDefault()
    setLoading(true)
    setError('')

    const result = await login(email, password)
    setLoading(false)

    if (result.success) {
      navigate('/')
    } else {
      setError(result.message || 'Unable to sign in')
    }
  }

  const handleForgotPasswordSubmit = (e) => {
    e.preventDefault()
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      setView('forgot-password-success')
    }, 800)
  }

  const loadSuperAdmin = () => {
    setEmail('superadmin@citygovernment.gov')
    setPassword('superadmin@123')
    setError('')
  }

  const loadDemoAdmin = () => {
    setEmail('admin@sadaksevak.org')
    setPassword('admin123')
    setError('')
  }

  return (
    <div className="login-page">
      <div className="login-card">
        {view === 'login' && (
          <>
            <h1>City Government Portal</h1>
            <p>Executive administration dashboard</p>

            <form onSubmit={handleSubmit} className="login-form">
              <label>
                Email
                <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
              </label>
              <label>
                Password
                <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
              </label>

              <div style={{ textAlign: 'right', marginTop: '-6px', marginBottom: '4px' }}>
                <button 
                  type="button" 
                  onClick={() => setView('forgot-password')} 
                  style={{ background: 'none', border: 'none', color: 'var(--success)', cursor: 'pointer', fontSize: '0.85rem', fontWeight: 600, padding: 0 }}
                >
                  Forgot Password?
                </button>
              </div>

              {error && <div className="login-error">{error}</div>}

              <button className="button button--primary button--full" type="submit" disabled={loading}>
                {loading ? 'Signing in...' : 'Sign In'}
              </button>
            </form>

            <div className="login-demos">
              <p style={{ fontSize: '12px', color: '#666', marginBottom: '10px', textAlign: 'center' }}>Demo Accounts:</p>
              <button type="button" onClick={loadSuperAdmin} className="button button--secondary" style={{ marginBottom: '8px' }}>
                👑 Load Super Admin
              </button>
              <button type="button" onClick={loadDemoAdmin} className="button button--secondary">
                Load Admin
              </button>
            </div>
          </>
        )}

        {view === 'forgot-password' && (
          <>
            <h1>Forgot Password</h1>
            <p>Enter your email address to receive a password reset link.</p>

            <form onSubmit={handleForgotPasswordSubmit} className="login-form">
              <label>
                Email Address
                <input 
                  type="email" 
                  value={resetEmail} 
                  onChange={(e) => setResetEmail(e.target.value)} 
                  placeholder="Enter registered email"
                  required 
                />
              </label>

              <button className="button button--primary button--full" type="submit" disabled={loading}>
                {loading ? 'Sending Request...' : 'Send Reset Link'}
              </button>
              <button 
                type="button" 
                onClick={() => setView('login')} 
                className="button button--secondary button--full"
                disabled={loading}
              >
                Back to Sign In
              </button>
            </form>
          </>
        )}

        {view === 'forgot-password-success' && (
          <>
            <h1>Check Your Email</h1>
            <p style={{ lineHeight: '1.6', marginBottom: '8px', textAlign: 'center' }}>
              If that email address exists in our system, we've sent a password reset link to it. Please check your inbox.
            </p>
            <button 
              type="button" 
              onClick={() => { setView('login'); setResetEmail(''); }} 
              className="button button--primary button--full"
            >
              Back to Sign In
            </button>
          </>
        )}
      </div>
    </div>
  )
}

export default Login
