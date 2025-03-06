function copyText(textElementId, copyLinkElementId) {
    let textElement = document.querySelector(textElementId);
    let copyLink = document.querySelector(copyLinkElementId);
    let referenceNumberAlert = document.getElementById("copy-reference-number-alert");

    if (textElement && copyLink) {
      copyLink.addEventListener('click', (e) => {
        e.preventDefault();

        let text = textElement.textContent.trim();
        window.navigator.clipboard.writeText(text);
        referenceNumberAlert.textContent = "Reference number copied";

        copyLink.blur();
        return true;
      });
    }
  }

  export default copyText;
