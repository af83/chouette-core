import vjReducer from '../../../../app/javascript/vehicle_journeys/reducers/vehicleJourneys'
import actions from '../../../../app/javascript/vehicle_journeys/actions/index'

let state = []
let stateModal = {
  type: '',
  modalProps: {},
  confirmModal: {}
}
let fakeFootnotes = [{
  id: 1,
  code: 1,
  label: "1"
},{
  id: 2,
  code: 2,
  label: "2"
}]

let fakeTimeTables = [{
  published_journey_name: 'test 1',
  objectid: '1'
},{
  published_journey_name: 'test 2',
  objectid: '2'
},{
  published_journey_name: 'test 3',
  objectid: '3'
}]
let fakeVJAS = [{
  delta : 0,
  arrival_time : {
    hour: '07',
    minute: '02'
  },
  departure_time : {
    hour: '07',
    minute: '02'
  },
  stop_area_object_id: "chouette:StopArea:8000b367-e07c-43b8-b1be-766f1bfe542a:LOC"
}, 
  {
    delta: 627,
    arrival_time: {
      hour: '11',
      minute: '55'
    },
    departure_time: {
      hour: '22',
      minute: '22'
    },
    stop_area_object_id: "chouette:StopArea:c9d50c53-e4f4-4ccb-b5bd-6b80c4a3e6d0:LOC"
  },
  {
    delta: 0,
    arrival_time: {
      hour: '23',
      minute: '00'
    },
    departure_time: {
      hour: '23',
      minute: '00'
    },
    stop_area_object_id: "chouette:StopArea:25821842-d8b9-4171-81d2-9b7f905c5291:LOC"
  }]

describe('vehicleJourneys reducer', () => {
  beforeEach(()=>{
    state = [
      {
        journey_pattern_id: 1,
        published_journey_name: "vj1",
        objectid: '11',
        short_id: '11',
        deletable: false,
        selected: true,
        footnotes: fakeFootnotes,
        time_tables: fakeTimeTables,
        vehicle_journey_at_stops: fakeVJAS,
        index: 0,
        custom_fields: {foo: {value: 1}}
      },
      {
        journey_pattern_id: 2,
        published_journey_name: "vj2",
        objectid: '22',
        short_id: '22',
        selected: false,
        deletable: false,
        footnotes: fakeFootnotes,
        time_tables: fakeTimeTables,
        vehicle_journey_at_stops: fakeVJAS,
        index: 1,
        custom_fields: {foo: {value: 1}}
      }
    ]
  })

  it('should return the initial state', () => {
    expect(
      vjReducer(undefined, {})
    ).toEqual([])
  })


  it('should handle ADD_VEHICLEJOURNEY', () => {
    let pristineVjasList = [{
      delta : 0,
      arrival_time : {
        hour: "00",
        minute: "00"
      },
      departure_time : {
        hour: "00",
        minute: "00"
      },
      stop_point_objectid: 'test',
      stop_area_cityname: 'city',
      dummy: true
    }]
    let fakeData = {
      published_journey_name: {value: 'test'},
      published_journey_identifier: {value : ''},
      custom_fields: {
        foo: {
          value: 12
        }
      }
    }
    let fakeSelectedJourneyPattern = {id: "1"}
    let fakeSelectedCompany = {name: "ALBATRANS"}
    expect(
      vjReducer(state, {
        type: 'ADD_VEHICLEJOURNEY',
        data: fakeData,
        selectedJourneyPattern: fakeSelectedJourneyPattern,
        stopPointsList: [{object_id: 'test', city_name: 'city'}],
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([{
      ignored_routing_contraint_zone_ids: [],
      journey_pattern: fakeSelectedJourneyPattern,
      company: fakeSelectedCompany,
      published_journey_name: 'test',
      published_journey_identifier: '',
      short_id: '',
      objectid: '',
      footnotes: [],
      time_tables: [],
      purchase_windows: [],
      vehicle_journey_at_stops: pristineVjasList,
      selected: false,
      deletable: false,
      transport_mode: 'undefined',
      transport_submode: 'undefined',
      custom_fields: {
        foo: {
          value: 12
        }
      }
    }, ...state])
  })

  it('should handle ADD_VEHICLEJOURNEY with a start time and a fully timed JP', () => {
    let pristineVjasList = [{
      delta : 0,
      arrival_time : {
        hour: 22,
        minute: 59
      },
      departure_time : {
        hour: 22,
        minute: 59
      },
      stop_point_objectid: 'test-1',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 10,
      arrival_time : {
        hour: 23,
        minute: 2
      },
      departure_time : {
        hour: 23,
        minute: 12
      },
      stop_point_objectid: 'test-2',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 0,
      arrival_time : {
        hour: "00",
        minute: "00"
      },
      departure_time : {
        hour: "00",
        minute: "00"
      },
      stop_point_objectid: 'test-3',
      stop_area_cityname: 'city',
      dummy: true
    },
    {
      delta : 0,
      arrival_time : {
        hour: 0,
        minute: 42
      },
      departure_time : {
        hour: 0,
        minute: 42
      },
      stop_point_objectid: 'test-4',
      stop_area_cityname: 'city',
      dummy: false
    }]
    let fakeData = {
      published_journey_name: {value: 'test'},
      published_journey_identifier: {value : ''},
      "start_time.hour": {value : '22'},
      "start_time.minute": {value : '59'}
    }
    let fakeSelectedJourneyPattern = {
      id: "1",
      full_schedule: true,
      stop_areas: [
        {stop_area_short_description: {id: 1}},
        {stop_area_short_description: {id: 2}},
        {stop_area_short_description: {id: 4}},
      ],
      costs: {
        "1-2": {
          distance: 10,
          time: 63
        },
        "2-4": {
          distance: 10,
          time: 30
        }
      }
    }
    let fakeSelectedCompany = {name: "ALBATRANS"}
    expect(
      vjReducer(state, {
        type: 'ADD_VEHICLEJOURNEY',
        data: fakeData,
        selectedJourneyPattern: fakeSelectedJourneyPattern,
        stopPointsList: [{object_id: 'test-1', city_name: 'city', stop_area_id: 1, id: 1, time_zone_offset: 0, waiting_time: 10}, {object_id: 'test-2', city_name: 'city', stop_area_id: 2, id: 2, time_zone_offset: -3600, waiting_time: 10}, {object_id: 'test-3', city_name: 'city', stop_area_id: 3, id: 3, time_zone_offset: 0, waiting_time: 20}, {object_id: 'test-4', city_name: 'city', stop_area_id: 4, id: 4, time_zone_offset: 0, waiting_time: 100}],
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([{
      ignored_routing_contraint_zone_ids: [],
      journey_pattern: fakeSelectedJourneyPattern,
      company: fakeSelectedCompany,
      published_journey_name: 'test',
      published_journey_identifier: '',
      short_id: '',
      objectid: '',
      footnotes: [],
      time_tables: [],
      purchase_windows: [],
      vehicle_journey_at_stops: pristineVjasList,
      selected: false,
      custom_fields: undefined,
      deletable: false,
      transport_mode: 'undefined',
      transport_submode: 'undefined'
    }, ...state])
  })

  it('should handle ADD_VEHICLEJOURNEY with a start time and a fully timed JP, and use user\'s TZ', () => {
    let pristineVjasList = [{
      delta : 0,
      arrival_time : {
        hour: 22,
        minute: 59
      },
      departure_time : {
        hour: 22,
        minute: 59
      },
      stop_point_objectid: 'test-1',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 10,
      arrival_time : {
        hour: 23,
        minute: 2
      },
      departure_time : {
        hour: 23,
        minute: 12
      },
      stop_point_objectid: 'test-2',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 0,
      arrival_time : {
        hour: "00",
        minute: "00"
      },
      departure_time : {
        hour: "00",
        minute: "00"
      },
      stop_point_objectid: 'test-3',
      stop_area_cityname: 'city',
      dummy: true
    },
    {
      delta : 0,
      arrival_time : {
        hour: 0,
        minute: 42
      },
      departure_time : {
        hour: 0,
        minute: 42
      },
      stop_point_objectid: 'test-4',
      stop_area_cityname: 'city',
      dummy: false
    }]
    let fakeData = {
      published_journey_name: {value: 'test'},
      published_journey_identifier: {value : ''},
      "start_time.hour": {value : '22'},
      "start_time.minute": {value : '59'},
      "tz_offset": {value : '-65'}
    }
    let fakeSelectedJourneyPattern = {
      id: "1",
      full_schedule: true,
      stop_areas: [
        {stop_area_short_description: {id: 1}},
        {stop_area_short_description: {id: 2}},
        {stop_area_short_description: {id: 4}},
      ],
      costs: {
        "1-2": {
          distance: 10,
          time: 63
        },
        "2-4": {
          distance: 10,
          time: 30
        }
      }
    }
    let fakeSelectedCompany = {name: "ALBATRANS"}
    expect(
      vjReducer(state, {
        type: 'ADD_VEHICLEJOURNEY',
        data: fakeData,
        selectedJourneyPattern: fakeSelectedJourneyPattern,
        stopPointsList: [{object_id: 'test-1', city_name: 'city', stop_area_id: 1, id: 1, time_zone_offset: 0, waiting_time: null}, {object_id: 'test-2', city_name: 'city', stop_area_id: 2, id: 2, time_zone_offset: -3600, waiting_time: 10}, {object_id: 'test-3', city_name: 'city', stop_area_id: 3, id: 3, time_zone_offset: 0, waiting_time: 20}, {object_id: 'test-4', city_name: 'city', stop_area_id: 4, id: 4, time_zone_offset: 0}],
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([{
      ignored_routing_contraint_zone_ids: [],
      journey_pattern: fakeSelectedJourneyPattern,
      company: fakeSelectedCompany,
      published_journey_name: 'test',
      published_journey_identifier: '',
      short_id: '',
      objectid: '',
      footnotes: [],
      time_tables: [],
      purchase_windows: [],
      vehicle_journey_at_stops: pristineVjasList,
      selected: false,
      custom_fields: undefined,
      deletable: false,
      transport_mode: 'undefined',
      transport_submode: 'undefined'
    }, ...state])
  })

  it('should handle ADD_VEHICLEJOURNEY with a start time and a fully timed JP but no time is set', () => {
    let pristineVjasList = [{
      delta : 0,
      arrival_time : {
        hour: 0,
        minute: 0
      },
      departure_time : {
        hour: 0,
        minute: 0
      },
      stop_point_objectid: 'test-1',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 0,
      arrival_time : {
        hour: 0,
        minute: 0
      },
      departure_time : {
        hour: 0,
        minute: 0
      },
      stop_point_objectid: 'test-2',
      stop_area_cityname: 'city',
      dummy: false
    }]
    let fakeData = {
      published_journey_name: {value: 'test'},
      published_journey_identifier: {value : ''},
      "start_time.hour": {value : ''},
      "start_time.minute": {value : ''}
    }
    let fakeSelectedJourneyPattern = {
      id: "1",
      full_schedule: true,
      stop_areas: [
        {stop_area_short_description: {id: 1}},
        {stop_area_short_description: {id: 2}},
      ],
      costs: {
        "1-2": {
          distance: 10,
          time: 63
        },
      }
    }
    let fakeSelectedCompany = {name: "ALBATRANS"}
    expect(
      vjReducer(state, {
        type: 'ADD_VEHICLEJOURNEY',
        data: fakeData,
        selectedJourneyPattern: fakeSelectedJourneyPattern,
        stopPointsList: [{object_id: 'test-1', city_name: 'city', stop_area_id: 1, id: 1, time_zone_offset: 0}, {object_id: 'test-2', city_name: 'city', stop_area_id: 2, id: 2, time_zone_offset: -3600}],
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([{
      journey_pattern: fakeSelectedJourneyPattern,
      company: fakeSelectedCompany,
      published_journey_name: 'test',
      published_journey_identifier: '',
      short_id: '',
      objectid: '',
      footnotes: [],
      ignored_routing_contraint_zone_ids: [],
      time_tables: [],
      purchase_windows: [],
      vehicle_journey_at_stops: pristineVjasList,
      selected: false,
      custom_fields: undefined,
      deletable: false,
      transport_mode: 'undefined',
      transport_submode: 'undefined'
    }, ...state])
  })

  it('should handle ADD_VEHICLEJOURNEY with a start time and a fully timed JP but the minutes are not set', () => {
    let pristineVjasList = [{
      delta : 0,
      arrival_time : {
        hour: 22,
        minute: 0
      },
      departure_time : {
        hour: 22,
        minute: 0
      },
      stop_point_objectid: 'test-1',
      stop_area_cityname: 'city',
      dummy: false
    },
    {
      delta : 0,
      arrival_time : {
        hour: 22,
        minute: 3
      },
      departure_time : {
        hour: 22,
        minute: 3
      },
      stop_point_objectid: 'test-2',
      stop_area_cityname: 'city',
      dummy: false
    }]
    let fakeData = {
      published_journey_name: {value: 'test'},
      published_journey_identifier: {value : ''},
      "start_time.hour": {value : '22'},
      "start_time.minute": {value : ''}
    }
    let fakeSelectedJourneyPattern = {
      id: "1",
      full_schedule: true,
      stop_areas: [
        {stop_area_short_description: {id: 1}},
        {stop_area_short_description: {id: 2}},
      ],
      costs: {
        "1-2": {
          distance: 10,
          time: 63
        },
      }
    }
    let fakeSelectedCompany = {name: "ALBATRANS"}
    expect(
      vjReducer(state, {
        type: 'ADD_VEHICLEJOURNEY',
        data: fakeData,
        selectedJourneyPattern: fakeSelectedJourneyPattern,
        stopPointsList: [{object_id: 'test-1', city_name: 'city', stop_area_id: 1, id: 1, time_zone_offset: 0}, {object_id: 'test-2', city_name: 'city', stop_area_id: 2, id: 2, time_zone_offset: -3600}],
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([{
      journey_pattern: fakeSelectedJourneyPattern,
      company: fakeSelectedCompany,
      published_journey_name: 'test',
      published_journey_identifier: '',
      short_id: '',
      objectid: '',
      footnotes: [],
      ignored_routing_contraint_zone_ids: [],
      time_tables: [],
      purchase_windows: [],
      vehicle_journey_at_stops: pristineVjasList,
      selected: false,
      custom_fields: undefined,
      deletable: false,
      transport_mode: 'undefined',
      transport_submode: 'undefined'
    }, ...state])
  })

  it('should handle RECEIVE_VEHICLE_JOURNEYS', () => {
    expect(
      vjReducer(state, {
        type: 'RECEIVE_VEHICLE_JOURNEYS',
        json: state
      })
    ).toEqual(state)
  })

  describe('UPDATE_TIME', () => {
    const val = '33', index = 0, timeUnit = 'minute', isDeparture = true, isArrivalsToggled = true

    context('first or last stop of a VJ', () => {
      set('subIndex', () => 0)
      set('updatedVJAS', () => {
        return {
          delta: 0,
          arrival_time: {
            hour: '07',
            minute: val
          },
          departure_time: {
            hour: '07',
            minute: val
          },
          stop_area_object_id: "chouette:StopArea:8000b367-e07c-43b8-b1be-766f1bfe542a:LOC"
        }
      })

      it('should set departure time & arrival time to the same value', () => {
        const vjas = state[index]['vehicle_journey_at_stops']
        const newVJAS = [updatedVJAS, ...vjas.slice(1)] 
        const newVJ = Object.assign({}, state[subIndex], { vehicle_journey_at_stops: newVJAS })

        expect(
          vjReducer(state, {
            type: 'UPDATE_TIME',
            val,
            subIndex,
            index,
            timeUnit,
            isDeparture,
            isArrivalsToggled
          })
        ).toEqual([newVJ, state[1]])
      })
    })

    context('other stops', () => {
      set('subIndex', () => 1)
      set('updatedVJAS', () => {
        return {
          delta: 638,
          arrival_time: {
            hour: '11',
            minute: '55'
          },
          departure_time: {
            hour: '22',
            minute: '33'
          },
          stop_area_object_id: "chouette:StopArea:c9d50c53-e4f4-4ccb-b5bd-6b80c4a3e6d0:LOC"
        }
      })

      it('should not set departure time & arrival time to the same value', () => {
        // const newState = JSON.parse(JSON.stringify(state))
        const vjas = state[index]['vehicle_journey_at_stops']
        const newVJAS = [...vjas.slice(0, 1), updatedVJAS, ...vjas.slice(2)]
        const newVJ = Object.assign({}, state[index], { vehicle_journey_at_stops: newVJAS })
        expect(
          vjReducer(state, {
            type: 'UPDATE_TIME',
            val,
            subIndex,
            index,
            timeUnit,
            isDeparture,
            isArrivalsToggled
          })
        ).toEqual([newVJ, state[1]])
      })
    })
  })

  it('should handle SELECT_VEHICLEJOURNEY', () => {
    const index = 1
    const newVJ = Object.assign({}, state[1], {selected: true})
    expect(
      vjReducer(state, {
        type: 'SELECT_VEHICLEJOURNEY',
        index
      })
    ).toEqual([state[0], newVJ])
  })

  it('should handle CANCEL_SELECTION', () => {
    const index = 1
    const newVJ = Object.assign({}, state[0], {selected: false})
    expect(
      vjReducer(state, {
        type: 'CANCEL_SELECTION',
        index
      })
    ).toEqual([newVJ, state[1]])
  })

  it('should handle DELETE_VEHICLEJOURNEYS', () => {
    const newVJ = Object.assign({}, state[0], {deletable: true, selected: false})
    expect(
      vjReducer(state, {
        type: 'DELETE_VEHICLEJOURNEYS'
      })
    ).toEqual([newVJ, state[1]])
  })

  it('should handle CANCEL_DELETION', () => {
    const newState = JSON.parse(JSON.stringify(state))
    newState[0]['deletable'] = true
    newState[0]['selected'] = true
    const newVJ = Object.assign({}, state[0], { deletable: false })
    expect(
      vjReducer(newState, {
        type: 'CANCEL_DELETION'
      })
    ).toEqual([newVJ, state[1]])
  })

  it('should handle SHIFT_VEHICLEJOURNEY', () => {
    const addtionalTime = 5
    const newState = JSON.parse(JSON.stringify(state))

    const newVJAS = newState[0].vehicle_journey_at_stops.map(vjas => {
      let { hasAllAttributes, departure_time, arrival_time } = actions.scheduleToDates(vjas)
      let shiftedDT = new Date(departure_time.getTime() + (addtionalTime * 60000))
      let shiftedAT = new Date(arrival_time.getTime() + (addtionalTime * 60000))
      return {
        delta: vjas.delta,
        stop_area_object_id: vjas.stop_area_object_id,
        departure_time: {
          hour: actions.simplePad(shiftedDT.getHours()),
          minute: actions.simplePad(shiftedDT.getMinutes())
        },
        arrival_time: {
          hour: actions.simplePad(shiftedAT.getHours()),
          minute: actions.simplePad(shiftedAT.getMinutes())
        }
      }
    })
    
    let newVJ = Object.assign({}, newState[0], {vehicle_journey_at_stops: newVJAS})
    expect(
      vjReducer(newState, {
        type: 'SHIFT_VEHICLEJOURNEY',
        addtionalTime
      })
    ).toEqual([newVJ, newState[1]])
  })

  it('should handle DUPLICATE_VEHICLEJOURNEY', () => {
    // const newState = JSON.parse(JSON.stringify(state))
    let departureDelta = 1
    let addtionalTime = 5
    let duplicateNumber = 1

    const newVJAS = state[0].vehicle_journey_at_stops.map(vjas => {
      let { hasAllAttributes, departure_time, arrival_time } = actions.scheduleToDates(vjas)
      let shiftedDT = new Date(departure_time.getTime() + ((addtionalTime + departureDelta) * 60000))
      let shiftedAT = new Date(arrival_time.getTime() + ((addtionalTime + departureDelta) * 60000))
      return {
        delta: vjas.delta,
        stop_area_object_id: vjas.stop_area_object_id,
        departure_time: {
          hour: actions.simplePad(shiftedDT.getHours()),
          minute: actions.simplePad(shiftedDT.getMinutes())
        },
        arrival_time: {
          hour: actions.simplePad(shiftedAT.getHours()),
          minute: actions.simplePad(shiftedAT.getMinutes())
        }
      }
    })

    let newVJ = Object.assign({}, state[0], {vehicle_journey_at_stops: newVJAS, selected: false})
    newVJ.published_journey_name = state[0].published_journey_name + '-0'
    newVJ.index = 1
    delete newVJ['objectid']
    delete newVJ['short_id']
    let newState
    expect(
      newState = vjReducer(state, {
        type: 'DUPLICATE_VEHICLEJOURNEY',
        addtionalTime,
        duplicateNumber,
        departureDelta
      })
    ).toEqual([state[0], newVJ, state[1]])
    newState[1].custom_fields.foo.value = 2
    expect(newState[0].custom_fields.foo.value).toEqual(1)
  })

  it('should handle EDIT_VEHICLEJOURNEY', () => {
    let custom_fields = {
      foo: {
        value: 12
      }
    }
    let fakeSelectedCompany = {name : 'ALBATRANS'}
    let fakeData = {
      published_journey_name: {value : 'test'},
      published_journey_identifier: {value: 'test'},
      custom_fields: {foo: {value: 12}}
    }
    let newVJ = Object.assign({}, state[0], {company: fakeSelectedCompany, published_journey_name: fakeData.published_journey_name.value, published_journey_identifier: fakeData.published_journey_identifier.value, custom_fields})
    expect(
      vjReducer(state, {
        type: 'EDIT_VEHICLEJOURNEY',
        data: fakeData,
        selectedCompany: fakeSelectedCompany
      })
    ).toEqual([newVJ, state[1]])
  })

  it('should handle EDIT_VEHICLEJOURNEYS_TIMETABLES', () => {
    let newState = JSON.parse(JSON.stringify(state))
    newState[0].time_tables = [fakeTimeTables[0]]
    expect(
      vjReducer(state, {
        type: 'EDIT_VEHICLEJOURNEYS_TIMETABLES',
        vehicleJourneys: state,
        timetables: [fakeTimeTables[0]]
      })
    ).toEqual(newState)
  })

  it('should handle EDIT_VEHICLEJOURNEYS_PURCHASE_WINDOWS', () => {
    let newState = JSON.parse(JSON.stringify(state))
    newState[0].purchase_windows = [fakeTimeTables[0]]
    expect(
      vjReducer(state, {
        type: 'EDIT_VEHICLEJOURNEYS_PURCHASE_WINDOWS',
        vehicleJourneys: state,
        purchase_windows: [fakeTimeTables[0]]
      })
    ).toEqual(newState)
  })
})
