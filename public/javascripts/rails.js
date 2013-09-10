(function(d) {
    var c;
    d.rails = c = {linkClickSelector:"a[data-confirm], a[data-method], a[data-remote]",formSubmitSelector:"form",formInputClickSelector:"form input[type=submit], form input[type=image], form button[type=submit], form button:not([type])",disableSelector:"input[data-disable-with], button[data-disable-with], textarea[data-disable-with]",enableSelector:"input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled",requiredInputSelector:"input[name][required],textarea[name][required]",
        fileInputSelector:"input:file",CSRFProtection:function(a) {
            var b = d('meta[name="csrf-token"]').attr("content");
            b && a.setRequestHeader("X-CSRF-Token", b)
        },fire:function(a, b, c) {
            b = d.Event(b);
            a.trigger(b, c);
            return b.result !== !1
        },confirm:function(a) {
            return confirm(a)
        },ajax:function(a) {
            return d.ajax(a)
        },handleRemote:function(a) {
            var b,g,e,f = a.data("type") || d.ajaxSettings && d.ajaxSettings.dataType;
            if (c.fire(a, "ajax:before")) {
                if (a.is("form")) {
                    b = a.attr("method");
                    g = a.attr("action");
                    e = a.serializeArray();
                    var h = a.data("ujs:submit-button");
                    h && (e.push(h),a.data("ujs:submit-button", null))
                } else b = a.data("method"),g = a.attr("href"),e = null;
                c.ajax({url:g,type:b || "GET",data:e,dataType:f,beforeSend:function(b, d) {
                    d.dataType === void 0 && b.setRequestHeader("accept", "*/*;q=0.5, " + d.accepts.script);
                    return c.fire(a, "ajax:beforeSend", [b,d])
                },success:function(b, c, d) {
                    a.trigger("ajax:success", [b,c,d])
                },complete:function(b, c) {
                    a.trigger("ajax:complete", [b,c])
                },error:function(b, c, d) {
                    a.trigger("ajax:error", [b,c,d])
                }})
            }
        },handleMethod:function(a) {
            var b = a.attr("href"),
                c = a.data("method"),a = d("meta[name=csrf-token]").attr("content"),e = d("meta[name=csrf-param]").attr("content"),b = d('<form method="post" action="' + b + '"></form>'),c = '<input name="_method" value="' + c + '" type="hidden" />';
            e !== void 0 && a !== void 0 && (c += '<input name="' + e + '" value="' + a + '" type="hidden" />');
            b.hide().append(c).appendTo("body");
            b.submit()
        },disableFormElements:function(a) {
            a.find(c.disableSelector).each(function() {
                var b = d(this),a = b.is("button") ? "html" : "val";
                b.data("ujs:enable-with", b[a]());
                b[a](b.data("disable-with"));
                b.attr("disabled", "disabled")
            })
        },enableFormElements:function(a) {
            a.find(c.enableSelector).each(function() {
                var b = d(this),a = b.is("button") ? "html" : "val";
                if (b.data("ujs:enable-with"))b[a](b.data("ujs:enable-with"));
                b.removeAttr("disabled")
            })
        },allowAction:function(a) {
            var b = a.data("confirm"),d = !1,e;
            if (!b)return!0;
            c.fire(a, "confirm") && (d = c.confirm(b),e = c.fire(a, "confirm:complete", [d]));
            return d && e
        },blankInputs:function(a, b, c) {
            var e = d(),f;
            a.find(b || "input,textarea").each(function() {
                f = d(this);
                if (c ? f.val() :
                    !f.val())e = e.add(f)
            });
            return e.length ? e : !1
        },nonBlankInputs:function(a, b) {
            return c.blankInputs(a, b, !0)
        },stopEverything:function(a) {
            d(a.target).trigger("ujs:everythingStopped");
            a.stopImmediatePropagation();
            return!1
        },callFormSubmitBindings:function(a) {
            var a = a.data("events"),b = !0;
            a !== void 0 && a.submit !== void 0 && d.each(a.submit, function(a, c) {
                if (typeof c.handler === "function")return b = c.handler(c.data)
            });
            return b
        }};
    "ajaxPrefilter"in d ? d.ajaxPrefilter(function(a, b, d) {
        c.CSRFProtection(d)
    }) : d(document).ajaxSend(function(a, b) {
        c.CSRFProtection(b)
    });
    d(c.linkClickSelector).live("click.rails", function(a) {
        var b = d(this);
        if (!c.allowAction(b))return c.stopEverything(a);
        if (b.data("remote") !== void 0)return c.handleRemote(b),!1; else if (b.data("method"))return c.handleMethod(b),!1
    });
    d(c.formSubmitSelector).live("submit.rails", function(a) {
        var b = d(this),g = b.data("remote") !== void 0,e = c.blankInputs(b, c.requiredInputSelector),f = c.nonBlankInputs(b, c.fileInputSelector);
        if (!c.allowAction(b))return c.stopEverything(a);
        if (e && c.fire(b, "ajax:aborted:required",
            [e]))return c.stopEverything(a);
        if (g) {
            if (f)return c.fire(b, "ajax:aborted:file", [f]);
            if (!d.support.submitBubbles && c.callFormSubmitBindings(b) === !1)return c.stopEverything(a);
            c.handleRemote(b);
            return!1
        } else setTimeout(function() {
            c.disableFormElements(b)
        }, 13)
    });
    d(c.formInputClickSelector).live("click.rails", function(a) {
        var b = d(this);
        if (!c.allowAction(b))return c.stopEverything(a);
        a = (a = b.attr("name")) ? {name:a,value:b.val()} : null;
        b.closest("form").data("ujs:submit-button", a)
    });
    d(c.formSubmitSelector).live("ajax:beforeSend.rails",
        function(a) {
            this == a.target && c.disableFormElements(d(this))
        });
    d(c.formSubmitSelector).live("ajax:complete.rails", function(a) {
        this == a.target && c.enableFormElements(d(this))
    })
})(jQuery);
