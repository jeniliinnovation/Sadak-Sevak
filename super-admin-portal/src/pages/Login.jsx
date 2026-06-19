import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

function Login() {
  const [email, setEmail] = useState('superadmin@citygovernment.gov')
  const [password, setPassword] = useState('superadmin@123')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
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

  return (
    <div className="login-page">
      <div className="login-card">
        <h1>👑 Super Admin Portal</h1>
        <p>City Government - Full Access Control</p>

        <form onSubmit={handleSubmit} className="login-form">
          <label>
            Email
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </label>
          <label>
            Password
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          </label>

          {error && <div className="login-error">{error}</div>}

          <button className="button button--primary button--full" type="submit" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>

        <div className="login-demos">
          <p style={{ fontSize: '12px', color: '#666', marginBottom: '10px', textAlign: 'center' }}>Demo Credentials (Pre-filled)</p>
          <p style={{ fontSize: '11px', color: '#999', textAlign: 'center' }}>
            Email: superadmin@citygovernment.gov
          </p>
          <p style={{ fontSize: '11px', color: '#999', textAlign: 'center' }}>
            Password: superadmin@123
          </p>
        </div>
      </div>
    </div>
  )
}

export default Login
