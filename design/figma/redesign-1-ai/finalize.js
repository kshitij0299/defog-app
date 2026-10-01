// Append after common.js. Targeted follow-up; inspect the live page before reuse.
async function editText(id,value){const n=await figma.getNodeByIdAsync(id);if(n.type!=='TEXT')throw Error('Expected text '+id);for(const s of n.getStyledTextSegments(['fontName']))await figma.loadFontAsync(s.fontName);n.characters=value;n.name=value.slice(0,48);mutated.push(n.id);}
for(const id of ['1097:671','1097:976']){const n=await figma.getNodeByIdAsync(id);await fonts(n);own(n,'Detail','No entries yet');}
await editText('1097:670','Things you’re growing');
await editText('1097:680','There’s room for one small thing today.');
await editText('1097:1054','No entries yet · Started today');
await editText('1097:1063','Your story starts here.');
const entry=await figma.getNodeByIdAsync('1097:1064');entry.visible=false;mutated.push(entry.id);
const empty=await figma.getNodeByIdAsync('1097:1062');await fonts(empty);empty.name='Empty timeline';mutated.push(empty.id);
if(!empty.children.some(n=>n.name==='Log a little progress, with or without a note.'))txt(empty,'Log a little progress, with or without a note.',354,'Body','Secondary');
await editText('1097:1238','Eight screens only. Start with Home empty → Brain dump → Review → Save. After saving, Home / Tasks / Goals and Settings are linked. Editing, voice, task actions, progress logging, Calendar, connection testing and other controls are visual specimens. Keyboard, processing/cancel, no-result, other review categories, Daily Summary and lifecycle/error states need later designs. This is a fixed-content prototype; source risks are not resolved by it.');
const destinations={settings:'1097:1082',capture:'1097:685',goal:'1097:991',review:'1097:745',saved:'1097:589'};
const actionNodes=[['1097:535','settings'],['1097:576','capture'],['1097:615','settings'],['1097:671','goal'],['1097:681','capture'],['1097:702','back'],['1097:741','review'],['1097:762','back'],['1097:819','saved'],['1097:842','settings'],['1097:915','capture'],['1097:938','settings'],['1097:976','goal'],['1097:987','capture'],['1097:1008','back'],['1097:1099','back']];
const links=[];
async function link(n,to){const action=to==='BACK'?{type:'BACK'}:{type:'NODE',destinationId:to,navigation:'NAVIGATE',transition:null,resetScrollPosition:true};await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[action]}]);mutated.push(n.id);links.push({nodeId:n.id,name:n.name,to});}
for(const[id,key]of actionNodes)await link(await figma.getNodeByIdAsync(id),key==='back'?'BACK':destinations[key]);
const tabs={Home:'1097:589',Tasks:'1097:823',Goals:'1097:919'};
for(const id of ['1097:624','1097:851','1097:947','1097:1025']){const bar=await figma.getNodeByIdAsync(id);for(const n of bar.findAllWithCriteria({types:['INSTANCE']})){const label=n.componentProperties['Label#5735:10']?.value;if(tabs[label]&&tabs[label]!==bar.parent.id)await link(n,tabs[label]);}}
page.flowStartingPoints=[{nodeId:'1097:516',name:'Start here · capture and review'},{nodeId:'1097:589',name:'Explore saved items'}];mutated.push(page.id);
// A real edit-and-restore verifies that the instances remain attached.
const main=await figma.getNodeByIdAsync('1096:680');const radius=main.cornerRadius;const instanceIds=['1097:671','1097:811','1097:976'];const before=[],during=[],after=[];
for(const id of instanceIds){const n=await figma.getNodeByIdAsync(id);before.push({id,radius:n.cornerRadius,mainId:(await n.getMainComponentAsync()).id});}
try{main.cornerRadius=radius+1;mutated.push(main.id);for(const id of instanceIds){const n=await figma.getNodeByIdAsync(id);during.push({id,radius:n.cornerRadius});}}finally{main.cornerRadius=radius;}
for(const id of instanceIds){const n=await figma.getNodeByIdAsync(id);after.push({id,radius:n.cornerRadius});}
const propagation={mainId:main.id,before,during,after,passed:during.every(n=>n.radius===radius+1)&&after.every(n=>n.radius===radius)};
const screens=page.children.filter(n=>n.name.startsWith('Screen / '));
const bounds=screens.map(n=>({id:n.id,name:n.name,width:n.width,height:n.height,regions:n.children.map(c=>({id:c.id,name:c.name,y:c.y,height:c.height}))}));
const allInstances=page.findAllWithCriteria({types:['INSTANCE']});let attached=0;const missing=[];for(const n of allInstances){if(await n.getMainComponentAsync())attached++;else missing.push(n.id);}
return summary({links,flowStartingPoints:page.flowStartingPoints,propagation,bounds,instances:{total:allInstances.length,attached,missing},screenCount:screens.length,componentCount:page.findAllWithCriteria({types:['COMPONENT']}).length,componentSets:page.findAllWithCriteria({types:['COMPONENT_SET']}).length});
