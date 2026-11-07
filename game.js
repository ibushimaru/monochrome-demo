'use strict';
const NatsukiGame=(()=>{
 const initial=()=>({affection:0,strokes:0});
 function tap(state){
  const next={...state,strokes:state.strokes+1};
  const lines=['わっ。','ふふっ。','……ありがと。','髪、くしゃくしゃだよ。'];
  return {state:next,line:lines[(next.strokes-1)%lines.length],face:'smile',pat:true};
 }
 return {initial,tap};
})();
if(typeof module!=='undefined')module.exports=NatsukiGame;
