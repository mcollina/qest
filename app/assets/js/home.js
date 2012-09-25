
$(document).ready(function() {
  $("#go").submit(function() {
    var val = $("#topic").val()
    if(val.length > 0) {
      window.location = "/topics/" + val;
    }
    return false;
  });
});
