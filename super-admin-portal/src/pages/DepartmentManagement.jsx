import { useState, useEffect } from 'react'
import { Plus, Edit, Trash2, X, Save, Search, RotateCcw } from 'lucide-react'
import { useAuth } from '../context/AuthContext'

function DepartmentManagement() {
  const { user } = useAuth()
  const [departments, setDepartments] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [editingId, setEditingId] = useState(null)
  const [editForm, setEditForm] = useState({})
  const [showAdd, setShowAdd] = useState(false)
  const [addForm, setAddForm] = useState({ companyName: '', specialization: '', contactPerson: '', phone: '' })

  const getHeaders = () => {
    const headers = { 'Content-Type': 'application/json' }
    if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
    return headers
  }

  const fetchDepartments = async () => {
    try {
      setLoading(true)
      const res = await fetch('/api/admin/contractors', { headers: getHeaders() })
      const data = await res.json()
      if (res.ok) setDepartments(data)
    } catch (error) { console.error('Error fetching contractors:', error) }
    finally { setLoading(false) }
  }

  useEffect(() => { fetchDepartments() }, [user])

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this department/contractor?')) return
    try {
      const res = await fetch(`/api/admin/contractors/${id}`, { method: 'DELETE', headers: getHeaders() })
      if (res.ok) setDepartments(departments.filter(d => d.id !== id))
    } catch (error) { console.error('Delete error:', error) }
  }

  const handleEditStart = (dept) => {
    setEditingId(dept.id)
    setEditForm({
      companyName: dept.companyName || '',
      specialization: dept.specialization || '',
      contactPerson: dept.contactPerson || '',
      phone: dept.phone || '',
      status: dept.status || 'pending'
    })
  }

  const handleEditSave = async (id) => {
    try {
      const res = await fetch(`/api/admin/contractors/${id}`, {
        method: 'PUT', headers: getHeaders(),
        body: JSON.stringify(editForm)
      })
      if (res.ok) {
        setEditingId(null)
        fetchDepartments()
      }
    } catch (error) { console.error('Update error:', error) }
  }

  const handleAdd = async () => {
    if (!addForm.companyName) return alert('Company name is required')
    try {
      const res = await fetch('/api/admin/contractors', {
        method: 'POST', headers: getHeaders(),
        body: JSON.stringify(addForm)
      })
      if (res.ok) {
        setShowAdd(false)
        setAddForm({ companyName: '', specialization: '', contactPerson: '', phone: '' })
        fetchDepartments()
      } else {
        const err = await res.json()
        alert(err.error || 'Failed to create')
      }
    } catch (error) { console.error('Add error:', error) }
  }

  const [specializationFilter, setSpecializationFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')

  const specializations = Array.from(new Set(departments.map(d => d.specialization).filter(Boolean)))

  const filtered = departments.filter(d => {
    const matchesSearch = !search || 
      (d.companyName || '').toLowerCase().includes(search.toLowerCase()) ||
      (d.specialization || '').toLowerCase().includes(search.toLowerCase()) ||
      (d.contactPerson || '').toLowerCase().includes(search.toLowerCase())
      
    if (!matchesSearch) return false

    if (specializationFilter && d.specialization !== specializationFilter) return false
    
    if (statusFilter && (d.status || 'pending').toLowerCase() !== statusFilter.toLowerCase()) return false

    return true
  })

  return (
    <div>
      <div className="page-header">
        <div>
          <p className="page-label">Organization</p>
          <h1>Department Management</h1>
        </div>
      </div>

      {/* Modern Search & Filters Panel */}
      <div className="panel panel--compact panel--toolbar" style={{ minHeight: 'auto', marginBottom: '20px' }}>
        <div className="filters-row">
          <div className="filters-row__search" style={{ flex: '1 1 300px' }}>
            <div className="filters-row__search-icon">
              <Search size={18} />
            </div>
            <input 
              type="text"
              className="input-search"
              placeholder="Search name, specialization, contact..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select filter-select--specialization"
              value={specializationFilter}
              onChange={(e) => setSpecializationFilter(e.target.value)}
            >
              <option value="">All Specializations</option>
              {specializations.map(spec => (
                <option key={spec} value={spec}>{spec}</option>
              ))}
            </select>

            <select
              className="filter-select filter-select--status"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="active">Active</option>
              <option value="rejected">Rejected</option>
            </select>

            {(search || specializationFilter || statusFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setSpecializationFilter('')
                  setStatusFilter('')
                }}
                title="Reset Filters"
                type="button"
                style={{ height: '46px' }}
              >
                <RotateCcw size={16} /> Reset
              </button>
            )}

            <button className="button button--primary" onClick={() => setShowAdd(!showAdd)} style={{ height: '46px', display: 'flex', alignItems: 'center', gap: '6px' }}>
              {showAdd ? <><X size={18} /> Cancel</> : <><Plus size={18} /> Add Department</>}
            </button>
          </div>
        </div>
      </div>

      {/* Add Form */}
      {showAdd && (
        <div className="panel" style={{ marginBottom: '20px' }}>
          <div className="panel__header"><h2>Add New Department / Contractor</h2></div>
          <div className="panel__body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px', marginBottom: '16px' }}>
              <input placeholder="Company Name *" value={addForm.companyName} onChange={(e) => setAddForm({ ...addForm, companyName: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Specialization" value={addForm.specialization} onChange={(e) => setAddForm({ ...addForm, specialization: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Contact Person" value={addForm.contactPerson} onChange={(e) => setAddForm({ ...addForm, contactPerson: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Phone" value={addForm.phone} onChange={(e) => setAddForm({ ...addForm, phone: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <button className="button button--primary" onClick={handleAdd}><Save size={16} /> Create</button>
            </div>
          </div>
        </div>
      )}

      <div className="panel">
        <div className="panel__header"><h2>Departments ({filtered.length})</h2></div>
        <div className="panel__body panel__table-wrap">
          <table className="data-table">
            <thead>
              <tr><th>Name</th><th>Specialization</th><th>Contact Person</th><th>Phone</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="6" style={{ textAlign: 'center' }}>Loading departments...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center' }}>No departments/contractors found.</td></tr>
              ) : filtered.map((dept) => {
                const isActive = dept.status === 'Active' || dept.status === 'active' || dept.status === 'approved'
                return (
                  <tr key={dept.id}>
                    <td>
                      {editingId === dept.id ? (
                        <input value={editForm.companyName} onChange={(e) => setEditForm({ ...editForm, companyName: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '13px', width: '100%' }} />
                      ) : (
                        <strong>{dept.companyName || dept.name}</strong>
                      )}
                    </td>
                    <td>
                      {editingId === dept.id ? (
                        <input value={editForm.specialization} onChange={(e) => setEditForm({ ...editForm, specialization: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '13px', width: '100%' }} />
                      ) : (
                        dept.specialization || 'N/A'
                      )}
                    </td>
                    <td>
                      {editingId === dept.id ? (
                        <input value={editForm.contactPerson} onChange={(e) => setEditForm({ ...editForm, contactPerson: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '13px', width: '100%' }} />
                      ) : (
                        dept.contactPerson || 'N/A'
                      )}
                    </td>
                    <td>
                      {editingId === dept.id ? (
                        <input value={editForm.phone} onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '13px', width: '100%' }} />
                      ) : (
                        dept.phone || 'N/A'
                      )}
                    </td>
                    <td>
                      {editingId === dept.id ? (
                        <select value={editForm.status} onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '12px' }}>
                          <option value="pending">Pending</option>
                          <option value="approved">Approved</option>
                          <option value="active">Active</option>
                          <option value="rejected">Rejected</option>
                        </select>
                      ) : (
                        <span style={{ padding: '4px 8px', background: isActive ? '#E8F5E9' : '#FFF3E0', color: isActive ? '#388E3C' : '#E65100', borderRadius: '4px', fontSize: '12px' }}>
                          {dept.status || 'Pending'}
                        </span>
                      )}
                    </td>
                    <td>
                      {editingId === dept.id ? (
                        <>
                          <button onClick={() => handleEditSave(dept.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px', color: '#388E3C' }} title="Save"><Save size={16} /></button>
                          <button onClick={() => setEditingId(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#D32F2F' }} title="Cancel"><X size={16} /></button>
                        </>
                      ) : (
                        <>
                          <button onClick={() => handleEditStart(dept)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px' }} title="Edit"><Edit size={16} /></button>
                          <button onClick={() => handleDelete(dept.id)} style={{ background: 'none', border: 'none', cursor: 'pointer' }} title="Delete"><Trash2 size={16} /></button>
                        </>
                      )}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default DepartmentManagement
