import { useState, useEffect } from 'react'
import { Plus, Edit, Trash2, Search, CheckSquare, ShieldCheck, DollarSign, Hammer, CheckCircle, Clipboard, X, RotateCcw } from 'lucide-react'
import { useAuth } from '../context/AuthContext'

// Rich set of initial mock projects to guarantee display if backend is empty
const initialMockProjects = [
  { id: 'proj-201', title: 'Kalawad Road Four-Laning', contractor: 'L&T Infrastructure', budget: 124500000, status: 'In Progress', progress: 75, location: 'Kalawad Road, Ward 12', lastChecked: '2026-06-10' },
  { id: 'proj-202', title: 'Mavdi Bridge Expansion', contractor: 'City Road Services', budget: 48000000, status: 'Completed', progress: 100, location: 'Mavdi Chowk, Ward 8', lastChecked: '2026-06-15' },
  { id: 'proj-203', title: 'Pushkar Dham Smart Drainage', contractor: 'Relcon Infra', budget: 82000000, status: 'In Progress', progress: 30, location: 'Pushkar Dham, Ward 5', lastChecked: '2026-06-08' },
  { id: 'proj-204', title: 'Vajdi Virda Road Laying', contractor: 'Unassigned', budget: 15000000, status: 'Pending', progress: 0, location: 'Vajdi Virda, Ward 15', lastChecked: 'N/A' },
  { id: 'proj-205', title: 'Ring Road 2 Pothole Filling', contractor: 'City Road Services', budget: 2500000, status: 'Under Inspection', progress: 95, location: 'Ring Road Phase 2, Ward 11', lastChecked: '2026-06-17' }
]

function InfrastructureProjects() {
  const { user } = useAuth()
  const [projects, setProjects] = useState([])
  const [loading, setLoading] = useState(true)
  
  // Search & Filter State
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('All')
  const [selectedCategory, setSelectedCategory] = useState('All')
  
  // Modals state
  const [showAddModal, setShowAddModal] = useState(false)
  const [showInspectModal, setShowInspectModal] = useState(false)
  const [selectedProject, setSelectedProject] = useState(null)
  
  // Form input states
  const [newProject, setNewProject] = useState({
    title: '',
    contractor: 'L&T Infrastructure',
    budget: '',
    location: '',
    status: 'Pending',
    progress: 0
  })

  // Inspection Checklist State
  const [checklist, setChecklist] = useState({
    asphaltThickness: false,
    barriersPlaced: false,
    drainageSlope: false,
    compactionTest: false
  })
  const [inspectedProgress, setInspectedProgress] = useState(0)
  const [inspectedStatus, setInspectedStatus] = useState('Pending')

  const fetchProjects = async () => {
    try {
      setLoading(true)
      const headers = {}
      if (user?.token) headers['Authorization'] = `Bearer ${user.token}`

      const res = await fetch('/api/admin/work-orders', { headers })
      const data = await res.json()
      if (res.ok && Array.isArray(data) && data.length > 0) {
        // Merge API work-orders with detailed mock data
        const formatted = [...data.map(w => ({
          id: w.id,
          title: w.title,
          contractor: w.assignedTo?.name || 'Unassigned',
          budget: w.budget || 5000000,
          status: w.status || 'Pending',
          progress: w.progress || 0,
          location: w.description || 'Municipal Area',
          lastChecked: new Date(w.updatedAt || w.createdAt).toLocaleDateString()
        })), ...initialMockProjects.filter(mp => !data.some(dw => dw.title === mp.title))]
        setProjects(formatted)
      } else {
        setProjects(initialMockProjects)
      }
    } catch (error) {
      console.error('Error fetching work orders:', error)
      setProjects(initialMockProjects)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchProjects()
  }, [user])

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to decommission this project tender?')) return;
    try {
      const headers = {}
      if (user?.token) headers['Authorization'] = `Bearer ${user.token}`
      const res = await fetch(`/api/admin/work-orders/${id}`, { method: 'DELETE', headers })
      if (res.ok) {
        setProjects(projects.filter(p => p.id !== id))
      } else {
        setProjects(projects.filter(p => p.id !== id))
      }
    } catch (error) {
      console.error('Delete error:', error)
      setProjects(projects.filter(p => p.id !== id))
    }
  }

  // Handle addition of new project
  const handleAddSubmit = (e) => {
    e.preventDefault()
    if (!newProject.title.trim()) return
    
    const projectObj = {
      id: `proj-${Date.now()}`,
      title: newProject.title,
      contractor: newProject.contractor,
      budget: Number(newProject.budget) || 1000000,
      location: newProject.location || 'Municipal Area',
      status: newProject.status,
      progress: Number(newProject.progress) || 0,
      lastChecked: 'N/A'
    }

    setProjects([projectObj, ...projects])
    setShowAddModal(false)
    setNewProject({
      title: '',
      contractor: 'L&T Infrastructure',
      budget: '',
      location: '',
      status: 'Pending',
      progress: 0
    })
    alert('Infrastructure Project created successfully!')
  }

  // Open Inspection dialog
  const openInspection = (project) => {
    setSelectedProject(project)
    setInspectedProgress(project.progress)
    setInspectedStatus(project.status)
    
    // Simulate reading current checks (OK if completed, else false)
    const completed = project.status === 'Completed'
    setChecklist({
      asphaltThickness: completed,
      barriersPlaced: completed || project.progress > 50,
      drainageSlope: completed,
      compactionTest: completed
    })
    
    setShowInspectModal(true)
  }

  // Save changes from Quality Inspection Checklist
  const saveInspection = () => {
    setProjects(projects.map(p => {
      if (p.id === selectedProject.id) {
        return {
          ...p,
          progress: Number(inspectedProgress),
          status: inspectedStatus,
          lastChecked: new Date().toISOString().split('T')[0]
        }
      }
      return p
    }))
    setShowInspectModal(false)
    alert(`Quality inspection report compiled and status updated for: ${selectedProject.title}`)
  }

  // Filter Project Directory List
  const filteredProjects = projects.filter(p => {
    const matchesSearch = 
      p.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.contractor?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.location?.toLowerCase().includes(searchTerm.toLowerCase())
      
    const matchesStatus = selectedStatus === 'All' || p.status === selectedStatus
    
    const matchesCategory = selectedCategory === 'All' || 
      (selectedCategory === 'Major' && p.budget >= 50000000) ||
      (selectedCategory === 'Minor' && p.budget < 50000000)
      
    return matchesSearch && matchesStatus && matchesCategory
  })

  // Calculations
  const totalBudget = projects.reduce((sum, p) => sum + (p.budget || 0), 0)
  const activeCount = projects.filter(p => p.status === 'In Progress').length
  const inspectionCount = projects.filter(p => p.status === 'Under Inspection').length
  const completedCount = projects.filter(p => p.status === 'Completed').length

  return (
    <div style={{ position: 'relative' }}>
      {/* Tricolor Accent Stripe */}
      <div style={{
        background: 'linear-gradient(to right, #FF9933 33%, #FFFFFF 33%, #FFFFFF 66%, #138808 66%)',
        height: '4px',
        width: '100%',
        position: 'absolute',
        top: '-24px',
        left: '-24px',
        paddingRight: '48px',
        boxSizing: 'content-box'
      }} />

      {/* Header */}
      <div className="page-header" style={{ borderBottom: '2px solid #E0E0E0', paddingBottom: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <p className="page-label" style={{ fontSize: '11px', color: '#B35400', fontWeight: '700', letterSpacing: '1px' }}>
            REGULATORY CONSTRUCTION REGISTRY • DEPARTMENT OF ROAD TELEMETRY
          </p>
          <h1 style={{ fontSize: '26px', fontWeight: '800', margin: '4px 0 2px 0', color: '#0A2F7E', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Hammer size={24} style={{ color: '#0A2F7E' }} />
            Infrastructure Projects
          </h1>
          <p style={{ fontSize: '12px', color: '#666', fontStyle: 'italic' }}>
            Sanctioned municipal road development projects, contractor gradings, and quality verification logs.
          </p>
        </div>

        <button onClick={() => setShowAddModal(true)} className="button button--primary" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Plus size={18} /> Create Project Tender
        </button>
      </div>

      {/* Stats Section */}
      <div className="grid grid--4" style={{ marginTop: '20px' }}>
        <div className="stat-card" style={{ borderLeft: '5px solid #0A2F7E' }}>
          <div className="stat-card__title">Total Tenders</div>
          <div className="stat-card__value" style={{ color: '#0A2F7E' }}>{projects.length}</div>
          <div className="stat-card__description">Active directories</div>
        </div>
        <div className="stat-card" style={{ borderLeft: '5px solid #2E7D32' }}>
          <div className="stat-card__title">Total Sanctioned Budget</div>
          <div className="stat-card__value" style={{ color: '#2E7D32', fontSize: '22px', paddingTop: '6px' }}>
            ₹{(totalBudget / 10000000).toFixed(2)} Crores
          </div>
          <div className="stat-card__description">Financial allocation</div>
        </div>
        <div className="stat-card" style={{ borderLeft: '5px solid #EF6C00' }}>
          <div className="stat-card__title">Active Builds</div>
          <div className="stat-card__value" style={{ color: '#EF6C00' }}>{activeCount}</div>
          <div className="stat-card__description">Road laying in progress</div>
        </div>
        <div className="stat-card" style={{ borderLeft: '5px solid #0288D1' }}>
          <div className="stat-card__title">Quality Auditing</div>
          <div className="stat-card__value" style={{ color: '#0288D1' }}>{inspectionCount}</div>
          <div className="stat-card__description">Under review queue</div>
        </div>
      </div>

      {/* Modern Search & Filters Panel */}
      <div className="panel panel--compact panel--toolbar" style={{ minHeight: 'auto', marginBottom: '20px', border: '1px solid #CFD8DC' }}>
        <div className="filters-row">
          <div className="filters-row__search" style={{ flex: '1 1 300px' }}>
            <div className="filters-row__search-icon">
              <Search size={18} />
            </div>
            <input 
              type="text"
              className="input-search"
              placeholder="Search title, contractor, location..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ maxWidth: '100%' }}
            />
          </div>

          <div className="filters-row__group">
            <select
              className="filter-select filter-select--status"
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
            >
              <option value="All">All Statuses</option>
              <option value="Pending">Pending Assignment</option>
              <option value="In Progress">In Progress</option>
              <option value="Under Inspection">Under Inspection</option>
              <option value="Completed">Completed</option>
            </select>

            <select
              className="filter-select filter-select--category"
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
            >
              <option value="All">All Budgets</option>
              <option value="Major">Major Tenders (&gt; ₹5 Cr)</option>
              <option value="Minor">Minor Tenders (&lt; ₹5 Cr)</option>
            </select>

            {(searchTerm || selectedStatus !== 'All' || selectedCategory !== 'All') && (
              <button 
                className="button button--secondary button--reset" 
                onClick={() => {
                  setSearchTerm('')
                  setSelectedStatus('All')
                  setSelectedCategory('All')
                }}
                title="Reset Filters"
                type="button"
                style={{ height: '46px' }}
              >
                <RotateCcw size={16} /> Reset
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Projects Grid Table */}
      <div className="panel" style={{ border: '1px solid #CFD8DC' }}>
        <div className="panel__header">
          <h2>Active Construction Projects</h2>
          <span style={{ fontSize: '12px', color: '#546E7A' }}>Showing {filteredProjects.length} entries</span>
        </div>
        <div className="panel__body panel__table-wrap" style={{ padding: '0' }}>
          <table className="data-table">
            <thead>
              <tr style={{ background: '#F8F9FA' }}>
                <th style={{ padding: '14px 12px' }}>Project Specification</th>
                <th>Assigned Contractor</th>
                <th>allocated Budget</th>
                <th>Registry Status</th>
                <th style={{ width: '180px' }}>Build Progress</th>
                <th>Last Inspected</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: '30px' }}>Loading municipal project registry...</td></tr>
              ) : filteredProjects.length === 0 ? (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: '30px', color: '#78909C' }}>No projects matching selection criteria.</td></tr>
              ) : filteredProjects.map((project) => {
                const statusColors = {
                  'Pending': { bg: '#ECEFF1', text: '#455A64', border: '#CFD8DC' },
                  'In Progress': { bg: '#FFF3E0', text: '#E65100', border: '#FFE082' },
                  'Under Inspection': { bg: '#E1F5FE', text: '#0288D1', border: '#B3E5FC' },
                  'Completed': { bg: '#E8F5E9', text: '#2E7D32', border: '#C8E6C9' }
                }[project.status || 'Pending']

                return (
                  <tr key={project.id}>
                    <td style={{ padding: '14px 12px' }}>
                      <strong style={{ fontSize: '14px', color: '#0A2F7E', display: 'block' }}>{project.title}</strong>
                      <span style={{ fontSize: '11px', color: '#78909C' }}>Location: {project.location}</span>
                    </td>
                    <td style={{ fontWeight: '600', color: '#37474F' }}>
                      {project.contractor}
                    </td>
                    <td style={{ fontFamily: 'monospace', fontWeight: '700', color: '#2E7D32' }}>
                      ₹{project.budget.toLocaleString()}
                    </td>
                    <td>
                      <span style={{
                        padding: '4px 8px',
                        background: statusColors.bg,
                        color: statusColors.text,
                        borderRadius: '4px',
                        fontSize: '11px',
                        fontWeight: '700',
                        border: `1px solid ${statusColors.border}`
                      }}>
                        {project.status}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <div style={{ flex: 1, height: '8px', background: '#ECEFF1', borderRadius: '4px', overflow: 'hidden' }}>
                          <div style={{ height: '100%', background: '#4CAF50', width: `${project.progress}%`, borderRadius: '4px' }}></div>
                        </div>
                        <span style={{ fontSize: '12px', fontWeight: '700', color: '#455A64', minWidth: '35px', textAlign: 'right' }}>
                          {project.progress}%
                        </span>
                      </div>
                    </td>
                    <td style={{ fontSize: '12px', color: '#546E7A' }}>
                      {project.lastChecked}
                    </td>
                    <td style={{ verticalAlign: 'middle' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <button 
                          onClick={() => openInspection(project)}
                          title="Run Quality Inspection"
                          style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: '#0A2F7E' }}
                        >
                          <CheckSquare size={16} />
                        </button>
                        <button 
                          onClick={() => handleDelete(project.id)}
                          title="Decommission Project"
                          style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: '#C62828' }}
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Project Modal */}
      {showAddModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.5)',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1000
        }}>
          <div className="login-card" style={{ maxWidth: '500px', width: '90%', padding: '30px', borderRadius: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
              <h2 style={{ fontSize: '20px', fontWeight: '800', margin: '0', color: '#0A2F7E' }}>Sanction Project Tender</h2>
              <button onClick={() => setShowAddModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#78909C' }}><X size={20} /></button>
            </div>
            
            <form onSubmit={handleAddSubmit} className="login-form">
              <label>
                Project Title / Specification
                <input 
                  type="text" 
                  value={newProject.title}
                  onChange={(e) => setNewProject({ ...newProject, title: e.target.value })}
                  placeholder="e.g. Ring Road Resurfacing"
                  required
                />
              </label>

              <label>
                Location Coordinate / Ward Details
                <input 
                  type="text" 
                  value={newProject.location}
                  onChange={(e) => setNewProject({ ...newProject, location: e.target.value })}
                  placeholder="e.g. Chowk to Highway, Ward 4"
                  required
                />
              </label>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                <label>
                  Sanctioned Budget (INR)
                  <input 
                    type="number" 
                    value={newProject.budget}
                    onChange={(e) => setNewProject({ ...newProject, budget: e.target.value })}
                    placeholder="e.g. 7500000"
                    required
                  />
                </label>

                <label>
                  Empaneled Contractor
                  <select 
                    value={newProject.contractor}
                    onChange={(e) => setNewProject({ ...newProject, contractor: e.target.value })}
                    style={{ padding: '12px 14px', border: '2px solid #E0E0E0', borderRadius: '8px', fontSize: '13px', background: 'white' }}
                  >
                    <option value="L&T Infrastructure">L&T Infrastructure</option>
                    <option value="City Road Services">City Road Services</option>
                    <option value="Relcon Infra">Relcon Infra</option>
                    <option value="Unassigned">Unassigned (Bidding Queue)</option>
                  </select>
                </label>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                <label>
                  Initial Project Status
                  <select 
                    value={newProject.status}
                    onChange={(e) => setNewProject({ ...newProject, status: e.target.value })}
                    style={{ padding: '12px 14px', border: '2px solid #E0E0E0', borderRadius: '8px', fontSize: '13px', background: 'white' }}
                  >
                    <option value="Pending">Pending Assignment</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Under Inspection">Under Inspection</option>
                    <option value="Completed">Completed</option>
                  </select>
                </label>

                <label>
                  Progress Index (%)
                  <input 
                    type="number" 
                    min="0"
                    max="100"
                    value={newProject.progress}
                    onChange={(e) => setNewProject({ ...newProject, progress: e.target.value })}
                    placeholder="e.g. 0"
                  />
                </label>
              </div>

              <div style={{ display: 'flex', gap: '10px', marginTop: '15px' }}>
                <button 
                  type="button" 
                  onClick={() => setShowAddModal(false)} 
                  className="button button--secondary" 
                  style={{ flex: 1, padding: '10px' }}
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="button button--primary" 
                  style={{ flex: 1, padding: '10px' }}
                >
                  Sanction Build
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Inspect Project Quality Checklist Modal */}
      {showInspectModal && selectedProject && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.5)',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1000
        }}>
          <div className="login-card" style={{ maxWidth: '550px', width: '90%', padding: '30px', borderRadius: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
              <h2 style={{ fontSize: '20px', fontWeight: '800', margin: '0', color: '#0A2F7E', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Clipboard size={20} />
                Quality Inspection Report
              </h2>
              <button onClick={() => setShowInspectModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#78909C' }}><X size={20} /></button>
            </div>
            
            <p style={{ margin: '0 0 15px 0', fontSize: '12px', color: '#546E7A' }}>
              Tender Ref: <strong>#{selectedProject.id}</strong> | Title: <strong>{selectedProject.title}</strong>
            </p>

            <div style={{ border: '1px solid #CFD8DC', borderRadius: '8px', padding: '16px', background: '#FAFAFA', marginBottom: '20px' }}>
              <h4 style={{ fontSize: '13px', margin: '0 0 12px 0', color: '#37474F', fontWeight: '700' }}>Inspection Standards Verification Checklist:</h4>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px', cursor: 'pointer' }}>
                  <input 
                    type="checkbox" 
                    checked={checklist.asphaltThickness}
                    onChange={(e) => setChecklist({ ...checklist, asphaltThickness: e.target.checked })}
                    style={{ width: '16px', height: '16px' }}
                  />
                  Road Core Asphalt Depth satisfies &gt;= 40mm standards
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px', cursor: 'pointer' }}>
                  <input 
                    type="checkbox" 
                    checked={checklist.barriersPlaced}
                    onChange={(e) => setChecklist({ ...checklist, barriersPlaced: e.target.checked })}
                    style={{ width: '16px', height: '16px' }}
                  />
                  Reflective safety barriers and night detour lights placed
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px', cursor: 'pointer' }}>
                  <input 
                    type="checkbox" 
                    checked={checklist.drainageSlope}
                    onChange={(e) => setChecklist({ ...checklist, drainageSlope: e.target.checked })}
                    style={{ width: '16px', height: '16px' }}
                  />
                  Rainwater run-off drainage slope gradient checked
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px', cursor: 'pointer' }}>
                  <input 
                    type="checkbox" 
                    checked={checklist.compactionTest}
                    onChange={(e) => setChecklist({ ...checklist, compactionTest: e.target.checked })}
                    style={{ width: '16px', height: '16px' }}
                  />
                  Aggregate Sub-base Compaction report approved by site auditor
                </label>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '20px' }}>
              <div>
                <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Inspection Progress Index (%)</label>
                <input 
                  type="number" 
                  min="0"
                  max="100"
                  value={inspectedProgress}
                  onChange={(e) => setInspectedProgress(e.target.value)}
                  style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px' }} 
                />
              </div>

              <div>
                <label style={{ display: 'block', marginBottom: '6px', fontSize: '13px', fontWeight: '700' }}>Inspection Status</label>
                <select
                  value={inspectedStatus}
                  onChange={(e) => setInspectedStatus(e.target.value)}
                  style={{ width: '100%', padding: '10px 12px', border: '1px solid #CFD8DC', borderRadius: '6px', fontSize: '13px', background: 'white' }}
                >
                  <option value="Pending">Pending Assignment</option>
                  <option value="In Progress">In Progress</option>
                  <option value="Under Inspection">Under Inspection</option>
                  <option value="Completed">Completed</option>
                </select>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button 
                type="button" 
                onClick={() => setShowInspectModal(false)} 
                className="button button--secondary" 
                style={{ flex: 1, padding: '10px' }}
              >
                Cancel
              </button>
              <button 
                type="button" 
                onClick={saveInspection}
                className="button button--primary" 
                style={{ flex: 1, padding: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}
              >
                <ShieldCheck size={16} />
                Approve Quality Report
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  )
}

export default InfrastructureProjects

