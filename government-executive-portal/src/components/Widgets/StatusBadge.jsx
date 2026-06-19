function StatusBadge({ status }) {
  if (!status) {
    return <span className="badge badge--unknown">Unknown</span>
  }
  return <span className={`badge badge--${status.toLowerCase().replace(/\s+/g, '-')}`}>{status}</span>
}

export default StatusBadge
