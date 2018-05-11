import React, { Component } from 'react'

export class SettingBtn extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { editFlag, learning_status, learning_id, box_id, sent_on, student_id, period_id, sub_unit_id, main_box_id } = this.props
    let settingBtnDom
    switch(learning_status) {
      case 'pass':
      case 'failure':
        settingBtnDom = <input type="button" className="el-button size-setting color-setting" value="もう一度授業に設定" onClick={this.props.onSetLearning.bind(this, learning_id, box_id, 'resent', sent_on, student_id, period_id, sub_unit_id)} />
        break;
      case 'sent':
        if( box_id == main_box_id){
          settingBtnDom = <input type="button" className="el-button size-setting color-return icon-return" value="もとにもどす" onClick={this.props.onSetLearning.bind(this, learning_id, box_id, 'scheduled', sent_on, student_id, period_id, sub_unit_id)} />
        }else{
          settingBtnDom = <input type="button" className="el-button size-setting" value="+ 今回の授業に設定" onClick={this.props.onSetLearning.bind(this, learning_id, box_id, 'sent', sent_on, student_id, period_id, sub_unit_id)} />
        }

        break;
      case 'scheduled':
      case null:
      default:
        settingBtnDom = <input type="button" className="el-button size-setting" value="+ 今回の授業に設定" onClick={this.props.onSetLearning.bind(this, learning_id, box_id, 'sent', sent_on, student_id, period_id, sub_unit_id)} />
        break;
    }
    if(editFlag) {
      settingBtnDom = null
    }
    return (
      <div>
        {settingBtnDom}
      </div>
    )
  }
}
