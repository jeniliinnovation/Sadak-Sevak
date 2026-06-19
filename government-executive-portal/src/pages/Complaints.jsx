import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useComplaints } from '../hooks/useApi'
import StatusBadge from '../components/Widgets/StatusBadge'
import Pagination from '../components/Widgets/Pagination'
import { 
  Search, 
  RotateCcw, 
  AlertCircle, 
  Clock, 
  Play, 
  CheckCircle2, 
  XCircle, 
  FileText 
} from 'lucide-react'

function formatLocation(location) {
  if (!location) return 'N/A'
  if (typeof location === 'string') return location
  if (typeof location === 'object') {
    return location.address || location.area || `${location.lat || ''}${location.lat && location.lng ? ', ' : ''}${location.lng || ''}` || JSON.stringify(location)
  }
  return String(location)
}

function getNormalizedStatus(status) {
  if (!status) return ''
  const lower = status.toLowerCase()
  if (lower === 'in-progress' || lower === 'in_progress') return 'in progress'
  return lower.replace(/[_-]/g, ' ')
}

function getStatusGroup(status) {
  if (!status) return ''
  const lower = status.toLowerCase()
  if (lower === 'submitted' || lower === 'pending') {
    return 'pending'
  }
  if (
    lower === 'under_review' || 
    lower === 'under review' ||
    lower === 'team_assigned' || 
    lower === 'team assigned' ||
    lower === 'repair_started' || 
    lower === 'repair started' ||
    lower === 'escalated' || 
    lower === 'reopened' ||
    lower === 'in progress' ||
    lower === 'in-progress'
  ) {
    return 'in progress'
  }
  if (
    lower === 'repair_completed' || 
    lower === 'repair completed' ||
    lower === 'verified_closed' || 
    lower === 'verified closed' ||
    lower === 'resolved'
  ) {
    return 'resolved'
  }
  if (lower === 'rejected') {
    return 'rejected'
  }
  return lower.replace(/[_-]/g, ' ')
}

function Complaints() {
  const { data: complaintsData, loading, error } = useComplaints()
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [priorityFilter, setPriorityFilter] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const perPage = 6

  const complaints = complaintsData || []

  // Dynamic filter lists
  const categories = Array.from(new Set(complaints.map(item => item.category).filter(Boolean)))

  // Filtering Logic
  const filtered = complaints.filter((item) => {
    // 1. Search Query filter
    const matchesSearch = !search ? true : (
      (item.id || '').toLowerCase().includes(search.toLowerCase()) ||
      (item.title || '').toLowerCase().includes(search.toLowerCase()) ||
      (item.category || '').toLowerCase().includes(search.toLowerCase()) ||
      (formatLocation(item.location)).toLowerCase().includes(search.toLowerCase()) ||
      (item.description || '').toLowerCase().includes(search.toLowerCase())
    )

    // 2. Status filter
    const matchesStatus = !statusFilter ? true : (getStatusGroup(item.status) === statusFilter)

    // 3. Priority filter
    const itemPriority = (item.priority || 'Normal').toLowerCase()
    const matchesPriority = !priorityFilter ? true : (itemPriority === priorityFilter.toLowerCase())

    // 4. Category filter
    const matchesCategory = !categoryFilter ? true : (item.category === categoryFilter)

    return matchesSearch && matchesStatus && matchesPriority && matchesCategory
  })

  const pages = Math.ceil(filtered.length / perPage)
  const paged = filtered.slice((currentPage - 1) * perPage, currentPage * perPage)

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Complaint Resolution</h1></div>
      
      {/* Dynamic Summary Stats Strip */}
      {!loading && complaints.length > 0 && (
        <div className="stats-strip">
          <div className="stat-strip-card">
            <div className="stat-strip-card__icon stat-strip-card__icon--all">
              <FileText size={20} />
            </div>
            <div className="stat-strip-card__info">
              <span className="stat-strip-card__value">{complaints.length}</span>
              <span className="stat-strip-card__label">Total Complaints</span>
            </div>
          </div>
          <div className="stat-strip-card">
            <div className="stat-strip-card__icon stat-strip-card__icon--pending">
              <Clock size={20} />
            </div>
            <div className="stat-strip-card__info">
              <span className="stat-strip-card__value">
                {complaints.filter(c => getStatusGroup(c.status) === 'pending').length}
              </span>
              <span className="stat-strip-card__label">Pending</span>
            </div>
          </div>
          <div className="stat-strip-card">
            <div className="stat-strip-card__icon stat-strip-card__icon--in-progress">
              <Play size={20} />
            </div>
            <div className="stat-strip-card__info">
              <span className="stat-strip-card__value">
                {complaints.filter(c => getStatusGroup(c.status) === 'in progress').length}
              </span>
              <span className="stat-strip-card__label">In Progress</span>
            </div>
          </div>
          <div className="stat-strip-card">
            <div className="stat-strip-card__icon stat-strip-card__icon--resolved">
              <CheckCircle2 size={20} />
            </div>
            <div className="stat-strip-card__info">
              <span className="stat-strip-card__value">
                {complaints.filter(c => getStatusGroup(c.status) === 'resolved').length}
              </span>
              <span className="stat-strip-card__label">Resolved</span>
            </div>
          </div>
          <div className="stat-strip-card">
            <div className="stat-strip-card__icon stat-strip-card__icon--rejected">
              <XCircle size={20} />
            </div>
            <div className="stat-strip-card__info">
              <span className="stat-strip-card__value">
                {complaints.filter(c => getStatusGroup(c.status) === 'rejected').length}
              </span>
              <span className="stat-strip-card__label">Rejected</span>
            </div>
          </div>
        </div>
      )}

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
              placeholder="Search ID, title, location, category..."
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
              className="filter-select filter-select--category"
              value={categoryFilter}
              onChange={(e) => {
                setCategoryFilter(e.target.value)
                setCurrentPage(1)
              }}
              disabled={loading}
            >
              <option value="">All Categories</option>
              {categories.map(cat => (
                <option key={cat} value={cat}>{cat}</option>
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
              <option value="resolved">Resolved</option>
              <option value="rejected">Rejected</option>
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

            {(search || categoryFilter || statusFilter || priorityFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setCategoryFilter('')
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
            <p>Loading complaints...</p>
          ) : filtered.length === 0 ? (
            <p className="text-center text-muted" style={{ padding: '24px' }}>No complaints found matching the criteria.</p>
          ) : (
            <table className="data-table">
              <thead><tr><th>ID</th><th>Title</th><th>Category</th><th>Location</th><th>Priority</th><th>Status</th><th>Date</th></tr></thead>
              <tbody>
                {paged.map((item) => (
                  <tr key={item.id}>
                    <td>
                      <Link to={`/complaints/${item.id}`} style={{ fontFamily: 'monospace', fontWeight: 600, color: 'var(--success)' }}>
                        {item.id}
                      </Link>
                    </td>
                    <td>
                      <Link to={`/complaints/${item.id}`} style={{ fontWeight: 600, color: 'var(--text)' }}>
                        {item.title}
                      </Link>
                    </td>
                    <td>{item.category}</td>
                    <td>{formatLocation(item.location)}</td>
                    <td>
                      <span className={`badge badge--${(item.priority || 'Normal').toLowerCase()}`}>
                        {item.priority || 'Normal'}
                      </span>
                    </td>
                    <td><StatusBadge status={item.status} /></td>
                    <td>{item.createdAt ? new Date(item.createdAt).toLocaleDateString() : ''}</td>
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
    </div>
  )
}

export default Complaints
