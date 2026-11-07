'use strict';
const NatsukiGame=(()=>{
 const topics=[
 {q:'さっきまで走ってたんだ。今日、最後の一本がきつくてさ。',a:[['最後まで走ったんだ。お疲れさま！',15,'ありがと！ そう言ってもらえると、頑張ったかいがあるね。'],['それくらい普通じゃない？',-8,'……そっか。まあ、私なりには頑張ったんだけどね。']]},
 {q:'次の大会、ちょっと緊張するんだよね。失敗したらどうしようって。',a:[['緊張してても、応援してるよ。',15,'うん。じゃあ、見ててよ。私、ちゃんと走り切るから！'],['絶対に勝ってよ。',-5,'絶対って言われると、余計に緊張するんだけど……。']]},
 {q:'休みの日って何してる？ 私はつい外に出ちゃうんだ。',a:[['散歩かな。おすすめの場所、ある？',12,'川沿い！ 夕方の風が気持ちいいんだ。今度、案内しようか？'],['夏希の好きなもの、もっと聞きたい。',10,'え、私？ 走ることと……帰りに食べるアイス、かな。']]},
 {q:'今日はちょっと張り切りすぎたかも。足がくたくただよ。',a:[['少し座ろう。急がなくていいよ。',15,'じゃあ、ちょっとだけ。……隣、空いてるよ。'],['もっと練習した方がいいんじゃない？',-8,'今日はもう十分。少しくらい休ませてよ。']]},
 {q:'また明日も、ここで会える？',a:[['うん。また話そう。',12,'約束ね！ じゃあ明日は、私から声かける。'],['気が向いたらね。',-5,'そっか。……まあ、無理には誘わないけど。']]}
 ];
 const initial=()=>({affection:0,topic:0,pending:false,patStreak:0});
 const relation=n=>n>=80?'すっかり仲良し':n>=50?'気を許している':n>=25?'話しやすい相手':'まだ知り合い';
 function act(s,type,index){
  s={...s};let line='',delta=0,pat=false,face='';
  if(type==='talk'){s.pending=true;return {state:s,line:topics[s.topic].q};}
  if(type==='answer'){
   if(!s.pending||!Number.isInteger(index)||!topics[s.topic].a[index])return {state:s};
   const a=topics[s.topic].a[index];delta=a[1];line=a[2];s.topic=(s.topic+1)%topics.length;s.pending=false;s.patStreak=0;face=delta>0?'smile':'neutral';
  }else if(type==='pat'){
   if(s.pending)return {state:s};
   s.patStreak++;
   if(s.affection<50){delta=-5;line='ちょ、いきなりはやめてよ。まだ、そういうの慣れてないから。';face='neutral';}
   else if(s.patStreak>2){delta=-6;line='もう、髪くしゃくしゃになるって！ そろそろ話そうよ。';face='neutral';}
   else{delta=4;line=s.affection>=80?'えへへ。……頑張ったご褒美ってことで。':'ちょっと照れるけど……少しだけなら、いいよ。';pat=true;}
  }else if(type==='wait'){s.pending=false;s.patStreak=0;line=s.affection>=25?'ふう。こうして一緒にのんびりするのも、いいね。':'……ちょっと休憩。話したくなったら声かけて。';}
  else if(type!=='answer')return {state:s};
  const old=s.affection;s.affection=Math.min(100,Math.max(0,s.affection+delta));
  return {state:s,line,delta:s.affection-old,pat,face};
 }
 return {initial,relation,topics,act};
})();
if(typeof module!=='undefined')module.exports=NatsukiGame;
