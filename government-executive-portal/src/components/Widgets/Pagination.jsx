function Pagination({ currentPage, totalPages, onPageChange }) {
  const pages = Array.from({ length: totalPages }, (_, index) => index + 1)

  return (
    <div className="pagination">
      {pages.map((page) => (
        <button key={page} type="button" className={page === currentPage ? 'pagination__item pagination__item--active' : 'pagination__item'} onClick={() => onPageChange(page)}>
          {page}
        </button>
      ))}
    </div>
  )
}

export default Pagination
