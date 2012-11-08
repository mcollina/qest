//= require ./jsonlint.js

function setupTopic(topic) {
  var url = window.location.protocol + '//' + window.location.hostname;
  if (window.location.port) {
    url += ':' + window.location.port;
  }
  var socket = io.connect(url)

  var textarea = $("#payload");
  var textarea_error = $("#payload-error");
  var textarea_field = $("#payload-field");
  var update = $("#update");
  var edit = $("#edit");
  var cancel = $("#cancel");
  var validate = $("#validate");

  update.hide();
  cancel.hide();

  var last_data = null;

  update_content = function(data) {
    data = { payload: data }
    last_data = data;
    if(textarea.attr("readonly")) {
      if(typeof data.payload === "string") {
        textarea.val(data.payload);
        validate.removeAttr("checked");
      } else {
        textarea.val(JSON.stringify(data.payload, null, 4));
        validate.attr("checked", true);
        last_data.json = true;
      }
    }
  };

  socket.on("connect", function(data) {
    socket.emit('subscribe', topic);
  });

  socket.on("/topics/" + topic, function(data) {
    update_content(data);
  });

  update.click(function() {
    var val = textarea.val();
    var settings = {
      url: "/topics/"+ topic,
      type: "PUT"
    }
    if(validate.attr("checked")) {
      try {
        val = JSON.parse(val);
        if(typeof val == 'string') {
          throw "invalid json";
        }
        settings.data = JSON.stringify(val);
        settings.contentType = "application/json";
      } catch(e) {
        textarea.addClass("error");
        textarea_field.addClass("error");
        textarea_error.show();
        return false;
      }
    } else {
       settings.data = { payload: val };
    }

    $.ajax(settings);
    textarea.removeClass("error");
    textarea_field.removeClass("error");
    textarea_error.hide();

    textarea.attr("readonly", true);
    validate.attr("disabled", true);
    edit.toggle();
    update.toggle();
    cancel.toggle();
    return false;
  });

  edit.click(function() {
    textarea.removeAttr("readonly");
    validate.removeAttr("disabled");
    update.toggle();
    cancel.toggle();
    edit.toggle();
    return false;
  });

  cancel.click(function() {
    if(last_data.json) {
      textarea.val(JSON.stringify(last_data.payload));
    } else {
      textarea.val(last_data.payload);
    }
    validate.attr("checked", last_data.json);
    textarea.attr("readonly", true);
    validate.attr("disabled", true);
    update.toggle();
    cancel.toggle();
    edit.toggle();

    textarea.removeClass("error");
    textarea_field.removeClass("error");
    textarea_error.hide();
    return false;
  });
}
