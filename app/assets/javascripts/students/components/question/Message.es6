import React, { Component } from 'react' 
import classNames from 'classnames'


export class Message extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    const { message } = this.props
    let iconClass = ""
    if (!!message.poster) {
      switch(message.poster.type) {
        case "teacher":
          iconClass = `el-icon size-small is-teacher u-left`
          break;
        case "student":
          iconClass = `el-icon size-small is-${message.poster.avatar} u-left`
          break;
        default:
          iconClass = `el-icon size-small is-try u-left`
          break; 
      }
    }
    return(
      <li className="message">
        <div className="u-clearfix">
          <div className={iconClass}></div>
          <p className="message-heading u-left">
            {message.poster.name}
          </p>
          <time className="message-date u-right">
            {message.date}
          </time>
        </div>
        <p className="message-text">
          {message.content}
        </p>
        {!!message.image &&
          <div className="message-image">
            <img src={message.image.desktop.resource_url} />
          </div>
        }
        {message.auto_reply &&
          <div className="u-clearfix">
            <p className="message-auto-replay u-right">
              自動返信
            </p>
          </div>
        }
      </li>
    )
  }
}