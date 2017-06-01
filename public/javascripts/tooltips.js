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
