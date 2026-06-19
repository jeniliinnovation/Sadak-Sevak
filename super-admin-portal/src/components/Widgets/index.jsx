import { TrendingUp, TrendingDown } from 'lucide-react'

export function StatCard({ title, value, description, change, accent = 'default' }) {
  const isPositive = change?.startsWith('+')
  const changeClass = accent === 'success' ? 'success' : accent === 'warning' ? 'warning' : accent === 'danger' ? 'danger' : ''

  return (
    <div className="stat-card">
      <div className="stat-card__title">{title}</div>
      <div className="stat-card__value">{value}</div>
      <div className="stat-card__description">{description}</div>
      {change && (
        <div className={`stat-card__change ${changeClass}`}>
          {isPositive ? <TrendingUp size={14} /> : <TrendingDown size={14} />} {change}
        </div>
      )}
    </div>
  )
}

export function StatusBadge({ status }) {
  const statusMap = {
    'submitted': 'submitted',
    'under_review': 'under-review',
    'resolved': 'resolved',
    'rejected': 'rejected',
  }

  return (
    <span className={`status-badge ${statusMap[status] || status}`}>
      {status?.replace(/_/g, ' ').charAt(0).toUpperCase() + status?.slice(1).replace(/_/g, ' ')}
    </span>
  )
}
