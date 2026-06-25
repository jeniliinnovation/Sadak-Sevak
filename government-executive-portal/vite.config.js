import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://jenili.in',
        changeOrigin: true,
        secure: false,
        configure(proxy) {
          // Handle backend connection errors gracefully to avoid repeated stack traces
          proxy.on('error', (err, req, res) => {
            try {
              if (res && !res.headersSent) {
                res.writeHead && res.writeHead(502, { 'Content-Type': 'application/json' })
                res.end && res.end(JSON.stringify({ error: 'Backend unavailable' }))
              }
            } catch (e) {
              // swallow
            }
          })
        },
      },
    },
  },
})
