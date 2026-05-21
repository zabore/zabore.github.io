include-after: |
  <script type="text/javascript">
    Reveal.on('ready', event => {
      if (event.indexh === 0) {
        document.querySelector("div.has-logo > img.slide-logo").style.display = "none";
      }
    });
    Reveal.addEventListener('slidechanged', (event) => {
      if (event.indexh === 0) {
        Reveal.configure({ slideNumber: null });
        document.querySelector("div.has-logo > img.slide-logo").style.display = "none";
      }
      if (event.indexh === 1) { 
        Reveal.configure({ slideNumber: 'c' });
        document.querySelector("div.has-logo > img.slide-logo").style.display = null;
      }
    });
  </script>