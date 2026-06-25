import { useState, useEffect } from 'react'
import { Heart, MessageCircle, Trash2, ChevronLeft, Edit, Save, X, Calendar, MapPin, ShieldAlert, Award } from 'lucide-react'
import { useNavigate, useParams, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { StatusBadge } from '../components/Widgets'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

// Leaflet red marker icon configuration to match app theme
const complaintIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
})

const STATUS_OPTIONS = [
  'submitted', 'under_review', 'pending', 'escalated', 
  'team_assigned', 'repair_started', 'repair_completed', 
  'verified_closed', 'reopened'
]

function ComplaintDetails() {
  const navigate = useNavigate()
  const { id: complaintId } = useParams()
  const { user } = useAuth()
  const [complaint, setComplaint] = useState(null)
  const [comments, setComments] = useState([])
  const [interactions, setInteractions] = useState({ likesCount: 0, commentsCount: 0 })
  const [newComment, setNewComment] = useState('')
  const [hasLiked, setHasLiked] = useState(false)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState(null)
  const [bids, setBids] = useState([])

  // Edit states for Super Admin Quick Actions
  const [isEditing, setIsEditing] = useState(false)
  const [editForm, setEditForm] = useState({ status: '', assignedTeamId: '', priority: '' })
  const [teams, setTeams] = useState([])

  const getHeaders = () => {
    const headers = { 'Content-Type': 'application/json' }
    if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
    return headers
  }

  const fetchComplaintData = async () => {
    try {
      setLoading(true)
      setError(null)
      const headers = getHeaders()

      const resComplaint = await fetch(`/api/complaints/${complaintId}`, { headers })
      if (!resComplaint.ok) throw new Error('Complaint details could not be loaded from API')
      const complaintData = await resComplaint.json()
      setComplaint(complaintData)

      // Fetch comments
      const resComments = await fetch(`/api/complaints/${complaintId}/comments`, { headers })
      if (resComments.ok) {
        const commentsData = await resComments.json()
        setComments(commentsData || [])
      }

      // Fetch interactions
      const resInteractions = await fetch(`/api/complaints/${complaintId}/interactions`, { headers })
      if (resInteractions.ok) {
        const interactionsData = await resInteractions.json()
        setInteractions(interactionsData || { likesCount: 0, commentsCount: 0 })
      }

      // Fetch contractor bids
      try {
        const resBids = await fetch(`/api/bids/complaint/${complaintId}`, { headers })
        if (resBids.ok) {
          const bidsData = await resBids.json()
          setBids(bidsData || [])
        }
      } catch (err) {
        console.error('Error fetching bids:', err)
      }
    } catch (err) {
      console.error('Error fetching complaint:', err)
      setError('Failed to load complaint details. Please check connection and try again.')
    } finally {
      setLoading(false)
    }
  }

  const fetchTeams = async () => {
    try {
      const res = await fetch('/api/admin/users', { headers: getHeaders() })
      const data = await res.json()
      if (res.ok) {
        setTeams(data.filter(u => u.role === 'team_member'))
      }
    } catch (e) {
      console.error('Error fetching operational teams:', e)
    }
  }

  useEffect(() => {
    if (complaintId) {
      fetchComplaintData()
      fetchTeams()
    }
  }, [complaintId, user])

  const handleLike = async () => {
    try {
      setHasLiked(!hasLiked)
      const newCount = hasLiked ? interactions.likesCount - 1 : interactions.likesCount + 1
      setInteractions(prev => ({ ...prev, likesCount: newCount }))
      
      await fetch(`/api/complaints/${complaintId}/like`, {
        method: 'POST',
        headers: getHeaders()
      })
    } catch (error) {
      setHasLiked(!hasLiked)
      console.error('Error liking complaint:', error)
    }
  }

  const handleAddComment = async (e) => {
    e.preventDefault()
    if (!newComment.trim()) return

    try {
      setSubmitting(true)
      const res = await fetch(`/api/complaints/${complaintId}/comments`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify({ content: newComment })
      })

      if (res.ok) {
        const response = await res.json()
        const newCommentObj = {
          id: response.id || Date.now(),
          content: newComment,
          user: { name: user?.name || 'Super Admin', role: user?.role || 'admin' },
          createdAt: new Date().toISOString()
        }
        setComments([...comments, newCommentObj])
        setNewComment('')
        setInteractions(prev => ({ ...prev, commentsCount: prev.commentsCount + 1 }))
      }
    } catch (error) {
      console.error('Error adding comment:', error)
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteComment = async (commentId) => {
    if (!window.confirm('Are you sure you want to delete this comment?')) return
    try {
      const res = await fetch(`/api/comments/${commentId}`, {
        method: 'DELETE',
        headers: getHeaders()
      })
      if (res.ok) {
        setComments(comments.filter(c => c.id !== commentId))
        setInteractions(prev => ({ ...prev, commentsCount: prev.commentsCount - 1 }))
      }
    } catch (error) {
      console.error('Error deleting comment:', error)
    }
  }

  const handleApproveBid = async (bidId) => {
    if (!window.confirm('Approve this contractor proposal? This will reject all other bids and initialize a work order.')) return
    try {
      const res = await fetch(`/api/bids/${bidId}/approve`, {
        method: 'PUT',
        headers: getHeaders()
      })
      if (res.ok) {
        fetchComplaintData()
      } else {
        const data = await res.json()
        alert(data.error || 'Failed to approve bid')
      }
    } catch (err) {
      console.error('Error approving bid:', err)
      alert('Failed to approve bid')
    }
  }

  const handleRejectBid = async (bidId) => {
    if (!window.confirm('Reject this contractor proposal?')) return
    try {
      const res = await fetch(`/api/bids/${bidId}/reject`, {
        method: 'PUT',
        headers: getHeaders()
      })
      if (res.ok) {
        fetchComplaintData()
      } else {
        const data = await res.json()
        alert(data.error || 'Failed to reject bid')
      }
    } catch (err) {
      console.error('Error rejecting bid:', err)
      alert('Failed to reject bid')
    }
  }

  const handleEditStart = () => {
    setIsEditing(true)
    setEditForm({
      status: complaint?.status || 'submitted',
      assignedTeamId: complaint?.assignedTeamId || '',
      priority: complaint?.priority || 'Medium'
    })
  }

  const handleEditSave = async () => {
    try {
      const headers = getHeaders()
      // Update status
      await fetch(`/api/complaints/${complaintId}/status`, {
        method: 'PUT',
        headers,
        body: JSON.stringify({ status: editForm.status })
      })
      // Assign team if changed
      if (editForm.assignedTeamId) {
        await fetch(`/api/admin/complaints/${complaintId}/assign`, {
          method: 'PUT',
          headers,
          body: JSON.stringify({ teamId: editForm.assignedTeamId })
        })
      }
      setIsEditing(false)
      fetchComplaintData()
    } catch (error) {
      console.error('Update error:', error)
    }
  }

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
        <p style={{ fontSize: '16px', fontWeight: '600', color: '#666' }}>Loading complaint details from e-governance database...</p>
      </div>
    )
  }

  if (error || !complaint) {
    return (
      <div style={{ padding: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '20px' }}>
          <button className="button button--secondary" onClick={() => navigate('/complaints')} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <ChevronLeft size={16} /> Back to Directory
          </button>
        </div>
        <div className="panel" style={{ border: '1px solid #FFCDD2', background: '#FFEBEE', padding: '24px', borderRadius: '8px' }}>
          <p style={{ color: '#C62828', fontWeight: 'bold', margin: 0 }}>{error || 'Complaint not found.'}</p>
        </div>
      </div>
    )
  }

  // Leaflet map setup coordinates parsing
  const getMapCoords = () => {
    if (complaint.coordinates && typeof complaint.coordinates.lat === 'number' && typeof complaint.coordinates.lng === 'number') {
      return [complaint.coordinates.lat, complaint.coordinates.lng]
    }
    if (complaint.location && typeof complaint.location === 'object') {
      if (typeof complaint.location.lat === 'number' && typeof complaint.location.lng === 'number') {
        return [complaint.location.lat, complaint.location.lng]
      }
    }
    if (typeof complaint.latitude === 'number' && typeof complaint.longitude === 'number') {
      return [complaint.latitude, complaint.longitude]
    }
    return [22.3072, 70.7654] // Fallback
  }

  const mapCoords = getMapCoords()

  // Format complaint location safely
  const formattedLocation = typeof complaint.location === 'object'
    ? (complaint.location.address || complaint.location.area || `${complaint.location.lat || ''}, ${complaint.location.lng || ''}`)
    : (complaint.location || 'Municipal Area')

  // Parse media array safely
  let mediaArray = []
  if (complaint.media) {
    if (Array.isArray(complaint.media)) {
      mediaArray = complaint.media
    } else if (typeof complaint.media === 'string') {
      try {
        const parsed = JSON.parse(complaint.media)
        if (Array.isArray(parsed)) {
          mediaArray = parsed
        } else if (parsed && typeof parsed === 'object') {
          mediaArray = [parsed]
        }
      } catch (e) {
        mediaArray = [{ url: complaint.media, type: 'image' }]
      }
    } else if (typeof complaint.media === 'object') {
      mediaArray = [complaint.media]
    }
  }

  return (
    <div style={{ position: 'relative' }}>
      {/* Tricolor Accent Stripe */}
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

      {/* Action Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <button className="button button--secondary" onClick={() => navigate('/complaints')} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <ChevronLeft size={16} /> Back to Directory
        </button>

        {isEditing ? (
          <div style={{ display: 'flex', gap: '8px' }}>
            <button className="button button--primary" onClick={handleEditSave} style={{ display: 'flex', alignItems: 'center', gap: '6px', background: '#2E7D32' }}>
              <Save size={16} /> Save Changes
            </button>
            <button className="button button--secondary" onClick={() => setIsEditing(false)} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <X size={16} /> Cancel
            </button>
          </div>
        ) : (
          <button className="button button--primary" onClick={handleEditStart} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Edit size={16} /> Quick Dispatch / Edit
          </button>
        )}
      </div>

      {/* Main Details Panel */}
      <div className="grid grid--2" style={{ gap: '20px', marginBottom: '20px' }}>
        
        {/* Left Side: General Info Cards */}
        <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
          <div className="panel__header" style={{ background: '#F8F9FA', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <p style={{ fontSize: '11px', color: '#B35400', fontWeight: '700', letterSpacing: '0.5px', margin: 0 }}>
                #{complaint.id?.substring(0, 18)}...
              </p>
              <h2 style={{ fontSize: '18px', fontWeight: '800', margin: '4px 0 0 0', color: '#0A2F7E' }}>
                Complaint Information Details
              </h2>
            </div>
            {isEditing ? (
              <select 
                value={editForm.status} 
                onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                style={{ padding: '6px 12px', borderRadius: '6px', border: '1px solid #B0BEC5', fontSize: '13px', fontWeight: '600' }}
              >
                {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s.toUpperCase().replace('_', ' ')}</option>)}
              </select>
            ) : (
              <StatusBadge status={complaint.status} />
            )}
          </div>

          <div className="panel__body" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Complaint Title</span>
              <p style={{ fontSize: '15px', fontWeight: '700', color: '#37474F', margin: '4px 0 0 0' }}>{complaint.title}</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Category Node</span>
                <p style={{ fontSize: '14px', fontWeight: '600', color: '#37474F', margin: '4px 0 0 0' }}>{complaint.category || 'Pothole'}</p>
              </div>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Priority Level</span>
                {isEditing ? (
                  <select
                    value={editForm.priority}
                    onChange={(e) => setEditForm({ ...editForm, priority: e.target.value })}
                    style={{ width: '100%', padding: '4px 8px', borderRadius: '4px', border: '1px solid #CFD8DC', fontSize: '12px', marginTop: '4px' }}
                  >
                    <option value="Low">Low</option>
                    <option value="Medium">Medium</option>
                    <option value="High">High</option>
                    <option value="Critical">Critical</option>
                  </select>
                ) : (
                  <p style={{ fontSize: '14px', fontWeight: '700', color: complaint.priority === 'Critical' || complaint.priority === 'High' ? '#C62828' : '#37474F', margin: '4px 0 0 0' }}>
                    {complaint.priority || 'Medium'}
                  </p>
                )}
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Reported By (Citizen)</span>
                <p style={{ fontSize: '14px', fontWeight: '600', color: '#37474F', margin: '4px 0 0 0' }}>{complaint.citizen?.name || complaint.User?.name || complaint.citizenName || 'Verified Resident'}</p>
              </div>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Assigned Operation Team</span>
                {isEditing ? (
                  <select
                    value={editForm.assignedTeamId}
                    onChange={(e) => setEditForm({ ...editForm, assignedTeamId: e.target.value })}
                    style={{ width: '100%', padding: '4px 8px', borderRadius: '4px', border: '1px solid #CFD8DC', fontSize: '12px', marginTop: '4px' }}
                  >
                    <option value="">Unassigned</option>
                    {teams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                  </select>
                ) : (
                  <p style={{ fontSize: '14px', fontWeight: '600', color: '#37474F', margin: '4px 0 0 0' }}>{complaint.team?.name || 'Unassigned / Pending'}</p>
                )}
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Incident Log Date</span>
                <p style={{ fontSize: '13px', fontWeight: '600', color: '#37474F', margin: '4px 0 0 0', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Calendar size={14} /> {complaint.createdAt ? new Date(complaint.createdAt).toLocaleDateString() : 'N/A'}
                </p>
              </div>
              <div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Zonal Address Details</span>
                <p style={{ fontSize: '13px', fontWeight: '600', color: '#37474F', margin: '4px 0 0 0', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <MapPin size={14} /> {formattedLocation}
                </p>
              </div>
            </div>

            <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '15px' }}>
              <span style={{ fontSize: '12px', fontWeight: '600', color: '#78909C' }}>Citizen Description Statement</span>
              <p style={{ fontSize: '13.5px', color: '#546E7A', lineHeight: '1.5', margin: '6px 0 0 0', background: '#F8F9FA', padding: '12px', borderRadius: '6px', borderLeft: '3px solid #0A2F7E' }}>
                {complaint.description || 'No descriptive statement provided.'}
              </p>
            </div>
          </div>
        </div>

        {/* Right Side: Map Coordinates Widget */}
        <div className="panel" style={{ border: '1px solid #CFD8DC', display: 'flex', flexDirection: 'column' }}>
          <div className="panel__header" style={{ background: '#F8F9FA' }}>
            <h2 style={{ fontSize: '16px', fontWeight: '700', color: '#37474F' }}>Incident GIS GPS Coordinates</h2>
          </div>
          <div className="panel__body" style={{ flex: 1, padding: 0, overflow: 'hidden', minHeight: '300px', position: 'relative' }}>
            <MapContainer center={mapCoords} zoom={15} style={{ height: '100%', minHeight: '320px', width: '100%' }}>
              <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="&copy; OpenStreetMap contributors" />
              <Marker position={mapCoords} icon={complaintIcon}>
                <Popup>
                  <strong>Complaint #{complaint.id?.substring(0, 6)}</strong><br />
                  {complaint.title}
                </Popup>
              </Marker>
            </MapContainer>
          </div>
        </div>
      </div>

      {/* Media Attachments Gallery */}
      <div className="panel" style={{ border: '1px solid #CFD8DC', marginBottom: '20px' }}>
        <div className="panel__header" style={{ background: '#F8F9FA' }}>
          <h2 style={{ fontSize: '16px', fontWeight: '700', color: '#37474F' }}>Complaint Photo Attachments</h2>
        </div>
        <div className="panel__body" style={{ padding: '20px' }}>
          {mediaArray.length > 0 ? (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '20px' }}>
              {mediaArray.map((media, index) => {
                if (!media || (!media.url && typeof media !== 'string')) return null
                const rawUrl = typeof media === 'string' ? media : media.url
                const imageUrl = rawUrl.startsWith('http') 
                  ? rawUrl 
                  : (rawUrl.startsWith('uploads') || rawUrl.startsWith('/uploads')
                      ? `http://jenili.in${rawUrl.startsWith('/') ? '' : '/'}${rawUrl}`
                      : rawUrl)
                return (
                  <div 
                    key={index}
                    style={{
                      border: '1px solid #CFD8DC',
                      borderRadius: '8px',
                      overflow: 'hidden',
                      boxShadow: '0 2px 6px rgba(0,0,0,0.04)',
                      transition: 'transform 0.2s ease',
                      cursor: 'pointer'
                    }}
                    onMouseEnter={(e) => e.currentTarget.style.transform = 'scale(1.03)'}
                    onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}
                  >
                    <a href={imageUrl} target="_blank" rel="noopener noreferrer">
                      <img 
                        src={imageUrl} 
                        alt={`Attachment ${index + 1}`} 
                        style={{ width: '100%', height: '140px', objectFit: 'cover', display: 'block' }}
                        onError={(e) => { e.target.src = 'https://placehold.co/600x400/e0e0e0/555555?text=No+Photo+Uploaded' }}
                      />
                    </a>
                    <div style={{ padding: '8px', fontSize: '11px', fontWeight: '600', color: '#666', background: 'white', borderTop: '1px solid #ECEFF1' }}>
                      Attachment {index + 1}
                    </div>
                  </div>
                )
              })}
            </div>
          ) : (
            <p style={{ margin: 0, fontSize: '13px', color: '#78909C', fontStyle: 'italic' }}>
              No visual photos uploaded for this complaint log.
            </p>
          )}
        </div>
      </div>

      {/* Contractor Bids Section */}
      <div className="panel" style={{ border: '1px solid #CFD8DC', marginBottom: '20px' }}>
        <div className="panel__header" style={{ background: '#F8F9FA', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ fontSize: '16px', fontWeight: '700', color: '#37474F', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Award size={18} style={{ color: '#0A2F7E' }} /> Empanelled Contractor Repair Offers
          </h2>
          <span className="badge badge--info" style={{ backgroundColor: 'rgba(10, 47, 126, 0.1)', color: '#0A2F7E', padding: '4px 10px', borderRadius: '12px', fontSize: '11px', fontWeight: 'bold' }}>
            {bids.length} Submissions
          </span>
        </div>
        <div className="panel__body" style={{ padding: '20px' }}>
          {bids.length === 0 ? (
            <p style={{ margin: 0, fontSize: '13px', color: '#78909C', fontStyle: 'italic' }}>No contractor proposal offers have been logged for this complaint yet.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {bids.map((bid) => (
                <div key={bid.id} style={{ border: '1px solid #ECEFF1', borderRadius: '8px', padding: '16px', background: '#FAFAFA', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <div>
                      <h4 style={{ margin: '0 0 4px 0', fontSize: '13.5px', color: '#37474F', fontWeight: 'bold' }}>
                        {bid.contractor?.name || 'Empanelled Contractor Partner'}
                      </h4>
                      <span style={{ fontSize: '11px', color: '#78909C' }}>{bid.contractor?.email}</span>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <span style={{ fontSize: '16px', fontWeight: '700', color: '#2E7D32' }}>₹{parseFloat(bid.cost).toLocaleString('en-IN')}</span>
                      <p style={{ margin: '2px 0 0 0', fontSize: '11px', color: '#78909C' }}>SLA Target: {bid.duration}</p>
                    </div>
                  </div>
                  <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
                    <p style={{ margin: 0, fontSize: '12.5px', color: '#546E7A', flex: 1 }}>
                      <strong>Proposal:</strong> {bid.message}
                    </p>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      {bid.status && bid.status !== 'pending' ? (
                        <span style={{
                          padding: '4px 10px',
                          borderRadius: '6px',
                          fontSize: '11px',
                          fontWeight: 'bold',
                          textTransform: 'uppercase',
                          backgroundColor: bid.status === 'approved' ? '#E8F5E9' : '#FFEBEE',
                          color: bid.status === 'approved' ? '#2E7D32' : '#C62828'
                        }}>
                          {bid.status}
                        </span>
                      ) : (
                        <>
                          <button
                            onClick={() => handleApproveBid(bid.id)}
                            style={{
                              padding: '5px 12px',
                              borderRadius: '4px',
                              border: 'none',
                              backgroundColor: '#2E7D32',
                              color: 'white',
                              fontSize: '11.5px',
                              fontWeight: '700',
                              cursor: 'pointer'
                            }}
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => handleRejectBid(bid.id)}
                            style={{
                              padding: '5px 12px',
                              borderRadius: '4px',
                              border: '1px solid #C62828',
                              backgroundColor: 'transparent',
                              color: '#C62828',
                              fontSize: '11.5px',
                              fontWeight: '700',
                              cursor: 'pointer'
                            }}
                          >
                            Reject
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Audit Log / Discussion Panel */}
      <div className="panel" style={{ border: '1px solid #CFD8DC', marginBottom: '20px' }}>
        <div className="panel__header" style={{ background: '#F8F9FA' }}>
          <h2 style={{ fontSize: '16px', fontWeight: '700', color: '#37474F', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <MessageCircle size={18} style={{ color: '#0A2F7E' }} /> Administrative Discussions / Notes
          </h2>
        </div>
        <div className="panel__body" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px', marginBottom: '20px' }}>
            {comments.length === 0 ? (
              <p style={{ margin: 0, fontSize: '13px', color: '#78909C', fontStyle: 'italic' }}>No discussion entries logged. Add an administrative note below.</p>
            ) : (
              comments.map((comment) => (
                <div key={comment.id} style={{ borderBottom: '1px solid #ECEFF1', paddingBottom: '12px', display: 'flex', justifyContent: 'space-between' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                      <strong style={{ fontSize: '13px', color: '#37474F' }}>{comment.user?.name || 'Staff User'}</strong>
                      <span style={{ fontSize: '10px', background: '#ECEFF1', padding: '2px 6px', borderRadius: '4px', color: '#546E7A' }}>
                        {comment.user?.role || 'operator'}
                      </span>
                      <span style={{ fontSize: '11px', color: '#90A4AE' }}>
                        {comment.createdAt ? new Date(comment.createdAt).toLocaleDateString() : 'N/A'}
                      </span>
                    </div>
                    <p style={{ margin: 0, fontSize: '13px', color: '#455A64', lineHeight: '1.4' }}>{comment.content}</p>
                  </div>
                  <button 
                    onClick={() => handleDeleteComment(comment.id)} 
                    style={{ background: 'none', border: 'none', color: '#C62828', cursor: 'pointer', padding: '4px' }}
                    title="Delete Comment"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              ))
            )}
          </div>

          <form onSubmit={handleAddComment} style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <textarea
              placeholder="Post a secure administrative response, status check, or internal note..."
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              rows={3}
              style={{ width: '100%', padding: '10px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }}
              required
            />
            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
              <button className="button button--primary" type="submit" disabled={submitting || !newComment.trim()}>
                {submitting ? 'Posting Note...' : 'Add Administrative Note'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}

export default ComplaintDetails
