var _ = require('lodash')
var actions = require("../actions")

const vehicleJourney= (state = {}, action, keep) => {
  switch (action.type) {
    case 'SELECT_VEHICLEJOURNEY':
      return _.assign({}, state, {selected: !state.selected})
    case 'CANCEL_SELECTION':
      return _.assign({}, state, {selected: false})
    case 'ADD_VEHICLEJOURNEY':
      let pristineVjasList = []
      _.each(action.stopPointsList, (sp) =>{
        let newVjas = {
          delta: 0,
          departure_time:{
            hour: '00',
            minute: '00'
          },
          arrival_time:{
            hour: '00',
            minute: '00'
          },
          stop_point_objectid: sp.object_id,
          stop_area_cityname: sp.city_name,
          dummy: true
        }
        _.each(action.selectedJourneyPattern.stop_areas, (jp) =>{
          if (jp.stop_area_short_description.id == sp.id){
            newVjas.dummy = false
            return
          }
        })
        pristineVjasList.push(newVjas)
      })
      return {
        company: action.selectedCompany,
        journey_pattern: action.selectedJourneyPattern,
        published_journey_name: action.data.published_journey_name.value,
        published_journey_identifier: action.data.published_journey_identifier.value,
        objectid: '',
        footnotes: [],
        time_tables: [],
        vehicle_journey_at_stops: pristineVjasList,
        selected: false,
        deletable: false,
        transport_mode: window.transportMode ? window.transportMode : 'undefined',
        transport_submode: window.transportSubmode ? window.transportSubmode : 'undefined'
      }
    case 'DUPLICATE_VEHICLEJOURNEY':
    case 'SHIFT_VEHICLEJOURNEY':
      let shiftedArray, shiftedSchedule, shiftedVjas
      shiftedArray = state.vehicle_journey_at_stops.map((vjas, i) => {
        if (!vjas.dummy){
          shiftedSchedule = actions.getShiftedSchedule(vjas, action.addtionalTime)

          shiftedVjas =  _.assign({}, state.vehicle_journey_at_stops[i], shiftedSchedule)
          vjas = _.assign({}, state.vehicle_journey_at_stops[i], shiftedVjas)
          if(!keep){
            delete vjas['id']
          }
          return vjas
        }else {
          if(!keep){
            delete vjas['id']
          }
          return vjas
        }
      })
      return _.assign({}, state, {vehicle_journey_at_stops: shiftedArray})
    case 'UPDATE_TIME':
      let vj, vjas, vjasArray, newSchedule
      vjasArray = state.vehicle_journey_at_stops.map((vjas, i) =>{
        if(i == action.subIndex){
          newSchedule = {
            departure_time: _.assign({}, vjas.departure_time),
            arrival_time: _.assign({}, vjas.arrival_time)
          }
          if (action.isDeparture){
            newSchedule.departure_time[action.timeUnit] = actions.pad(action.val, action.timeUnit)
            if(!action.isArrivalsToggled)
              newSchedule.arrival_time[action.timeUnit] = actions.pad(action.val, action.timeUnit)
            newSchedule = actions.getDelta(newSchedule)
            if(newSchedule.delta < 0){
              return vjas
            }
            return _.assign({}, state.vehicle_journey_at_stops[action.subIndex], {arrival_time: newSchedule.arrival_time, departure_time: newSchedule.departure_time, delta: newSchedule.delta})
          }else{
            newSchedule.arrival_time[action.timeUnit] = actions.pad(action.val, action.timeUnit)
            newSchedule = actions.getDelta(newSchedule)
            if(newSchedule.delta < 0){
              return vjas
            }
            return _.assign({}, state.vehicle_journey_at_stops[action.subIndex],  {arrival_time: newSchedule.arrival_time, departure_time: newSchedule.departure_time, delta: newSchedule.delta})
          }
        }else{
          return vjas
        }
      })
      return _.assign({}, state, {vehicle_journey_at_stops: vjasArray})
    default:
      return state
  }
}

const vehicleJourneys = (state = [], action) => {
  switch (action.type) {
    case 'RECEIVE_VEHICLE_JOURNEYS':
      return [...action.json]
    case 'RECEIVE_ERRORS':
      return [...action.json]
    case 'GO_TO_PREVIOUS_PAGE':
      if(action.pagination.page > 1){
        actions.fetchVehicleJourneys(action.dispatch, action.pagination.page, action.nextPage, action.queryString)
      }
      return state
    case 'GO_TO_NEXT_PAGE':
      if (action.pagination.totalCount - (action.pagination.page * action.pagination.perPage) > 0){
        actions.fetchVehicleJourneys(action.dispatch, action.pagination.page, action.nextPage, action.queryString)
      }
      return state
    case 'ADD_VEHICLEJOURNEY':
      return [
        vehicleJourney(state, action),
        ...state
      ]
    case 'EDIT_VEHICLEJOURNEY':
      return state.map((vj, i) => {
        if (vj.selected){
          return _.assign({}, vj, {
            company: action.selectedCompany,
            published_journey_name: action.data.published_journey_name.value,
            published_journey_identifier: action.data.published_journey_identifier.value,
          })
        }else{
          return vj
        }
      })
    case 'EDIT_VEHICLEJOURNEY_NOTES':
      return state.map((vj, i) => {
        if (vj.selected){
          return _.assign({}, vj, {
            footnotes: action.footnotes
          })
        }else{
          return vj
        }
      })
    case 'EDIT_VEHICLEJOURNEYS_TIMETABLES':
      let newTimetables = JSON.parse(JSON.stringify(action.timetables))
      return state.map((vj,i) =>{
        if(vj.selected){
          let updatedVJ = _.assign({}, vj)
          action.vehicleJourneys.map((vjm, j) =>{
            if(vj.objectid == vjm.objectid){
              updatedVJ.time_tables =  newTimetables
            }
          })
          return updatedVJ
        }else{
          return vj
        }
      })
    case 'SHIFT_VEHICLEJOURNEY':
      return state.map((vj, i) => {
        if (vj.selected){
          return vehicleJourney(vj, action, true)
        }else{
          return vj
        }
      })
    case 'DUPLICATE_VEHICLEJOURNEY':
      let dupeVj
      let dupes = []
      let selectedIndex
      let val = action.addtionalTime
      let departureDelta = action.departureDelta
      state.map((vj, i) => {
        if(vj.selected){
          selectedIndex = i
          for (i = 0; i< action.duplicateNumber; i++){
            // We check if the departureDelta is != 0 to create the first VJ on the updated deparure time if it is the case
            // let delta = departureDelta == 0 ? 1 : 0
            // action.addtionalTime = (val * (i + delta)) + departureDelta
            action.addtionalTime = (val * (i + 1)) + departureDelta
            dupeVj = vehicleJourney(vj, action, false)
            dupeVj.published_journey_name = dupeVj.published_journey_name + '-' + i
            dupeVj.selected = false
            delete dupeVj['objectid']
            dupes.push(dupeVj)
          }
        }
      })
      let concatArray = state.slice(0, selectedIndex + 1).concat(dupes)
      concatArray = concatArray.concat(state.slice(selectedIndex + 1))
      return concatArray
    case 'DELETE_VEHICLEJOURNEYS':
      return state.map((vj, i) =>{
        if (vj.selected){
          return _.assign({}, vj, {deletable: true, selected: false})
        } else {
          return vj
        }
      })
    case 'SELECT_VEHICLEJOURNEY':
      return state.map((vj, i) =>{
        if (i == action.index){
          return vehicleJourney(vj, action)
        } else {
          return vj
        }
      })
    case 'CANCEL_SELECTION':
      return state.map((vj) => {
        return vehicleJourney(vj, action)
      })
    case 'UPDATE_TIME':
      return state.map((vj, i) =>{
        if (i == action.index){
          return vehicleJourney(vj, action)
        } else {
          return vj
        }
      })
    default:
      return state
  }
}

module.exports = vehicleJourneys
