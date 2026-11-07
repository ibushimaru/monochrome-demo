'use strict';
(()=>{
 const $=id=>document.getElementById(id),G=NatsukiGame,key='natsuki-demo-v2';let state=G.initial(),timer=null,busy=false,nextFrame=0,saveOK=true;
 try{const s=JSON.parse(localStorage.getItem(key));if(s&&Number.isFinite(s.affection)&&Number.isInteger(s.topic)&&s.topic>=0&&s.topic<G.topics.length){state={...G.initial(),affection:Math.max(0,Math.min(100,s.affection)),topic:s.topic};}}catch(e){saveOK=false;}
 const images={};for(const name of ['neutral','smile','pat1','pat2']){images[name]=new Image();images[name].src='assets/natsuki/'+name+'.png';}
 const show=name=>{$('portrait').src=images[name].src;$('portrait').alt=name.startsWith('pat')?'頭を撫でられて微笑む夏希':name==='smile'?'笑顔の夏希':'少し警戒した表情の夏希';};
 const rest=()=>show(state.affection>=25?'smile':'neutral');
 function save(){try{localStorage.setItem(key,JSON.stringify(state));}catch(e){saveOK=false;}}
 function render(){
  $('score').textContent=state.affection+' / 100';$('meter').value=state.affection;$('relationship').textContent=G.relation(state.affection);
  $('choices').replaceChildren();$('choices').hidden=!state.pending;
  if(state.pending)G.topics[state.topic].a.forEach((a,i)=>{const b=document.createElement('button');b.textContent=a[0];b.addEventListener('click',()=>run('answer',i));$('choices').append(b);});
  $('talk').disabled=busy||state.pending;$('pat').disabled=busy||state.pending;$('wait').disabled=busy;
 }
 async function animate(){
  busy=true;render();
  const names=['pat1','pat2'];
  try{await Promise.all(names.map(n=>images[n].decode()));}catch(e){busy=false;rest();render();return;}
  let ticks=0;show(names[nextFrame]);nextFrame=1-nextFrame;
  timer=setInterval(()=>{ticks++;if(ticks>=4){clearInterval(timer);timer=null;busy=false;rest();render();return;}show(names[nextFrame]);nextFrame=1-nextFrame;},300);
 }
 function run(type,index){
  if(busy)return;const result=G.act(state,type,index);state=result.state;
  if(result.line)$('line').textContent=result.line;
  if(type==='talk')$('feedback').textContent='返事を選んでね。';
  else $('feedback').textContent=result.delta>0?'好感度 ＋'+result.delta:result.delta<0?'好感度 '+result.delta:'少しずつ、夏希のことを知っていこう。';
  if(result.face)show(result.face);else rest();save();render();
  if(result.pat)animate();
 }
 $('talk').addEventListener('click',()=>run('talk'));$('pat').addEventListener('click',()=>run('pat'));$('wait').addEventListener('click',()=>run('wait'));
 $('reset').addEventListener('click',()=>$('confirm').showModal());
 $('confirm').addEventListener('close',()=>{if($('confirm').returnValue!=='reset')return;clearInterval(timer);busy=false;state=G.initial();save();rest();render();$('line').textContent='あれ、まだ帰ってなかったんだ。何か用？';$('feedback').textContent='まずは話しかけてみよう。';});
 if(state.affection>0)$('line').textContent=state.affection>=50?'あ、おかえり！ また話せると思ってた。':'また会ったね。今日はどうしたの？';
 rest();render();if(!saveOK)$('feedback').textContent='このブラウザでは進行を保存できません。';
})();
