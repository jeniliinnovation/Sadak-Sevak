import { useState, useEffect, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { useContractors } from '../hooks/useApi'
import { apiFetch } from '../services/api'
import StatusBadge from '../components/Widgets/StatusBadge'
import Pagination from '../components/Widgets/Pagination'
import { Search, RotateCcw, CheckCircle2, XCircle, Trash2, Clock, ShieldCheck, ShieldX, Building2, AlertTriangle, Plus } from 'lucide-react'

function Contractors() {
  const navigate = useNavigate()
  const { data: contractorsData, loading: initialLoading, error: fetchError } = useContractors()
  const [contractors, setContractors] = useState([])
  const [search, setSearch] = useState('')
  const [specFilter, setSpecFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [activeTab, setActiveTab] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [actionLoading, setActionLoading] = useState(null)
  const [showRejectModal, setShowRejectModal] = useState(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [actionError, setActionError] = useState(null)
  const [actionSuccess, setActionSuccess] = useState(null)
  const perPage = 6

  useEffect(() => {
    if (contractorsData) {
      setContractors(contractorsData)
    }
  }, [contractorsData])

  // Auto-clear success/error messages
  useEffect(() => {
    if (actionSuccess) {
      const timer = setTimeout(() => setActionSuccess(null), 3000)
      return () => clearTimeout(timer)
    }
  }, [actionSuccess])

  useEffect(() => {
    if (actionError) {
      const timer = setTimeout(() => setActionError(null), 5000)
      return () => clearTimeout(timer)
    }
  }, [actionError])

  const loading = initialLoading

  // Dynamic filter lists
  const specializations = Array.from(
    new Set(
      contractors.map(c => c.specialization || c.expertise)
        .flatMap(item => Array.isArray(item) ? item : [item])
        .filter(Boolean)
    )
  )

  // Status counts for tabs
  const statusCounts = {
    all: contractors.length,
    pending: contractors.filter(c => (c.status || 'pending') === 'pending').length,
    approved: contractors.filter(c => c.status === 'approved').length,
    rejected: contractors.filter(c => c.status === 'rejected').length,
  }

  // Handle Approve
  const handleApprove = useCallback(async (contractor) => {
    setActionLoading(contractor.id)
    setActionError(null)
    try {
      const updated = await apiFetch(`/admin/contractors/${contractor.id}`, {
        method: 'PUT',
        body: JSON.stringify({ status: 'approved', rejectionReason: null }),
      })
      setContractors(prev => prev.map(c => c.id === contractor.id ? { ...c, ...updated } : c))
      setActionSuccess(`${contractor.companyName || contractor.name} has been approved!`)
    } catch (err) {
      setActionError(err.message || 'Failed to approve contractor')
    } finally {
      setActionLoading(null)
    }
  }, [])

  // Handle Reject
  const handleReject = useCallback(async () => {
    if (!showRejectModal) return
    setActionLoading(showRejectModal.id)
    setActionError(null)
    try {
      const updated = await apiFetch(`/admin/contractors/${showRejectModal.id}`, {
        method: 'PUT',
        body: JSON.stringify({ status: 'rejected', rejectionReason }),
      })
      setContractors(prev => prev.map(c => c.id === showRejectModal.id ? { ...c, ...updated } : c))
      setActionSuccess(`${showRejectModal.companyName || showRejectModal.name} has been rejected.`)
      setShowRejectModal(null)
      setRejectionReason('')
    } catch (err) {
      setActionError(err.message || 'Failed to reject contractor')
    } finally {
      setActionLoading(null)
    }
  }, [showRejectModal, rejectionReason])

  // Handle Delete
  const handleDelete = useCallback(async (contractor) => {
    if (!window.confirm(`Are you sure you want to permanently delete "${contractor.companyName || contractor.name}"?`)) return
    setActionLoading(contractor.id)
    setActionError(null)
    try {
      await apiFetch(`/admin/contractors/${contractor.id}`, { method: 'DELETE' })
      setContractors(prev => prev.filter(c => c.id !== contractor.id))
      setActionSuccess(`${contractor.companyName || contractor.name} has been deleted.`)
    } catch (err) {
      setActionError(err.message || 'Failed to delete contractor')
    } finally {
      setActionLoading(null)
    }
  }, [])

  // Filtering Logic
  const filtered = contractors.filter((c) => {
    const name = c.name || c.companyName || ''
    const contact = c.contact || c.contactPerson || ''
    const spec = c.specialization || (Array.isArray(c.expertise) ? c.expertise.join(', ') : c.expertise) || ''
    const phone = c.phone || ''

    const matchesSearch = !search ? true : (
      name.toLowerCase().includes(search.toLowerCase()) || 
      contact.toLowerCase().includes(search.toLowerCase()) || 
      spec.toLowerCase().includes(search.toLowerCase()) ||
      phone.toLowerCase().includes(search.toLowerCase())
    )

    const matchesSpec = !specFilter ? true : (
      (c.specialization === specFilter) || 
      (Array.isArray(c.expertise) && c.expertise.includes(specFilter)) ||
      (typeof c.expertise === 'string' && c.expertise === specFilter)
    )

    // Tab filter
    const cStatus = c.status || 'pending'
    const matchesTab = activeTab === 'all' ? true : (cStatus.toLowerCase() === activeTab)

    // Status dropdown filter (independent of tab)
    const matchesStatus = !statusFilter ? true : (cStatus.toLowerCase() === statusFilter.toLowerCase())

    return matchesSearch && matchesSpec && matchesTab && matchesStatus
  })

  const pages = Math.ceil(filtered.length / perPage)
  const paged = filtered.slice((currentPage - 1) * perPage, currentPage * perPage)

  const getStatusVariant = (status) => {
    switch ((status || 'pending').toLowerCase()) {
      case 'approved': return 'approved'
      case 'rejected': return 'rejected'
      case 'pending': return 'pending'
      default: return 'pending'
    }
  }

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>Infrastructure Projects</h1>
        <button className="button button--primary" type="button" onClick={() => navigate('/contractor-form')}>
          <Plus size={16} /> Add Project Contractor
        </button>
      </div>

      {/* Action Feedback Messages */}
      {actionSuccess && (
        <div className="contractor-toast contractor-toast--success">
          <CheckCircle2 size={18} />
          <span>{actionSuccess}</span>
        </div>
      )}
      {actionError && (
        <div className="contractor-toast contractor-toast--error">
          <AlertTriangle size={18} />
          <span>{actionError}</span>
        </div>
      )}

      {/* Status Tabs */}
      <div className="contractor-tabs">
        <button
          className={`contractor-tab ${activeTab === 'all' ? 'contractor-tab--active' : ''}`}
          onClick={() => { setActiveTab('all'); setCurrentPage(1) }}
        >
          <Building2 size={16} />
          All Contractors
          <span className="contractor-tab__count">{statusCounts.all}</span>
        </button>
        <button
          className={`contractor-tab contractor-tab--pending ${activeTab === 'pending' ? 'contractor-tab--active' : ''}`}
          onClick={() => { setActiveTab('pending'); setCurrentPage(1) }}
        >
          <Clock size={16} />
          Pending Approval
          <span className="contractor-tab__count">{statusCounts.pending}</span>
        </button>
        <button
          className={`contractor-tab contractor-tab--approved ${activeTab === 'approved' ? 'contractor-tab--active' : ''}`}
          onClick={() => { setActiveTab('approved'); setCurrentPage(1) }}
        >
          <ShieldCheck size={16} />
          Approved
          <span className="contractor-tab__count">{statusCounts.approved}</span>
        </button>
        <button
          className={`contractor-tab contractor-tab--rejected ${activeTab === 'rejected' ? 'contractor-tab--active' : ''}`}
          onClick={() => { setActiveTab('rejected'); setCurrentPage(1) }}
        >
          <ShieldX size={16} />
          Rejected
          <span className="contractor-tab__count">{statusCounts.rejected}</span>
        </button>
      </div>

      {/* Search & Filters Panel */}
      <div className="panel panel--compact panel--toolbar" style={{ minHeight: 'auto', marginBottom: '20px' }}>
        <div className="filters-row">
          <div className="filters-row__search">
            <div className="filters-row__search-icon">
              <Search size={18} />
            </div>
            <input 
              className="input-search" 
              value={search} 
              onChange={(e) => {
                setSearch(e.target.value)
                setCurrentPage(1)
              }} 
              placeholder="Search company, contact, specialization..." 
              disabled={loading}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select filter-select--specialization"
              value={specFilter}
              onChange={(e) => {
                setSpecFilter(e.target.value)
                setCurrentPage(1)
              }}
              disabled={loading}
            >
              <option value="">All Specializations</option>
              {specializations.map(s => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>

            <select
              className="filter-select filter-select--status"
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value)
                setCurrentPage(1)
              }}
              disabled={loading}
            >
              <option value="">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>

            {(search || specFilter || statusFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setSpecFilter('')
                  setStatusFilter('')
                  setCurrentPage(1)
                }}
                title="Reset Filters"
                type="button"
              >
                <RotateCcw size={16} /> Reset
              </button>
            )}
          </div>
        </div>
      </div>
      
      {fetchError && <div className="error-message">{fetchError}</div>}

      {/* Main Contractors Table */}
      <section className="panel panel--full">
        <div className="panel__body panel__table-wrap">
          {loading ? (
            <div className="contractor-loading">
              <div className="contractor-loading__spinner"></div>
              <p>Loading contractors...</p>
            </div>
          ) : filtered.length === 0 ? (
            <div className="contractor-empty">
              <Building2 size={48} strokeWidth={1} />
              <h3>No contractors found</h3>
              <p>No contractors matching the current filters. Try adjusting your search or filter criteria.</p>
            </div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Company</th>
                  <th>Contact Person</th>
                  <th>Phone</th>
                  <th>Specialization</th>
                  <th>Rating</th>
                  <th>Status</th>
                  <th style={{ textAlign: 'center', minWidth: '180px' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {paged.map((contractor) => (
                  <tr key={contractor.id || contractor.name} className={`contractor-row contractor-row--${getStatusVariant(contractor.status)}`}>
                    <td>
                      <div className="contractor-company">
                        <span className="contractor-company__name">{contractor.name || contractor.companyName}</span>
                      </div>
                    </td>
                    <td>{contractor.contact || contractor.contactPerson || '—'}</td>
                    <td>{contractor.phone || '—'}</td>
                    <td>
                      <span className="contractor-spec-badge">
                        {contractor.specialization || 
                         (Array.isArray(contractor.expertise) ? contractor.expertise.join(', ') : contractor.expertise) || 
                         '—'}
                      </span>
                    </td>
                    <td>
                      <div className="contractor-rating">
                        <span className="contractor-rating__stars">
                          {'★'.repeat(Math.round(contractor.rating || 0))}{'☆'.repeat(5 - Math.round(contractor.rating || 0))}
                        </span>
                        <span className="contractor-rating__value">{(contractor.rating || 0).toFixed(1)}</span>
                      </div>
                    </td>
                    <td>
                      <StatusBadge status={contractor.status || 'pending'} />
                      {contractor.status === 'rejected' && contractor.rejectionReason && (
                        <div className="contractor-rejection-reason" title={contractor.rejectionReason}>
                          <small>Reason: {contractor.rejectionReason}</small>
                        </div>
                      )}
                    </td>
                    <td>
                      <div className="contractor-actions">
                        {(contractor.status === 'pending' || !contractor.status) && (
                          <>
                            <button
                              className="contractor-action-btn contractor-action-btn--approve"
                              onClick={() => handleApprove(contractor)}
                              disabled={actionLoading === contractor.id}
                              title="Approve Contractor"
                            >
                              <CheckCircle2 size={15} />
                              {actionLoading === contractor.id ? '...' : 'Approve'}
                            </button>
                            <button
                              className="contractor-action-btn contractor-action-btn--reject"
                              onClick={() => { setShowRejectModal(contractor); setRejectionReason('') }}
                              disabled={actionLoading === contractor.id}
                              title="Reject Contractor"
                            >
                              <XCircle size={15} />
                              Reject
                            </button>
                          </>
                        )}
                        {contractor.status === 'rejected' && (
                          <button
                            className="contractor-action-btn contractor-action-btn--approve"
                            onClick={() => handleApprove(contractor)}
                            disabled={actionLoading === contractor.id}
                            title="Re-Approve Contractor"
                          >
                            <CheckCircle2 size={15} />
                            {actionLoading === contractor.id ? '...' : 'Re-Approve'}
                          </button>
                        )}
                        {contractor.status === 'approved' && (
                          <button
                            className="contractor-action-btn contractor-action-btn--reject"
                            onClick={() => { setShowRejectModal(contractor); setRejectionReason('') }}
                            disabled={actionLoading === contractor.id}
                            title="Revoke Approval"
                          >
                            <XCircle size={15} />
                            Revoke
                          </button>
                        )}
                        <button
                          className="contractor-action-btn contractor-action-btn--delete"
                          onClick={() => handleDelete(contractor)}
                          disabled={actionLoading === contractor.id}
                          title="Delete Contractor"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </section>

      {pages > 1 && (
        <Pagination currentPage={currentPage} totalPages={pages} onPageChange={setCurrentPage} />
      )}

      {/* Rejection Reason Modal */}
      {showRejectModal && (
        <div className="contractor-modal-overlay" onClick={() => setShowRejectModal(null)}>
          <div className="contractor-modal" onClick={(e) => e.stopPropagation()}>
            <div className="contractor-modal__header">
              <div className="contractor-modal__icon contractor-modal__icon--reject">
                <ShieldX size={28} />
              </div>
              <h2>Reject Contractor</h2>
              <p>You are about to reject <strong>{showRejectModal.companyName || showRejectModal.name}</strong>. Please provide a reason for rejection.</p>
            </div>
            <div className="contractor-modal__body">
              <label className="contractor-modal__label">Rejection Reason</label>
              <textarea
                className="contractor-modal__textarea"
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                placeholder="Enter the reason for rejecting this contractor..."
                rows={4}
                autoFocus
              />
            </div>
            <div className="contractor-modal__footer">
              <button
                className="button button--secondary"
                onClick={() => setShowRejectModal(null)}
                type="button"
              >
                Cancel
              </button>
              <button
                className="contractor-action-btn contractor-action-btn--reject"
                onClick={handleReject}
                disabled={actionLoading === showRejectModal?.id || !rejectionReason.trim()}
                type="button"
                style={{ padding: '10px 24px', fontSize: '0.9rem' }}
              >
                <XCircle size={16} />
                {actionLoading === showRejectModal?.id ? 'Rejecting...' : 'Confirm Rejection'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Contractors
