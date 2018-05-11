import React, { Component } from 'react'
import { connect } from 'react-redux'

class CommerceLaw extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    return (
      <div className="page-static">
        <div className="top">
          <h2 className="top-heading">特定商取引法に関する表示</h2>
          <p className="top-description">
            「特定商取引に関する法律」第11条に基づき、以下の通り表示いたします。</p>
        </div>
        <div className="content">
          <h3 className="content-heading">販売事業者の名称・所在地</h3>
          <p className="content-text">
            株式会社トライグループ
            <br/>
            東京都千代田区飯田橋1丁目10番3号
            <br/>
          </p>
          <h3 className="content-heading">責任者名</h3>
          <p className="content-text">
            Try IT事業部　責任者　森山真有
          </p>
          <h3 className="content-heading">お問い合わせ</h3>
          <p className="content-text">
            0120-555-202
            <br/>
            受付時間：10:00-17:00
            <br/>
            月～金（祝日・年末年始・GW・夏季休業除く）
          </p>
          <h3 className="content-heading">販売価格</h3>
          <p className="content-text">
            購入手続きの際に画面に表示されます。
          </p>
          <h3 className="content-heading">販売価格以外でお客様に発生する金銭</h3>
          <p className="content-text">
            当サイトのページの閲覧、コンテンツ購入、ソフトウェアのダウンロード等に必要となるインターネット接続料金、通信料金等はお客様の負担となります。
            <br/>
            それぞれの料金は、お客様がご利用のインターネットプロバイダーまたは携帯電話会社にお問い合わせください。
          </p>
          <h3 className="content-heading">
            商品が利用可能となる時期
          </h3>
          <p className="content-text">
            購入に関するページに特別な定めを置いている場合を除き、購入取引完了後、直ちにご利用いただけます。
          </p>
          <h3 className="content-heading">
            お支払方法
          </h3>
          <p className="content-text">
            以下のお支払方法をご利用いただけます。
            <br/>
            ・クレジットカード
          </p>
          <h3 className="content-heading">
            支払時期
          </h3>
          <p className="content-text">
            利用規約に定めるとおりとします。
          </p>
          <h3 className="content-heading">
            キャンセル・返品
          </h3>
          <p className="content-text">
            オプションサービス等購入後のお客様のご都合によるキャンセルは、お受けできません。
            <br/>
            その他商品をご購入いただいた後のお客様のご都合による返品は、お受けできません。
            <br/>
            なお、商品初期不良（問題集の乱丁、落丁など）の場合、商品の返品についてご対応いたします。
          </p>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(CommerceLaw);