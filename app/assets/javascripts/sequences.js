$(function () {
  $("#toggle_board").on("click", function() {
    $("#board").toggle();
  });

  $("#remove_robots").on("click", function() {
    $("#robot_4").remove();
    $("#robot_5").remove();
    $("#robot_6").remove();
    $("#robot_7").remove();
    $("#robot_8").remove();
  });

  var delay = 1000;

  $("#play_sequence_01").on("click", function(e) {

    // first cards

    // Robot 1 move 3
    setTimeout(function() {
      $("#robot_1").removeClass("y_0");
      $("#robot_1").addClass("y_3");
    }, 0);

    // Robot 2 move 1
    setTimeout(function() {
      $("#robot_2").removeClass("y_0");
      $("#robot_2").addClass("y_1");
    }, 1 * delay);

    // Robot 3 rotate left
    setTimeout(function() {
      $("#robot_3").removeClass("face_180");
      $("#robot_3").addClass("face_90");
    }, 2 * delay);

  });

  $("#play_sequence_02").on("click", function(e) {

    // second cards

    // Robot 2 move 2
    setTimeout(function() {
      $("#robot_2").removeClass("y_1");
      $("#robot_2").addClass("y_3");
    }, 0);

    // Robot 3 move -1
    setTimeout(function() {
      $("#robot_3").removeClass("x_2");
      $("#robot_3").addClass("x_1");
    }, 1 * delay);

    // Robot 1 rotate u-turn
    setTimeout(function() {
      $("#robot_1").removeClass("face_180");
      $("#robot_1").addClass("face_0");
    }, 2 * delay);

  })

});
