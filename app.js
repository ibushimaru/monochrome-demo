'use strict';
(()=>{
 const $=id=>document.getElementById(id),G=NatsukiGame;
 let state=G.initial(),generation=0,strokeTimer,bubbleTimer;
 const hand=$('hand');
 const sources={head:'assets/natsuki/hand-flat.png',cheek:'assets/natsuki/poke-flat.png',shoulder:'assets/natsuki/hand-flat.png'};
 const ready={};for(const src of new Set(Object.values(sources))){const image=new Image();image.src=src;ready[src]=image.decode().then(()=>true,()=>false);}
 function render(){ $('score').textContent=state.affection+' / 100';$('meter').value=state.affection;$('relationship').textContent=''; }
 function say(line,part='head',duration=3200){clearTimeout(bubbleTimer);$('line').textContent=line;$('bubble').dataset.part=part;$('bubble').classList.remove('faded');if(duration)bubbleTimer=setTimeout(()=>$('bubble').classList.add('faded'),duration);}
 const speech=NatsukiSpeech.create({speak:(line,part)=>say(line,part,0),hide:()=>$('bubble').classList.add('faded')});
 async function gesture(part,side,frame){
  const token=++generation;clearTimeout(strokeTimer);hand.hidden=true;
  const src=sources[part];
  if(!await ready[src]){if(token===generation)$('hint').textContent='画像を読み込めませんでした。再読み込みしてください。';return;}
  if(token!==generation)return;
  hand.src=src;hand.dataset.part=part;hand.dataset.side=side;hand.dataset.frame=frame;hand.hidden=false;
  strokeTimer=setTimeout(()=>{if(token===generation)hand.hidden=true;},1200);
 }
 document.querySelectorAll('[data-part][data-side]').forEach(zone=>{
  zone.addEventListener('click',()=>{const {part,side}=zone.dataset;const r=G.tap(state,part);state=r.state;render();gesture(part,side,r.frame);speech.touch(part);});
 });
 $('reset').addEventListener('click',()=>$('confirm').showModal());
 $('confirm').addEventListener('close',()=>{if($('confirm').returnValue!=='reset')return;generation++;clearTimeout(strokeTimer);hand.hidden=true;speech.reset();state=G.initial();say('……なに？');render();});
 render();say('……なに？');
})();
