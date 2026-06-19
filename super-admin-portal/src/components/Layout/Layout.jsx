import { Outlet } from 'react-router-dom'
import Sidebar from './Sidebar'
import Header from './Header'

function Layout({ children }) {
  return (
    <div className="app-shell">
      <Sidebar />
      <div className="app-shell__main">
        <Header />
        <main className="page-content">{children || <Outlet />}</main>
      </div>
    </div>
  )
}

export default Layout
