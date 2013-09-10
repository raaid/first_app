//$("input.date_picker").datepicker();

$(function() {
    $("#date-pick").datepicker({
        showOn: "button",
        buttonImage: "/images/cal2.png",
        buttonImageOnly: true
    });
});
$(document).ready(function() {
    $("#date-pick").datepicker({
        dateFormat: "mm-dd-yy"
    });
    $("#date-pick").focus(function() {
        $("#date-pick").datepicker("show");
    });
});

$(function() {
    $("#date-pick2").datepicker({
        showOn: "button",
        buttonImage: "/images/cal2.png",
        buttonImageOnly: true,
        minDate: +21
    });
});
$(document).ready(function() {
    $("#date-pick2").datepicker({
        dateFormat: "mm-dd-yy"
    });
    $("#date-pick2").focus(function() {
        $("#date-pick2").datepicker("show");
    });
});
$(function() {
    $("#date-pick3").datepicker({
        showOn: "button",
        buttonImage: "/images/cal2.png",
        buttonImageOnly: true
    });
});
$(document).ready(function() {
    $("#date-pick3").datepicker({
        dateFormat: "mm-dd-yy"
    });
    $("#date-pick3").focus(function() {
        $("#date-pick3").datepicker("show");
    });
});

