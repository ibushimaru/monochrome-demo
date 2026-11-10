'use strict';
// Touch animation stays immediate; speech has its own reading time and pauses.
const NatsukiSpeech=(()=>{
 function create({speak,hide,now=()=>performance.now(),random=Math.random,schedule=setTimeout,cancel=clearTimeout}){
  let pending=null,hideTimer=null,nextAt=0,lastTouch=-Infinity,part='head';
  const counts={head:0,cheek:0,shoulder:0};
  function respond(){
   pending=null;
   // A tap during a pause must not become a delayed remark after the player leaves.
   if(now()-lastTouch>1600)return;
   const line=NatsukiGame.reaction(part,counts[part]++);
   const readingTime=Math.max(2600,Math.min(4200,1700+line.length*130));
   nextAt=now()+readingTime+2000+random()*1000;
   speak(line,part);
   hideTimer=schedule(()=>{hideTimer=null;hide();},readingTime);
  }
  function touch(touchedPart){
   if(!Object.hasOwn(counts,touchedPart))return;
   part=touchedPart;lastTouch=now();
   if(pending!==null)return;
   pending=schedule(respond,Math.max(nextAt-now(),550+random()*450));
  }
  function reset(){
   if(pending!==null)cancel(pending);
   if(hideTimer!==null)cancel(hideTimer);
   pending=hideTimer=null;nextAt=0;lastTouch=-Infinity;
   for(const key of Object.keys(counts))counts[key]=0;
   hide();
  }
  return {touch,reset};
 }
 return {create};
})();
if(typeof module!=='undefined')module.exports=NatsukiSpeech;
