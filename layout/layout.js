(function () {
  var htmlIframeDocument = document.querySelector("#html-iframe").contentDocument;
  var indexIframe = document.querySelector("#index-iframe");
  htmlIframeDocument.write(mailBody);
  htmlIframeDocument.close();

  var textIframeDocument = document.querySelector("#text-iframe").contentDocument;
  textIframeDocument.write('<pre>' + escapedTextBody + '</pre>');
  textIframeDocument.close();

  var sourceHighlightBundle = [
     '<link rel="stylesheet"',
     '     href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.3/styles/agate.min.css"',
     '     integrity="sha512-mMMMPADD4HAIogAWZbv+WjZTC0itafUZNI0jQm48PMBTApXt11omF5jhS7U1kp3R2Pr6oGJ+JwQKiUkUwCQaUQ=="',
     '     crossorigin="anonymous" />',
     '<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.3/highlight.min.js"',
     '        integrity="sha512-tHQeqtcNWlZtEh8As/4MmZ5qpy0wj04svWFK7MIzLmUVIzaHXS8eod9OmHxyBL1UET5Rchvw7Ih4ZDv5JojZww=="',
     '        crossorigin="anonymous"></' + 'script>',
     '<script>hljs.initHighlightingOnLoad();</' + 'script>',
  ].join('\n');

  var sourceIframeDocument = document.querySelector("#source-iframe").contentDocument;
  sourceIframeDocument.write('<pre><code style="padding: 1rem;" class="language-html">' + escapedHtmlBody + '</code></pre>');
  sourceIframeDocument.write(sourceHighlightBundle);
  sourceIframeDocument.close();

  var twoColumnView;
  var headersView;
  var headers = document.querySelector('.headers');
  var inbox = document.querySelector('#inbox');
  var columnSwitch = document.querySelector('.column-switch');
  var headersViewSwitch = document.querySelector('.headers-view-switch');

  var setHeadersView = function (enableHeadersView) {
    headersView = enableHeadersView;
    if (enableHeadersView) {
      setOn(headersViewSwitch);
      headers.classList.add('visible');
    } else {
      setOff(headersViewSwitch);
      headers.classList.remove('visible');
    }
  };

  var setColumnView = function (enableTwoColumnView) {
    var container = document.querySelector('.container');
    twoColumnView = enableTwoColumnView;
    if (twoColumnView) {
      setVisible(inbox, true);
      setOn(columnSwitch);
      container.classList.add('full-width');
    } else {
      setVisible(inbox, false);
      setOff(columnSwitch);
      container.classList.remove('full-width');
    }
  };

  var contexts = ['source', 'text', 'html'];

  var views = {
    source: document.querySelector('.source-view'),
    html: document.querySelector('.html-view'),
    text: document.querySelector('.text-view'),
  };

  var toolbar = {
    source: document.querySelector('.source-view-switch'),
    html: document.querySelector('.html-view-switch'),
    text: document.querySelector('.text-view-switch'),
    headers: document.querySelector('.headers-view-switch'),
  };

  var setOn = function(element) {
    element.classList.add('text-primary');
    element.classList.remove('text-secondary');
  };

  var setOff = function(element) {
    element.classList.add('text-secondary');
    element.classList.remove('text-primary');
  };

  var setDisabled = function(element) {
    element.classList.add('disabled');
    element.classList.remove('text-secondary');
    element.onclick = function () {};
  };

  var setVisible = function(element, visible) {
    if (visible) {
      element.classList.add('visible');
    } else {
      element.classList.remove('visible');
    }
  };

  var setView = function(context) {
    var key;
    for (i = 0; i < contexts.length; i++) {
      key = contexts[i];
      if (key === context) {
        setOn(toolbar[key]);
        setVisible(views[key], true);
      } else {
        setOff(toolbar[key]);
        setVisible(views[key], false);
      }
    }
  };

  toolbar.html.onclick    = function () { setView('html'); };
  toolbar.text.onclick    = function () { setView('text'); };
  toolbar.source.onclick  = function () { setView('source'); };
  toolbar.headers.onclick = function () { setHeadersView(!headersView); };
  columnSwitch.onclick    = function () { setColumnView(!twoColumnView); };

  if (!hasText) setDisabled(toolbar.text);

  if (hasHtml) {
    setView('html');
  } else {
    setDisabled(toolbar.html);
    setDisabled(toolbar.source);
    setView('text');
  }

  setColumnView(true);
  setHeadersView(true);

  $('[data-toggle="tooltip"]').tooltip();

  let previousInbox;

  const arrayIdentical = (a, b) => {
    if (a && !b) return false;
    if (a.length !== b.length) return false;
    if (!a.every((item, index) => item === b[index])) return false;

    return true;
  };

  const renderInbox = function (mails) {
    const html = mails.map(mail => {
      const [subject, timestamp, path] = mail;
      const parsedTimestamp = new Date(timestamp);
      const timestampSpan = `<span class="timestamp">${parsedTimestamp.toLocaleString()}</span>`;
      const classes = ['list-group-item'];
      if (window.location.href.endsWith(path)) classes.push('active');
      return `<li class="${classes.join(' ')}"><a title="${subject}" href="${path}">${subject}</a>${timestampSpan}</li>`
    });
    if (arrayIdentical(html, previousInbox)) return;
    previousInbox = html;
    $('#inbox').html('<ul class="list-group">' + html.join('\n') + '</ul>');
  };

  let reloadIframeTimeout = setTimeout(() => indexIframe.src += '', 2000);
  window.addEventListener('message', function (ev) {
    clearTimeout(reloadIframeTimeout);
    reloadIframeTimeout = setTimeout(() => indexIframe.src += '', 2000);
    renderInbox(ev.data);
  });
  setInterval(function () {
    indexIframe.contentWindow.postMessage('HELO', '*');
  }, 500);
})();

