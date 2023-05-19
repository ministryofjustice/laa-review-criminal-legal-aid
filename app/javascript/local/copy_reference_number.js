function copyReferenceNumber(){
  let referenceNumber = document.querySelector('#reference-number');
  let copyLink = document.querySelector('#copy-reference-number');

  if (referenceNumber && copyLink) {
    copyLink.addEventListener('click', (e) => {
      e.preventDefault();

      let text = referenceNumber.textContent.trim();
      window.navigator.clipboard.writeText(text);
      copyLink.blur();
    });
  }
}

export default copyReferenceNumber;
