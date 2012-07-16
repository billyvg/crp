$ = jQuery

$ ->
  window.namespace 'Focus', (exports, top) ->
    exports.app = new top.Crp.App
      el: '#main'

