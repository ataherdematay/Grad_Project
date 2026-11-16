(function () {
  var root = document.documentElement;
  function stored() { try { return localStorage.getItem("bt-lang"); } catch (e) { return null; } }
  function save(v) { try { localStorage.setItem("bt-lang", v); } catch (e) {} }
  function apply(lang) {
    root.setAttribute("data-lang", lang);
    root.setAttribute("lang", lang);
    var btns = document.querySelectorAll(".lang button");
    for (var i = 0; i < btns.length; i++) {
      btns[i].setAttribute("aria-pressed", btns[i].getAttribute("data-set") === lang ? "true" : "false");
    }
    var t = document.documentElement.getAttribute("data-title-" + lang);
    if (t) document.title = t;
  }
  var q = /[?&]lang=(tr|en)/.exec(location.search);
  var initial = (q && q[1]) || stored() || "tr";
  apply(initial);
  document.addEventListener("click", function (e) {
    var b = e.target.closest && e.target.closest(".lang button");
    if (!b) return;
    var l = b.getAttribute("data-set");
    save(l);
    apply(l);
  });
})();
