function copyText(textElementId, copyLinkElementId) {
    let textElement = document.querySelector(textElementId);
    let copyLink = document.querySelector(copyLinkElementId);
  
    if (textElement && copyLink) {
      copyLink.addEventListener('click', (e) => {
        e.preventDefault();
  
        let text = textElement.textContent.trim();
        window.navigator.clipboard.writeText(text);
        copyLink.blur();
        return true;
      });
    }
  }
  
  export default copyText;