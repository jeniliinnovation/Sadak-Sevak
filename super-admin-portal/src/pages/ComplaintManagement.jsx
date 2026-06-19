import { useState, useEffect } from 'react'
import { Plus, Search, Edit, Trash2, X, Save } from 'lucide-react'
import { StatusBadge } from '../components/Widgets'
import { useAuth } from '../context/AuthContext'
import { Link } from 'react-router-dom'

const STATUS_OPTIONS = ['submitted','under_review','pending','escalated','team_assigned','repair_started','repair_completed','verified_closed','reopened']

function ComplaintManagement() {
  const { user } = useAuth()
  const [complaints, setComplaints] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [editingId, setEditingId] = useState(null)
  const [editForm, setEditForm] = useState({})
  const [showAdd, setShowAdd] = useState(false)
  const [addForm, setAddForm] = useState({ title: '', description: '', category: 'Pothole', priority: 'Medium' })
  const [teams, setTeams] = useState([])

  const getHeaders = () => {
    const headers = { 'Content-Type': 'application/json' }
    if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
    return headers
  }

  const fetchComplaints = async () => {
    try {
      setLoading(true)
      const res = await fetch('/api/complaints', { headers: getHeaders() })
      const data = await res.json()
      if (res.ok) setComplaints(data)
    } catch (error) {
      console.error('Error fetching complaints:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchTeams = async () => {
    try {
      const res = await fetch('/api/admin/users', { headers: getHeaders() })
      const data = await res.json()
      if (res.ok) setTeams(data.filter(u => u.role === 'team_member'))
    } catch (e) { /* skip */ }
  }

  useEffect(() => {
    fetchComplaints()
    fetchTeams()
  }, [user])

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this complaint?')) return
    try {
      const res = await fetch(`/api/complaints/${id}`, { method: 'DELETE', headers: getHeaders() })
      if (res.ok) setComplaints(complaints.filter(c => c.id !== id))
    } catch (error) { console.error('Delete error:', error) }
  }

  const handleEditStart = (complaint) => {
    setEditingId(complaint.id)
    setEditForm({
      status: complaint.status || 'submitted',
      assignedTeamId: complaint.assignedTeamId || '',
      priority: complaint.priority || 'Medium'
    })
  }

  const handleEditSave = async (id) => {
    try {
      // Update status
      await fetch(`/api/complaints/${id}/status`, {
        method: 'PUT',
        headers: getHeaders(),
        body: JSON.stringify({ status: editForm.status })
      })
      // Assign team if changed
      if (editForm.assignedTeamId) {
        await fetch(`/api/admin/complaints/${id}/assign`, {
          method: 'PUT',
          headers: getHeaders(),
          body: JSON.stringify({ teamId: editForm.assignedTeamId })
        })
      }
      setEditingId(null)
      fetchComplaints()
    } catch (error) { console.error('Update error:', error) }
  }

  const filtered = complaints.filter(c =>
    !search || (c.title || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.category || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.status || '').toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div>
      <div className="page-header">
        <div>
          <p className="page-label">Management</p>
          <h1>Complaint Management</h1>
        </div>
      </div>

      <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
        <div style={{ flex: 1, position: 'relative' }}>
          <Search size={16} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
          <input type="search" placeholder="Search complaints..." value={search} onChange={(e) => setSearch(e.target.value)}
            style={{ width: '100%', padding: '8px 12px 8px 36px', border: '1px solid #ccc', borderRadius: '6px' }} />
        </div>
      </div>

      <div className="panel">
        <div className="panel__header"><h2>All Complaints ({filtered.length})</h2></div>
        <div className="panel__body panel__table-wrap">
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th><th>Title</th><th>Category</th><th>Status</th>
                <th>Priority</th><th>Assigned To</th><th>Date</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="8" style={{ textAlign: 'center' }}>Loading complaints...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan="8" style={{ textAlign: 'center' }}>No complaints found.</td></tr>
              ) : filtered.map((complaint) => (
                <tr key={complaint.id}>
                  <td>
                    <Link to={`/complaints/${complaint.id}`} style={{ color: '#0A2F7E', fontWeight: '700', textDecoration: 'none' }}>
                      #{String(complaint.id).substring(0, 6)}
                    </Link>
                  </td>
                  <td>
                    <Link to={`/complaints/${complaint.id}`} style={{ color: '#37474F', fontWeight: '600', textDecoration: 'none' }} onMouseEnter={(e) => e.target.style.textDecoration = 'underline'} onMouseLeave={(e) => e.target.style.textDecoration = 'none'}>
                      {complaint.title}
                    </Link>
                  </td>
                  <td>{complaint.category || 'General'}</td>
                  <td>
                    {editingId === complaint.id ? (
                      <select value={editForm.status} onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                        style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '12px' }}>
                        {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s.replace('_', ' ')}</option>)}
                      </select>
                    ) : (
                      <StatusBadge status={complaint.status} />
                    )}
                  </td>
                  <td>
                    <span style={{ fontSize: '12px', fontWeight: '500' }}>{complaint.priority || 'Medium'}</span>
                  </td>
                  <td>
                    {editingId === complaint.id ? (
                      <select value={editForm.assignedTeamId} onChange={(e) => setEditForm({ ...editForm, assignedTeamId: e.target.value })}
                        style={{ padding: '4px 6px', borderRadius: '4px', border: '1px solid #ccc', fontSize: '12px' }}>
                        <option value="">Unassigned</option>
                        {teams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                      </select>
                    ) : (
                      complaint.team?.name || 'Unassigned'
                    )}
                  </td>
                  <td>{new Date(complaint.createdAt).toLocaleDateString()}</td>
                  <td>
                    {editingId === complaint.id ? (
                      <>
                        <button onClick={() => handleEditSave(complaint.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px', color: '#388E3C' }} title="Save">
                          <Save size={16} />
                        </button>
                        <button onClick={() => setEditingId(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#D32F2F' }} title="Cancel">
                          <X size={16} />
                        </button>
                      </>
                    ) : (
                      <>
                        <button onClick={() => handleEditStart(complaint)} style={{ background: 'none', border: 'none', cursor: 'pointer', marginRight: '8px' }} title="Edit">
                          <Edit size={16} />
                        </button>
                        <button onClick={() => handleDelete(complaint.id)} style={{ background: 'none', border: 'none', cursor: 'pointer' }} title="Delete">
                          <Trash2 size={16} />
                        </button>
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default ComplaintManagement
