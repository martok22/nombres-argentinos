// tooltip form-name
Opentip.styles.formStyle = {
  target: true,
  stem: true,
  background: "black",
  borderColor: "black",
  shadow: false
};

var opentipTop1 = new Opentip("#name", "<span class='colorWhite'>Escribí tu nombre. ¡Pssst! Si querés compararlo con otro, separalos con una coma. Por ejemplo: Juan, Pablo.</span>", { style: "formStyle", showOn: "focusin", hideOn: "blur", tipJoint: "top" });
var opentipTop2 = new Opentip("#year", "<span class='colorWhite'>Escribí en qué año naciste.</span>", { style: "formStyle", showOn: "focusin", hideOn: "blur", tipJoint: "top" });
var opentipRight1 = new Opentip("#name", "<span class='colorWhite'>Escribí tu nombre. ¡Pssst! Si querés compararlo con otro, separalos con una coma. Por ejemplo: Juan, Pablo</span>.", { style: "formStyle", showOn: "null", hideOn: "blur", tipJoint: "right" });
var opentipRight2 = new Opentip("#year", "<span class='colorWhite'>Escribí en qué año naciste</span>.", { style: "formStyle", showOn: "null", hideOn: "blur", tipJoint: "right" });
var inputName = window.document.querySelector('#name');
var inputYear = window.document.querySelector('#year');

inputName.addEventListener('focusin', function(){
  if($(window).width() > 1200) {
    opentipTop1.hide();
    opentipRight1.show();
  } else {
    opentipTop1.show();
    opentipRight1.hide();
  }
});
inputYear.addEventListener('focusin', function(){
  if($(window).width() > 1200) {
    opentipTop2.hide();
    opentipRight2.show();
  } else {
    opentipTop2.show();
    opentipRight2.hide();
  }
});

// tooltip bubble graphic
Opentip.styles.bubbleStyle = {
  stem: true,
  background: "white",
  borderColor: "silver",
  shadow: false,
  showEffectDuration: 0 
};

window.addEventListener("hashchange", function(){
   for(var i = 0; i < Opentip.tips.length; i ++) { Opentip.tips[i].hide(); }
});
