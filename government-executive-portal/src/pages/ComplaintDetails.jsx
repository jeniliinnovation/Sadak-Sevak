import { useState, useEffect } from 'react'
import { Heart, MessageCircle, Trash2, ChevronLeft } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { apiFetch } from '../services/api'
import StatusBadge from '../components/Widgets/StatusBadge'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'

// Fix Leaflet marker icon issue in React
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
})

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

  useEffect(() => {
    if (complaintId) {
      fetchComplaintData()
    }
  }, [complaintId])

  const fetchComplaintData = async () => {
    try {
      setLoading(true)
      setError(null)
      const complaintData = await apiFetch(`/complaints/${complaintId}`)
      setComplaint(complaintData)

      const commentsData = await apiFetch(`/complaints/${complaintId}/comments`)
      setComments(commentsData || [])

      const interactionsData = await apiFetch(`/complaints/${complaintId}/interactions`)
      setInteractions(interactionsData || { likesCount: 0, commentsCount: 0 })

      try {
        const bidsData = await apiFetch(`/bids/complaint/${complaintId}`)
        setBids(bidsData || [])
      } catch (err) {
        console.error('Error fetching bids:', err)
      }
    } catch (error) {
      console.error('Error fetching complaint:', error)
      setError('Failed to load complaint details. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleLike = async () => {
    try {
      setHasLiked(!hasLiked)
      const newCount = hasLiked ? interactions.likesCount - 1 : interactions.likesCount + 1
      setInteractions((prev) => ({ ...prev, likesCount: newCount }))
      await apiFetch(`/complaints/${complaintId}/like`, { method: 'POST' })
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
      const response = await apiFetch(`/complaints/${complaintId}/comments`, {
        method: 'POST',
        body: JSON.stringify({ content: newComment }),
      })

      const newCommentObj = {
        id: response.id || Date.now(),
        content: newComment,
        user: { name: user?.name || 'You', role: user?.role || 'User' },
        createdAt: new Date().toISOString().split('T')[0],
      }
      setComments([...comments, newCommentObj])
      setNewComment('')
      setInteractions((prev) => ({ ...prev, commentsCount: prev.commentsCount + 1 }))
    } catch (error) {
      console.error('Error adding comment:', error)
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteComment = async (commentId) => {
    try {
      await apiFetch(`/comments/${commentId}`, { method: 'DELETE' })
      setComments(comments.filter((c) => c.id !== commentId))
      setInteractions((prev) => ({ ...prev, commentsCount: prev.commentsCount - 1 }))
    } catch (error) {
      console.error('Error deleting comment:', error)
    }
  }

  const handleApproveBid = async (bidId) => {
    if (!window.confirm('Approve this contractor proposal? This will reject all other bids and initialize a work order.')) return
    try {
      await apiFetch(`/bids/${bidId}/approve`, { method: 'PUT' })
      fetchComplaintData()
    } catch (err) {
      console.error('Error approving bid:', err)
      alert(err.message || 'Failed to approve bid')
    }
  }

  const handleRejectBid = async (bidId) => {
    if (!window.confirm('Reject this contractor proposal?')) return
    try {
      await apiFetch(`/bids/${bidId}/reject`, { method: 'PUT' })
      fetchComplaintData()
    } catch (err) {
      console.error('Error rejecting bid:', err)
      alert(err.message || 'Failed to reject bid')
    }
  }

  if (loading) {
    return <div className="page-shell"><div className="page-header"><h1>Loading...</h1></div></div>
  }

  if (error) {
    return (
      <div className="page-shell">
        <div className="page-header">
          <button className="button button--secondary" type="button" onClick={() => navigate('/complaints')}>
            <ChevronLeft size={18} /> Back
          </button>
          <h1>Complaint Details</h1>
        </div>
        <section className="panel panel--full">
          <div className="panel__body">
            <p className="text-danger">{error}</p>
          </div>
        </section>
      </div>
    )
  }

  const getMapCoords = () => {
    if (!complaint) return [22.3072, 70.7654]
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
    return [22.3072, 70.7654]
  }

  const mapCoords = getMapCoords()

  // Parse and extract media attachments safely
  let mediaArray = []
  if (complaint && complaint.media) {
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
    <div className="page-shell">
      <div className="page-header">
        <button className="button button--secondary" type="button" onClick={() => navigate('/complaints')}>
          <ChevronLeft size={18} /> Back
        </button>
        <h1>Complaint Details</h1>
      </div>

      {complaint && (
        <>
          <section className="panel panel--full">
            <div className="panel__header">
              <div>
                <h2>{complaint.id}</h2>
                <p className="text-muted">{complaint.title}</p>
              </div>
              <StatusBadge status={complaint.status} />
            </div>

            <div className="panel__body complaint-detail-grid">
              <div>
                <p><strong>Category</strong><br />{complaint.category || 'N/A'}</p>
                <p><strong>Location</strong><br />{typeof complaint.location === 'object' ? (complaint.location.address || complaint.location.area || `${complaint.location.lat || ''}${complaint.location.lat && complaint.location.lng ? ', ' : ''}${complaint.location.lng || ''}`) : complaint.location || 'N/A'}</p>
                <p><strong>Reported by</strong><br />{complaint.User?.name || complaint.citizenName || 'N/A'}</p>
              </div>
              <div>
                <p><strong>Status</strong><br />{complaint.status || 'N/A'}</p>
                <p><strong>Date</strong><br />{complaint.createdAt?.split('T')[0] || complaint.date || 'N/A'}</p>
              </div>
            </div>

            <div className="panel__body">
              <p><strong>Description</strong></p>
              <p>{complaint.description}</p>
            </div>

            <div className="panel__body">
              <p><strong>Incident Location Map</strong></p>
              <div className="map-container" style={{ minHeight: '320px', borderRadius: '14px', overflow: 'hidden', border: '1px solid var(--border-muted)' }}>
                <MapContainer center={mapCoords} zoom={15} style={{ height: '320px', width: '100%' }}>
                  <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="&copy; OpenStreetMap contributors" />
                  <Marker position={mapCoords}>
                    <Popup>
                      <strong>{complaint.id}</strong><br />{complaint.title || 'Complaint Location'}
                    </Popup>
                  </Marker>
                </MapContainer>
              </div>
            </div>

            <div className="panel__body">
              <p style={{ fontWeight: '600', marginBottom: '12px', fontSize: '1.05rem', color: 'var(--text-main, #333)' }}>
                Attached Complaint Media
              </p>
              {mediaArray.length > 0 ? (
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
                  gap: '20px',
                  marginTop: '10px'
                }}>
                  {mediaArray.map((item, index) => {
                    if (!item || (!item.url && typeof item !== 'string')) return null
                    const rawUrl = typeof item === 'string' ? item : item.url
                    // Check if the URL is absolute or local relative path
                    const imageUrl = rawUrl.startsWith('http') 
                      ? rawUrl 
                      : (rawUrl.startsWith('uploads') || rawUrl.startsWith('/uploads')
                          ? `http://localhost:5000${rawUrl.startsWith('/') ? '' : '/'}${rawUrl}`
                          : rawUrl)
                          
                    return (
                      <div 
                        key={index} 
                        style={{
                          border: '1px solid var(--border-muted, #e0e0e0)',
                          borderRadius: '12px',
                          overflow: 'hidden',
                          backgroundColor: '#fafafa',
                          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                          transition: 'transform 0.2s ease, box-shadow 0.2s ease',
                          cursor: 'pointer'
                        }}
                        onMouseEnter={(e) => {
                          e.currentTarget.style.transform = 'translateY(-4px)'
                          e.currentTarget.style.boxShadow = '0 8px 16px rgba(0,0,0,0.1)'
                        }}
                        onMouseLeave={(e) => {
                          e.currentTarget.style.transform = 'none'
                          e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.05)'
                        }}
                      >
                        <a href={imageUrl} target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'none' }}>
                          <img 
                            src={imageUrl} 
                            alt={`Complaint Media ${index + 1}`}
                            style={{
                              width: '100%',
                              height: '160px',
                              objectFit: 'cover',
                              display: 'block'
                            }}
                            onError={(e) => {
                              e.target.src = 'https://placehold.co/600x400/e0e0e0/555555?text=No+Preview+Available'
                            }}
                          />
                          <div style={{ 
                            padding: '10px 14px', 
                            fontSize: '0.8rem', 
                            color: '#666', 
                            fontWeight: '600',
                            background: '#ffffff',
                            borderTop: '1px solid #eee',
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center'
                          }}>
                            <span>Attachment {index + 1}</span>
                            <span style={{ 
                              fontSize: '0.7rem', 
                              padding: '2px 6px', 
                              background: '#e8f5e9', 
                              color: '#2e7d32', 
                              borderRadius: '4px' 
                            }}>
                              {item.type || 'Image'}
                            </span>
                          </div>
                        </a>
                      </div>
                    )
                  })}
                </div>
              ) : (
                <div style={{ 
                  padding: '24px', 
                  textAlign: 'center', 
                  background: '#f5f5f5', 
                  borderRadius: '12px', 
                  color: '#888',
                  border: '1px dashed #ccc'
                }}>
                  📷 No photo attachments uploaded for this complaint.
                </div>
              )}
            </div>

            <div className="panel__body">
              <div className="interaction-bar">
                <button className={`interaction-btn ${hasLiked ? 'active' : ''}`} onClick={handleLike} type="button">
                  <Heart size={18} /> {interactions.likesCount} Likes
                </button>
                <button className="interaction-btn" type="button">
                  <MessageCircle size={18} /> {interactions.commentsCount} Comments
                </button>
              </div>
            </div>
          </section>

          <section className="panel panel--full">
            <div className="panel__header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2>Contractor Repair Offers / Bids</h2>
              <span className="badge badge--info" style={{ backgroundColor: 'var(--primary-light, #e3f2fd)', color: 'var(--primary, #1976d2)', padding: '6px 12px', borderRadius: '8px', fontSize: '0.85rem', fontWeight: 'bold' }}>
                {bids.length} Submitted
              </span>
            </div>
            <div className="panel__body">
              {bids.length === 0 ? (
                <p className="text-muted">No contractor offers submitted for this complaint yet.</p>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  {bids.map((bid) => (
                    <div 
                      key={bid.id} 
                      style={{ 
                        border: '1px solid var(--border-muted, #e0e0e0)', 
                        borderRadius: '12px', 
                        padding: '18px', 
                        backgroundColor: '#fafafa',
                        boxShadow: '0 2px 4px rgba(0,0,0,0.02)'
                      }}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                        <div>
                          <h4 style={{ margin: 0, color: '#333', fontSize: '1.1rem', fontWeight: 'bold' }}>
                            {bid.contractor?.name || 'Unknown Contractor'}
                          </h4>
                          <span style={{ fontSize: '0.8rem', color: '#888' }}>
                            {bid.contractor?.email}
                          </span>
                        </div>
                        <div style={{ textAlign: 'right' }}>
                          <span style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#2e7d32' }}>
                            ₹{parseFloat(bid.cost).toLocaleString('en-IN')}
                          </span>
                          <div style={{ fontSize: '0.85rem', color: '#666', marginTop: '2px' }}>
                            ⏱ {bid.duration}
                          </div>
                        </div>
                      </div>
                      <div style={{ borderTop: '1px solid #eee', paddingTop: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
                        <p style={{ margin: 0, fontSize: '0.9rem', color: '#555', lineHeight: '1.4', flex: 1 }}>
                          <strong>Proposal Details:</strong> {bid.message}
                        </p>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          {bid.status && bid.status !== 'pending' ? (
                            <span style={{
                              padding: '4px 10px',
                              borderRadius: '6px',
                              fontSize: '0.75rem',
                              fontWeight: 'bold',
                              textTransform: 'uppercase',
                              backgroundColor: bid.status === 'approved' ? '#e8f5e9' : '#ffebee',
                              color: bid.status === 'approved' ? '#2e7d32' : '#c62828'
                            }}>
                              {bid.status}
                            </span>
                          ) : (
                            <>
                              <button
                                onClick={() => handleApproveBid(bid.id)}
                                style={{
                                  padding: '6px 12px',
                                  borderRadius: '6px',
                                  border: 'none',
                                  backgroundColor: '#2e7d32',
                                  color: 'white',
                                  fontSize: '0.75rem',
                                  fontWeight: 'bold',
                                  cursor: 'pointer'
                                }}
                              >
                                Approve
                              </button>
                              <button
                                onClick={() => handleRejectBid(bid.id)}
                                style={{
                                  padding: '6px 12px',
                                  borderRadius: '6px',
                                  border: '1px solid #c62828',
                                  backgroundColor: 'transparent',
                                  color: '#c62828',
                                  fontSize: '0.75rem',
                                  fontWeight: 'bold',
                                  cursor: 'pointer'
                                }}
                              >
                                Reject
                              </button>
                            </>
                          )}
                        </div>
                      </div>
                      <div style={{ marginTop: '10px', fontSize: '0.75rem', color: '#999', textAlign: 'right' }}>
                        Submitted on: {new Date(bid.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </section>

          <section className="panel panel--full">
            <div className="panel__header">
              <h2>Comments & Discussion</h2>
            </div>

            <div className="panel__body">
              <div className="comments-list">
                {comments.length === 0 ? (
                  <p className="text-muted">No comments yet. Be the first to comment!</p>
                ) : (
                  comments.map((comment) => (
                    <div key={comment.id} className="comment-item">
                      <div className="comment-header">
                        <div>
                          <p className="comment-author">{comment.user.name}</p>
                          <p className="comment-role">{comment.user.role}</p>
                        </div>
                        <div className="comment-meta">
                          <p className="comment-date">{comment.createdAt}</p>
                          {user?.role === 'Admin' && (
                            <button
                              className="comment-delete"
                              type="button"
                              onClick={() => handleDeleteComment(comment.id)}
                              aria-label="Delete comment"
                            >
                              <Trash2 size={16} />
                            </button>
                          )}
                        </div>
                      </div>
                      <p className="comment-content">{comment.content}</p>
                    </div>
                  ))
                )}
              </div>

              <form onSubmit={handleAddComment} className="comment-form">
                <textarea
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  placeholder="Add a comment as a team member or government user..."
                  rows={3}
                />
                <button className="button button--primary" type="submit" disabled={submitting || !newComment.trim()}>
                  {submitting ? 'Posting...' : 'Post Comment'}
                </button>
              </form>
            </div>
          </section>
        </>
      )}
    </div>
  )
}

export default ComplaintDetails
