function StatCard({ title, value, description, change, icon, accent }) {
  return (
    <div className={`stat-card ${accent ? `stat-card--${accent}` : ''}`}>
      <div className="stat-card__header">
        <span>{title}</span>
        {icon && <div className="stat-card__icon">{icon}</div>}
      </div>
      <div className="stat-card__value">{value}</div>
      <div className="stat-card__footer">
        <span>{description}</span>
        {change && <span className="stat-card__change">{change}</span>}
      </div>
    </div>
  )
}

export default StatCard
