'use strict';
(()=>{
 const $=id=>document.getElementById(id),G=NatsukiGame;
 let state=G.initial(),generation=0,strokeTimer,bubbleTimer;
 // One stable portrait plus a true-alpha hand. Never overlay regenerated hair.
 const hand=$('hand');
 const handReady=hand.decode().then(()=>true,()=>false);
 function render(){ $('score').textContent=state.affection+' / 100';$('meter').value=state.affection;$('relationship').textContent=''; }
 function say(line){clearTimeout(bubbleTimer);$('line').textContent=line;$('bubble').classList.remove('faded');bubbleTimer=setTimeout(()=>$('bubble').classList.add('faded'),3200);}
 async function stroke(count){
  const token=++generation;clearTimeout(strokeTimer);
  if(!await handReady){$('hint').textContent='画像を読み込めませんでした。再読み込みしてください。';return;}
  if(token!==generation)return;
  hand.dataset.frame=count%2?'1':'2';hand.hidden=false;
  strokeTimer=setTimeout(()=>{if(token===generation)hand.hidden=true;},1200);
 }
 $('head').addEventListener('click',()=>{
  const r=G.tap(state);state=r.state;say(r.line);render();stroke(state.strokes);
 });
 $('reset').addEventListener('click',()=>$('confirm').showModal());
 $('confirm').addEventListener('close',()=>{if($('confirm').returnValue!=='reset')return;generation++;clearTimeout(strokeTimer);hand.hidden=true;state=G.initial();say('……なに？');render();});
 render();say('……なに？');
})();
