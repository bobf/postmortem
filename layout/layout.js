(function () {
  if (POSTMORTEM && POSTMORTEM.downloadedPreview) document.title = 'PostMortem';

  let previousInbox;
  let currentView;
  let reloadIdentityIframeTimeout;
  let identityUuid;
  let indexUuid;
  let twoColumnView;
  let headersView;
  let indexIframeTimeout;
  let requestedId;
  let requestedPending = false;

  const inboxContent = [];
  const headers = document.querySelector('.headers');
  const inbox = document.querySelector('#inbox-container');
  const inboxInfo = document.querySelector('#inbox-info');
  const columnSwitch = document.querySelector('.column-switch');
  const headersViewSwitch = document.querySelector('.headers-view-switch');
  const readAllButton = document.querySelector('.read-all-button');
  const showHideReadButton = document.querySelector('.show-hide-read-button');
  const showHideReadIcon = document.querySelector('.show-hide-read-icon');
  const getIndexIframe = () => document.querySelector("#index-iframe");
  const getIdentityIframe = () => document.querySelector("#identity-iframe");
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
    reloadIdentityIframeTimeout = setTimeout(() => getIdentityIframe().src += '', 1000);

    setInterval(function () { getIdentityIframe().contentWindow.postMessage('HELO', '*'); }, 200);

    toolbar.html.onclick       = (ev) => setView('html', ev);
    toolbar.text.onclick       = (ev) => setView('text', ev);
    toolbar.source.onclick     = (ev) => setView('source', ev);
    toolbar.headers.onclick    = ()   => setHeadersView(!headersView);
    columnSwitch.onclick       = ()   => setColumnView(!twoColumnView);
    readAllButton.onclick      = ()   => markAllAsRead();
    showHideReadButton.onclick = ()   => toggleHideReadMessages();

    if (POSTMORTEM.hasHtml) {
      setView('html');
    } else {
      setView('text');
    }

    setColumnView(!POSTMORTEM.downloadedPreview);
    setHeadersView(true);
    setEnabled(columnSwitch);
    setOn(columnSwitch);
    setHidden(inbox, POSTMORTEM.downloadedPreview);

    if (POSTMORTEM.downloadedPreview) {
      setHidden(toolbar.download, true);
      setHidden(columnSwitch, true);
      loadMail(POSTMORTEM.initialData);
    } else {
      requestLoad(window.location.hash.replace('#', ''));
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
    }

    $('[data-toggle="tooltip"]').tooltip();
  }

  const requestLoad = (id) => {
    requestedId = id;
    requestedPending = true;
  };

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
    twoColumnView = POSTMORTEM.downloadedPreview ? false : enableTwoColumnView;
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

  const setHidden = function(element, hidden) {
    if (hidden) {
      element.classList.add('hidden');
    } else {
      element.classList.remove('hidden');
    }
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

  const setContent = (selector, content) => {
    const target = document.querySelector(selector).contentDocument;

    target.open();
    target.write(content);
    target.close();
  };

  const loadMail = (mail) => {
    const initializeScript = document.querySelector("#initialize-script");
    const initObject = {
      initialData: mail,
      hasHtml: !!mail.htmlBody,
      hasText: !!mail.textBody,
      downloadedPreview: true,
    };

    initializeScript.text = [
      `const POSTMORTEM = ${JSON.stringify(initObject)};`
    ].join('\n\n');

    setContent('#html-iframe', mail.htmlBody);
    setContent('#text-iframe', `<pre>${htmlEscape(mail.textBody)}</pre>`);
    setContent('#source-iframe', `<pre><code style="padding: 1rem;" class="language-html">${htmlEscape(mail.htmlBody)}</code></pre>` + sourceHighlightBundle);

    loadHeaders(mail);
    loadToolbar(mail);
    loadDownloadLink(mail);
    loadUploadLink(mail);

    highlightMail(mail);
    markAsRead(mail);
    updateInboxInfo();
  };

  const markAsRead = (mail) => {
    storage.setItem(mail.id, 'read');
    $(`li[data-email-id="${mail.id}"]`).removeClass('unread');
    $(readAllButton).blur();
  };

  const showReadMessages = (show) => {
    if (show) {
      inbox.classList.remove('hide-read');
    } else {
      inbox.classList.add('hide-read');
    }
  };

  const toggleHideReadMessages = () => {
    const $target = $(showHideReadButton);
    const $icon = $(showHideReadIcon);

    if ($target.data('state') === 'hide') {
      $target.data('state', 'show');
      $target.attr('data-original-title', 'Hide read messages');
      $target.attr('title', 'Hide read messages');
      $icon.removeClass('fa-eye-slash');
      $icon.addClass('fa fa-eye text-primary');
      showReadMessages(true);
    } else {
      $target.data('state', 'hide');
      $target.attr('data-original-title', 'Show read messages');
      $target.attr('title', 'Show read messages');
      $icon.removeClass('fa-eye text-primary');
      $icon.addClass('fa fa-eye-slash');
      showReadMessages(false);
    }

    $target.blur();
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

  const alertUploadFailure = (response, content) => {
    alert(`Upload failed. Got: ${response.status} ${response.statusText}: ${content}`);
  };

  const copyToClipboard = (text) => {
    const textArea = document.createElement("textarea");
    textArea.style.position = 'fixed';
    textArea.style.top = 0;
    textArea.style.left = 0;
    textArea.style.width = '2em';
    textArea.style.height = '2em';
    textArea.style.padding = 0;
    textArea.style.border = 'none';
    textArea.style.outline = 'none';
    textArea.style.boxShadow = 'none';
    textArea.style.background = 'transparent';
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    let success;

    try {
      success = document.execCommand('copy');
    } catch (err) {
      console.log('Clipboard copy error');
    }

    document.body.removeChild(textArea);
    return success;
  };

  const alertUploadSuccess = (data) => {
    const popup = document.querySelector("#upload-popup");
    const uploadedEmailLink = document.querySelector("#uploaded-email-link");
    const copyUploadedEmailLink = document.querySelector("#copy-uploaded-email-link");
    const url = `https://postmortem.delivery/${data.uri}`;

    uploadedEmailLink.textContent = `postmortem.delivery/${data.uri}`;
    uploadedEmailLink.href = url;
    copyUploadedEmailLink.onclick = (ev) => {
      ev.stopPropagation();
      ev.preventDefault();
      const success = copyToClipboard(url);
      console.log(success);
    };

    popup.classList.remove("hidden");
    popup.classList.add("fade-in");
  };

  const loadDownloadLink = (mail) => {
    const html = document.documentElement.innerHTML;
    const start = html.indexOf('<!--INBOX-START-->');
    const end = html.indexOf('<!--INBOX-END-->') + '<!--INBOX-END-->'.length;
    const modifiedHtml = [html.substring(0, start), html.substring(end + 1, html.length)].join('');
    const blob = new Blob([modifiedHtml], { type: 'application/octet-stream' });
    const uri = window.URL.createObjectURL(blob);
    const subject = mail.subject || '(No subject)'
    $("#download-link").attr('href', uri);
    $("#download-link").attr('download', subject.replace(/[^0-9a-zA-Z_ -]/gi, '') + '.html');
  };

  const loadUploadLink = (email) => {
    const link = document.querySelector("#upload-link");

    link.onclick = async (ev) => {
      ev.stopPropagation();
      ev.preventDefault();

      const response = await fetch(POSTMORTEM.uploadUrl, {
        method: 'POST',
        cache: 'no-cache',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });

      if (response.ok) {
        const data = await response.json();
        alertUploadSuccess(data);
      } else {
        const content = await response.text();
        alertUploadFailure(response, content);
      }

      return false;
    };
  };

  const compareIdentity = (uuid) => {
    clearTimeout(reloadIdentityIframeTimeout);
    reloadIdentityIframeTimeout = setTimeout(() => getIdentityIframe().src += '', 1000);
    if (identityUuid !== uuid) {
      getIndexIframe().src += '';
      clearTimeout(indexIframeTimeout);
      indexIframeTimeout = setInterval(function () { getIndexIframe().contentWindow.postMessage('HELO', '*'); }, 200);
    }
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
    clearTimeout(indexIframeTimeout);
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

      if (requestedPending && mail.id === requestedId) {
        requestedPending = false;
        requestedId = null;
        setTimeout(() => loadMail(mail.content), 0);
      }

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
