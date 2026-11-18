class JavaScriptCode {
  static var desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static const String resetCode =
      'window.__resetMapUI && window.__resetMapUI();';

  static var javascriptCode = r'''
(function () {
  if (window.__mapScreenInitDone) return;
  window.__mapScreenInitDone = true;

  /* The site's ".row" has margin-left:-15px, which shifts the map image.
     Plot numbers are positioned from the container origin, so we keep the
     same offset on the image. Change this number only if the plot numbers
     are still off horizontally (negative = image moves left). */
  var IMG_OFFSET_X = -15;

  /* ================================================================
     1. FORCE MOBILE VIEWPORT
     ================================================================ */
  var meta = document.querySelector('meta[name="viewport"]');
  if (!meta) {
    meta = document.createElement('meta');
    document.head.appendChild(meta);
  }
  meta.name = 'viewport';
  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';

  /* ================================================================
     2. CSS INJECTION
     ================================================================ */
  var customStyle = document.createElement('style');
  customStyle.innerHTML = `
    html, body {
      width: 100% !important;
      height: 100% !important;
      margin: 0 !important;
      padding: 0 !important;
      overflow: hidden !important;
      background-color: #003331 !important;
      touch-action: none !important;
    }

    /* ── HEADER ── */
    #mainHeaderContainer {
      position: fixed !important;
      top: 0 !important;
      left: 0 !important;
      background-color: #003331 !important;
      z-index: 10001 !important;
      padding: 6px 14px 8px 14px !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.5) !important;
      transform-origin: top left !important;
    }

    .filter-controls-container {
      display: flex !important;
      flex-wrap: nowrap !important;
      align-items: flex-end !important;
      gap: 10px !important;
      min-width: 1100px !important;
    }

    .filter-box { flex: 1 !important; }
    .filter-box label { color: #fff !important; font-size: 13px !important; font-weight: 500 !important; margin-bottom:2px !important;}
    .filter-box select, .filter-box input { width: 100% !important; height: 32px !important; font-size: 13px !important; padding: 2px 8px !important; border-radius: 4px !important; }

    .search-retrieve-box {
      display: flex !important;
      align-items: flex-end !important;
      gap: 8px !important;
      flex: 0 0 350px !important;
    }

    .search-input-field { flex: 1 !important; }
    .search-input-field input { height: 32px !important; width: 100% !important; font-size: 13px !important; }

    .btn-retrieve-style {
      background-color: #3993ad !important; color: #fff !important; font-weight: bold !important;
      height: 32px !important; padding: 0 16px !important; border-radius: 4px !important;
      font-size: 13px !important; border: none !important; cursor:pointer !important;
    }

    .search-icon-btn i { color: #28a745 !important; font-size: 26px !important; margin-left: 5px !important; }

    /* ── SIDEBAR ── */
    #mapSidebar {
      position: fixed !important;
      right: 0 !important;
      width: 65px !important;
      background: #003331 !important;
      z-index: 10000 !important;
      border-left: 1px solid rgba(255,255,255,0.2) !important;
    }

    #sidebarappend {
      overflow-y: auto !important;
      overflow-x: hidden !important;
      -webkit-overflow-scrolling: touch !important;
      text-align: center !important;
    }

    #sidebarappend a {
      display: block !important; color: #fff !important; font-size: 12px !important;
      font-weight: bold !important; padding: 5px 0 !important; text-decoration: none !important;
      border-bottom: 1px solid rgba(255,255,255,0.1) !important;
    }

    /* ── MAP CANVAS ──
       Container origin (0,0) is the origin for all plot margins from the API. */
    #PlotsAppendid {
      position: absolute !important;
      top: 0 !important; left: 0 !important;
      margin: 0 !important; padding: 0 !important;
      transform-origin: 0 0 !important;
      will-change: transform !important;
      z-index: 1 !important;
    }
    /* restore the image offset the original page had (.row negative margin) */
    #PlotsAppendid > div:first-child {
      margin-left: ${IMG_OFFSET_X}px !important;
    }
    #PlotsAppendid img { pointer-events: none !important; max-width: none !important; }
    .modal { z-index: 20000 !important; }

    /* ── PLOT INFO MODAL: compact size ── */
    #exampleModal .modal-dialog {
      width: 420px !important;
      max-width: 94vw !important;
      margin: 6px auto !important;
    }
    #exampleModal .modal-content {
      max-height: calc(100vh - 12px) !important;
      overflow-y: auto !important;
      -webkit-overflow-scrolling: touch !important;
      border-radius: 10px !important;
    }
    #exampleModal, #exampleModal * { touch-action: pan-y !important; }

    #exampleModal .modal-header {
      padding: 6px 12px !important;
      min-height: 0 !important;
    }
    #exampleModal .modal-header .modal-title {
      font-size: 14px !important;
      line-height: 1.2 !important;
      margin: 0 !important;
    }
    #exampleModal .modal-header .close { margin-top: -2px !important; font-size: 22px !important; }

    #exampleModal .modal-body {
      padding: 8px 10px !important;
    }
    #exampleModal .modal-body h4 {
      font-size: 14px !important;
      margin: 0 0 6px 0 !important;
    }
    #exampleModal .modal-body .row {
      margin-left: -4px !important;
      margin-right: -4px !important;
    }
    #exampleModal .modal-body .row > [class*="col-md-"] {
      float: left !important;
      width: 33.3333% !important;
      max-width: 33.3333% !important;
      flex: 0 0 33.3333% !important;
      padding: 0 4px !important;
      margin-bottom: 4px !important;
    }
    #exampleModal label {
      font-size: 11px !important;
      margin-bottom: 1px !important;
    }
    #exampleModal input.form-control {
      height: 26px !important;
      font-size: 12px !important;
      padding: 2px 6px !important;
    }

    /* hide Reserve / Allocation / Go To Live */
    #exampleModal .StatusAdd,
    #exampleModal #goToLive,
    #exampleModal .info,
    #exampleModal .info2 {
      display: none !important;
    }

    #interestedWrap {
      padding: 8px 12px 12px 12px;
      background: #9c3bd9;
      text-align: center;
    }
    #interestedBtn {
      width: 100%;
      height: 38px;
      border: none;
      border-radius: 8px;
      background: #3993ad;
      color: #fff;
      font-size: 15px;
      font-weight: bold;
      cursor: pointer;
    }
  `;
  document.head.appendChild(customStyle);

  /* ================================================================
     2b. MODAL HELPERS + "INTERESTED" BUTTON
     ================================================================ */
  function val(id) {
    var el = document.getElementById(id);
    return el ? (el.value || '').toString().trim() : '';
  }

  // Force-close the plot modal immediately (no animation needed), so it can
  // never stay on top of the map and block touches.
  function closePlotModal() {
    if (window.jQuery) { try { window.jQuery('#exampleModal').modal('hide'); } catch (_) {} }
    var m = document.getElementById('exampleModal');
    if (m) {
      m.classList.remove('in');
      m.style.display = 'none';
      m.setAttribute('aria-hidden', 'true');
    }
    document.body.classList.remove('modal-open');
    document.body.style.paddingRight = '';
    var backs = document.querySelectorAll('.modal-backdrop');
    for (var i = 0; i < backs.length; i++) backs[i].parentNode.removeChild(backs[i]);
  }

  function addInterestedButton() {
    if (document.getElementById('interestedBtn')) return;
    var content = document.querySelector('#exampleModal .modal-content');
    if (!content) { setTimeout(addInterestedButton, 500); return; }

    var wrap = document.createElement('div');
    wrap.id = 'interestedWrap';
    wrap.innerHTML = '<button type="button" id="interestedBtn">Interested</button>';
    content.appendChild(wrap);

    document.getElementById('interestedBtn').addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();

      var payload = {
        branchCode: val('brncode'),
        blockNo: val('blockno'),
        plotNo: val('plotno'),
        plotSize: val('PlotSize'),
        plotNature: val('PlotNature'),
        plotType: val('Type')
      };

      closePlotModal();

      try {
        if (window.InterestedChannel) {
          window.InterestedChannel.postMessage(JSON.stringify(payload));
        }
      } catch (err) {}

      // second cleanup in case bootstrap finished its own hide late
      setTimeout(closePlotModal, 400);
    });
  }
  addInterestedButton();

  /* ================================================================
     3. DYNAMIC LAYOUT & SCALING LOGIC
     ================================================================ */
  var currentScale = 1.0;
  var currentPanX = 0;
  var currentPanY = 0;

  function applyTransform() {
    var mapEl = document.getElementById('PlotsAppendid');
    if (mapEl) {
      mapEl.style.transform =
        'translate3d(' + currentPanX.toFixed(2) + 'px,' +
        currentPanY.toFixed(2) + 'px, 0px) scale(' + currentScale.toFixed(4) + ')';
    }
  }

  function recalculateLayout() {
    var header = document.getElementById('mainHeaderContainer');
    var targetHeaderWidth = 1120;
    var screenW = window.innerWidth;
    var headerScale = screenW < targetHeaderWidth ? (screenW / targetHeaderWidth) : 1;

    if (header) {
      header.style.transform = 'scale(' + headerScale + ')';
      header.style.width = (100 / headerScale) + '%';
    }

    var sidebar = document.getElementById('mapSidebar');
    var sidebarAppend = document.getElementById('sidebarappend');
    var rect = header ? header.getBoundingClientRect() : { height: 70 };
    var headerH = rect.height;

    if (sidebar) {
      sidebar.style.top = headerH + 'px';
      sidebar.style.height = 'calc(100vh - ' + headerH + 'px)';
    }
    if (sidebarAppend && sidebar) {
      sidebarAppend.style.height = (sidebar.offsetHeight - 45) + 'px';
    }
    return headerH;
  }

  /* Fit the whole map image into the free area (uses the image's real
     position inside the container, so margins are respected). */
  function autoFitMap() {
    var img = document.querySelector('#PlotsAppendid img');
    if (!img || img.naturalWidth === 0) {
      setTimeout(autoFitMap, 500);
      return;
    }

    var headerH = recalculateLayout();
    var availW = window.innerWidth - 65;
    var availH = window.innerHeight - headerH;

    var imgW = img.naturalWidth;
    var imgH = img.naturalHeight;
    var ox = img.offsetLeft || 0;   // image offset inside container
    var oy = img.offsetTop || 0;

    var scaleW = availW / imgW;
    var scaleH = availH / imgH;
    currentScale = Math.min(scaleW, scaleH) * 0.95;
    if (currentScale < 0.1) currentScale = 0.1;
    if (currentScale > 2.0) currentScale = 2.0;

    currentPanX = (availW - imgW * currentScale) / 2 - ox * currentScale;
    currentPanY = headerH + (availH - imgH * currentScale) / 2 - oy * currentScale;
    applyTransform();
  }

  window.addEventListener('resize', function() {
    recalculateLayout();
    autoFitMap();
  });

  setInterval(recalculateLayout, 1000);
  setTimeout(autoFitMap, 800);

  /* ================================================================
     4. CUSTOM PINCH & PAN ENGINE
     ================================================================ */
  var isPinching = false, isDragging = false;
  var startDist = 0, startScale = 1.0;
  var startX = 0, startY = 0, initialPanX = 0, initialPanY = 0;

  function dist(t) {
    var dx = t[0].clientX - t[1].clientX;
    var dy = t[0].clientY - t[1].clientY;
    return Math.sqrt(dx * dx + dy * dy);
  }

  function mid(t) {
    return { x: (t[0].clientX + t[1].clientX) / 2, y: (t[0].clientY + t[1].clientY) / 2 };
  }

  function isOverUI(el) {
    if (!el) return false;
    return Boolean(el.closest('#mainHeaderContainer') || el.closest('#mapSidebar') || el.closest('.modal') || el.closest('#__customDD'));
  }

  document.addEventListener('touchstart', function (e) {
    if (isOverUI(e.target)) return;
    if (e.touches.length === 2) {
      isPinching = true; isDragging = false;
      startDist = dist(e.touches); startScale = currentScale;
      initialPanX = currentPanX; initialPanY = currentPanY;
    } else if (e.touches.length === 1) {
      isDragging = true; isPinching = false;
      startX = e.touches[0].clientX; startY = e.touches[0].clientY;
      initialPanX = currentPanX; initialPanY = currentPanY;
    }
  }, { passive: true });

  document.addEventListener('touchmove', function (e) {
    if (isOverUI(e.target)) return;
    if (isPinching && e.touches.length === 2) {
      e.preventDefault();
      var newScale = Math.min(5.0, Math.max(0.1, startScale * (dist(e.touches) / startDist)));
      var m = mid(e.touches);
      currentPanX = m.x - (m.x - initialPanX) * (newScale / startScale);
      currentPanY = m.y - (m.y - initialPanY) * (newScale / startScale);
      currentScale = newScale;
      applyTransform();
    } else if (isDragging && e.touches.length === 1) {
      var dx = e.touches[0].clientX - startX;
      var dy = e.touches[0].clientY - startY;
      if (Math.abs(dx) > 5 || Math.abs(dy) > 5) {
        e.preventDefault();
        currentPanX = initialPanX + dx;
        currentPanY = initialPanY + dy;
        applyTransform();
      }
    }
  }, { passive: false });

  document.addEventListener('touchend', function (e) {
    if (e.touches.length === 0) { isDragging = false; isPinching = false; }
    else if (e.touches.length === 1) {
      isPinching = false; isDragging = true;
      startX = e.touches[0].clientX; startY = e.touches[0].clientY;
      initialPanX = currentPanX; initialPanY = currentPanY;
    }
  }, { passive: true });

  document.addEventListener('touchcancel', function () {
    isDragging = false; isPinching = false;
  }, { passive: true });

  /* ================================================================
     5. CENTER MAP ON SELECTED PLOT (SIDEBAR / SEARCH)
     NOTE: the page calls plot_div(id, TOP_margin, LEFT_margin)
     ================================================================ */
  var prevPlotDiv = window.plot_div;
  window.plot_div = function (id, top_margin, left_margin) {
    if (typeof prevPlotDiv === 'function') {
      try { prevPlotDiv(id, top_margin, left_margin); } catch (_) {}
    }
    var tm = parseFloat(top_margin);
    var lm = parseFloat(left_margin);
    if (!isNaN(lm) && !isNaN(tm)) {
      var headerH = document.getElementById('mainHeaderContainer').getBoundingClientRect().height;
      var viewW = window.innerWidth - 65;
      var viewH = window.innerHeight - headerH;

      if (currentScale < 1.0) currentScale = 1.3;
      currentPanX = (viewW / 2) - (lm * currentScale);
      currentPanY = headerH + (viewH / 2) - (tm * currentScale);
      applyTransform();
    }
  };

  /* ================================================================
     6. CUSTOM DROPDOWN SELECTOR FIX
     ================================================================ */
  var dd = null;
  function closeDD() { if (dd) { dd.remove(); dd = null; } }

  document.addEventListener('touchstart', function (e) {
    if (dd && !dd.contains(e.target)) closeDD();
    var sel = e.target ? e.target.closest('select') : null;
    if (sel && e.touches.length === 1 && !sel.disabled) {
      e.preventDefault();
      closeDD();

      var rect = sel.getBoundingClientRect();
      dd = document.createElement('div');
      dd.id = '__customDD';
      dd.style.cssText = 'position:fixed;z-index:999999;background:#fff;color:#000;border:1px solid #333;box-shadow:0 4px 10px rgba(0,0,0,0.5);overflow-y:auto;font-size:14px;';
      dd.style.left = Math.max(0, rect.left) + 'px';
      dd.style.top = (rect.bottom + 2) + 'px';
      dd.style.minWidth = Math.max(rect.width, 150) + 'px';
      dd.style.maxHeight = Math.max(120, window.innerHeight - rect.bottom - 10) + 'px';

      Array.prototype.forEach.call(sel.options, function (opt, idx) {
        var row = document.createElement('div');
        row.textContent = opt.text;
        row.style.cssText = 'padding:10px;border-bottom:1px solid #ddd;cursor:pointer;';
        if (idx === sel.selectedIndex) row.style.background = '#003331'; row.style.color = idx === sel.selectedIndex ? '#fff' : '#000';
        row.addEventListener('click', function (ev) {
          ev.stopPropagation(); sel.selectedIndex = idx;
          sel.dispatchEvent(new Event('change', { bubbles: true }));
          if (window.jQuery) { try { window.jQuery(sel).trigger('change'); } catch (_) {} }
          closeDD();
        });
        dd.appendChild(row);
      });
      document.body.appendChild(dd);
      var ddRect = dd.getBoundingClientRect();
      if (ddRect.right > window.innerWidth) dd.style.left = Math.max(0, window.innerWidth - ddRect.width - 5) + 'px';
    }
  }, { passive: false });

  /* ================================================================
     7. RESET (called from Flutter when coming back from another screen)
     ================================================================ */
  window.__resetMapUI = function () {
    closePlotModal();
    closeDD();
    isDragging = false;
    isPinching = false;
    recalculateLayout();
    applyTransform();
  };

})();
''';
}