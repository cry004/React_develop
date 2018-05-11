TryAdminApp = TryAdminApp or {}
window.TryAdminApp = TryAdminApp

class SearchView
  constructor: ->
    @searchButton = $('#typusSearchButton')
    @searchAttribute = new SearchAttribute(this)
    this.setEvent()

  getSearchAttribute: ->
    return @searchAttribute
  getSearchButton: ->
    return @searchButton

  setEvent: ()->
    that = this
    @searchButton.on('click', (e)->
      that.submit()
    )

  submit: ()->
    text = @searchAttribute.getTextVal()
    name = @searchAttribute.getName()
    if text and name
      window.location.href = "/admin/students?#{name}=#{text}"
class SearchAttribute
  constructor: (parent)->
    @parent = parent
    @el = $('#typusSearchAttribute')
    @textEl = $('#typusSearchText')
    this.initParentDisabled()
    this.setEvent()

  initParentDisabled: ()->
    this.toggleDisabled()

  setEvent: ()->
    that = this
    @el.on('change', (e)->
      that.toggleDisabled()
    )

  getTextVal: ()->
    return @textEl.val()
  getName: ()->
    return @el.val()

  toggleDisabled: ()->
    parentSearchButton = @parent.getSearchButton()
    if @el.val() != ''
      parentSearchButton.prop('disabled', false)
    else
      parentSearchButton.prop('disabled', true)

TryAdminApp.SearchView = SearchView

$(() -> )
