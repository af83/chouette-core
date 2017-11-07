import _ from 'lodash'
import React, { PropTypes, Component } from 'react'
import Select2 from 'react-select2'
import actions from '../../../actions'

// get JSON full path
var origin = window.location.origin
var path = window.location.pathname.split('/', 3).join('/')


export default class BSelect4 extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <Select2
        data={(this.props.isFilter) ? [this.props.filters.query.timetable.comment] : undefined}
        value={(this.props.isFilter) ? this.props.filters.query.timetable.comment : undefined}
        onSelect={(e) => this.props.onSelect2Timetable(e) }
        multiple={false}
        ref='timetable_id'
        options={{
          allowClear: false,
          theme: 'bootstrap',
          width: '100%',
          placeholder: 'Filtrer par calendrier...',
          language: require('./fr'),
          ajax: {
            url: origin + path + this.props.chunkURL,
            dataType: 'json',
            delay: '500',
            data: function(params) {
              return {
                q: {
                  comment_or_objectid_cont_any: actions.escapeWildcardCharacters(params.term)
                }
              };
            },
            processResults: function(data, params) {
              return {
                results: data.map(
                  item => _.assign(
                    {},
                    item,
                    {text: '<strong>' + "<span class='fa fa-circle' style='color:" + (item.color ? item.color : '#4B4B4B') + "'></span> " + item.comment + ' - ' + actions.humanOID(item.objectid) + '</strong><br/><small>' + (item.day_types ? item.day_types.match(/[A-Z]?[a-z]+/g).join(', ') : "") + '</small>'}
                  )
                )
              };
            },
            cache: true
          },
          minimumInputLength: 1,
          escapeMarkup: function (markup) { return markup; },
          templateResult: formatRepo
        }}
      />
    )
  }
}

const formatRepo = (props) => {
  if(props.text) return props.text
}