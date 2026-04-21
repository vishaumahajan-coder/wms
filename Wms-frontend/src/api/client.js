/**
 * API base URL - sabhi pages yahi se API call karenge.
 */

// Dynamically detect current host to ensure API connection works on any network
const isLocalhost = Boolean(
  typeof window !== 'undefined' && (
    window.location.hostname === 'localhost' ||
    window.location.hostname === '[::1]' ||
    window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/)
  )
);

// We prioritize the environment variable, then fallback to automatic detection
export const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (isLocalhost 
    ? 'http://localhost:3001' 
    : 'https://wms-new-backend-production.up.railway.app');

/**
 * Auth token get karke headers return karta hai (Bearer token)
 */
export function getAuthHeaders(token) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  return headers;
}

/**
 * API request helper - auth header automatically add
 */
export async function apiRequest(path, options = {}, token = null) {
  // Normalize path
  let normalizedPath = path.startsWith('/') ? path : `/${path}`;
  
  // Strip trailing slash from base if present
  let base = API_BASE_URL.endsWith('/') ? API_BASE_URL.slice(0, -1) : API_BASE_URL;

  const url = normalizedPath.startsWith('http') ? normalizedPath : `${base}${normalizedPath}`;
  
  const headers = getAuthHeaders(token);
  if (options.headers) Object.assign(headers, options.headers);
  
  const res = await fetch(url, { ...options, headers });
  const data = await res.json().catch(() => ({}));
  
  if (!res.ok) {
    const err = new Error(data.message || data.error || `Request failed ${res.status}`);
    err.status = res.status;
    err.data = data;
    throw err;
  }
  
  if (data != null && typeof data === 'object' && 'data' in data) return data;
  return { data };
}

export default { API_BASE_URL, getAuthHeaders, apiRequest };
