import actions from '../../../app/javascript/vehicle_journeys/actions/index'

const dispatch = function(){}
const currentPage = 1

describe('when cannot fetch api', () => {
  it('should create an action to toggle error', () => {
    const expectedAction = {
      type: 'UNAVAILABLE_SERVER',
    }
    expect(actions.unavailableServer()).toEqual(expectedAction)
  })
})
describe('when fetching api', () => {
  it('should create an action to fetch api', () => {
    const expectedAction = {
      type: 'FETCH_API',
    }
    expect(actions.fetchingApi()).toEqual(expectedAction)
  })
})
describe('when receiveJourneyPatterns is triggered', () => {
  it('should create an action to pass json to reducer', () => {
    const json = undefined
    const expectedAction = {
      type: 'RECEIVE_VEHICLE_JOURNEYS',
      json
    }
    expect(actions.receiveVehicleJourneys()).toEqual(expectedAction)
  })
})
describe('when clicking on add button', () => {
  it('should create an action to open a create modal', () => {
    const expectedAction = {
      type: 'CREATE_VEHICLEJOURNEY_MODAL',
    }
    expect(actions.openCreateModal()).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a journey pattern', () => {
  it('should create an action to select a journey pattern inside modal', () => {
    let selectedJP = {
      id: 1,
      object_id: 2,
      name: 'test',
      published_name: 'test',
      stop_area_short_descriptions: ['test']
    }
    const expectedAction = {
      type: 'SELECT_JP_CREATE_MODAL',
      selectedItem:{
        id: selectedJP.id,
        objectid: selectedJP.object_id,
        name: selectedJP.name,
        published_name: selectedJP.published_name,
        stop_areas: selectedJP.stop_area_short_descriptions
      }
    }
    expect(actions.selectJPCreateModal(selectedJP)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside create modal', () => {
  it('should create an action to create a new vehicle journey', () => {
    const data = {}
    const selectedJourneyPattern = {}
    const selectedCompany = {}
    const stopPointsList = []
    const expectedAction = {
      type: 'ADD_VEHICLEJOURNEY',
      data,
      selectedJourneyPattern,
      stopPointsList,
      selectedCompany
    }
    expect(actions.addVehicleJourney(data, selectedJourneyPattern, stopPointsList, selectedCompany)).toEqual(expectedAction)
  })
})
describe('when previous navigation button is clicked', () => {
  it('should create an action to go to previous page', () => {
    const nextPage = false
    const queryString = ''
    const pagination = {
      totalCount: 25,
      perPage: 12,
      page:1
    }
    const expectedAction = {
      type: 'GO_TO_PREVIOUS_PAGE',
      dispatch,
      pagination,
      nextPage,
      queryString
    }
    expect(actions.goToPreviousPage(dispatch, pagination, queryString)).toEqual(expectedAction)
  })
})
describe('when next navigation button is clicked', () => {
  it('should create an action to go to next page', () => {
    const queryString = ''
    const nextPage = true
    const pagination = {
      totalCount: 25,
      perPage: 12,
      page:1
    }
    const expectedAction = {
      type: 'GO_TO_NEXT_PAGE',
      dispatch,
      pagination,
      nextPage,
      queryString
    }
    expect(actions.goToNextPage(dispatch, pagination, queryString)).toEqual(expectedAction)
  })
})
describe('when checking a vehicleJourney', () => {
  it('should create an action to select vj', () => {
    const index = 1
    const expectedAction = {
      type: 'SELECT_VEHICLEJOURNEY',
      index
    }
    expect(actions.selectVehicleJourney(index)).toEqual(expectedAction)
  })
})
describe('when clicking on cancel selection button', () => {
  it('should create an action to cancel whole selection', () => {
    const index = 1
    const expectedAction = {
      type: 'CANCEL_SELECTION'
    }
    expect(actions.cancelSelection()).toEqual(expectedAction)
  })
})
describe('when clicking on delete button', () => {
  it('should create an action to delete vj', () => {
    const expectedAction = {
      type: 'DELETE_VEHICLEJOURNEYS',
    }
    expect(actions.deleteVehicleJourneys()).toEqual(expectedAction)
  })
})
describe('when toggling arrivals', () => {
  it('should create an action to toggleArrivals', () => {
    const expectedAction = {
      type: 'TOGGLE_ARRIVALS',
    }
    expect(actions.toggleArrivals()).toEqual(expectedAction)
  })
})
describe('when updating vjas time', () => {
  it('should create an action to update time', () => {
    const val = 33, subIndex = 0, index = 0, timeUnit = 'minute', isDeparture = true, isArrivalsToggled = true
    const expectedAction = {
      type: 'UPDATE_TIME',
      val,
      subIndex,
      index,
      timeUnit,
      isDeparture,
      isArrivalsToggled
    }
    expect(actions.updateTime(val, subIndex, index, timeUnit, isDeparture, isArrivalsToggled)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside shifting modal', () => {
  it('should create an action to shift a vehiclejourney schedule', () => {
    const addtionalTime = 0
    const expectedAction = {
      type: 'SHIFT_VEHICLEJOURNEY',
      addtionalTime
    }
    expect(actions.shiftVehicleJourney(addtionalTime)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside editing modal', () => {
  it('should create an action to update a vehiclejourney', () => {
    const data = {}
    const selectedCompany = {}
    const expectedAction = {
      type: 'EDIT_VEHICLEJOURNEY',
      data,
      selectedCompany
    }
    expect(actions.editVehicleJourney(data, selectedCompany)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside duplicating modal', () => {
  it('should create an action to duplicate a vehiclejourney schedule', () => {
    const addtionalTime = 0
    const departureDelta = 0
    const duplicateNumber = 1
    const expectedAction = {
      type: 'DUPLICATE_VEHICLEJOURNEY',
      addtionalTime,
      duplicateNumber,
      departureDelta
    }
    expect(actions.duplicateVehicleJourney(addtionalTime, duplicateNumber, departureDelta)).toEqual(expectedAction)
  })
})
describe('when clicking on edit notes modal', () => {
  it('should create an action to open footnotes modal', () => {
    const vehicleJourney = {}
    const expectedAction = {
      type: 'EDIT_NOTES_VEHICLEJOURNEY_MODAL',
      vehicleJourney
    }
    expect(actions.openNotesEditModal(vehicleJourney)).toEqual(expectedAction)
  })
})

 //  ___ ___   ___ _____ _  _  ___ _____ ___ ___
 // | __/ _ \ / _ \_   _| \| |/ _ \_   _| __/ __|
 // | _| (_) | (_) || | | .` | (_) || | | _|\__ \
 // |_| \___/ \___/ |_| |_|\_|\___/ |_| |___|___/
 //

describe('when clicking on a footnote button inside footnote modal', () => {
  it('should create an action to toggle this footnote', () => {
    const footnote = {}, isShown = true
    const expectedAction = {
      type: 'TOGGLE_FOOTNOTE_MODAL',
      footnote,
      isShown
    }
    expect(actions.toggleFootnoteModal(footnote, isShown)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside footnote modal', () => {
  it('should create an action to update vj footnotes', () => {
    const footnotes = []
    const expectedAction = {
      type: 'EDIT_VEHICLEJOURNEY_NOTES',
      footnotes
    }
    expect(actions.editVehicleJourneyNotes(footnotes)).toEqual(expectedAction)
  })
})

 //  _____ ___ __  __ ___ _____ _   ___ _    ___ ___
 // |_   _|_ _|  \/  | __|_   _/_\ | _ ) |  | __/ __|
 //   | |  | || |\/| | _|  | |/ _ \| _ \ |__| _|\__ \
 //   |_| |___|_|  |_|___| |_/_/ \_\___/____|___|___/
 //

describe('when clicking on calendar button in toolbox', () => {
  it('should create an action to open calendar modal', () => {
    const vehicleJourneys = []
    const expectedAction = {
      type: 'EDIT_CALENDARS_VEHICLEJOURNEY_MODAL',
      vehicleJourneys
    }
    expect(actions.openCalendarsEditModal(vehicleJourneys)).toEqual(expectedAction)
  })
})
describe('when clicking on delete button next to a timetable inside modal', () => {
  it('should create an action to delete timetable from selected vehicle journeys', () => {
    const timetable = {}
    const expectedAction = {
      type: 'DELETE_CALENDAR_MODAL',
      timetable
    }
    expect(actions.deleteCalendarModal(timetable)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside calendars modal', () => {
  it('should create an action to update vj calendars', () => {
    const vehicleJourneys = []
    const timetables = []
    const expectedAction = {
      type: 'EDIT_VEHICLEJOURNEYS_TIMETABLES',
      vehicleJourneys,
      timetables
    }
    expect(actions.editVehicleJourneyTimetables(vehicleJourneys, timetables)).toEqual(expectedAction)
  })
})
describe('when clicking on add button inside calendars modal', () => {
  it('should create an action to add the selected timetable to preselected vjs', () => {
    const expectedAction = {
      type: 'ADD_SELECTED_TIMETABLE',
    }
    expect(actions.addSelectedTimetable()).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a timetable', () => {
  it('should create an action to select a timetable inside modal', () => {
    let selectedTT = {
      id: 1,
      objectid: 2,
      comment: 'test',
    }
    const expectedAction = {
      type: 'SELECT_TT_CALENDAR_MODAL',
      selectedItem:{
        id: selectedTT.id,
        objectid: selectedTT.objectid,
        comment: selectedTT.comment,
      }
    }
    expect(actions.selectTTCalendarsModal(selectedTT)).toEqual(expectedAction)
  })
})

 //  ___ _   _ ___  ___ _  _   _   ___ ___
 // | _ \ | | | _ \/ __| || | /_\ / __| __|
 // |  _/ |_| |   / (__| __ |/ _ \\__ \ _|
 // |_|  \___/|_|_\\___|_||_/_/_\_\___/___|__
 // \ \    / /_ _| \| |   \ / _ \ \    / / __|
 //  \ \/\/ / | || .` | |) | (_) \ \/\/ /\__ \
 //   \_/\_/ |___|_|\_|___/ \___/ \_/\_/ |___/
 //

describe('when clicking on purchase window button in toolbox', () => {
  it('should create an action to open purchase window modal', () => {
    const vehicleJourneys = []
    const expectedAction = {
      type: 'EDIT_PURCHASE_WINDOWS_VEHICLEJOURNEY_MODAL',
      vehicleJourneys
    }
    expect(actions.openPurchaseWindowsEditModal(vehicleJourneys)).toEqual(expectedAction)
  })
})
describe('when clicking on delete button next to a purchase window inside modal', () => {
  it('should create an action to delete purchase window from selected vehicle journeys', () => {
    const purchaseWindow = {}
    const expectedAction = {
      type: 'DELETE_PURCHASE_WINDOW_MODAL',
      purchaseWindow
    }
    expect(actions.deletePurchaseWindowsModal(purchaseWindow)).toEqual(expectedAction)
  })
})
describe('when clicking on validate button inside purchase windows modal', () => {
  it('should create an action to update vj purchase windows', () => {
    const vehicleJourneys = []
    const purchase_windows = []
    const expectedAction = {
      type: 'EDIT_VEHICLEJOURNEYS_PURCHASE_WINDOWS',
      vehicleJourneys,
      purchase_windows
    }
    expect(actions.editVehicleJourneyPurchaseWindows(vehicleJourneys, purchase_windows)).toEqual(expectedAction)
  })
})
describe('when clicking on add button inside purchase windows modal', () => {
  it('should create an action to add the selected purchase window to preselected vjs', () => {
    const expectedAction = {
      type: 'ADD_SELECTED_PURCHASE_WINDOW',
    }
    expect(actions.addSelectedPurchaseWindow()).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a purchase window', () => {
  it('should create an action to select a purchase window inside modal', () => {
    let selectedTT = {
      id: 1,
      objectid: 2,
      name: 'test',
      color: 'color',
    }
    const expectedAction = {
      type: 'SELECT_PURCHASE_WINDOW_MODAL',
      selectedItem:{
        id: selectedTT.id,
        objectid: selectedTT.objectid,
        name: selectedTT.name,
        color: "color"
      }
    }
    expect(actions.selectPurchaseWindowsModal(selectedTT)).toEqual(expectedAction)
  })
})

 //  ___ ___ _  _____ ___ ___  ___
 // | __|_ _| ||_   _| __| _ \/ __|
 // | _| | || |__| | | _||   /\__ \
 // |_| |___|____|_| |___|_|_\|___/
 //

describe('when clicking on reset button inside query filters', () => {
  it('should create an action to reset the query filters', () => {
    const expectedAction = {
      type: 'BATCH',
      payload: [
        {type: 'RESET_FILTERS'},
        {type: 'RESET_PAGINATION'},
        {type: 'QUERY_FILTER_VEHICLEJOURNEYS', dispatch: undefined},
      ]
    }
    expect(actions.resetFilters()).toEqual(expectedAction)
  })
})
describe('when clicking on filter button inside query filters', () => {
  it('should create an action to filter', () => {
    const expectedAction = {
      type: 'BATCH',
      payload: [
        {type: 'CREATE_QUERY_STRING'},
        {type: 'RESET_PAGINATION'},
        {type: 'QUERY_FILTER_VEHICLEJOURNEYS', dispatch: undefined},
      ]
    }
    expect(actions.filterQuery()).toEqual(expectedAction)
  })
})
describe('when clicking on checkbox to show vj without schedule', () => {
  it('should create an action to toggle this filter', () => {
    const expectedAction = {
      type: 'TOGGLE_WITHOUT_SCHEDULE',
    }
    expect(actions.toggleWithoutSchedule()).toEqual(expectedAction)
  })
})
describe('when setting new interval', () => {
  const val = 1
  const unit = 'hour'
  it('should create actions to update intervals in state', () => {
    let expectedAction = {
      type: 'UPDATE_START_TIME_FILTER',
      val,
      unit
    }
    expect(actions.updateStartTimeFilter(val, unit)).toEqual(expectedAction)
  })
  it('should create actions to update intervals in state', () => {
    let expectedAction = {
      type: 'UPDATE_END_TIME_FILTER',
      val,
      unit
    }
    expect(actions.updateEndTimeFilter(val, unit)).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a timetable in the filters', () => {
  it('should create an action to select a timetable as a filter', () => {
    let selectedTT = {
      id: 1,
      objectid: 2,
      comment: 'test',
    }
    const expectedAction = {
      type: 'SELECT_TT_FILTER',
      selectedItem:{
        id: selectedTT.id,
        objectid: selectedTT.objectid,
        comment: selectedTT.comment,
      }
    }
    expect(actions.filterSelect2Timetable(selectedTT)).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a journeypattern in the filters', () => {
  it('should create an action to select a journey pattern as a filter', () => {
    let selectedJP = {
      id: 1,
      object_id: 2,
      name: 'test',
      published_name: 'test'
    }
    const expectedAction = {
      type: 'SELECT_JP_FILTER',
      selectedItem:{
        id: selectedJP.id,
        objectid: selectedJP.object_id,
        name: selectedJP.name,
        published_name: selectedJP.published_name
      }
    }
    expect(actions.filterSelect2JourneyPattern(selectedJP)).toEqual(expectedAction)
  })
})
describe('when user clicked either on filter or reset button in filters', () => {
  it('should create an action to reset pagination', () => {
    const expectedAction = {
      type: 'RESET_PAGINATION',
    }
    expect(actions.resetPagination()).toEqual(expectedAction)
  })
})
describe('when user clicked either on filter or reset button in filters', () => {
  it('should create an action to create a queryString with params filters', () => {
    const expectedAction = {
      type: 'CREATE_QUERY_STRING',
    }
    expect(actions.createQueryString()).toEqual(expectedAction)
  })
})
describe('when submitting new vj', () => {
  it('should create an action to update pagination totalCount', () => {
    const diff = 1
    const expectedAction = {
      type: 'UPDATE_TOTAL_COUNT',
      diff
    }
    expect(actions.updateTotalCount(diff)).toEqual(expectedAction)
  })
})
describe('when receiving vj', () => {
  it('should create an action to show pagination totalCount', () => {
    const total = 1
    const expectedAction = {
      type: 'RECEIVE_TOTAL_COUNT',
      total
    }
    expect(actions.receiveTotalCount(total)).toEqual(expectedAction)
  })
})
describe('when using select2 to pick a company', () => {
  it('should create an action to select a company inside modal', () => {
    let selectedCompany = {
      id: 1,
      objectid: 2,
      name: 'test',
    }
    const expectedAction = {
      type: 'SELECT_CP_EDIT_MODAL',
      selectedItem:{
        id: selectedCompany.id,
        objectid: selectedCompany.objectid,
        name: selectedCompany.name,
      }
    }
    expect(actions.select2Company(selectedCompany)).toEqual(expectedAction)
  })
})
describe('when using select2 to unselect a company', () => {
  it('should create an action to unselect a company inside modal', () => {
    let selectedCompany = {
      id: 1,
      objectid: 2,
      name: 'test',
    }
    const expectedAction = {
      type: 'UNSELECT_CP_EDIT_MODAL'
    }
    expect(actions.unselect2Company()).toEqual(expectedAction)
  })
})

describe('actions.adjustSchedule', () => {
  set('time', () => {
    return {
      hour: 9,
      minute: 30
    }
  })
  context('when editing the departure time', () => {
    set('action', () => { return { isDeparture: true } })
    context('with a positive delta', () => {
      set('schedule', () => {
        return {
          departure_time: time,
          arrival_time: time
        }
      })
      it('should do nothing', () => {
        expect(actions.adjustSchedule(action, schedule)).toEqual(schedule)
      })
    }),
    context('with a delta < 0', () => {
      set('departure_time', () => {
        return {
          hour: time.hour,
          minute: time.minute - 1
        }
      })
      set('schedule', () => {
        return {
          departure_time: departure_time,
          arrival_time: time
        }
      })
      it('should adjust arrival time', () => {
        let expected = {
          departure_time: departure_time,
          arrival_time: departure_time,
          delta: 0
        }
        expect(actions.adjustSchedule(action, schedule)).toEqual(expected)
      })
    })
  }),
  context('when editing the arrival time', () => {
    set('action', () => { return { isDeparture: false } })
    context('with a positive delta', () => {
      set('schedule', () => {
        return {
          departure_time: time,
          arrival_time: time
        }
      })
      it('should do nothing', () => {
        expect(actions.adjustSchedule(action, schedule)).toEqual(schedule)
      })
    }),
    context('with a delta < 0', () => {
      set('arrival_time', () => {
        return {
          hour: time.hour,
          minute: time.minute + 1
        }
      })
      set('schedule', () => {
        return {
          departure_time: time,
          arrival_time: arrival_time
        }
      })
      it('should adjust departure time', () => {
        let expected = {
          departure_time: arrival_time,
          arrival_time: arrival_time,
          delta: 0
        }
        expect(actions.adjustSchedule(action, schedule)).toEqual(expected)
      })
    })
  })
})
