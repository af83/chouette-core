import '../../helpers/polyfills'

import React from 'react'
import { render } from 'react-dom'
import { Provider } from 'react-redux'
import { createStore } from 'redux'
import applyMiddleware from '../../helpers/middlewares'

import vehicleJourneysApp from '../../vehicle_journeys/reducers'
import App from '../../vehicle_journeys/components/App'
import { enableBatching } from '../../vehicle_journeys/batch'

import { initialState } from '../../vehicle_journeys/reducers'

let store = createStore(
  enableBatching(vehicleJourneysApp),
  initialState,
  applyMiddleware()
)

render(
  <Provider store={store}>
    <App returnRouteUrl={window.returnRouteUrl} />
  </Provider>,
  document.getElementById('vehicle_journeys_wip')
)
