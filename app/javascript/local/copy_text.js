function copyText(textElementId, copyLinkElementId, screenReaderAlertText, originalCopyLinkText = 'Copy') {
    let textElement = document.querySelector(textElementId);
    let copyLink = document.querySelector(copyLinkElementId);
    let screenReaderAlert = document.getElementById("copy-alert");

    if (textElement && copyLink) {
      copyLink.addEventListener('click', (e) => {
        e.preventDefault();

        let text = textElement.textContent.trim();
        window.navigator.clipboard.writeText(text);
        screenReaderAlert.textContent = screenReaderAlertText;
        copyLink.classList.add('disable-click');
        copyLink.textContent = "Copied";
        copyLink.classList.remove('govuk-link--no-visited-state');

        setTimeout(() => {
            screenReaderAlert.textContent = "";
            copyLink.classList.remove('disable-click');
            copyLink.textContent = originalCopyLinkText;
            copyLink.classList.add('govuk-link--no-visited-state');
        }, 4000);

        copyLink.blur();
        return true;
      });
    }
  }

  export default copyText;
