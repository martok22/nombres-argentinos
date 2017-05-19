// tooltip form-name
Opentip.styles.formStyle = {
  target: true,
  stem: true,
  background: "black",
  borderColor: "black",
  shadow: false
};

var opentipTop1   = new Opentip("#pregName", "<span class='colorWhite'>Escribí tu nombre. ¡Pssst! Si querés compararlo con otro, separalos con una coma. Por ejemplo: Emilia, Benjamín.</span>", { style: "formStyle", showOn: "focusin", hideOn: "blur", tipJoint: "top" , borderRadius: 0});
var opentipRight1 = new Opentip("#pregName", "<span class='colorWhite'>Escribí tu nombre. ¡Pssst! Si querés compararlo con otro, separalos con una coma. Por ejemplo: Emilia, Benjamín</span>.", { style: "formStyle", showOn: "null", hideOn: "blur", tipJoint: "right" , borderRadius: 0});
var inputName     = window.document.querySelector('#pregName');

inputName.addEventListener('mouseover', function(){
  if($(window).width() > 1200) {
    opentipTop1.hide();
    opentipRight1.show();
  } else {
    opentipTop1.show();
    opentipRight1.hide();
  }
});
inputName.addEventListener('mouseout', function(){
  opentipTop1.hide();
  opentipRight1.hide();
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
