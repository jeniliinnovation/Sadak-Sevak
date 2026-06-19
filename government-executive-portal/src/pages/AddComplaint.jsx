import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useComplaintCategories, useDepartments } from '../hooks/useApi'
import { apiFetch } from '../services/api'

function AddComplaint() {
  const navigate = useNavigate()
  const { data: categories, loading: categoriesLoading } = useComplaintCategories()
  const { data: departments, loading: departmentsLoading } = useDepartments()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [formData, setFormData] = useState({
    category: '',
    title: '',
    priority: 'Medium',
    location: '',
    department: '',
    description: '',
    media: null,
  })

  const handleChange = (e) => {
    const { name, value, files } = e.target
    if (files) {
      setFormData(prev => ({ ...prev, media: files[0] }))
    } else {
      setFormData(prev => ({ ...prev, [name]: value }))
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      setLoading(true)
      setError(null)
      const formDataObj = new FormData()
      Object.keys(formData).forEach(key => {
        if (formData[key]) {
          formDataObj.append(key, formData[key])
        }
      })
      await apiFetch('/complaints', {
        method: 'POST',
        body: formDataObj,
      })
      navigate('/complaints')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const categoryList = categories || []
  const departmentList = departments || []

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Add Complaint</h1></div>
      
      {error && <div className="error-message">{error}</div>}

      <section className="panel panel--full">
        <form onSubmit={handleSubmit}>
          <div className="panel__body form-grid">
            <label>
              Category
              <select name="category" value={formData.category} onChange={handleChange} required disabled={categoriesLoading}>
                <option value="">Select category...</option>
                {categoryList.map((cat) => (
                  <option key={cat.id || cat.name} value={cat.id || cat.name}>
                    {cat.name || cat}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Title
              <input 
                type="text" 
                name="title" 
                value={formData.title} 
                onChange={handleChange}
                placeholder="Complaint title" 
                required
              />
            </label>
            <label>
              Priority
              <select name="priority" value={formData.priority} onChange={handleChange}>
                <option>High</option>
                <option>Medium</option>
                <option>Low</option>
              </select>
            </label>
            <label>
              Location
              <input 
                type="text" 
                name="location" 
                value={formData.location} 
                onChange={handleChange}
                placeholder="Location details" 
                required
              />
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
              Description
              <textarea 
                name="description" 
                value={formData.description} 
                onChange={handleChange}
                placeholder="Describe the issue" 
                rows="4" 
                required
              />
            </label>
            <label>
              Media Upload
              <input 
                type="file" 
                name="media" 
                onChange={handleChange} 
                accept="image/*"
              />
            </label>
          </div>
          <div className="form-actions">
            <button className="button button--primary" type="submit" disabled={loading}>
              {loading ? 'Submitting...' : 'Submit'}
            </button>
            <button 
              className="button button--secondary" 
              type="button" 
              onClick={() => navigate('/complaints')}
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

export default AddComplaint
