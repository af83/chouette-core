class window.NotificationCenter
  constructor: (@channel, @receiver)->
    @lastSeen = @getCookie @channel + "_lastSeen"
    @lastReload = Date.now()
    @period = 3000
    requestAnimationFrame(@checkNotifications.bind(this))

  checkNotifications: =>
    reload = @getCookie @channel + "_reloadState"
    if reload && reload > @lastReload
      @receiver.loadState()
      @lastReload = Date.now()
    else
      url = "/notifications?channel=" + @channel
      url = url + "&lastSeen=" + @lastSeen if @lastSeen?

      $.get(url).then (response)=>
        for payload in response
          @lastSeen = payload.id
          @setCookie @channel + "_lastSeen", @lastSeen
          @receiver.receivedNotification(payload)
        setTimeout =>
          requestAnimationFrame(@checkNotifications.bind(this))
        , @period

  reloadState: =>
    @setCookie @channel + "_reloadState", Date.now()

  setCookie: (name, value, days=null) ->
    value = window.escape(value)
    if days
      date = new Date()
      date.setTime date.getTime() + (days * 24 * 60 * 60 * 1000)
      expires = "; expires=" + date.toGMTString()
    else
      expires = ""
    document.cookie = name + "=" + value + expires + "; path=/"

  getCookie: (name) ->
    nameEQ = name + "="
    ca = document.cookie.split(";")
    i = 0

    while i < ca.length
      c = ca[i]
      c = c.substring(1, c.length)  while c.charAt(0) is " "
      return value = window.unescape(c.substring(nameEQ.length, c.length)) if c.indexOf(nameEQ) is 0
      i++
    null

  deleteCookie: (name) ->
    setCookie name, "", -1
