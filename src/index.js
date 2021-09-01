import 'lodash'
import 'jquery'
import 'bootstrap'

import 'bootstrap/dist/css/bootstrap.min.css';
import './index.css'

/**
 * Print Hello World
 */
function helloWorld() {
  console.log('Hello World');
};

function FWToggle() {
  // Get the checkbox
  var checkBox = document.getElementById("FWCheck");
  // Get the output text
  var text = document.getElementById("FWYes");

  // If the checkbox is checked, display the output text
  if (checkBox.checked == true) {
    text.style.display = "block";
  } else {
    text.style.display = "none";
  }
}

// Fix proper later
function CloseAlert() {
  document.getElementById("MacroAssignedAlert").style.display = "none";
}

function ShowModal() {
  $('#SetSettingsModal').modal();
}

function SettingsPage() {
  $('#v-pills-tab a[href="#v-pills-Settings"]').tab('show')
}

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})