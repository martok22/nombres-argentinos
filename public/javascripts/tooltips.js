// tooltip form-name
Opentip.styles.formStyle = {
  target: true,
  stem: true,
  background: "black",
  borderColor: "black",
  shadow: false
};

var opentip    = new Opentip("#pregName", "<span class='colorWhite'>Escribí tu nombre. ¡Pssst! Si querés compararlo con otro, separalos con una coma. Por ejemplo: Emilia, Benjamín.</span>", { style: "formStyle", showOn: "focusin", hideOn: "blur", tipJoint: "bottom" , borderRadius: 0});
var inputName  = window.document.querySelector('#pregName');

inputName.addEventListener('mouseover', function(){
  opentip.show();
});
inputName.addEventListener('mouseout', function(){
  opentip.hide();
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
