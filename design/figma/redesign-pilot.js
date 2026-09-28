// PAUSED historical draft: do not execute or resume until owner agrees on Components and screen work.
// Executed through Figma MCP. Creates no app implementation changes.
// Prerequisites: figma-use + figma-generate-design; published iOS 27 assets inspected.
// Re-run only after inspecting the live page. Populated wrappers are not overwritten.
const page = await figma.getNodeByIdAsync('1024:2614');
await figma.setCurrentPageAsync(page);
const created = [], mutated = [], removed = [];
const keys = {
  toolbar: '5a5c7f4643552b05f680c5ee9b1c085a942881cc',
  home: 'db1fd2b84f66cfc75ab693b5b0b77b90ae471e38',
  tabs: '971f4862d60ea7fb60429ff57f4e51dc42758f6a',
  row: 'da6c778eb113a68c7fd6f3828741ab33c3ec8f12',
  button: 'bba76d7e88d66c8704a07953ccc6056a185022b0',
  symbol: '36df7438d67ed37c94488fd11d425899f1a902ba',
  segments: 'f508912e2177f4744038dc6591e976abf1040806',
};
const assets = Object.fromEntries(await Promise.all(Object.entries(keys).map(async ([k,v])=>[k,await figma.importComponentSetByKeyAsync(v)])));
const status = await figma.importComponentByKeyAsync('e01a1714aeec1a5a0a6453485bf16e975008b282');
const colors = Object.fromEntries(await Promise.all(Object.entries({
  background:'a90ed703166e4696edc327f717296a29491d2124',
  surface:'8b0a221303d2f2bb0871eddd4274517a90e17762',
  label:'f53b56d4ed0520da1fb2c8586d67d82113ae1dcb',
  secondary:'4cd5aad6cbe2b035a0865fe9661e1e5458ab8f8c',
  blue:'a2a887a78db2624665e93ec4f131d7c56da46f24',
}).map(async([k,v])=>[k,await figma.variables.importVariableByKeyAsync(v)])));
const bodyStyle = await figma.importStyleByKeyAsync('5e51bb075a2e98b7f8345cbb49bcf155a767717f');
const fonts = new Map();
for (const root of [status,...Object.values(assets)]) for(const t of root.findAllWithCriteria({types:['TEXT']})) for(const s of t.getStyledTextSegments(['fontName'])) fonts.set(JSON.stringify(s.fontName),s.fontName);
for(const family of ['SF Pro','SF Pro Rounded']) for(const style of ['Regular','Semibold','Bold']) fonts.set(family+style,{family,style});
await Promise.all([...fonts.values()].map(f=>figma.loadFontAsync(f)));
const paint = key => figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color',colors[key]);
const variant = (key,name) => {const c=assets[key].children.find(n=>n.name===name);if(!c)throw Error('Missing native variant: '+key+'/'+name);return c;};
const track = n => {created.push(n.id);return n;};
function instance(parent,component,name){const n=track(component.createInstance());parent.appendChild(n);n.name=name;return n;}
function stack(parent,name,width,gap=0){const n=track(figma.createAutoLayout('VERTICAL'));parent.appendChild(n);n.name=name;n.fills=[];n.resize(width,1);n.layoutSizingVertical='HUG';n.itemSpacing=gap;return n;}
function textNode(parent,label,width,size=17,weight='Regular',color='label',rounded=false){const n=track(figma.createText());parent.appendChild(n);n.textStyleId=bodyStyle.id;n.fontName={family:rounded?'SF Pro Rounded':'SF Pro',style:weight};n.fontSize=size;n.lineHeight={unit:'PIXELS',value:size<=13?18:size<=17?22:size<=22?28:38};n.characters=label;n.name=label;n.fills=[paint(color)];n.textAutoResize='HEIGHT';n.resize(width,n.height);n.layoutSizingVertical='HUG';return n;}
function fillSpace(parent){const n=stack(parent,'Flexible space',1);n.layoutSizingVertical='FILL';return n;}
function button(parent,label,width,secondary=false){const n=instance(parent,variant('button',`Size=Large, Style=${secondary?'Bordered':'Bordered - Prominent'}, Label Style=Title only, Is Enabled=True, Destructive=False`),label);n.setProperties({'Label#488:0':label});n.resize(width,50);return n;}
const defaultToolbar=variant('toolbar','Style=Default');
const groupMain=await defaultToolbar.findAllWithCriteria({types:['INSTANCE']}).find(n=>n.name==='Button Group').getMainComponentAsync();
const groupSet=groupMain.parent;
function toolbar(parent,title,large=false,leading='back',trailing='ellipsis'){
  const n=instance(parent,variant('toolbar',large?'Style=Large Title':'Style=Default'),'Native navigation');
  n.resize(402,large?105:54);n.setProperties({'Show Subtitle#5561:8':false});
  for(const t of n.findAllWithCriteria({types:['INSTANCE']}).filter(i=>i.name==='Title')) {const p=Object.keys(t.componentProperties).find(k=>k.startsWith('Title#'));if(p){t.setProperties({[p]:title});mutated.push(t.id);}}
  const slots=n.findAllWithCriteria({types:['SLOT']});
  for(const [name,value]of [['Leading',leading],['Trailing',trailing]]){
    const slot=slots.find(s=>s.name===name);if(!slot)throw Error('Missing '+name+' slot');
    for(const child of [...slot.children]){removed.push(child.id);child.remove();}
    if(!value)continue;
    const group=groupSet.children.find(c=>c.name===(value==='back'?'Type=Back':'Type=Symbol'));
    const g=instance(slot,group,name==='Leading'?'Back':value==='gearshape'?'Settings':'More goal actions');
    if(value!=='back'){const symbol=g.findAllWithCriteria({types:['INSTANCE']}).find(i=>'Symbol#5429:0'in i.componentProperties);symbol.setProperties({'Symbol#5429:0':figma.util.getSfSymbolCharacter(value)});mutated.push(symbol.id);}
  }
  return n;
}
function shell(frame,title,selected,{large=false,leading='back',trailing='ellipsis'}={}){
  if(frame.children.length)throw Error('Wrapper already populated: '+frame.id);
  frame.fills=[paint('background')];frame.placeholder=false;mutated.push(frame.id);
  const s=instance(frame,status,'Status bar · 62pt');s.setProperties({'Time#5466:4':'9:41'});s.resize(402,62);
  const nav=toolbar(frame,title,large,leading,trailing);
  const body=stack(frame,'Content',402);body.layoutSizingVertical='FILL';
  const tabs=instance(frame,variant('tabs','Minimized=False, Tabs=3, Type=Default'),'Tab bar · full 95pt bounds');tabs.resize(402,95);
  const items=tabs.findAllWithCriteria({types:['INSTANCE']}).filter(n=>n.name==='Tab');
  const labels=['Home','Tasks','Goals'],symbols=['house.fill','checkmark.square.fill','target'];
  for(let i=0;i<items.length;i++){items[i].setProperties({'Label#5735:10':labels[i],'Symbol#5735:9':figma.util.getSfSymbolCharacter(symbols[i]),Selected:i===selected?'True':'False'});mutated.push(items[i].id);}
  tabs.resize(402,95);tabs.layoutSizingVertical='FIXED';tabs.minHeight=95;
  const h=instance(frame,variant('home','Device=iPhone, Orientation=Portrait'),'Home indicator · full 34pt bounds');h.resize(402,34);
  return {frame,nav,body,tabs,items,home:h};
}
const home=shell(await figma.getNodeByIdAsync('1024:2615'),'Home',0,{large:true,leading:null,trailing:'gearshape'});
home.body.paddingLeft=24;home.body.paddingRight=24;home.body.paddingTop=46;home.body.paddingBottom=20;home.body.itemSpacing=24;
const hero=stack(home.body,'First-use guidance',354,12);hero.counterAxisAlignItems='CENTER';
const icon=textNode(hero,figma.util.getSfSymbolCharacter('brain.head.profile'),354,48,'Regular','blue');icon.lineHeight={unit:'PIXELS',value:60};icon.textAlignHorizontal='CENTER';
const headline=textNode(hero,'A little less on\nyour mind.',354,32,'Bold','label',true);headline.textAlignHorizontal='CENTER';
const intro=textNode(hero,'Turn scattered thoughts into tasks\nand goals, one small step at a time.',354,17,'Regular','secondary');intro.textAlignHorizontal='CENTER';
const start=button(home.body,'Start a brain dump',354);
const assurance=textNode(home.body,'Type or speak. Review everything\nbefore it’s saved.',354,15,'Regular','secondary');assurance.textAlignHorizontal='CENTER';
fillSpace(home.body);
const example=button(home.body,'Try an example',354,true);
const goal=shell(await figma.getNodeByIdAsync('1024:2616'),'Guitar',2);
goal.body.paddingTop=16;goal.body.paddingLeft=16;goal.body.paddingRight=16;goal.body.paddingBottom=16;goal.body.itemSpacing=24;
const summary=textNode(goal.body,'1 entry · Updated today',370,13,'Regular','secondary');
const picker=instance(goal.body,variant('segments','Size=Large, Is Enabled=True'),'Timeline / Calendar');
const segmentSlot=picker.findAllWithCriteria({types:['SLOT']}).find(n=>n.name==='Segments');
for(const child of [...segmentSlot.children].slice(2)){removed.push(child.id);child.remove();}
segmentSlot.children.forEach((n,i)=>{n.setProperties({'Title#10512:0':i?'Calendar':'Timeline','Is Selected':i?'False':'True'});mutated.push(n.id);});
const timeline=stack(goal.body,'Activity',370,12);textNode(timeline,'Today',370,20,'Bold','label',true);
const entry=instance(timeline,variant('row','Height=Tall'),'Quick progress entry');
entry.resize(370,68);entry.setProperties({'Title#519:116':'Did something','Subtitle#519:149':'9:04 PM · Quick entry','Show Trailing#5534:8':false});entry.fills=[paint('surface')];entry.cornerRadius=20;
const progress=instance(goal.body,variant('row','Height=Regular'),'View progress');progress.resize(370,52);progress.setProperties({'Title#519:116':'View progress','Show Subtitle#525:450':false});progress.fills=[paint('surface')];progress.cornerRadius=20;
const trailing=progress.findAllWithCriteria({types:['INSTANCE']}).find(i=>i.name==='Contents - Trailing');
if(trailing){trailing.setProperties({'Detail Text#508:54':'1 entry','Show Symbol#212:5':false,'Show Drill-in#212:3':true});mutated.push(trailing.id);}
fillSpace(goal.body);
const gentle=textNode(goal.body,'Small steps still count.',370,15,'Regular','secondary');gentle.textAlignHorizontal='CENTER';
const actionRow=track(figma.createAutoLayout('HORIZONTAL'));goal.frame.insertChild(3,actionRow);actionRow.name='Progress actions · reserved space';actionRow.resize(402,67);actionRow.fills=[];actionRow.paddingLeft=16;actionRow.paddingRight=16;actionRow.paddingTop=8;actionRow.paddingBottom=9;actionRow.itemSpacing=8;
const quick=button(actionRow,'Did something today',312);
const note=instance(actionRow,variant('symbol','Style=Glass, Is Enabled=True, Destructive=False'),'Add progress note');note.resize(50,50);
const noteText=note.findAllWithCriteria({types:['INSTANCE']}).find(i=>'Label#5429:13'in i.componentProperties);if(noteText){noteText.setProperties({'Label#5429:13':figma.util.getSfSymbolCharacter('square.and.pencil')});mutated.push(noteText.id);}
return {createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed,pageId:page.id,frames:[home,goal].map(x=>({id:x.frame.id,name:x.frame.name,bounds:{w:x.frame.width,h:x.frame.height},regions:x.frame.children.map(n=>({id:n.id,name:n.name,y:n.y,h:n.height})),slotViolations:x.frame.findAllWithCriteria({types:['SLOT']}).map(s=>({id:s.id,name:s.name,violations:s.limitViolations}))})),actions:{start:start.id,example:example.id,quick:quick.id,note:note.id,progress:progress.id,picker:picker.id}};
