import { useState } from 'react'
import { useRoles } from '../hooks/useApi'
import StatusBadge from '../components/Widgets/StatusBadge'
import { Search, RotateCcw } from 'lucide-react'

function Roles() {
  const { data: rolesData, loading, error } = useRoles()
  const [selectedRole, setSelectedRole] = useState(null)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')

  const defaultRoles = [
    { id: '1', role: 'Super Admin', users: 2, status: 'Active' },
    { id: '2', role: 'Admin', users: 5, status: 'Active' },
    { id: '3', role: 'Department Head', users: 12, status: 'Active' },
    { id: '4', role: 'Field Officer', users: 35, status: 'Active' },
    { id: '5', role: 'Contractor', users: 18, status: 'Active' },
    { id: '6', role: 'Citizen', users: 495, status: 'Active' }
  ]

  const rolesList = rolesData && rolesData.length > 0 ? rolesData : defaultRoles

  // Filtering Logic
  const filteredRoles = rolesList.filter((item) => {
    const roleName = item.role || item.name || ''
    const matchesSearch = !search ? true : roleName.toLowerCase().includes(search.toLowerCase())

    const roleStatus = item.status || 'Active'
    const matchesStatus = !statusFilter ? true : (roleStatus.toLowerCase() === statusFilter.toLowerCase())

    return matchesSearch && matchesStatus
  })

  return (
    <div className="page-shell">
      <div className="page-header"><h1>Departments & Roles</h1></div>

      {/* Search & Filters Panel */}
      <div className="panel panel--toolbar">
        <div className="filters-row">
          <div className="filters-row__search">
            <div className="filters-row__search-icon">
              <Search size={18} />
            </div>
            <input 
              className="input-search" 
              value={search} 
              onChange={(e) => setSearch(e.target.value)} 
              placeholder="Search roles..." 
              disabled={loading}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select filter-select--status"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              disabled={loading}
            >
              <option value="">All Statuses</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>

            {(search || statusFilter) && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setStatusFilter('')
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
            <p>Loading roles...</p>
          ) : filteredRoles.length === 0 ? (
            <p className="text-center text-muted" style={{ padding: '24px' }}>No roles found matching the criteria.</p>
          ) : (
            <table className="data-table">
              <thead><tr><th>Role Name</th><th>Users</th><th>Status</th></tr></thead>
              <tbody>
                {filteredRoles.map((item) => (
                  <tr 
                    key={item.id || item.role} 
                    onClick={() => setSelectedRole(item.role || item.name)}
                    style={{ cursor: 'pointer' }}
                  >
                    <td>{item.role || item.name}</td>
                    <td>{item.users || item.userCount || 0}</td>
                    <td><StatusBadge status={item.status || 'Active'} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </section>
      {selectedRole && (
        <div className="panel panel--compact" style={{ marginTop: '20px', padding: '20px' }}>
          <h3>Selected role: {selectedRole}</h3>
          <p className="text-muted" style={{ margin: 0 }}>Permission editing is available in the real admin portal.</p>
        </div>
      )}
    </div>
  )
}

export default Roles
