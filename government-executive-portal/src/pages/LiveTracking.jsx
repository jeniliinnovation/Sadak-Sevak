import { useState, useEffect } from 'react'
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import { useLiveTracking, useComplaints } from '../hooks/useApi'
import { Locate } from 'lucide-react'

// Define custom marker icons
const complaintIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
})

const trackingIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
})

const userIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
})

// Subcomponent to control map view (fly to center when it changes)
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
  // 1. Direct lat/lng check
  if (typeof item.lat === 'number' && typeof item.lng === 'number') {
    return [item.lat, item.lng]
  }
  if (typeof item.latitude === 'number' && typeof item.longitude === 'number') {
    return [item.latitude, item.longitude]
  }
  // 2. coordinates object
  if (item.coordinates && typeof item.coordinates.lat === 'number' && typeof item.coordinates.lng === 'number') {
    return [item.coordinates.lat, item.coordinates.lng]
  }
  // 3. location object lat/lng
  if (item.location && typeof item.location === 'object') {
    if (typeof item.location.lat === 'number' && typeof item.location.lng === 'number') {
      return [item.location.lat, item.location.lng]
    }
  }
  // 4. coordinates array
  if (Array.isArray(item.coordinates) && item.coordinates.length === 2) {
    return [Number(item.coordinates[0]), Number(item.coordinates[1])]
  }
  // 5. position array
  if (Array.isArray(item.position) && item.position.length === 2) {
    return [Number(item.position[0]), Number(item.position[1])]
  }
  return null
}

function formatLocation(location) {
  if (!location) return 'N/A'
  if (typeof location === 'string') return location
  if (typeof location === 'object') {
    return location.address || location.area || `${location.lat || ''}${location.lat && location.lng ? ', ' : ''}${location.lng || ''}` || JSON.stringify(location)
  }
  return String(location)
}

function LiveTracking() {
  const { data: liveTrackingData, loading: trackingLoading, error: trackingError } = useLiveTracking()
  const { data: complaintsData, loading: complaintsLoading, error: complaintsError } = useComplaints()

  const defaultCenter = [22.3072, 70.7654]
  const [mapCenter, setMapCenter] = useState(defaultCenter)
  const [mapZoom, setMapZoom] = useState(13)
  const [activeItemId, setActiveItemId] = useState(null)
  const [userLocation, setUserLocation] = useState(null)

  const trackingItems = liveTrackingData || []
  const complaintsItems = complaintsData || []

  // Combine live tracking events and complaints
  const allMapItems = [
    ...trackingItems.map(item => ({ 
      ...item, 
      isComplaint: false,
      type: item.type || item.category || 'Live Event'
    })),
    ...complaintsItems.map(item => ({ 
      ...item, 
      isComplaint: true,
      type: item.title || item.category || 'Complaint'
    }))
  ]

  // Automatically fetch user's real location on mount
  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const coords = [pos.coords.latitude, pos.coords.longitude]
          setUserLocation(coords)
          setMapCenter(coords)
          setMapZoom(15)
        },
        (err) => {
          console.warn('Geolocation not allowed or failed on initial load:', err)
        }
      )
    }
  }, [])

  const handleItemClick = (item) => {
    const coords = parseCoordinates(item)
    if (coords) {
      setMapCenter(coords)
      setMapZoom(16)
      setActiveItemId(item.id)
    }
  }

  const handleLocateMe = () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser.')
      return
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const coords = [pos.coords.latitude, pos.coords.longitude]
        setUserLocation(coords)
        setMapCenter(coords)
        setMapZoom(15)
        setActiveItemId(null)
      },
      () => {
        alert('Unable to retrieve your location.')
      }
    )
  }

  const loading = trackingLoading || complaintsLoading
  const error = trackingError || complaintsError

  return (
    <div className="page-shell">
      <div className="page-header">
        <h1>Live City Tracking</h1>
        <button 
          className="button button--secondary" 
          onClick={handleLocateMe}
          title="Locate Current Position"
          type="button"
        >
          <Locate size={18} /> Locate Me
        </button>
      </div>
      
      {error && <div className="error-message">{error}</div>}

      <div className="panel panel--full" style={{ padding: 0 }}>
        <div className="map-split-container">
          {/* Sidebar List of Locations */}
          <div className="map-sidebar">
            <h2 className="map-sidebar__title">
              Map Locations
              <span className="badge badge--in-progress">{allMapItems.length}</span>
            </h2>
            <div className="map-sidebar-list">
              {loading ? (
                <p className="text-muted">Loading locations...</p>
              ) : allMapItems.length === 0 ? (
                <p className="text-muted">No map locations to display.</p>
              ) : (
                allMapItems.map((item) => {
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
                        <span className="map-sidebar-item__id">{item.id}</span>
                        <span className={`badge badge--${item.isComplaint ? 'rejected' : 'in-progress'}`} style={{ fontSize: '0.75rem', padding: '2px 6px' }}>
                          {item.isComplaint ? 'Complaint' : 'Live Item'}
                        </span>
                      </div>
                      <p className="map-sidebar-item__title">{item.type}</p>
                      <span className="map-sidebar-item__meta">
                        📍 {formatLocation(item.location)}
                      </span>
                      <span className="map-sidebar-item__meta">
                        Status: <strong style={{ color: 'var(--success)' }}>{item.status || 'Active'}</strong>
                      </span>
                    </button>
                  )
                })
              )}
            </div>
          </div>

          {/* Interactive Map View */}
          <div style={{ flex: 1, position: 'relative' }}>
            {loading ? (
              <p style={{ padding: '24px' }}>Loading map...</p>
            ) : (
              <MapContainer center={defaultCenter} zoom={13} className="map-container" style={{ height: '100%', minHeight: '600px' }}>
                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="&copy; OpenStreetMap contributors" />
                <MapController center={mapCenter} zoom={mapZoom} />
                
                {/* User Location Marker */}
                {userLocation && (
                  <Marker position={userLocation} icon={userIcon}>
                    <Popup>
                      <div style={{ padding: '4px', minWidth: '130px' }}>
                        <span className="badge badge--resolved" style={{ fontSize: '0.75rem', marginBottom: '6px' }}>Your Location</span>
                        <h4 style={{ margin: '4px 0', fontSize: '1rem', fontWeight: 700 }}>You Are Here</h4>
                        <p style={{ margin: '2px 0', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                          Lat: {userLocation[0].toFixed(4)}<br />Lng: {userLocation[1].toFixed(4)}
                        </p>
                      </div>
                    </Popup>
                  </Marker>
                )}

                {allMapItems.map((item) => {
                  const position = parseCoordinates(item)
                  if (!position) return null
                  return (
                    <Marker 
                      key={item.id} 
                      position={position}
                      icon={item.isComplaint ? complaintIcon : trackingIcon}
                    >
                      <Popup>
                        <div style={{ padding: '4px', minWidth: '150px' }}>
                          <span className={`badge badge--${item.isComplaint ? 'rejected' : 'in-progress'}`} style={{ marginBottom: '6px', fontSize: '0.75rem' }}>
                            {item.isComplaint ? 'Complaint' : 'Live Item'}
                          </span>
                          <span style={{ display: 'block', fontFamily: 'monospace', fontWeight: 700, color: 'var(--success)' }}>{item.id}</span>
                          <h4 style={{ margin: '4px 0', fontSize: '1rem', fontWeight: 700 }}>{item.type}</h4>
                          <p style={{ margin: '2px 0', fontSize: '0.85rem' }}>{formatLocation(item.location)}</p>
                          <p style={{ margin: '4px 0 0', fontSize: '0.85rem' }}>
                            <strong>Status:</strong> {item.status}
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
