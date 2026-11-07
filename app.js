'use strict';
(()=>{
 const $=id=>document.getElementById(id),G=NatsukiGame;
 let state=G.initial(),generation=0,strokeTimer,bubbleTimer;
 const images={};for(const n of ['neutral','smile','pat1','pat2']){images[n]=new Image();images[n].src='assets/natsuki/'+n+'.png';}
 const handsReady=Promise.all([images.pat1.decode(),images.pat2.decode()]).then(()=>true,()=>false);
 function face(n){$('portrait').src=images[n].src;$('portrait').alt=n==='smile'?'笑顔の夏希':'夏希';}
 function render(){ $('score').textContent=state.affection+' / 100';$('meter').value=state.affection;$('relationship').textContent=''; }
 function say(line){clearTimeout(bubbleTimer);$('line').textContent=line;$('bubble').classList.remove('faded');bubbleTimer=setTimeout(()=>$('bubble').classList.add('faded'),3200);}
 async function stroke(count){
  const token=++generation;clearTimeout(strokeTimer);
  if(!await handsReady){$('hint').textContent='画像を読み込めませんでした。再読み込みしてください。';return;}
  if(token!==generation)return;
  $('hand').src=images[count%2?'pat1':'pat2'].src;$('hand').hidden=false;
  strokeTimer=setTimeout(()=>{if(token===generation)$('hand').hidden=true;},1200);
 }
 $('head').addEventListener('click',()=>{
  const r=G.tap(state);state=r.state;face(r.face);say(r.line);render();stroke(state.strokes);
 });
 $('reset').addEventListener('click',()=>$('confirm').showModal());
 $('confirm').addEventListener('close',()=>{if($('confirm').returnValue!=='reset')return;generation++;clearTimeout(strokeTimer);$('hand').hidden=true;state=G.initial();face('neutral');say('……なに？');render();});
 face('neutral');render();say('……なに？');
})();
