import { useState } from 'react'
import { useUsers } from '../hooks/useApi'
import StatusBadge from '../components/Widgets/StatusBadge'
import Pagination from '../components/Widgets/Pagination'
import { Search, RotateCcw } from 'lucide-react'

function Users() {
  const { data: usersData, loading, error } = useUsers()
  const [search, setSearch] = useState('')
  const [roleFilter, setRoleFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const perPage = 5

  const users = usersData || []

  // Dynamic filter lists
  const roles = Array.from(new Set(users.map(u => u.role).filter(Boolean)))
  const statuses = Array.from(new Set(users.map(u => u.status).filter(Boolean)))

  // Filtering Logic
  const filtered = users.filter((user) => {
    // 1. Search Query filter
    const matchesSearch = !search ? true : (
      (user.name || '').toLowerCase().includes(search.toLowerCase()) || 
      (user.email || '').toLowerCase().includes(search.toLowerCase()) || 
      (user.role || '').toLowerCase().includes(search.toLowerCase()) ||
      (user.phone || '').toLowerCase().includes(search.toLowerCase())
    )

    // 2. Role filter
    const matchesRole = !roleFilter ? true : (user.role === roleFilter)

    // 3. Status filter
    const matchesStatus = !statusFilter ? true : (user.status?.toLowerCase() === statusFilter.toLowerCase())

    return matchesSearch && matchesRole && matchesStatus
  })

  const pages = Math.ceil(filtered.length / perPage)
  const paged = filtered.slice((currentPage - 1) * perPage, currentPage * perPage)

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Staff Directory</h1></div>
      
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
              placeholder="Search name, email, phone, role..." 
              disabled={loading}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select filter-select--role"
              value={roleFilter}
              onChange={(e) => {
                setRoleFilter(e.target.value)
                setCurrentPage(1)
              }}
              disabled={loading}
            >
              <option value="">All Roles</option>
              {roles.map(r => (
                <option key={r} value={r}>{r}</option>
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
              {statuses.map(s => (
                <option key={s} value={s.toLowerCase()}>{s}</option>
              ))}
            </select>

            {(search || roleFilter || statusFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setRoleFilter('')
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

      {error && <div className="error-message">{error}</div>}

      <section className="panel panel--full">
        <div className="panel__body panel__table-wrap">
          {loading ? (
            <p>Loading users...</p>
          ) : filtered.length === 0 ? (
            <p className="text-center text-muted" style={{ padding: '24px' }}>No users found matching the criteria.</p>
          ) : (
            <table className="data-table">
              <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Role</th><th>Joined</th><th>Status</th></tr></thead>
              <tbody>
                {paged.map((user) => (
                  <tr key={user.id || user.email}>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>{user.phone || 'N/A'}</td>
                    <td>{user.role}</td>
                    <td>{user.joinedDate ? new Date(user.joinedDate).toLocaleDateString() : user.joined}</td>
                    <td><StatusBadge status={user.status} /></td>
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

export default Users
