export const API_BASE = import.meta.env.VITE_API_BASE || '/api'

export async function apiFetch(path, options = {}) {
  const tokenData = localStorage.getItem('admin_user')
  const token = tokenData ? JSON.parse(tokenData).token : null
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  }

  if (token) {
    headers.Authorization = `Bearer ${token}`
  }

  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  })

  const text = await response.text()
  let json = null
  try {
    json = text ? JSON.parse(text) : null
  } catch (error) {
    throw new Error(`Invalid JSON response: ${text}`)
  }

  if (!response.ok) {
    throw new Error(json?.message || response.statusText || 'Request failed')
  }

  return json
}
