import { useState, useEffect, useRef } from 'react'
import { useAuth } from '../context/AuthContext'
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import { Locate } from 'lucide-react'

// Custom marker icons
const complaintIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
})

const activeIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [30, 49], iconAnchor: [15, 49], popupAnchor: [1, -40], shadowSize: [41, 41]
})

const userIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
})

// Subcomponent to fly the map to a new center
function MapController({ center, zoom }) {
  const map = useMap()
  useEffect(() => {
    if (center) {
      map.flyTo(center, zoom || 15, { animate: true, duration: 1.5 })
    }
  }, [center, zoom, map])
  return null
}

function parseCoordinates(item) {
  if (!item) return null
  if (item.location && typeof item.location === 'object') {
    if (typeof item.location.lat === 'number' && typeof item.location.lng === 'number') {
      return [item.location.lat, item.location.lng]
    }
  }
  if (item.location && typeof item.location === 'string') {
    try {
      const loc = JSON.parse(item.location)
      if (loc.lat && loc.lng) return [parseFloat(loc.lat), parseFloat(loc.lng)]
    } catch (e) { /* skip */ }
  }
  return null
}

function formatLocation(location) {
  if (!location) return 'N/A'
  if (typeof location === 'string') return location
  if (typeof location === 'object') {
    return location.address || location.area || `${location.lat || ''}, ${location.lng || ''}` || 'N/A'
  }
  return String(location)
}

function LiveTracking() {
  const { user } = useAuth()
  const [complaints, setComplaints] = useState([])
  const [loading, setLoading] = useState(true)
  const defaultCenter = [22.3072, 70.7654]
  const [mapCenter, setMapCenter] = useState(defaultCenter)
  const [mapZoom, setMapZoom] = useState(13)
  const [activeItemId, setActiveItemId] = useState(null)
  const [userLocation, setUserLocation] = useState(null)
  const markerRefs = useRef({})

  useEffect(() => {
    const fetchMapData = async () => {
      try {
        setLoading(true)
        const headers = {}
        if (user?.token) headers['Authorization'] = `Bearer ${user.token}`

        const res = await fetch('/api/complaints', { headers })
        if (res.ok) {
          const data = await res.json()
          setComplaints(data)
        }
      } catch (error) {
        console.error('Error fetching map data:', error)
      } finally {
        setLoading(false)
      }
    }
    fetchMapData()
  }, [user])

  // Auto-locate on mount
  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const coords = [pos.coords.latitude, pos.coords.longitude]
          setUserLocation(coords)
          setMapCenter(coords)
          setMapZoom(13)
        },
        () => { /* denied – use default */ }
      )
    }
  }, [])

  const handleItemClick = (item) => {
    const coords = parseCoordinates(item)
    if (coords) {
      setMapCenter(coords)
      setMapZoom(16)
      setActiveItemId(item.id)
      // Auto-open the marker popup after the map flies there
      setTimeout(() => {
        const marker = markerRefs.current[item.id]
        if (marker) {
          marker.openPopup()
        }
      }, 1600) // Wait for flyTo animation to complete
    }
  }

  const handleLocateMe = () => {
    if (!navigator.geolocation) return alert('Geolocation not supported.')
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const coords = [pos.coords.latitude, pos.coords.longitude]
        setUserLocation(coords)
        setMapCenter(coords)
        setMapZoom(15)
        setActiveItemId(null)
      },
      () => alert('Unable to retrieve your location.')
    )
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <p className="page-label">Operations</p>
          <h1>Live City Tracking</h1>
        </div>
        <button className="button button--secondary" onClick={handleLocateMe} type="button">
          <Locate size={18} /> Locate Me
        </button>
      </div>

      <div className="panel" style={{ padding: 0, overflow: 'hidden' }}>
        <div className="map-split-container">
          {/* Sidebar List */}
          <div className="map-sidebar">
            <h2 className="map-sidebar__title">
              Map Locations
              <span style={{ background: '#9C27B0', color: '#fff', borderRadius: '999px', padding: '2px 10px', fontSize: '0.85rem', fontWeight: 700 }}>
                {complaints.length}
              </span>
            </h2>
            <div className="map-sidebar-list">
              {loading ? (
                <p style={{ color: '#999' }}>Loading locations...</p>
              ) : complaints.length === 0 ? (
                <p style={{ color: '#999' }}>No map locations to display.</p>
              ) : (
                complaints.map((item) => {
                  const coords = parseCoordinates(item)
                  const isActive = activeItemId === item.id
                  return (
                    <button
                      key={item.id}
                      className={`map-sidebar-item ${isActive ? 'map-sidebar-item--active' : ''}`}
                      onClick={() => handleItemClick(item)}
                      disabled={!coords}
                      type="button"
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%' }}>
                        <span className="map-sidebar-item__id">{item.id?.substring(0, 8)}...</span>
                        <span style={{ background: 'rgba(220,38,38,0.12)', color: '#b91c1c', fontSize: '0.75rem', padding: '2px 6px', borderRadius: '999px', fontWeight: 600 }}>
                          Complaint
                        </span>
                      </div>
                      <p className="map-sidebar-item__title">{item.title || item.category || 'Complaint'}</p>
                      <span className="map-sidebar-item__meta">📍 {formatLocation(item.location)}</span>
                      <span className="map-sidebar-item__meta">
                        Status: <strong style={{ color: '#9C27B0' }}>{(item.status || 'active').replace('_', ' ')}</strong>
                      </span>
                    </button>
                  )
                })
              )}
            </div>
          </div>

          {/* Interactive Map */}
          <div style={{ flex: 1, position: 'relative' }}>
            {loading ? (
              <p style={{ padding: '24px' }}>Loading map...</p>
            ) : (
              <MapContainer center={defaultCenter} zoom={13} style={{ height: '100%', minHeight: '600px', width: '100%' }}>
                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="&copy; OpenStreetMap contributors" />
                <MapController center={mapCenter} zoom={mapZoom} />

                {/* User Location Marker */}
                {userLocation && (
                  <Marker position={userLocation} icon={userIcon}>
                    <Popup>
                      <div style={{ padding: '4px', minWidth: '130px' }}>
                        <span style={{ background: 'rgba(76,175,80,0.12)', color: '#2E7D32', fontSize: '0.75rem', padding: '2px 8px', borderRadius: '999px', fontWeight: 600 }}>Your Location</span>
                        <h4 style={{ margin: '6px 0 2px', fontSize: '1rem', fontWeight: 700 }}>You Are Here</h4>
                        <p style={{ margin: 0, fontSize: '0.85rem', color: '#666' }}>
                          Lat: {userLocation[0].toFixed(4)}<br/>Lng: {userLocation[1].toFixed(4)}
                        </p>
                      </div>
                    </Popup>
                  </Marker>
                )}

                {/* Complaint Markers */}
                {complaints.map((c) => {
                  const position = parseCoordinates(c)
                  if (!position) return null
                    return (
                    <Marker key={c.id} position={position} icon={activeItemId === c.id ? activeIcon : complaintIcon}
                      ref={(ref) => { if (ref) markerRefs.current[c.id] = ref }}
                    >
                      <Popup>
                        <div style={{ padding: '4px', minWidth: '150px' }}>
                          <span style={{ background: 'rgba(220,38,38,0.12)', color: '#b91c1c', fontSize: '0.75rem', padding: '2px 8px', borderRadius: '999px', fontWeight: 600, display: 'inline-block', marginBottom: '6px' }}>
                            Complaint
                          </span>
                          <h4 style={{ margin: '4px 0', fontSize: '1rem', fontWeight: 700 }}>{c.title}</h4>
                          <p style={{ margin: '2px 0', fontSize: '0.85rem' }}>📍 {formatLocation(c.location)}</p>
                          <p style={{ margin: '2px 0', fontSize: '0.85rem' }}>Category: {c.category || 'General'}</p>
                          <p style={{ margin: '4px 0 0', fontSize: '0.85rem' }}>
                            <strong>Status:</strong> {(c.status || '').replace('_', ' ')}
                          </p>
                        </div>
                      </Popup>
                    </Marker>
                  )
                })}
              </MapContainer>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default LiveTracking
