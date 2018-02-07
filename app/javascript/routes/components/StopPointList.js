import React from 'react'
import PropTypes from 'prop-types'

import StopPoint from './StopPoint'

export default function StopPointList({ stopPoints, onDeleteClick, onMoveUpClick, onMoveDownClick, onChange, onSelectChange, onToggleMap, onToggleEdit, onSelectMarker, onUnselectMarker, onUpdateViaOlMap }, {I18n}) {
  return (
    <div className='subform'>
      <div className='nested-head'>
        <div className="wrapper">
          <div style={{width: 100}}>
            <div className="form-group">
              <label className="control-label">{I18n.reflex_id}</label>
            </div>
          </div>
          <div>
            <div className="form-group">
              <label className="control-label">{I18n.simple_form.labels.stop_point.name}</label>
            </div>
          </div>
          <div>
            <div className="form-group">
              <label className="control-label">{I18n.simple_form.labels.stop_point.for_boarding}</label>
            </div>
          </div>
          <div>
            <div className="form-group">
              <label className="control-label">{I18n.simple_form.labels.stop_point.for_alighting}</label>
            </div>
          </div>
          <div className='actions-5'></div>
        </div>
      </div>
      {stopPoints.map((stopPoint, index) =>
        <StopPoint
          key={'item-' + index}
          onDeleteClick={() => onDeleteClick(index)}
          onMoveUpClick={() => {
            onMoveUpClick(index)
          }}
          onMoveDownClick={() => onMoveDownClick(index)}
          onChange={ onChange }
          onSelectChange={ (e) => onSelectChange(e, index) }
          onToggleMap={() => onToggleMap(index)}
          onToggleEdit={() => onToggleEdit(index)}
          onSelectMarker={onSelectMarker}
          onUnselectMarker={onUnselectMarker}
          onUpdateViaOlMap={onUpdateViaOlMap}
          first={ index === 0 }
          last={ index === (stopPoints.length - 1) }
          index={ index }
          value={ stopPoint }
        />
      )}
    </div>
  )
}

StopPointList.propTypes = {
  stopPoints: PropTypes.array.isRequired,
  onDeleteClick: PropTypes.func.isRequired,
  onMoveUpClick: PropTypes.func.isRequired,
  onMoveDownClick: PropTypes.func.isRequired,
  onSelectChange: PropTypes.func.isRequired,
  onSelectMarker: PropTypes.func.isRequired,
  onUnselectMarker : PropTypes.func.isRequired
}

StopPointList.contextTypes = {
  I18n: PropTypes.object
}
