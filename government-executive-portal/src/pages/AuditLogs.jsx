import { useState } from 'react'
import { useAuditLogs } from '../hooks/useApi'
import Pagination from '../components/Widgets/Pagination'
import { Search, RotateCcw } from 'lucide-react'

function AuditLogs() {
  const { data: auditLogsData, loading, error } = useAuditLogs()
  const [search, setSearch] = useState('')
  const [actionFilter, setActionFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const perPage = 5

  const logs = auditLogsData || []

  // Dynamic filter lists
  const uniqueActions = Array.from(new Set(logs.map(item => item.action).filter(Boolean)))

  // Filtering Logic
  const filtered = logs.filter((item) => {
    const userVal = item.userName || item.user || ''
    const actionVal = item.action || ''
    const detailsVal = item.details || ''
    const ipVal = item.ipAddress || item.ip || ''

    // 1. Search Query filter
    const matchesSearch = !search ? true : (
      userVal.toLowerCase().includes(search.toLowerCase()) || 
      actionVal.toLowerCase().includes(search.toLowerCase()) || 
      detailsVal.toLowerCase().includes(search.toLowerCase()) ||
      ipVal.toLowerCase().includes(search.toLowerCase())
    )

    // 2. Action filter
    const matchesAction = !actionFilter ? true : (item.action === actionFilter)

    return matchesSearch && matchesAction
  })

  const pages = Math.ceil(filtered.length / perPage)
  const paged = filtered.slice((currentPage - 1) * perPage, currentPage * perPage)

  return (
    <div className="page-shell">
      <div className="page-header"><h1>System Audit Logs</h1></div>

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
              placeholder="Search user, action, details, IP..." 
              disabled={loading}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select"
              value={actionFilter}
              onChange={(e) => {
                setActionFilter(e.target.value)
                setCurrentPage(1)
              }}
              disabled={loading}
            >
              <option value="">All Actions</option>
              {uniqueActions.map(act => (
                <option key={act} value={act}>
                  {act.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}
                </option>
              ))}
            </select>

            {(search || actionFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setActionFilter('')
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
            <p>Loading audit logs...</p>
          ) : filtered.length === 0 ? (
            <p className="text-center text-muted" style={{ padding: '24px' }}>No audit logs found matching the criteria.</p>
          ) : (
            <table className="data-table">
              <thead><tr><th>User</th><th>Action</th><th>Details</th><th>IP Address</th><th>Date & Time</th></tr></thead>
              <tbody>
                {paged.map((item, index) => (
                  <tr key={`${item.userId || item.user}-${index}`}>
                    <td>{item.userName || item.user}</td>
                    <td>{item.action ? item.action.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase()) : ''}</td>
                    <td>{item.details}</td>
                    <td>{item.ipAddress || item.ip || 'N/A'}</td>
                    <td>{item.timestamp ? new Date(item.timestamp).toLocaleString() : item.datetime}</td>
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

export default AuditLogs
