import React, { PropTypes, Component } from 'react'
import actions from '../../actions'
import _ from 'lodash'

export default class NotesEditVehicleJourney extends Component {
  constructor(props) {
    super(props)
  }

  handleSubmit() {
    this.props.onNotesEditVehicleJourney(this.props.modal.modalProps.vehicleJourney.footnotes)
    this.props.onModalClose()
    $('#NotesEditVehicleJourneyModal').modal('hide')
  }

  footnotes() {
    let { footnotes } = this.props.modal.modalProps.vehicleJourney
    let fnIds = footnotes.map(fn => fn.id)
    return {
      associated: footnotes,
      to_associate: window.line_footnotes.filter(fn => !fnIds.includes(fn.id)) 
    }
  }

  renderFootnoteButton(lf) {
    if (!this.props.editMode) return false

    if (this.footnotes().associated.includes(lf)) {
      return <button
        type='button'
        className='btn btn-outline-danger btn-xs'
        onClick={() => this.props.onToggleFootnoteModal(lf, false)}
      ><span className="fa fa-trash"></span> Retirer</button>
    } else {
      return <button
        type='button'
        className='btn btn-outline-primary btn-xs'
        onClick={() => this.props.onToggleFootnoteModal(lf, true)}
      ><span className="fa fa-plus"></span> Ajouter</button>
    }
  }

  renderAssociatedFN() {
    if (this.footnotes().associated.length == 0) {
      return <h3>Aucune note associée</h3>
    } else {
      return (
        <div>
          <h3>Notes associées :</h3>
          {this.footnotes().associated.map((lf, i) =>
            <div
              key={i}
              className='panel panel-default'
            >
              <div className='panel-heading'>
                <h4 className='panel-title clearfix'>
                  <div className='pull-left' style={{ paddingTop: '3px' }}>{lf.code}</div>
                  <div className='pull-right'>{this.renderFootnoteButton(lf, this.props.modal.modalProps.vehicleJourney.footnotes)}</div>
                </h4>
              </div>
              <div className='panel-body'><p>{lf.label}</p></div>
            </div>
          )}
        </div>
      )
    }
  }

  renderToAssociateFN() {
    if (window.line_footnotes.length == 0) return <h3>La ligne ne possède pas de notes</h3>

    if (this.footnotes().to_associate.length == 0) return false
    
    return (
      <div>
        <h3 className='mt-lg'>Sélectionnez les notes à associer à cette course :</h3>
        {this.footnotes().to_associate.map((lf, i) =>
          <div key={i} className='panel panel-default'>
            <div className='panel-heading'>
              <h4 className='panel-title clearfix'>
                <div className='pull-left' style={{ paddingTop: '3px' }}>{lf.code}</div>
                <div className='pull-right'>{this.renderFootnoteButton(lf)}</div>
              </h4>
            </div>
            <div className='panel-body'><p>{lf.label}</p></div>
          </div>
        )}
      </div>
    ) 
  }

  render() {
    if (this.props.status.isFetching == true) return false

    if (this.props.status.fetchSuccess == true) {
      return (
        <li className='st_action'>
          <button
            type='button'
            disabled={(actions.getSelected(this.props.vehicleJourneys).length != 1 || this.props.disabled)}
            data-toggle='modal'
            data-target='#NotesEditVehicleJourneyModal'
            onClick={() => this.props.onOpenNotesEditModal(actions.getSelected(this.props.vehicleJourneys)[0])}
          >
            <span className='fa fa-sticky-note'></span>
          </button>

          <div className={ 'modal fade ' + ((this.props.modal.type == 'duplicate') ? 'in' : '') } id='NotesEditVehicleJourneyModal'>
            <div className='modal-container'>
              <div className='modal-dialog'>
                <div className='modal-content'>
                  <div className='modal-header'>
                    <h4 className='modal-title'>Notes</h4>
                    <span type="button" className="close modal-close" data-dismiss="modal">&times;</span>
                  </div>

                  {(this.props.modal.type == 'notes_edit') && (
                    <form>
                      <div className='modal-body'>
                        {this.renderAssociatedFN()}
                        {this.props.editMode && this.renderToAssociateFN()}
                      </div>
                      {
                        this.props.editMode &&
                        <div className='modal-footer'>
                          <button
                            className='btn btn-link'
                            data-dismiss='modal'
                            type='button'
                            onClick={this.props.onModalClose}
                          >
                            Annuler
                        </button>
                          <button
                            className='btn btn-primary'
                            type='button'
                            onClick={this.handleSubmit.bind(this)}
                          >
                            Valider
                        </button>
                        </div>
                      }
                    </form>
                  )}

                </div>
              </div>
            </div>
          </div>
        </li>
      )
    } else {
      return false
    }
  }
}

NotesEditVehicleJourney.propTypes = {
  onOpenNotesEditModal: PropTypes.func.isRequired,
  onModalClose: PropTypes.func.isRequired,
  onToggleFootnoteModal: PropTypes.func.isRequired,
  onNotesEditVehicleJourney: PropTypes.func.isRequired,
  disabled: PropTypes.bool.isRequired
}