$ ->
  $('#toggle_board').on 'click', ->
    $('#board').toggle()
    return
  $('#remove_robots').on 'click', ->
    $('#robot_4').remove()
    $('#robot_5').remove()
    $('#robot_6').remove()
    $('#robot_7').remove()
    $('#robot_8').remove()
    return
  delay = 1000
  $('#play_sequence_01').on 'click', (e) ->
    # first cards
    # Robot 1 move 3
    setTimeout (->
      $('#robot_1').removeClass 'y_0'
      $('#robot_1').addClass 'y_3'
      return
    ), 0
    # Robot 2 move 1
    setTimeout (->
      $('#robot_2').removeClass 'y_0'
      $('#robot_2').addClass 'y_1'
      return
    ), 1 * delay
    # Robot 3 rotate left
    setTimeout (->
      $('#robot_3').removeClass 'face_180'
      $('#robot_3').addClass 'face_90'
      return
    ), 2 * delay
    return
  $('#play_sequence_02').on 'click', (e) ->
    # second cards
    # Robot 2 move 2
    setTimeout (->
      $('#robot_2').removeClass 'y_1'
      $('#robot_2').addClass 'y_3'
      return
    ), 0
    # Robot 3 move -1
    setTimeout (->
      $('#robot_3').removeClass 'x_2'
      $('#robot_3').addClass 'x_1'
      return
    ), 1 * delay
    # Robot 1 rotate u-turn
    setTimeout (->
      $('#robot_1').removeClass 'face_180'
      $('#robot_1').addClass 'face_0'
      return
    ), 2 * delay
    return
  return
