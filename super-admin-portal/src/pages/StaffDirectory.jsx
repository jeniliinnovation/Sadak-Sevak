import { useState, useEffect } from 'react'
import { Plus, Edit, Trash2, X, Save } from 'lucide-react'
import { useAuth } from '../context/AuthContext'

const ROLE_OPTIONS = ['admin', 'department_head', 'team_member', 'contractor']

function StaffDirectory() {
  const { user } = useAuth()
  const [staff, setStaff] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [editingId, setEditingId] = useState(null)
  const [editForm, setEditForm] = useState({})
  const [showAdd, setShowAdd] = useState(false)
  const [addForm, setAddForm] = useState({ name: '', email: '', phone: '', role: 'team_member', password: '' })

  const getHeaders = () => {
    const headers = { 'Content-Type': 'application/json' }
    if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
    return headers
  }

  const fetchStaff = async () => {
    try {
      setLoading(true)
      const res = await fetch('/api/admin/users', { headers: getHeaders() })
      const data = await res.json()
      if (res.ok) setStaff(data.filter(u => u.role !== 'citizen'))
    } catch (error) { console.error('Error fetching staff:', error) }
    finally { setLoading(false) }
  }

  useEffect(() => { fetchStaff() }, [user])

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this staff member?')) return
    try {
      const res = await fetch(`/api/admin/users/${id}`, { method: 'DELETE', headers: getHeaders() })
      if (res.ok) setStaff(staff.filter(s => s.id !== id))
    } catch (error) { console.error('Delete error:', error) }
  }

  const handleEditStart = (member) => {
    setEditingId(member.id)
    setEditForm({ role: member.role || 'team_member', isVerified: member.isVerified !== false })
  }

  const handleEditSave = async (id) => {
    try {
      const res = await fetch(`/api/admin/users/${id}`, {
        method: 'PUT', headers: getHeaders(),
        body: JSON.stringify({ role: editForm.role, isVerified: editForm.isVerified })
      })
      if (res.ok) {
        setEditingId(null)
        fetchStaff()
      }
    } catch (error) { console.error('Update error:', error) }
  }

  const handleAdd = async () => {
    try {
      const res = await fetch('/api/auth/register', {
        method: 'POST', headers: getHeaders(),
        body: JSON.stringify({ ...addForm })
      })
      if (res.ok) {
        setShowAdd(false)
        setAddForm({ name: '', email: '', phone: '', role: 'team_member', password: '' })
        fetchStaff()
      } else {
        const err = await res.json()
        alert(err.error || 'Failed to create user')
      }
    } catch (error) { console.error('Add error:', error) }
  }

  const filtered = staff.filter(s =>
    !search || (s.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (s.email || '').toLowerCase().includes(search.toLowerCase()) ||
    (s.role || '').toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div>
      <div className="page-header">
        <div>
          <p className="page-label">Organization</p>
          <h1>Staff Directory</h1>
        </div>
      </div>

      <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
        <input type="search" placeholder="Search staff..." value={search} onChange={(e) => setSearch(e.target.value)}
          style={{ flex: 1, padding: '8px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
        <button className="button button--primary" onClick={() => setShowAdd(!showAdd)}>
          {showAdd ? <><X size={18} /> Cancel</> : <><Plus size={18} /> Add Staff</>}
        </button>
      </div>

      {/* Add Staff Form */}
      {showAdd && (
        <div className="panel" style={{ marginBottom: '20px' }}>
          <div className="panel__header"><h2>Add New Staff Member</h2></div>
          <div className="panel__body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px', marginBottom: '16px' }}>
              <input placeholder="Full Name" value={addForm.name} onChange={(e) => setAddForm({ ...addForm, name: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Email" type="email" value={addForm.email} onChange={(e) => setAddForm({ ...addForm, email: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Phone" value={addForm.phone} onChange={(e) => setAddForm({ ...addForm, phone: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <input placeholder="Password" type="password" value={addForm.password} onChange={(e) => setAddForm({ ...addForm, password: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }} />
              <select value={addForm.role} onChange={(e) => setAddForm({ ...addForm, role: e.target.value })}
                style={{ padding: '10px 12px', border: '1px solid #ccc', borderRadius: '6px' }}>
                {ROLE_OPTIONS.map(r => <option key={r} value={r}>{r.replace('_', ' ')}</option>)}
              </select>
              <button className="button button--primary" onClick={handleAdd}><Save size={16} /> Create</button>
            </div>
          </div>
        </div>
      )}

      <div className="panel">
        <div className="panel__header"><h2>Staff Members ({filtered.length})</h2></div>
        <div className="panel__body panel__table-wrap">
          <table className="data-table">
            <thead>
              <tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading staff...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan="5" style={{ textAlign: 'center' }}>No staff found.</td></tr>
              ) : filtered.map((member) => {
                const isActive = member.isVerified !== false
                return (
                  <tr key={member.id}>
                    <td><strong>{member.name || 'Unknown'}</strong></td>
                    <td>{member.email}</td>
                    <td>
                      {editingId === member.id ? (
                        <select value={editForm.role} onChange={(e) => setEditForm({ ...editForm, role: e.target.value })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '12px' }}>
                          {ROLE_OPTIONS.map(r => <option key={r} value={r}>{r.replace('_', ' ')}</option>)}
                        </select>
                      ) : (
                        <span style={{ textTransform: 'capitalize' }}>{(member.role || 'Staff').replace('_', ' ')}</span>
                      )}
                    </td>
                    <td>
                      {editingId === member.id ? (
                        <select value={editForm.isVerified ? 'active' : 'inactive'}
                          onChange={(e) => setEditForm({ ...editForm, isVerified: e.target.value === 'active' })}
                          style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '12px' }}>
                          <option value="active">Active</option>
                          <option value="inactive">Inactive</option>
                        </select>
                      ) : (
                        <span style={{ padding: '4px 8px', background: isActive ? '#E8F5E9' : '#F5F5F5', color: isActive ? '#388E3C' : '#757575', borderRadius: '4px', fontSize: '12px' }}>
                          {isActive ? 'Active' : 'Inactive'}
                        </span>
                      )}
                    </td>
                    <td>
                      {editingId === member.id ? (
                        <>
                          <button onClick={() => handleEditSave(member.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px', color: '#388E3C' }} title="Save"><Save size={16} /></button>
                          <button onClick={() => setEditingId(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#D32F2F' }} title="Cancel"><X size={16} /></button>
                        </>
                      ) : (
                        <>
                          <button onClick={() => handleEditStart(member)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px' }} title="Edit"><Edit size={16} /></button>
                          <button onClick={() => handleDelete(member.id)} style={{ background: 'none', border: 'none', cursor: 'pointer' }} title="Delete"><Trash2 size={16} /></button>
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

export default StaffDirectory
