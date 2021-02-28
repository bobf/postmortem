(function () {
  let previousInbox;
  let currentView;
  let reloadIdentityIframeTimeout;
  let identityUuid;
  let indexUuid;
  let twoColumnView;
  let headersView;

  const inboxContent = [];
  const headers = document.querySelector('.headers');
  const inbox = document.querySelector('#inbox-container');
  const inboxInfo = document.querySelector('#inbox-info');
  const columnSwitch = document.querySelector('.column-switch');
  const headersViewSwitch = document.querySelector('.headers-view-switch');
  const readAllButton = document.querySelector('.read-all-button');
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
    reloadIdentityIframeTimeout = setTimeout(() => identityIframe.src += '', 3000);

    setInterval(function () { indexIframe.contentWindow.postMessage('HELO', '*'); }, 1000);
    setInterval(function () { identityIframe.contentWindow.postMessage('HELO', '*'); }, 1000);

    toolbar.html.onclick    = function (ev) { setView('html', ev); };
    toolbar.text.onclick    = function (ev) { setView('text', ev); };
    toolbar.source.onclick  = function (ev) { setView('source', ev); };
    toolbar.headers.onclick = function () { setHeadersView(!headersView); };
    columnSwitch.onclick    = function () { setColumnView(!twoColumnView); };
    readAllButton.onclick   = function () { markAllAsRead(); };

    if (POSTMORTEM.hasHtml) {
      setView('html');
    } else {
      setView('text');
    }

    setColumnView(POSTMORTEM.displayInbox);
    setHeadersView(true);
    setEnabled(columnSwitch);
    setVisible(inbox, POSTMORTEM.displayInbox);

    if (inbox) {
      window.addEventListener('message', function (ev) {
        switch (ev.data.type) {
          case 'index':
            loadInbox(ev.data.uuid, ev.data.mails);
            break;
          case 'identity':
            compareIdentity(ev.data.uuid);
            break;
        };
      });
    } else {
      // Downloaded preview mode.
      setDisabled(columnSwitch);
      toolbar.download.classList.add('hidden');
    }

    loadMail(POSTMORTEM.initialData);

    $('[data-toggle="tooltip"]').tooltip();
  }

  const setHeadersView = (enableHeadersView) => {
    headersView = enableHeadersView;
    if (enableHeadersView) {
      setOn(headersViewSwitch);
      headers.classList.add('visible');
    } else {
      setOff(headersViewSwitch);
      headers.classList.remove('visible');
    }
  };

  const setColumnView = (enableTwoColumnView) => {
    if (!inbox) return;

    const container = document.querySelector('.container');
    twoColumnView = POSTMORTEM.displayInbox ? enableTwoColumnView : false;
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

  const contexts = ['source', 'text', 'html'];

  const views = {
    source: document.querySelector('.source-view'),
    html: document.querySelector('.html-view'),
    text: document.querySelector('.text-view'),
  };

  const toolbar = {
    source: document.querySelector('.source-view-switch'),
    html: document.querySelector('.html-view-switch'),
    text: document.querySelector('.text-view-switch'),
    headers: document.querySelector('.headers-view-switch'),
    download: document.querySelector('#download-link'),
  };

  const setOn = function(element) {
    element.classList.add('text-primary');
    element.classList.remove('text-secondary');
  };

  const setOff = function(element) {
    element.classList.add('text-secondary');
    element.classList.remove('text-primary');
  };

  const setDisabled = function(element) {
    element.classList.add('disabled');
    element.classList.remove('text-secondary');
  };

  const setEnabled = function(element) {
    element.classList.remove('disabled');
    element.classList.add('text-secondary');
  };

  const setVisible = function(element, visible) {
    if (visible) {
      element.classList.add('visible');
    } else {
      element.classList.remove('visible');
    }
  };

  const setView = function(context, ev) {
    if (ev && $(ev.target).hasClass('disabled')) return;
    let key;
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

    setView(currentView);
  };

  const loadMail = (mail) => {
    const initializeScript = document.querySelector("#initialize-script");
    const initObject = {
      initialData: mail,
      hasHtml: !!mail.htmlBody,
      hasText: !!mail.textBody,
      displayInbox: false,
    };

    initializeScript.text = [
      `const POSTMORTEM = ${JSON.stringify(initObject)};`
    ].join('\n\n');

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
    updateInboxInfo();
  };

  const markAsRead = (mail) => {
    storage.setItem(mail.id, 'read');
    $(`li[data-email-id="${mail.id}"]`).removeClass('unread');
  };

  const markAllAsRead = () => {
    inboxContent.forEach(mail => markAsRead(mail));
    updateInboxInfo();
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
  };

  const loadDownloadLink = () => {
    const html = document.documentElement.innerHTML;
    const start = html.indexOf('<!--INBOX-START-->');
    const end = html.indexOf('<!--INBOX-END-->') + '<!--INBOX-END-->'.length;
    const modifiedHtml = [html.substring(0, start), html.substring(end + 1, html.length)].join('');
    const blob = new Blob([modifiedHtml], { type: 'application/octet-stream' });
    const uri = window.URL.createObjectURL(blob);
    $("#download-link").attr('href', uri);
  };

  const compareIdentity = (uuid) => {
    clearTimeout(reloadIdentityIframeTimeout);
    reloadIdentityIframeTimeout = setTimeout(() => identityIframe.src += '', 3000);
    if (identityUuid !== uuid) indexIframe.src += '';
    identityUuid = uuid;
  };

  const updateInboxInfo = () => {
    if (!inboxContent.length) return;

    const unreadCount = inboxContent.filter((mail) => isNewMail(mail)).length;
    document.title = `PostMortem ${unreadCount}/${inboxContent.length} (unread/total)`;
    inboxInfo.textContent = `${inboxContent.length} emails (${unreadCount} unread)`;
    inboxInfo.innerHTML = `&mdash; ${inboxInfo.innerHTML}`;
  };

  const loadInbox = (uuid, mails) => {
    inboxContent.splice(0, Infinity, ...mails)
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
    updateInboxInfo();
    if (arrayIdentical(html, previousInbox)) return;
    previousInbox = html;
    $('#inbox').html('<ul class="list-group">' + html.join('\n') + '</ul>');
    $('.inbox-item').click((ev) => {
      const $target = $(ev.currentTarget);
      const id = $target.data('email-id');
      setTimeout(() => loadMail(mailsById[id].content), 0);
    });

    indexUuid = uuid;
  };

  initialize();
})();
