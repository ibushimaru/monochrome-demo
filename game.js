'use strict';
const NatsukiGame=(()=>{
 const initial=()=>({affection:0,welcomed:false,lastTap:null,needsSpace:false,strokes:0});
 const relation=n=>n>=80?'すっかり仲良し':n>=50?'気を許している':n>=20?'少し打ち解けた':'まだ知り合い';
 function tap(state,now){
  const s={...state};const quick=s.lastTap!==null&&now-s.lastTap<1800;s.lastTap=now;
  if(!s.welcomed||s.needsSpace||quick){s.needsSpace=true;s.affection=Math.max(0,s.affection-(quick?3:0));return {state:s,line:quick?'ちょっと、待って。':'急に触らないでよ。',face:'neutral',pat:false};}
  s.strokes++;s.affection=Math.min(100,s.affection+6);
  const lines=s.affection>=80?['えへへ。','……ありがと。','もう、くすぐったい。']:s.affection>=50?['ふふっ。','……悪くないね。','髪、乱れちゃうよ。']:['わっ。','……少しだけね。','そっと、だよ。'];
  return {state:s,line:lines[(s.strokes-1)%lines.length],face:s.affection>=20?'smile':'neutral',pat:true};
 }
 function pause(state,now){
  const s={...state};if(!s.needsSpace||s.lastTap===null||now-s.lastTap<4000)return {state:s};
  s.needsSpace=false;s.welcomed=true;s.affection=Math.min(100,s.affection+8);
  return {state:s,line:s.affection>=30?'……待ってくれたんだ。':'……そっとなら、いいよ。',face:s.affection>=20?'smile':'neutral',thought:false};
 }
 return {initial,relation,tap,pause};
})();
if(typeof module!=='undefined')module.exports=NatsukiGame;
