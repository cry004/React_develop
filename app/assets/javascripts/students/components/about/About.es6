import React, { Component } from 'react'
import { connect } from 'react-redux'

class About extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    return (
      <div className="page-about">
        <h1 className="heading">Try ITについて</h1>
        <div className="container u-clearfix">
          <ul className="menu u-left">
            <li>
              添削指導サービスについて
            </li>
          </ul>
          <div className="u-left pointconfig__introduction">
            <div className="pointconfig__about">
              <div className="pointconfig__top">
                <p className="pointconfig__top__description">
                  ポイントを増やすには、マイページ（管理画面）にアクセスいただき、
                  <br/>
                  ポイントの利用設定をお願いします。
                </p>
                <a href="https://www.try-it.jp/mypage/" target="_blank" className="el-button size-large is-white">
                  マイページ（管理画面）をブラウザでひらく
                </a>
              </div>
              <div className="pointconfig__about__mov"><iframe frameborder="0" height="478px" src="https://www.youtube.com/embed/VHZYhJmb8Ec?rel=0&amp;amp;showinfo=0" width="850px">allowfullscreen</iframe></div></div><div className="pointconfig__txt"><p className="pointconfig-ruby">Try IT<i>トライイット</i></p>では以下のオプションサービスがご利用いただけます。</div><div className="pointconfig__service"><h2 className="pointconfig__service__title">トライさんの「<p className="pointconfig-ruby">添削<i>てんさく</i></p>指導サービス」</h2><div className="pointconfig__serviceInner"><dl className="pointconfig__service__what"><dt><span>1</span>トライさんの「<p className="pointconfig-ruby">添削<i>てんさく</i></p>指導サービス」とは</dt><dd className="u-clearfix"><p className="pointconfig__service__what__description">Try ITなら、勉強中の「わからない」を残しません！<br/>映像授業のことでも、学校・塾のことでも、<br/>スマホを「振る」だけで、すぐに質問ができます。<br/>トライの厳選教師の丁寧な添削指導が受けられます。<br/>中学版は、英語・数学・国語・理科・社会、<br/>高校版は、英語・数学・国語・物理・化学・生物・<br/>日本史・世界史・地理について質問が可能です。<br/><span>※PC、タブレットの場合はボタン１つで質問可能です。</span></p><div className="pointconfig__service__what__image"><img alt="" src="https://assets.try-it.jp/assets/introduction/pointconfig_trysan-a1fb80e58b51e82a27d8ca2acb6e19686132e3cb471db55ace47fb0a1d45f115.png" /></div></dd></dl><dl className="pointconfig__service__flow"><dt><span>2</span>「<p className="pointconfig-ruby">添削<i>てんさく</i></p>指導サービス」利用の流れ</dt><dd><img alt="" src="https://assets.try-it.jp/assets/introduction/pointconfig_flow-c6c108e1e8c140f40e5ed5ca48176c459fbcc6072f6a82f8baebb4445c64a570.png" /></dd></dl><dl className="pointconfig__service__check"><dt><span>3</span>「<p className="pointconfig-ruby">添削<i>てんさく</i></p>指導サービス」を受けるにあたって</dt><dd><ul className="pointconfig__service__checkList"><li>・映像授業のことでも、学校・塾のことでも質問することができます。</li><li>・質問をいただいてから翌日24時までに添削をお返しします。</li><li>・添削は、1回につき500円（税別）でご利用いただけます</li></ul><div className="pointconfig__service__checkPoint"><div className="pointconfig__service__checkPoint_title"><span>ご注意ください</span></div><div className="pointconfig__service__checkPoint_list"><ul><li>・質問は中学校および高等学校の学習指導要領の範囲に限ります。</li><li>・1回で質問できる範囲は、原則大問は1問までといたします。</li><li>・質問の写真（画像）は鮮明なものでお願いいたします。</li><li>・質問内容は具体的に明記してください。</li><li>・公序良俗に反する質問などお答えしかねることがございますが、<br/>　ご了承ください。</li><li>・ご利用の際は、必ず利用規約をご確認下さい。</li></ul></div></div></dd></dl></div></div><div className="pointconfig__step"><h2 className="pointconfig__step__title">利用開始までの流れ</h2><dl className="pointconfig__step__flow"><dt><span>STEP 1</span>クレジットカードのご登録</dt><dd>お支払いは、ご登録のクレジットカードより毎月決済できます。<br/>入力画面よりクレジットカード情報をご登録いただきます。</dd><dt><span>STEP 2</span>ご利用限度額の設定 (あんしんストッパー制度)</dt><dd>Try IT では、生徒（利用者）がオプションサービスを利用しすぎないように、<br/>ご利用できる金額について保護者の方に上限金額を設定して頂いております。<br/><span>※「限度額＝月額定額料金」ではございません。<br/>　利用した料金分のみをご請求致しますので、生徒（利用者）のオプションサービスの<br/>　利用がない月は、お支払いは発生しません。</span></dd></dl><div className="pointconfig__step__stoper"><img alt="" src="https://assets.try-it.jp/assets/introduction/pointconfig_anshinstoper-7ebe1853c31b10ecdc83126e1e3516dc105c5625e266e533be00681ff9b2ead6.png" /></div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(About);