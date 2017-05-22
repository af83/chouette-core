var actions = require('../actions')
var connect = require('react-redux').connect
var MetasComponent = require('../components/Metas')

const mapStateToProps = (state) => {
  return {
    metas: state.metas
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onUpdateDayTypes: (index, dayTypes) => {
      let newDayTypes = dayTypes.slice(0)
      newDayTypes[index] = !newDayTypes[index]
      dispatch(actions.updateDayTypes(newDayTypes))
      dispatch(actions.updateCurrentMonthFromDaytypes(newDayTypes))
    },
    onUpdateComment: (comment) => {
      dispatch(actions.updateComment(comment))
    },
    onUpdateColor: (color) => {
      dispatch(actions.updateColor(color))
    },
    onSelect2Tags: (e) => {
      e.preventDefault()
      dispatch(actions.select2Tags(e.params.data))
    },
    onUnselect2Tags: (e) => {
      e.preventDefault()
      dispatch(actions.unselect2Tags(e.params.data))
    }
  }
}

const Metas = connect(mapStateToProps, mapDispatchToProps)(MetasComponent)

module.exports = Metas
