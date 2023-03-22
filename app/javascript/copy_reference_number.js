function copyReferenceNumber(){
  let referenceNumber = document.querySelector('#reference-number');
  let copyLink = document.querySelector('#copy-reference-number');

  copyLink.addEventListener('click', (e) => {
    e.preventDefault();

    let text = referenceNumber.textContent.trim();
    window.navigator.clipboard.writeText(text);
  });
}

export default copyReferenceNumber;
