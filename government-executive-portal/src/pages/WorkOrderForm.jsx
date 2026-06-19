import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { apiFetch } from '../services/api'
import './WorkOrderForm.css'

function WorkOrderForm() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    workType: 'Maintenance',
    location: { address: '', area: '' },
    assignedToId: '',
    priority: 'Medium',
    status: 'pending',
    progress: 0,
    startDate: '',
    endDate: '',
    budget: '',
    estimatedDuration: '',
    notes: ''
  })

  useEffect(() => {
    if (id) {
      const fetchWorkOrder = async () => {
        try {
          setLoading(true)
          const data = await apiFetch(`/admin/work-orders/${id}`)
          setFormData(data)
        } catch (err) {
          setError(err.message)
        } finally {
          setLoading(false)
        }
      }
      fetchWorkOrder()
    }
  }, [id])

  const handleChange = (e) => {
    const { name, value } = e.target
    if (name.includes('location.')) {
      const field = name.split('.')[1]
      setFormData(prev => ({
        ...prev,
        location: { ...prev.location, [field]: value }
      }))
    } else {
      setFormData(prev => ({ ...prev, [name]: value }))
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      setLoading(true)
      setError(null)
      
      const method = id ? 'PUT' : 'POST'
      const endpoint = id ? `/admin/work-orders/${id}` : '/admin/work-orders'
      
      // Strip empty optional fields before submission
      const submitData = { ...formData }
      if (!submitData.startDate) delete submitData.startDate
      if (!submitData.endDate) delete submitData.endDate
      if (!submitData.budget) delete submitData.budget
      if (!submitData.estimatedDuration) delete submitData.estimatedDuration
      if (!submitData.assignedToId) delete submitData.assignedToId
      
      const response = await apiFetch(endpoint, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(submitData)
      })

      navigate('/work-orders')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>{id ? 'Edit Work Order' : 'New Work Order'}</h1>
        <p className="subtitle">{id ? 'Update the work order details' : 'Create a new work order for road maintenance or infrastructure work'}</p>
      </div>

      {error && (
        <div className="alert alert--error">
          <span className="alert-icon">⚠️</span>
          <span>{error}</span>
        </div>
      )}

      {loading && (
        <div className="alert alert--info">
          <span>Processing...</span>
        </div>
      )}

      <section className="panel panel--form">
        <form onSubmit={handleSubmit} className="form">
          {/* BASIC INFORMATION SECTION */}
          <div className="form-section">
            <div className="section-header">
              <h3>Basic Information</h3>
              <p className="section-subtitle">Essential details about the work order</p>
            </div>

            <div className="form-group">
              <label htmlFor="title">
                <span className="required">*</span> Title
              </label>
              <input
                id="title"
                type="text"
                name="title"
                value={formData.title}
                onChange={handleChange}
                required
                placeholder="E.g., Repair large pothole on Main Street"
                className="form-control"
              />
            </div>

            <div className="form-group">
              <label htmlFor="description">
                <span className="required">*</span> Description
              </label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                required
                placeholder="Provide detailed information about the work to be done, scope, and any special considerations..."
                rows="5"
                className="form-control"
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="workType">
                  <span className="required">*</span> Work Type
                </label>
                <select 
                  id="workType"
                  name="workType" 
                  value={formData.workType} 
                  onChange={handleChange} 
                  required
                  className="form-control"
                >
                  <option value="Pothole Repair">Pothole Repair</option>
                  <option value="Drainage Cleaning">Drainage Cleaning</option>
                  <option value="Street Light Installation">Street Light Installation</option>
                  <option value="Road Resurfacing">Road Resurfacing</option>
                  <option value="Maintenance">Maintenance</option>
                  <option value="Inspection">Inspection</option>
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="priority">Priority Level</label>
                <select 
                  id="priority"
                  name="priority" 
                  value={formData.priority} 
                  onChange={handleChange}
                  className="form-control"
                >
                  <option value="Low">Low</option>
                  <option value="Medium">Medium</option>
                  <option value="High">High</option>
                  <option value="Critical">Critical</option>
                </select>
              </div>
            </div>
          </div>

          {/* LOCATION SECTION */}
          <div className="form-section">
            <div className="section-header">
              <h3>Location</h3>
              <p className="section-subtitle">Where the work will be performed</p>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="location-address">
                  <span className="required">*</span> Street Address
                </label>
                <input
                  id="location-address"
                  type="text"
                  name="location.address"
                  value={formData.location.address}
                  onChange={handleChange}
                  required
                  placeholder="E.g., Yagnik Road, Rajkot"
                  className="form-control"
                />
              </div>

              <div className="form-group">
                <label htmlFor="location-area">Area / Zone</label>
                <input
                  id="location-area"
                  type="text"
                  name="location.area"
                  value={formData.location.area}
                  onChange={handleChange}
                  placeholder="E.g., Downtown, Zone 1"
                  className="form-control"
                />
              </div>
            </div>
          </div>

          {/* STATUS & PROGRESS SECTION */}
          <div className="form-section">
            <div className="section-header">
              <h3>Status & Progress</h3>
              <p className="section-subtitle">Track the work order status and completion</p>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="status">Current Status</label>
                <select 
                  id="status"
                  name="status" 
                  value={formData.status} 
                  onChange={handleChange}
                  className="form-control"
                >
                  <option value="pending">Pending</option>
                  <option value="in_progress">In Progress</option>
                  <option value="on_hold">On Hold</option>
                  <option value="completed">Completed</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="progress">
                  Progress: <span className="progress-value">{formData.progress}%</span>
                </label>
                <div className="progress-input-group">
                  <input
                    id="progress"
                    type="range"
                    name="progress"
                    value={formData.progress}
                    onChange={handleChange}
                    min="0"
                    max="100"
                    className="progress-slider"
                  />
                  <input
                    type="number"
                    name="progress"
                    value={formData.progress}
                    onChange={handleChange}
                    min="0"
                    max="100"
                    className="form-control progress-number"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* TIMELINE SECTION */}
          <div className="form-section">
            <div className="section-header">
              <h3>Timeline</h3>
              <p className="section-subtitle">Set dates and duration for the work</p>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="startDate">Start Date</label>
                <input
                  id="startDate"
                  type="date"
                  name="startDate"
                  value={formData.startDate ? formData.startDate.split('T')[0] : ''}
                  onChange={handleChange}
                  className="form-control"
                />
              </div>

              <div className="form-group">
                <label htmlFor="endDate">End Date</label>
                <input
                  id="endDate"
                  type="date"
                  name="endDate"
                  value={formData.endDate ? formData.endDate.split('T')[0] : ''}
                  onChange={handleChange}
                  className="form-control"
                />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="estimatedDuration">Estimated Duration (days)</label>
                <input
                  id="estimatedDuration"
                  type="number"
                  name="estimatedDuration"
                  value={formData.estimatedDuration}
                  onChange={handleChange}
                  min="0"
                  placeholder="e.g., 5, 10, 30"
                  className="form-control"
                />
              </div>

              <div className="form-group">
                <label htmlFor="budget">Budget (₹)</label>
                <input
                  id="budget"
                  type="number"
                  name="budget"
                  value={formData.budget}
                  onChange={handleChange}
                  step="1"
                  min="0"
                  placeholder="e.g., 50000, 100000"
                  className="form-control"
                />
              </div>
            </div>
          </div>

          {/* ADDITIONAL INFORMATION SECTION */}
          <div className="form-section">
            <div className="section-header">
              <h3>Additional Information</h3>
              <p className="section-subtitle">Any extra details or special instructions</p>
            </div>

            <div className="form-group">
              <label htmlFor="notes">Notes & Comments</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                placeholder="Add any special instructions, contractor details, or other important information..."
                rows="4"
                className="form-control"
              />
            </div>
          </div>

          {/* ACTION BUTTONS */}
          <div className="form-actions">
            <button 
              type="submit" 
              className="button button--primary button--lg"
              disabled={loading}
            >
              {loading ? (
                <>
                  <span className="spinner"></span>
                  {id ? 'Updating...' : 'Creating...'}
                </>
              ) : (
                id ? '✓ Update Work Order' : '+ Create Work Order'
              )}
            </button>
            <button 
              type="button" 
              className="button button--secondary button--lg" 
              onClick={() => navigate('/work-orders')}
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

export default WorkOrderForm
