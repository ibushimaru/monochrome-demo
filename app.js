'use strict';
(()=>{
 const $=id=>document.getElementById(id),G=NatsukiGame,key='natsuki-demo-v3';let state=G.initial(),generation=0,frame=0,strokeTimer,spaceTimer,bubbleTimer;
 try{const s=JSON.parse(localStorage.getItem(key));if(s&&Number.isFinite(s.affection))state={...state,affection:Math.max(0,Math.min(100,s.affection)),welcomed:s.welcomed===true};}catch(e){}
 const images={};for(const n of ['neutral','smile','pat1','pat2']){images[n]=new Image();images[n].src='assets/natsuki/'+n+'.png';}
 function save(){try{localStorage.setItem(key,JSON.stringify({affection:state.affection,welcomed:state.welcomed}));}catch(e){$('hint').textContent='頭をタップ（この環境では保存できません）';}}
 function face(n){$('portrait').src=images[n].src;$('portrait').alt=n==='smile'?'笑顔の夏希':'少し警戒した表情の夏希';}
 function render(){ $('score').textContent=state.affection+' / 100';$('meter').value=state.affection;$('relationship').textContent=G.relation(state.affection);save(); }
 function say(line,thought=false){clearTimeout(bubbleTimer);$('line').textContent=line;$('bubble').classList.remove('faded');$('bubble').classList.toggle('thought',thought);bubbleTimer=setTimeout(()=>$('bubble').classList.add('faded'),3200);}
 function stopHand(){generation++;clearTimeout(strokeTimer);$('hand').hidden=true;}
 async function stroke(){const token=generation;try{await Promise.all([images.pat1.decode(),images.pat2.decode()]);}catch(e){return;}if(token!==generation)return;frame=1-frame;$('hand').src=images[frame?'pat1':'pat2'].src;$('hand').hidden=false;strokeTimer=setTimeout(()=>{if(token!==generation)return;frame=1-frame;$('hand').src=images[frame?'pat1':'pat2'].src;strokeTimer=setTimeout(()=>$('hand').hidden=true,350);},350);}
 $('head').addEventListener('click',()=>{
  stopHand();clearTimeout(spaceTimer);const r=G.tap(state,Date.now());state=r.state;face(r.face);say(r.line);render();if(r.pat)stroke();
  if(state.needsSpace)spaceTimer=setTimeout(()=>{const r=G.pause(state,Date.now());state=r.state;if(r.line){say(r.line,r.thought);face(r.face);render();}},4100);
 });
 $('reset').addEventListener('click',()=>$('confirm').showModal());
 $('confirm').addEventListener('close',()=>{if($('confirm').returnValue!=='reset')return;stopHand();clearTimeout(spaceTimer);state=G.initial();face('neutral');say('……なに？');render();});
 face(state.affection>=20?'smile':'neutral');render();say(state.welcomed?'あ、おかえり。':'……なに？');
})();
