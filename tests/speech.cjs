const assert=require('node:assert/strict');
global.NatsukiGame=require('../game.js');
const Speech=require('../speech.js');
function harness(){
 let time=0,id=0;const timers=new Map(),events=[];
 const speech=Speech.create({now:()=>time,random:()=>0,schedule:(fn,ms)=>{timers.set(++id,{fn,at:time+ms});return id;},cancel:id=>timers.delete(id),speak:(line,part)=>events.push({line,part,time}),hide:()=>events.push({hide:true,time})});
 function advance(ms){const end=time+ms;while(true){const next=[...timers].filter(([,t])=>t.at<=end).sort((a,b)=>a[1].at-b[1].at)[0];if(!next)break;time=next[1].at;timers.delete(next[0]);next[1].fn();}time=end;}
 return {speech,events,advance};
}
const h=harness();
h.speech.touch('head');h.advance(549);assert.equal(h.events.length,0);
h.advance(1);assert.equal(h.events[0].line,'わっ。');
for(let i=0;i<25;i++){h.speech.touch('cheek');h.advance(100);}
assert.equal(h.events.filter(e=>e.line).length,1,'rapid taps must not replace a visible remark');
h.advance(100);assert.equal(h.events.at(-1).hide,true);
for(let i=0;i<20;i++){h.speech.touch('cheek');h.advance(100);}
assert.equal(h.events.at(-1).line,'なに？','spoken lines advance independently of tap counts');
const quiet=harness();quiet.speech.touch('head');quiet.advance(550);quiet.speech.touch('shoulder');quiet.advance(6000);
assert.equal(quiet.events.filter(e=>e.line).length,1,'stale queued reactions should be discarded');
const reset=harness();reset.speech.touch('cheek');reset.speech.reset();reset.advance(6000);assert.equal(reset.events.filter(e=>e.line).length,0);
reset.speech.touch('cheek');reset.advance(550);assert.equal(reset.events.at(-1).line,'なに？');
console.log('Speech timing tests passed');
