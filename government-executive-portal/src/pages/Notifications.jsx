import { useState, useEffect } from 'react'
import { useNotifications } from '../hooks/useApi'
import { Search, RotateCcw } from 'lucide-react'

const defaultNotifications = [
  {
    id: 'notif-1',
    message: 'New complaint submitted for Road Damage in Sector 5',
    timestamp: new Date(Date.now() - 2 * 60 * 1000).toISOString(),
    unread: true,
    read: false
  },
  {
    id: 'notif-2',
    message: 'Work order WO-2651 has been assigned to Green Roads Pvt Ltd',
    timestamp: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    unread: true,
    read: false
  },
  {
    id: 'notif-3',
    message: 'Complaint CMP-1002 has been marked as RESOLVED by Field Officer Patel',
    timestamp: new Date(Date.now() - 120 * 60 * 1000).toISOString(),
    unread: false,
    read: true
  },
  {
    id: 'notif-4',
    message: 'Super Admin added Vikram Singh as a new Field Officer',
    timestamp: new Date(Date.now() - 1440 * 60 * 1000).toISOString(),
    unread: false,
    read: true
  }
]

function Notifications() {
  const { data: notificationsData, loading, error } = useNotifications()
  const [items, setItems] = useState([])
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  useEffect(() => {
    if (notificationsData) {
      if (notificationsData.length > 0) {
        setItems(notificationsData)
      } else {
        setItems(defaultNotifications)
      }
    }
  }, [notificationsData])

  const markAllRead = () => setItems(items.map((item) => ({ ...item, unread: false, read: true })))
  const toggleRead = (id) => setItems(items.map((item) => item.id === id ? { ...item, unread: false, read: true } : item))

  const getIsUnread = (item) => {
    return item.unread === true || item.read === false
  }

  // Filtering Logic
  const filteredItems = items.filter((item) => {
    // 1. Search Query filter
    const matchesSearch = !search ? true : (item.message || '').toLowerCase().includes(search.toLowerCase())

    // 2. Status filter
    const isUnread = getIsUnread(item)
    const matchesStatus = statusFilter === 'all' ? true : (
      statusFilter === 'unread' ? isUnread : !isUnread
    )

    return matchesSearch && matchesStatus
  })

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>Public Alerts</h1>
        <button className="button button--secondary" type="button" onClick={markAllRead} disabled={loading}>Mark all read</button>
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
              onChange={(e) => setSearch(e.target.value)} 
              placeholder="Search notifications..." 
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
              <option value="all">All Notifications</option>
              <option value="unread">Unread</option>
              <option value="read">Read</option>
            </select>

            {(search || statusFilter !== 'all') && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearch('')
                  setStatusFilter('all')
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

      <div className="panel panel--full">
        <div className="panel__body notifications-list">
          {loading ? (
            <p>Loading notifications...</p>
          ) : filteredItems.length === 0 ? (
            <p className="text-muted text-center" style={{ padding: '24px' }}>No notifications found matching the criteria.</p>
          ) : (
            filteredItems.map((item) => (
              <div 
                key={item.id} 
                className={`notification ${getIsUnread(item) ? 'notification--unread' : ''}`} 
                onClick={() => toggleRead(item.id)}
              >
                <p>{item.message}</p>
                <small>{item.timestamp ? new Date(item.timestamp).toLocaleString() : item.time}</small>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  )
}

export default Notifications
