import React, { Component } from 'react'
import PropTypes from 'prop-types'

export default function ConfirmModal({dispatch, modal, onModalAccept, onModalCancel, vehicleJourneys}) {
  return (
    <div className={'modal fade ' + ((modal.type == 'confirm') ? 'in' : '')} id='ConfirmModal'>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-body'>
            <p> {I18n.t('vehicle_journeys.vehicle_journeys_matrix.modal_confirm')} </p>
          </div>
          <div className='modal-footer'>
            <button
              className='btn btn-default'
              data-dismiss='modal'
              type='button'
              onClick={() => { onModalCancel(modal.confirmModal.callback) }}
            >
              Ne pas valider
          </button>
            <button
              className='btn btn-danger'
              data-dismiss='modal'
              type='button'
              onClick={() => { onModalAccept(modal.confirmModal.callback, vehicleJourneys) }}
            >
              Valider
          </button>
          </div>
        </div>
      </div>
    </div>
  )
}

ConfirmModal.propTypes = {
  vehicleJourneys: PropTypes.array.isRequired,
  modal: PropTypes.object.isRequired,
  onModalAccept: PropTypes.func.isRequired,
  onModalCancel: PropTypes.func.isRequired
}
