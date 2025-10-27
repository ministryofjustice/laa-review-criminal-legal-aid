function copyText(textElementId, copyElementId, screenReaderAlertText, originalCopyText = 'Copy') {
    let textElement = document.querySelector(textElementId);
    let copyElement = document.querySelector(copyElementId);
    let screenReaderAlert = document.getElementById("copy-alert");

    if (textElement && copyElement) {
      copyElement.addEventListener('click', (e) => {
        e.preventDefault();

        let text = textElement.textContent.trim();
        window.navigator.clipboard.writeText(text);
        screenReaderAlert.textContent = screenReaderAlertText;
        copyElement.classList.add('disable-click');
        copyElement.textContent = "Copied";

        setTimeout(() => {
            screenReaderAlert.textContent = "";
            copyElement.classList.remove('disable-click');
            copyElement.textContent = originalCopyText;
        }, 4000);

        copyElement.blur();
        return true;
      });
    }
  }

  export default copyText;
