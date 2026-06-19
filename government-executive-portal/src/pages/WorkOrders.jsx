import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useWorkOrders } from '../hooks/useApi'
import StatusBadge from '../components/Widgets/StatusBadge'
import Pagination from '../components/Widgets/Pagination'
import { apiFetch } from '../services/api'
import { Search, RotateCcw } from 'lucide-react'

function getNormalizedStatus(s) {
  if (!s) return ''
  const lower = s.toLowerCase()
  if (lower === 'in-progress' || lower === 'in_progress') return 'in progress'
  return lower.replace(/[_-]/g, ' ')
}

function WorkOrders() {
  const navigate = useNavigate()
  const { data: workOrdersData, loading, error } = useWorkOrders()
  const [orders, setOrders] = useState(workOrdersData || [])
  const [deleteConfirm, setDeleteConfirm] = useState(null)
  const [deleting, setDeleting] = useState(false)

  // Search and Filter States
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [priorityFilter, setPriorityFilter] = useState('')
  const [typeFilter, setTypeFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const perPage = 6

  const [activeTab, setActiveTab] = useState('orders') // 'orders' or 'bids'
  const [bids, setBids] = useState([])
  const [loadingBids, setLoadingBids] = useState(false)

  useEffect(() => {
    if (activeTab === 'bids') {
      const fetchBids = async () => {
        try {
          setLoadingBids(true)
          const data = await apiFetch('/bids')
          setBids(data || [])
        } catch (err) {
          console.error('Error fetching bids:', err)
        } finally {
          setLoadingBids(false)
        }
      }
      fetchBids()
    }
  }, [activeTab])

  // Update orders when data changes
  if (workOrdersData && JSON.stringify(workOrdersData) !== JSON.stringify(orders)) {
    setOrders(workOrdersData)
  }

  const handleDelete = async (id) => {
    try {
      setDeleting(true)
      await apiFetch(`/admin/work-orders/${id}`, { method: 'DELETE' })
      setOrders(orders.filter(o => o.id !== id))
      setDeleteConfirm(null)
    } catch (err) {
      alert('Error deleting work order: ' + err.message)
    } finally {
      setDeleting(false)
    }
  }

  const allOrders = orders || []

  // Dynamic filter lists
  const workTypes = Array.from(new Set(allOrders.map(o => o.workType || o.type).filter(Boolean)))

  // Filtering Logic
  const filteredOrders = allOrders.filter((order) => {
    // 1. Search Query filter
    const orderLocation = typeof order.location === 'string' ? order.location : (order.location?.address || '')
    const orderType = order.workType || order.type || ''
    const matchesSearch = !search ? true : (
      (order.title || '').toLowerCase().includes(search.toLowerCase()) ||
      (orderType || '').toLowerCase().includes(search.toLowerCase()) ||
      (orderLocation || '').toLowerCase().includes(search.toLowerCase()) ||
      (order.assigned || '').toLowerCase().includes(search.toLowerCase())
    )

    // 2. Type filter
    const matchesType = !typeFilter ? true : (orderType === typeFilter)

    // 3. Status filter
    const matchesStatus = !statusFilter ? true : (getNormalizedStatus(order.status) === statusFilter)

    // 4. Priority filter
    const matchesPriority = !priorityFilter ? true : ((order.priority || 'Normal').toLowerCase() === priorityFilter.toLowerCase())

    return matchesSearch && matchesType && matchesStatus && matchesPriority
  })

  const pages = Math.ceil(filteredOrders.length / perPage)
  const paged = filteredOrders.slice((currentPage - 1) * perPage, currentPage * perPage)

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>Work Orders</h1>
        <Link to="/work-orders/new" className="button button--primary">
          + New Work Order
        </Link>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '12px', marginBottom: '20px' }}>
        <button 
          onClick={() => setActiveTab('orders')}
          style={{
            padding: '8px 16px',
            borderRadius: '8px',
            border: activeTab === 'orders' ? 'none' : '1px solid #ddd',
            backgroundColor: activeTab === 'orders' ? 'var(--primary, #1976d2)' : '#fff',
            color: activeTab === 'orders' ? '#fff' : '#666',
            fontWeight: 'bold',
            cursor: 'pointer'
          }}
          type="button"
        >
          Active Work Orders
        </button>
        <button 
          onClick={() => setActiveTab('bids')}
          style={{
            padding: '8px 16px',
            borderRadius: '8px',
            border: activeTab === 'bids' ? 'none' : '1px solid #ddd',
            backgroundColor: activeTab === 'bids' ? 'var(--primary, #1976d2)' : '#fff',
            color: activeTab === 'bids' ? '#fff' : '#666',
            fontWeight: 'bold',
            cursor: 'pointer'
          }}
          type="button"
        >
          Contractor Bids / Offers
        </button>
      </div>

      {activeTab === 'orders' && (
        <>
          {/* Modern Search & Filters Panel */}
          <div className="panel panel--compact panel--toolbar" style={{ minHeight: 'auto', marginBottom: '20px' }}>
            <div className="filters-row">
              <div className="filters-row__search">
                <div className="filters-row__search-icon">
                  <Search size={18} />
                </div>
                <input 
                  type="text"
                  className="input-search"
                  placeholder="Search title, type, location, assigned..."
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value)
                    setCurrentPage(1)
                  }}
                  disabled={loading}
                  style={{ maxWidth: '100%' }}
                />
              </div>

              <div className="filters-row__group">
                <select
                  className="filter-select filter-select--type"
                  value={typeFilter}
                  onChange={(e) => {
                    setTypeFilter(e.target.value)
                    setCurrentPage(1)
                  }}
                  disabled={loading}
                >
                  <option value="">All Types</option>
                  {workTypes.map(t => (
                    <option key={t} value={t}>{t}</option>
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
                  <option value="in progress">In Progress</option>
                  <option value="completed">Completed</option>
                  <option value="resolved">Resolved</option>
                </select>

                <select
                  className="filter-select filter-select--priority"
                  value={priorityFilter}
                  onChange={(e) => {
                    setPriorityFilter(e.target.value)
                    setCurrentPage(1)
                  }}
                  disabled={loading}
                >
                  <option value="">All Priorities</option>
                  <option value="High">High</option>
                  <option value="Normal">Normal/Medium</option>
                  <option value="Low">Low</option>
                </select>

                {(search || typeFilter || statusFilter || priorityFilter) && (
                  <button 
                    className="button button--secondary button--reset" 
                    onClick={() => {
                      setSearch('')
                      setTypeFilter('')
                      setStatusFilter('')
                      setPriorityFilter('')
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
          
          {error && <div className="error-message">{error}</div>}

          <section className="panel panel--full">
            <div className="panel__body panel__table-wrap">
              {loading ? (
                <p>Loading work orders...</p>
              ) : filteredOrders.length === 0 ? (
                <p className="text-center text-muted" style={{ padding: '24px' }}>No work orders found matching the criteria.</p>
              ) : (
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Title</th>
                      <th>Type</th>
                      <th>Location</th>
                      <th>Priority</th>
                      <th>Status</th>
                      <th>Progress</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paged.map((order) => (
                      <tr key={order.id}>
                        <td>{order.title}</td>
                        <td>{order.workType || order.type}</td>
                        <td>
                          {typeof order.location === 'string' 
                            ? order.location 
                            : order.location?.address || 'N/A'}
                        </td>
                        <td>
                          <span className={`badge badge--${(order.priority || 'Normal').toLowerCase()}`}>
                            {order.priority}
                          </span>
                        </td>
                        <td><StatusBadge status={order.status} /></td>
                        <td>
                          <div className="progress-bar">
                            <div className="progress-bar__fill" style={{ width: `${order.progress}%` }}></div>
                            <span className="progress-bar__text">{order.progress}%</span>
                          </div>
                        </td>
                        <td>
                          <div className="action-buttons">
                            <Link 
                              to={`/work-orders/${order.id}`} 
                              className="button button--small button--secondary"
                            >
                              Edit
                            </Link>
                            <button
                              className="button button--small button--danger"
                              onClick={() => setDeleteConfirm(order.id)}
                            >
                              Delete
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
        </>
      )}

      {activeTab === 'bids' && (
        <section className="panel panel--full">
          <div className="panel__body panel__table-wrap">
            {loadingBids ? (
              <p>Loading contractor bids...</p>
            ) : bids.length === 0 ? (
              <p className="text-center text-muted" style={{ padding: '24px' }}>No contractor bids found.</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Contractor</th>
                    <th>Complaint / Job</th>
                    <th>Est. Cost</th>
                    <th>Est. Duration</th>
                    <th>Proposal Description</th>
                    <th>Submitted On</th>
                  </tr>
                </thead>
                <tbody>
                  {bids.map((bid) => (
                    <tr key={bid.id}>
                      <td>
                        <div style={{ fontWeight: 600, color: 'var(--text)' }}>{bid.contractor?.name || 'N/A'}</div>
                        <div style={{ fontSize: '0.8rem', color: '#666' }}>{bid.contractor?.email}</div>
                      </td>
                      <td>
                        <Link to={`/complaints/${bid.complaint?.id}`} style={{ fontWeight: 600, color: 'var(--success)' }}>
                          {bid.complaint?.title || bid.complaintId}
                        </Link>
                      </td>
                      <td>
                        <span style={{ fontWeight: 'bold', color: '#2e7d32' }}>
                          ₹{parseFloat(bid.cost).toLocaleString('en-IN')}
                        </span>
                      </td>
                      <td>{bid.duration}</td>
                      <td>{bid.message}</td>
                      <td>{new Date(bid.createdAt).toLocaleDateString('en-IN')}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </section>
      )}

      {deleteConfirm && (
        <div className="modal-overlay" onClick={() => setDeleteConfirm(null)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h2>Delete Work Order?</h2>
            <p>Are you sure you want to delete this work order? This action cannot be undone.</p>
            <div className="modal-actions">
              <button
                className="button button--danger"
                onClick={() => handleDelete(deleteConfirm)}
                disabled={deleting}
              >
                {deleting ? 'Deleting...' : 'Delete'}
              </button>
              <button
                className="button button--secondary"
                onClick={() => setDeleteConfirm(null)}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default WorkOrders
