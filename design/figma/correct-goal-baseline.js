// Run after build-baseline-screens.js and repair-native-controls.js.
// Corrected from settled Simulator capture 17, not captures 10/11.
await figma.setCurrentPageAsync(await figma.getNodeByIdAsync('967:1893'));
const root = await figma.getNodeByIdAsync('984:436');
const created = [], mutated = [], removed = [];
const fonts = new Map();
for (const t of root.findAllWithCriteria({types:['TEXT']}))
  for (const s of t.getStyledTextSegments(['fontName'])) fonts.set(JSON.stringify(s.fontName),s.fontName);
const note = await figma.getNodeByIdAsync('990:371');
for (const s of note.getStyledTextSegments(['fontName'])) fonts.set(JSON.stringify(s.fontName),s.fontName);
await Promise.all([...fonts.values(),{family:'SF Pro',style:'Regular Italic'},{family:'SF Pro',style:'Regular'},{family:'SF Pro Rounded',style:'Semibold'}].map(f=>figma.loadFontAsync(f)));
const solid = (r,g,b)=>({type:'SOLID',color:{r:r/255,g:g/255,b:b/255}});
function stack(parent,name,dir,w,h) {
  const n=figma.createAutoLayout(dir); n.name=name; n.fills=[];
  n.resize(w,h||1); parent.appendChild(n); n.layoutSizingHorizontal='FIXED'; n.layoutSizingVertical=h?'FIXED':'HUG';
  created.push(n.id); return n;
}
root.name='Baseline / Goal detail / Reverified'; mutated.push(root.id);
const body=await figma.getNodeByIdAsync('984:451');
const nav=await figma.getNodeByIdAsync('984:447');
const bottom=await figma.getNodeByIdAsync('984:452');
const picker=await figma.getNodeByIdAsync('990:366');
const entry=await figma.getNodeByIdAsync('984:482');
const title=await figma.getNodeByIdAsync('984:450');
const quick=await figma.getNodeByIdAsync('984:485');
const overview=await figma.getNodeByIdAsync('984:490');
const button=await figma.getNodeByIdAsync('984:486');
const label=await figma.getNodeByIdAsync('984:487');
const compose=await figma.getNodeByIdAsync('984:488');
for(const id of ['993:630','993:636']) {
  const b=await figma.getNodeByIdAsync(id);
  const sym=b.findOne(n=>n.type==='INSTANCE'&&Object.prototype.hasOwnProperty.call(n.componentProperties,'Label#5429:13'));
  sym.setProperties({'Label#5429:13':figma.util.getSfSymbolCharacter(id==='993:630'?'chevron.backward':'ellipsis.circle')});
  mutated.push(b.id,sym.id);
}
if(!nav.children.some(n=>n.name==='Goal title')) {
  const titleGroup=stack(nav,'Goal title','HORIZONTAL',258,44); nav.insertChild(1,titleGroup);
  titleGroup.itemSpacing=6;titleGroup.primaryAxisAlignItems='CENTER';titleGroup.counterAxisAlignItems='CENTER';
  const dot=figma.createEllipse();dot.name='Goal color';dot.resize(8,8);dot.fills=[solid(167,139,250)];titleGroup.appendChild(dot);created.push(dot.id);
  titleGroup.appendChild(title);title.fontName={family:'SF Pro Rounded',style:'Semibold'};title.textAutoResize='WIDTH_AND_HEIGHT';title.layoutSizingHorizontal='HUG';title.layoutSizingVertical='HUG';
}
body.clipsContent=true;body.paddingTop=26;body.paddingBottom=18;body.paddingLeft=16;body.paddingRight=16;body.itemSpacing=32;body.layoutSizingVertical='FILL';
body.insertChild(0,picker);picker.layoutPositioning='AUTO';picker.resize(370,32);picker.layoutSizingVertical='FIXED';
const oldTexts=[...entry.children].filter(n=>n.type==='TEXT');
if(oldTexts.length) {
  entry.name='Progress entry';entry.layoutMode='HORIZONTAL';entry.itemSpacing=16;
  entry.paddingTop=0;entry.paddingBottom=24;entry.paddingLeft=0;entry.paddingRight=0;
  const marker=stack(entry,'Timeline marker','VERTICAL',12,16);marker.paddingTop=4;
  const dot=figma.createEllipse();dot.name='Goal color';dot.resize(12,12);dot.fills=[solid(167,139,250)];marker.appendChild(dot);created.push(dot.id);
  const col=stack(entry,'Entry content','VERTICAL',342);col.itemSpacing=4;
  for(const t of oldTexts){col.appendChild(t);t.resize(342,1);t.textAutoResize='HEIGHT';t.layoutSizingVertical='HUG';mutated.push(t.id);}
  oldTexts[0].characters='28 Sep at 9:04 PM';
  oldTexts[1].fontName={family:'SF Pro',style:'Regular Italic'};
}
body.insertChild(1,entry);entry.layoutPositioning='AUTO';entry.resize(370,63);entry.layoutSizingVertical='HUG';
let space=body.children.find(n=>n.name==='Flexible space');
if(!space)space=stack(body,'Flexible space','VERTICAL',370,1);
body.insertChild(2,space);space.layoutSizingVertical='FILL';
let overviewRow=body.children.find(n=>n.name==='Overview action row');
if(!overviewRow)overviewRow=stack(body,'Overview action row','HORIZONTAL',370,50);
overviewRow.primaryAxisAlignItems='MAX';overviewRow.appendChild(overview);overview.layoutPositioning='AUTO';overview.resize(50,50);overview.layoutSizingVertical='FIXED';overview.fills=[solid(0,0,0)];overview.opacity=.8;
bottom.name='Progress actions';bottom.paddingTop=0;bottom.paddingBottom=3;bottom.paddingLeft=0;bottom.paddingRight=0;bottom.itemSpacing=15;bottom.layoutSizingVertical='HUG';
if(!bottom.children.some(n=>n.name==='Divider')) {
  const divider=figma.createRectangle();divider.name='Divider';divider.resize(402,1);divider.fills=[solid(220,220,222)];bottom.appendChild(divider);created.push(divider.id);
}
let actionSlot=bottom.children.find(n=>n.name==='Action inset');
if(!actionSlot)actionSlot=stack(bottom,'Action inset','HORIZONTAL',402,48);
actionSlot.paddingLeft=16;actionSlot.paddingRight=16;actionSlot.appendChild(quick);
quick.name='Progress actions / Current app';quick.layoutPositioning='AUTO';quick.resize(370,48);quick.itemSpacing=8;
button.resize(314,48);button.cornerRadius=12;button.fills=[solid(52,199,89)];
label.fontName={family:'SF Pro',style:'Regular'};
compose.resize(48,48);compose.cornerRadius=12;compose.layoutSizingVertical='FIXED';
note.name='Baseline verification correction';
note.characters='REVERIFIED BASELINE · Capture 17\nAfter reopening the app, both controls sit clear of navigation. The earlier overlap claim is withdrawn. Native Apple controls are retained. The bottom area follows the agreed 95pt tab + 34pt home-indicator layout slots.';
note.resize(402,1);note.textAutoResize='HEIGHT';
mutated.push(body.id,nav.id,bottom.id,picker.id,entry.id,title.id,quick.id,overview.id,button.id,label.id,compose.id,note.id,space.id,overviewRow.id,actionSlot.id);
return {createdIds:created,mutatedIds:mutated,removedIds:removed,rootId:root.id,regions:root.children.map(n=>({id:n.id,name:n.name,y:n.y,height:n.height})),picker:picker.absoluteBoundingBox,quick:quick.absoluteBoundingBox};
