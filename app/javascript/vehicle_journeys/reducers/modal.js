import _ from 'lodash'

let vehicleJourneysModal, newModalProps, vehicleJourney

export default function modal(state = {}, action) {
  switch (action.type) {
    case 'OPEN_CONFIRM_MODAL':
      $('#ConfirmModal').modal('show')
      return _.assign({}, state, {
        type: 'confirm',
        confirmModal: {
          callback: action.callback,
        }
      })
    case 'EDIT_NOTES_VEHICLEJOURNEY_MODAL':
      let vehicleJourneyModal = _.assign({}, action.vehicleJourney)
      return {
        type: 'notes_edit',
        modalProps: {
          vehicleJourney: vehicleJourneyModal
        },
        confirmModal: {}
      }
    case 'TOGGLE_FOOTNOTE_MODAL':
      newModalProps = JSON.parse(JSON.stringify(state.modalProps))
      if (action.isShown){
        newModalProps.vehicleJourney.footnotes.push(action.footnote)
      }else{
        newModalProps.vehicleJourney.footnotes = newModalProps.vehicleJourney.footnotes.filter((f) => {return f.id != action.footnote.id })
      }
      return _.assign({}, state, {modalProps: newModalProps})
    case 'EDIT_VEHICLEJOURNEY_MODAL':
      return {
        type: 'edit',
        modalProps: {
          vehicleJourney: action.vehicleJourney
        },
        confirmModal: {}
      }
    case 'EDIT_CALENDARS_VEHICLEJOURNEY_MODAL':
      vehicleJourneysModal = JSON.parse(JSON.stringify(action.vehicleJourneys))
      let uniqTimetables = []
      vehicleJourneysModal.map((vj, i) => {
        vj.time_tables.map((tt, j) =>{
          if(!(_.find(uniqTimetables, tt))){
            uniqTimetables.push(tt)
          }
        })
      })
      return {
        type: 'calendars_edit',
        modalProps: {
          vehicleJourneys: vehicleJourneysModal,
          timetables: uniqTimetables
        },
        confirmModal: {}
      }
    case 'EDIT_PURCHASE_WINDOWS_VEHICLEJOURNEY_MODAL':
      var vehicleJourneys = JSON.parse(JSON.stringify(action.vehicleJourneys))
      let uniqPurchaseWindows = []
      vehicleJourneys.map((vj, i) => {
        vj.purchase_windows.map((pw, j) =>{
          if(!(_.find(uniqPurchaseWindows, pw))){
            uniqPurchaseWindows.push(pw)
          }
        })
      })
      return {
        type: 'purchase_windows_edit',
        modalProps: {
          vehicleJourneys: vehicleJourneys,
          purchase_windows: uniqPurchaseWindows
        },
        confirmModal: {}
      }
    case 'SELECT_CP_EDIT_MODAL':
      vehicleJourney =  _.assign({}, state.modalProps.vehicleJourney, {company: action.selectedItem})
      newModalProps = _.assign({}, state.modalProps, {vehicleJourney})
      return _.assign({}, state, {modalProps: newModalProps})
    case 'UNSELECT_CP_EDIT_MODAL':
      vehicleJourney =  _.assign({}, state.modalProps.vehicleJourney, {company: undefined})
      newModalProps = _.assign({}, state.modalProps, {vehicleJourney})
      return _.assign({}, state, {modalProps: newModalProps})
    case 'SELECT_TT_CALENDAR_MODAL':
      newModalProps = _.assign({}, state.modalProps, {selectedTimetable : action.selectedItem})
      return _.assign({}, state, {modalProps: newModalProps})
    case 'SELECT_PURCHASE_WINDOW_MODAL':
      newModalProps = _.assign({}, state.modalProps, {selectedPurchaseWindow : action.selectedItem})
      return _.assign({}, state, {modalProps: newModalProps})
    case 'ADD_SELECTED_TIMETABLE':
      if(state.modalProps.selectedTimetable){
        newModalProps = JSON.parse(JSON.stringify(state.modalProps))
        if (!_.find(newModalProps.timetables, newModalProps.selectedTimetable)){
          newModalProps.timetables.push(newModalProps.selectedTimetable)
        }
        return _.assign({}, state, {modalProps: newModalProps})
      }
    case 'ADD_SELECTED_PURCHASE_WINDOW':
      if(state.modalProps.selectedPurchaseWindow){
        newModalProps = JSON.parse(JSON.stringify(state.modalProps))
        if (!_.find(newModalProps.purchase_windows, newModalProps.selectedPurchaseWindow)){
          newModalProps.purchase_windows.push(newModalProps.selectedPurchaseWindow)
        }
        return _.assign({}, state, {modalProps: newModalProps})
      }
    case 'DELETE_CALENDAR_MODAL':
      newModalProps = JSON.parse(JSON.stringify(state.modalProps))
      let timetablesModal = state.modalProps.timetables.slice(0)
      timetablesModal.map((tt, i) =>{
        if(tt == action.timetable){
          timetablesModal.splice(i, 1)
        }
      })
      vehicleJourneysModal = state.modalProps.vehicleJourneys.slice(0)
      vehicleJourneysModal.map((vj) =>{
        vj.time_tables.map((tt, i) =>{
          if (_.isEqual(tt, action.timetable)){
            vj.time_tables.splice(i, 1)
          }
        })
      })
      newModalProps.vehicleJourneys = vehicleJourneysModal
      newModalProps.timetables = timetablesModal
      return _.assign({}, state, {modalProps: newModalProps})
    case 'DELETE_PURCHASE_WINDOW_MODAL':
        newModalProps = JSON.parse(JSON.stringify(state.modalProps))
        let purchase_windows = state.modalProps.purchase_windows.slice(0)
        purchase_windows.map((tt, i) =>{
          if(tt == action.purchaseWindow){
            purchase_windows.splice(i, 1)
          }
        })
        vehicleJourneysModal = state.modalProps.vehicleJourneys.slice(0)
        vehicleJourneysModal.map((vj) =>{
          vj.purchase_windows.map((tt, i) =>{
            if (_.isEqual(tt, action.purchaseWindow)){
              vj.purchase_windows.splice(i, 1)
            }
          })
        })
        newModalProps.vehicleJourneys = vehicleJourneysModal
        newModalProps.purchase_windows = purchase_windows
        return _.assign({}, state, {modalProps: newModalProps})
    case 'CREATE_VEHICLEJOURNEY_MODAL':
      let selectedJP = {}
      if (window.jpOrigin){
        let stopAreas = _.map(window.jpOriginStopPoints, (sa, i) =>{
          return _.assign({}, {stop_area_short_description : {id : sa.stop_area_id}})
        })
        selectedJP = {
          id: window.jpOrigin.id,
          name: window.jpOrigin.name,
          published_name: window.jpOrigin.published_name,
          objectid: window.jpOrigin.objectid,
          stop_areas: stopAreas,
          missions: state.missions
        }
      }
      return {
        type: 'create',
        modalProps: window.jpOrigin ? {selectedJPModal: selectedJP} : {},
        confirmModal: {}
      }
    case 'SELECT_JP_CREATE_MODAL':
      newModalProps = _.assign({}, state.modalProps, {selectedJPModal : action.selectedItem})
      return _.assign({}, state, {modalProps: newModalProps})
    case 'SHIFT_VEHICLEJOURNEY_MODAL':
      return {
        type: 'shift',
        modalProps: {},
        confirmModal: {}
      }
    case 'DUPLICATE_VEHICLEJOURNEY_MODAL':
      return {
        type: 'duplicate',
        modalProps: {},
        confirmModal: {}
      }
    case 'CLOSE_MODAL':
      return {
        type: '',
        modalProps: {},
        confirmModal: {}
      }
    default:
      return state
  }
}
