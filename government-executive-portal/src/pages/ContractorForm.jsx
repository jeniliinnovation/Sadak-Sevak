import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { apiFetch } from '../services/api'
import { ArrowLeft, Building2, User, Phone, Mail, Wrench, Star, MapPin, Save, Loader2 } from 'lucide-react'

function ContractorForm() {
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(false)
  const [form, setForm] = useState({
    companyName: '',
    contactPerson: '',
    phone: '',
    specialization: '',
    rating: '5.0',
  })

  const specializations = [
    'Pothole Repair',
    'Road Resurfacing',
    'Drainage & Water Logging',
    'Bridge Construction',
    'Street Lighting',
    'Traffic Signal',
    'Footpath & Sidewalk',
    'Storm Water Drain',
    'Sewer Line Repair',
    'General Maintenance',
  ]

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm(prev => ({ ...prev, [name]: value }))
    setError(null)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    // Validation
    if (!form.companyName.trim()) {
      setError('Company name is required')
      return
    }
    if (!form.specialization) {
      setError('Please select a specialization')
      return
    }

    setLoading(true)
    setError(null)
    try {
      await apiFetch('/admin/contractors', {
        method: 'POST',
        body: JSON.stringify({
          companyName: form.companyName.trim(),
          contactPerson: form.contactPerson.trim() || null,
          phone: form.phone.trim() || null,
          specialization: form.specialization,
          rating: parseFloat(form.rating) || 5.0,
        }),
      })
      setSuccess(true)
      setTimeout(() => {
        navigate('/contractors')
      }, 1500)
    } catch (err) {
      setError(err.message || 'Failed to add contractor')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="page-shell">
        <div className="contractor-form-success">
          <div className="contractor-form-success__icon">
            <Building2 size={40} />
          </div>
          <h2>Contractor Added Successfully!</h2>
          <p>The new contractor has been submitted for approval. Redirecting...</p>
          <div className="contractor-form-success__bar"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="page-shell">
      <div className="page-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button
            className="contractor-back-btn"
            onClick={() => navigate('/contractors')}
            type="button"
          >
            <ArrowLeft size={18} />
          </button>
          <h1>Add Project Contractor</h1>
        </div>
      </div>

      {error && (
        <div className="contractor-toast contractor-toast--error" style={{ marginBottom: '20px' }}>
          <span>{error}</span>
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <section className="panel panel--full">
          <div className="panel__body">
            <div className="contractor-form-grid">
              {/* Company Name */}
              <div className="contractor-form-field contractor-form-field--full">
                <label className="contractor-form-label">
                  <Building2 size={15} />
                  Company Name <span className="contractor-form-required">*</span>
                </label>
                <input
                  type="text"
                  name="companyName"
                  className="contractor-form-input"
                  value={form.companyName}
                  onChange={handleChange}
                  placeholder="Enter company or firm name"
                  autoFocus
                />
              </div>

              {/* Contact Person */}
              <div className="contractor-form-field">
                <label className="contractor-form-label">
                  <User size={15} />
                  Contact Person
                </label>
                <input
                  type="text"
                  name="contactPerson"
                  className="contractor-form-input"
                  value={form.contactPerson}
                  onChange={handleChange}
                  placeholder="Enter contact person name"
                />
              </div>

              {/* Phone */}
              <div className="contractor-form-field">
                <label className="contractor-form-label">
                  <Phone size={15} />
                  Phone Number
                </label>
                <input
                  type="tel"
                  name="phone"
                  className="contractor-form-input"
                  value={form.phone}
                  onChange={handleChange}
                  placeholder="+91 XXXXX XXXXX"
                />
              </div>

              {/* Specialization */}
              <div className="contractor-form-field">
                <label className="contractor-form-label">
                  <Wrench size={15} />
                  Specialization <span className="contractor-form-required">*</span>
                </label>
                <select
                  name="specialization"
                  className="contractor-form-input contractor-form-select"
                  value={form.specialization}
                  onChange={handleChange}
                >
                  <option value="">Select Specialization</option>
                  {specializations.map(s => (
                    <option key={s} value={s}>{s}</option>
                  ))}
                </select>
              </div>

              {/* Rating */}
              <div className="contractor-form-field">
                <label className="contractor-form-label">
                  <Star size={15} />
                  Initial Rating
                </label>
                <div className="contractor-form-rating-input">
                  <input
                    type="range"
                    name="rating"
                    min="1"
                    max="5"
                    step="0.5"
                    value={form.rating}
                    onChange={handleChange}
                    className="contractor-form-slider"
                  />
                  <div className="contractor-form-rating-display">
                    <span className="contractor-rating__stars">
                      {'★'.repeat(Math.round(parseFloat(form.rating) || 0))}{'☆'.repeat(5 - Math.round(parseFloat(form.rating) || 0))}
                    </span>
                    <span className="contractor-rating__value">{parseFloat(form.rating).toFixed(1)}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="contractor-form-actions">
            <button
              className="button button--secondary"
              type="button"
              onClick={() => navigate('/contractors')}
              disabled={loading}
            >
              Cancel
            </button>
            <button
              className="button button--primary"
              type="submit"
              disabled={loading}
            >
              {loading ? (
                <>
                  <Loader2 size={16} className="spin-icon" />
                  Submitting...
                </>
              ) : (
                <>
                  <Save size={16} />
                  Add Contractor
                </>
              )}
            </button>
          </div>
        </section>
      </form>
    </div>
  )
}

export default ContractorForm
