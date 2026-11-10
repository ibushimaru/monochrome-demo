'use strict';
const NatsukiGame=(()=>{
 const lines={head:['わっ。','ふふっ。','……ありがと。','髪、くしゃくしゃだよ。'],cheek:['なに？','ほっぺに何かついてる？','もう、つつかないの。','ふふ、変なの。'],shoulder:['呼んだ？','どうしたの？','はいはい、聞いてるよ。','あ、びっくりした。']};
 const initial=()=>({affection:0,strokes:0,counts:{head:0,cheek:0,shoulder:0}});
 function tap(state,part='head'){
  if(!Object.hasOwn(lines,part))return {state};
  const counts={...state.counts,[part]:state.counts[part]+1};
  const next={...state,strokes:state.strokes+1,counts};
  return {state:next,part,line:lines[part][(counts[part]-1)%lines[part].length],frame:counts[part]%2?'1':'2'};
 }
 const reaction=(part,index)=>lines[part]?.[index%lines[part].length];
 return {initial,tap,reaction};
})();
if(typeof module!=='undefined')module.exports=NatsukiGame;
