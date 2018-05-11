import React, { Component } from 'react'
import classNames from 'classnames'
import constants from '../../../constants.es6'

export class Graph extends Component {
  constructor(props) {
    super(props)
    this.state = {
      num: 0
    }
  }
  componentDidMount() {
    const { completedVideosCount, totalVideosCount, subject} = this.props
    const bgCxt = this.bgDom.getContext('2d')
    const bgColor = '#eeeeee'
    bgCxt.beginPath()
    bgCxt.fillStyle = bgColor
    bgCxt.arc(constants.graph.centerX, constants.graph.centerY, constants.graph.radius, 0, 360 , false)
    bgCxt.closePath()
    bgCxt.fill()
    this.setState({num: this.state.num + 1})
    this.renderGraph(completedVideosCount, totalVideosCount, subject, this.state.num + 1)
  }
  componentDidUpdate(prevProps, prevState) {
    const { completedVideosCount, totalVideosCount, subject } = this.props
    if (completedVideosCount !== prevProps.completedVideosCount 
      || totalVideosCount !== prevProps.totalVideosCount 
      || subject !== prevProps.subject) {
      this.setState({num: this.state.num + 1})
      this.renderGraph(completedVideosCount, totalVideosCount, subject, this.state.num + 1)
    }
  }
  renderGraph(completedVideos, totalVideos, subj, num) {
    const graphCxt = this.graphDom.getContext('2d')
    const startRad = 0 - 90
    let endAngle = 360 * completedVideos / totalVideos
    endAngle = endAngle > 0 && endAngle < 3 ? 3 : endAngle //0 < endangle <4の時はグラフが見えないので3度とみなす
    const graphColor = constants.subjectColor[subj]
    let animCnt = 0
    graphCxt.beginPath()
    const setSector = () => {
      if (num >= this.state.num) { // 最新のグラフのみ描画(古いグラフを描画中のとき、古いグラフは描画を中止する)
        let endRad = animCnt - 90
        animCnt += 3
        this.graphDom.width = constants.graph.canvasW
        this.graphDom.height = constants.graph.canvasH
        graphCxt.fillStyle = graphColor
        graphCxt.moveTo(constants.graph.centerX, constants.graph.centerY) 
        graphCxt.arc(constants.graph.centerX, constants.graph.centerY, constants.graph.radius, startRad * Math.PI / 180, endRad * Math.PI / 180 , false)
        graphCxt.closePath()
        graphCxt.fill()
        if (animCnt <= endAngle) {
          window.requestAnimationFrame(setSector);
        } else if (completedVideos === 0) { // 0の時も描画時直す(前回のグラフが残っている可能性があるため)
          graphCxt.arc(constants.graph.centerX, constants.graph.centerY, constants.graph.radius, startRad * Math.PI / 180, startRad * Math.PI / 180 , false)
          graphCxt.closePath()
          graphCxt.fill()
        }
      }
    }
    setSector()
  }

  render() {
    const { completedVideosCount, totalVideosCount, subject } = this.props
    const graphClass = `el-graph-number u-color-${subject}`
    return(
      <div className="el-graph">
        <canvas width="130" height="130" ref={(canvas) => this.bgDom = canvas} />
        <canvas width="130" height="130" ref={(canvas) => this.graphDom = canvas} />
        <p className={graphClass}>
          <span>{completedVideosCount}</span>
          <br/>
          / {totalVideosCount}
        </p>
      </div>
    )
  }
}
