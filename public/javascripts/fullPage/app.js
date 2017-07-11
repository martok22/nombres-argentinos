$(document).ready(function () {

  // Generar FullPage
  $('#fullpage').fullpage({
      //Navigation
      menu: '#menu',
      lockAnchors: false,
      anchors: ['seccion1', 'seccion2', 'seccion3', 'seccion4', 'seccion5'],
      navigation: true,
      navigationPosition: 'right',
      navigationTooltips: [],
      showActiveTooltip: false,
      slidesNavigation: false,
      slidesNavPosition: 'bottom',

      //Scrolling
      css3: false,
      scrollingSpeed: 700,
      autoScrolling: false,
      fitToSection: false,
      fitToSectionDelay: 1000,
      scrollBar: false,
      easing: 'easeInOutCubic',
      easingcss3: 'ease',
      loopBottom: false,
      loopTop: false,
      loopHorizontal: false,
      continuousVertical: false,
      continuousHorizontal: false,
      scrollHorizontally: false,
      interlockedSlides: false,
      resetSliders: false,
      fadingEffect: false,
      normalScrollElements: '#element1, .element2',
      scrollOverflow: false,
      scrollOverflowOptions: null,
      touchSensitivity: 15,
      normalScrollElementTouchThreshold: 5,
      bigSectionsDestination: null,

      //Accessibility
      keyboardScrolling: false,
      animateAnchor: false,
      recordHistory: false,

      //Custom selectors
      sectionSelector: '.section',
      slideSelector: '.slide',

      //events
      onLeave: function (index, nextIndex, direction) {},
      afterLoad: function (anchorLink, index) {},
      afterRender: function () {},
      afterResize: function () {},
      afterSlideLoad: function (anchorLink, index, slideAnchor, slideIndex) {},
      onSlideLeave: function (anchorLink, index, slideIndex, direction, nextSlideIndex) {}
  });

  // Modificar Color
  var seccionesColor = window.document.querySelector('#fp-nav').children[0].children;

  function detectarColor(){
    var i;

    if (window.location.hash === '' || window.location.hash === '#seccion1' || window.location.hash === '#seccion3') {
      for (i = 0; i < seccionesColor.length; i++) {
        window.document.querySelector('#fp-nav').children[0].children[i].children[0].children[0].style.backgroundColor = 'white';
      }
    } else {
      for (i = 0; i < seccionesColor.length; i++) {
        window.document.querySelector('#fp-nav').children[0].children[i].children[0].children[0].style.backgroundColor = 'gray';
      }
    }
  }

  detectarColor();

  window.addEventListener('hashchange', function(){
    detectarColor();
  });

  window.document.getElementById('section5').style.height = '';
  window.document.querySelector('#section5').children[0].style.height = '';
});
