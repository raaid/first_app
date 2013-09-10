// Opening popup in Right Buttom of the screen	27-1-12
function T2M_caller_RB(T2MCallId) {
    var h = screen.height - 337;
    var w = screen.width - 350;
    var Wspecs = "top=" + h + ",left=" + w + ",width=260,height=280,location=0,menubar=0,resizable=0,scrollbars=0,status=0,toolbar=0";
    window.open("http://talk-2-me.ca/truevoicecaller.aspx?id=" + T2MCallId, "Call_VIA_T2M", Wspecs);
}

// Opening popup in next to tab			1-28-12/6-23-12/7-26-12
function T2M_caller(T2MCallId) {
    var h = (screen.height / 2) - 200;
    var w = 100;
    var Wspecs = "top=" + h + ",left=" + w + ",width=260,height=280,location=0,menubar=0,resizable=0,scrollbars=0,status=0,toolbar=0";
    window.open("http://talk-2-me.ca/truevoicecaller.aspx?Au=1&bg=336699&id=" + T2MCallId, "Call_VIA_T2M", Wspecs);
}