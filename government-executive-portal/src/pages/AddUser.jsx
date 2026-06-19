import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useRoles, useDepartments } from '../hooks/useApi'
import { apiFetch } from '../services/api'

function AddUser() {
  const navigate = useNavigate()
  const { data: roles, loading: rolesLoading } = useRoles()
  const { data: departments, loading: departmentsLoading } = useDepartments()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    department: '',
    password: '',
    status: true,
  })

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      setLoading(true)
      setError(null)
      await apiFetch('/admin/users', {
        method: 'POST',
        body: JSON.stringify(formData),
      })
      navigate('/users')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const rolesList = (roles || []).map(r => ({ id: r.id || r, name: r.name || r.role || r }))
  const departmentList = departments || []

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Add / Edit User</h1></div>
      
      {error && <div className="error-message">{error}</div>}

      <section className="panel panel--full">
        <form onSubmit={handleSubmit}>
          <div className="panel__body form-grid">
            <label>
              Name
              <input 
                type="text" 
                name="name" 
                value={formData.name} 
                onChange={handleChange}
                placeholder="Name" 
                required
              />
            </label>
            <label>
              Email
              <input 
                type="email" 
                name="email" 
                value={formData.email} 
                onChange={handleChange}
                placeholder="Email" 
                required
              />
            </label>
            <label>
              Phone
              <input 
                type="tel" 
                name="phone" 
                value={formData.phone} 
                onChange={handleChange}
                placeholder="Phone" 
              />
            </label>
            <label>
              Role
              <select name="role" value={formData.role} onChange={handleChange} required disabled={rolesLoading}>
                <option value="">Select role...</option>
                {rolesList.map((role) => (
                  <option key={role.id} value={role.id}>
                    {role.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Department
              <select name="department" value={formData.department} onChange={handleChange} disabled={departmentsLoading}>
                <option value="">Select department...</option>
                {departmentList.map((dept) => (
                  <option key={dept.id || dept.name} value={dept.id || dept.name}>
                    {dept.name || dept}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Password
              <input 
                type="password" 
                name="password" 
                value={formData.password} 
                onChange={handleChange}
                placeholder="Password" 
                required
              />
            </label>
            <label className="toggle-label">
              Status
              <input 
                type="checkbox" 
                name="status" 
                checked={formData.status} 
                onChange={handleChange}
              />
              <span className="toggle-slider" />
            </label>
          </div>
          <div className="form-actions">
            <button className="button button--primary" type="submit" disabled={loading}>
              {loading ? 'Saving...' : 'Save'}
            </button>
            <button 
              className="button button--secondary" 
              type="button" 
              onClick={() => navigate('/users')}
              disabled={loading}
            >
              Cancel
            </button>
          </div>
        </form>
      </section>
    </div>
  )
}

export default AddUser
