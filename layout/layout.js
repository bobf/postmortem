(function () {
  let previousInbox;
  let currentView;
  let reloadIdentityIframeTimeout;
  let identityUuid;
  let indexUuid;
  let inboxInitialized = false;

  const htmlIframeDocument = document.querySelector("#html-iframe").contentDocument;
  const indexIframe = document.querySelector("#index-iframe");
  const identityIframe = document.querySelector("#identity-iframe");
  const textIframeDocument = document.querySelector("#text-iframe").contentDocument;
  const sourceIframeDocument = document.querySelector("#source-iframe").contentDocument;
  const sourceHighlightBundle = [
     '<link rel="stylesheet"',
     '     href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.3/styles/agate.min.css"',
     '     integrity="sha512-mMMMPADD4HAIogAWZbv+WjZTC0itafUZNI0jQm48PMBTApXt11omF5jhS7U1kp3R2Pr6oGJ+JwQKiUkUwCQaUQ=="',
     '     crossorigin="anonymous" />',
     '<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.3/highlight.min.js"',
     '        integrity="sha512-tHQeqtcNWlZtEh8As/4MmZ5qpy0wj04svWFK7MIzLmUVIzaHXS8eod9OmHxyBL1UET5Rchvw7Ih4ZDv5JojZww=="',
     '        crossorigin="anonymous"></' + 'script>',
     '<script>hljs.initHighlightingOnLoad();</' + 'script>',
  ].join('\n');

  const storage = window.localStorage;

  const initialize = () => {
    loadMail(initialData);

    reloadIdentityIframeTimeout = setTimeout(() => identityIframe.src += '', 3000);

    window.addEventListener('message', function (ev) {
      switch (ev.data.type) {
        case 'index':
          renderInbox(ev.data.uuid, ev.data.mails);
          break;
        case 'identity':
          compareIdentity(ev.data.uuid);
          break;
      };
    });

    setInterval(function () { indexIframe.contentWindow.postMessage('HELO', '*'); }, 1000);
    setInterval(function () { identityIframe.contentWindow.postMessage('HELO', '*'); }, 1000);

    toolbar.html.onclick    = function (ev) { setView('html', ev); };
    toolbar.text.onclick    = function (ev) { setView('text', ev); };
    toolbar.source.onclick  = function (ev) { setView('source', ev); };
    toolbar.headers.onclick = function () { setHeadersView(!headersView); };
    columnSwitch.onclick    = function () { setColumnView(!twoColumnView); };

    if (hasHtml) {
      setView('html');
    } else {
      setView('text');
    }

    setColumnView(false);
    setHeadersView(true);

    $('[data-toggle="tooltip"]').tooltip();
  }


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
    if (!inboxInitialized) return;

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
  };

  var setEnabled = function(element) {
    element.classList.remove('disabled');
    element.classList.add('text-secondary');
  };

  var setVisible = function(element, visible) {
    if (visible) {
      element.classList.add('visible');
    } else {
      element.classList.remove('visible');
    }
  };

  var setView = function(context, ev) {
    if (ev && $(ev.target).hasClass('disabled')) return;
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
    currentView = context;
  };

  const arrayIdentical = (a, b) => {
    if (a && !b) return false;
    if (a.length !== b.length) return false;
    if (!a.every((item, index) => item === b[index])) return false;

    return true;
  };

  const htmlEscape = (html) => {
    return $("<div></div>").text(html).html();
  };

  const $headersTemplate = $("#headers-template");

  const loadHeaders = (mail) => {
    $template = $headersTemplate.clone();
    $('#headers').html($template.html());
    ['subject', 'from', 'replyTo', 'to', 'cc', 'bcc'].forEach(item => {
      const $item = $(`#email-${item}`)
      $item.text(mail[item]);
      if (!mail[item]) $item.parent().addClass('hidden');
    });
  };

  const loadToolbar = (mail) => {
    if (!mail.textBody) {
      setDisabled(toolbar.text);
      setView('html');
    } else {
      setEnabled(toolbar.text);
    }

    if (!mail.htmlBody) {
      setDisabled(toolbar.html);
      setDisabled(toolbar.source);
      setView('text');
    } else {
      setEnabled(toolbar.html);
      setEnabled(toolbar.source);
    }

    setDisabled(columnSwitch);
    setView(currentView);
  };

  const loadMail = (mail) => {
    htmlIframeDocument.open();
    htmlIframeDocument.write(mail.htmlBody);
    htmlIframeDocument.close();

    textIframeDocument.open();
    textIframeDocument.write(`<pre>${htmlEscape(mail.textBody)}</pre>`);
    textIframeDocument.close();

    sourceIframeDocument.open();
    sourceIframeDocument.write(`<pre><code style="padding: 1rem;" class="language-html">${htmlEscape(mail.htmlBody)}</code></pre>`);
    sourceIframeDocument.write(sourceHighlightBundle);
    sourceIframeDocument.close();

    loadHeaders(mail);
    loadToolbar(mail);
    loadDownloadLink();

    highlightMail(mail);
    markAsRead(mail);
  };

  const markAsRead = (mail) => {
    storage.setItem(mail.id, 'read');
  };

  const isNewMail = (mail) => {
    if (!storage.getItem(mail.id)) return true;

    return false;
  };

  const highlightMail = (mail) => {
    window.location.hash = mail.id;
    const $target = $(`li[data-email-id="${mail.id}"]`);
    $('.inbox-item').removeClass('active');
    $target.addClass('active');
    $target.removeClass('unread');
  };

  const loadDownloadLink = () => {
    const blob = new Blob([document.documentElement.innerHTML], { type: 'application/octet-stream' });
    const uri = window.URL.createObjectURL(blob);
    $("#download-link").attr('href', uri);
  };

  const compareIdentity = (uuid) => {
    clearTimeout(reloadIdentityIframeTimeout);
    reloadIdentityIframeTimeout = setTimeout(() => identityIframe.src += '', 3000);
    if (identityUuid !== uuid) indexIframe.src += '';
    identityUuid = uuid;
  };

  const renderInbox = (uuid, mails) => {
    if (uuid === indexUuid) {
      return;
    }
    const mailsById = {};
    const html = mails.map((mail, index) => {
      const parsedTimestamp = new Date(mail.timestamp);
      const timestampSpan = `<span class="timestamp">${parsedTimestamp.toLocaleString()}</span>`;
      const classes = ['list-group-item', 'inbox-item'];
      if (window.location.hash === '#' + mail.id) classes.push('active');
      if (isNewMail(mail)) classes.push('unread');
      mailsById[mail.id] = mail;
      return [`<li data-email-id="${mail.id}" class="${classes.join(' ')}">`,
              `<a title="${mail.subject}" href="javascript:void(0)">`,
              `<i class="fa fa-envelope-open read-icon"></i>`,
              `<i class="fa fa-envelope unread-icon"></i>${mail.subject}`,
              `</a>`,
              `${timestampSpan}</li>`].join('');
    });
    if (arrayIdentical(html, previousInbox)) return;
    previousInbox = html;
    $('#inbox').html('<ul class="list-group">' + html.join('\n') + '</ul>');
    $('.inbox-item').click((ev) => {
      const $target = $(ev.currentTarget);
      const id = $target.data('email-id');
      setTimeout(() => loadMail(mailsById[id].content), 0);
    });

    if (!inboxInitialized) {
      setEnabled(columnSwitch);
      setColumnView(true);
      setVisible(inbox, true);
    }
    inboxInitialized = true;
    indexUuid = uuid;
  };

  initialize();
})();
