import { renderToString } from 'react-dom/server'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import App from './App'

describe('App', () => {
  it('renders the onboarding heading', () => {
    expect(renderToString(
      <MemoryRouter>
        <App />
      </MemoryRouter>,
    )).toContain('Selamat Datang di Yomu')
  })
})
