import { connect } from 'react-redux'
import actions from '../actions'
import JourneyPatterns from '../components/JourneyPatterns'

const mapStateToProps = (state) => {
  return {
    journeyPatterns: state.journeyPatterns,
    status: state.status,
    editMode: state.editMode,
    stopPointsList: state.stopPointsList
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onLoadFirstPage: () =>{
      dispatch(actions.fetchingApi())
      actions.fetchJourneyPatterns(dispatch)
    },
    onCheckboxChange: (e, index) =>{
      dispatch(actions.updateCheckboxValue(e, index))
    },
    onOpenEditModal: (index, journeyPattern) =>{
      dispatch(actions.openEditModal(index, journeyPattern))
    },
    onDeleteJourneyPattern: (index) =>{
      dispatch(actions.deleteJourneyPattern(index))
    },
    onUpdateJourneyPatternCosts: (index, costs) =>{
      dispatch(actions.updateJourneyPatternCosts(index, costs))
    },
  }
}

const JourneyPatternList = connect(mapStateToProps, mapDispatchToProps)(JourneyPatterns)

export default JourneyPatternList
