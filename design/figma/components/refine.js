// Append after common.js. Targeted visual/variant corrections on Components only.
for(const row of cols)for(const col of row.slice(1,3)){col.resize(420,col.height);col.layoutSizingVertical='HUG';mutated.push(col.id);}
for(const[id,selection]of [['1055:608','Timeline'],['1055:632','Calendar']]){
 const c=await figma.getNodeByIdAsync(id);await fonts(c);const control=c.children[0];control.setProperties({'Is Enabled':'True'});mutated.push(control.id);
 for(const opt of control.findAllWithCriteria({types:['INSTANCE']}).filter(n=>'Title#10512:0'in n.componentProperties)){opt.setProperties({'Is Selected':opt.componentProperties['Title#10512:0'].value===selection?'True':'False'});mutated.push(opt.id);}
 rounded(c);
}
for(const id of ['1055:583','1055:586','1055:589','1055:592','1055:595']){
 const c=await figma.getNodeByIdAsync(id);await fonts(c);for(const t of c.findAllWithCriteria({types:['TEXT']}))if(/[A-Za-z]/.test(t.characters)){t.fontName={family:'SF Pro Rounded',style:'Semibold'};mutated.push(t.id);}
}
for(const id of ['1055:404','1055:452','1055:492']){const c=await figma.getNodeByIdAsync(id);await fonts(c);rounded(c);}
// Different variant examples need distinct content defaults after combineAsVariants.
for(const[setId,textId,label,value]of [
 ['1058:654','1058:649','Linked goal','Guitar'],
 ['1058:738','1058:733','List detail','1 entry'],
 ['1058:762','1058:757','Note','Practised chord changes for 10 minutes.'],
 ['1058:868','1058:848','Entered text','Buy groceries today\nCall the dentist this week\nLearn guitar']
]){const s=await figma.getNodeByIdAsync(setId);const t=await figma.getNodeByIdAsync(textId);for(const seg of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(seg.fontName);const key=s.addComponentProperty(label,'TEXT',value);t.componentPropertyReferences={...t.componentPropertyReferences,characters:key};t.characters=value;mutated.push(s.id,t.id);}
const bottom=await figma.getNodeByIdAsync('1060:1266');bottom.paddingBottom=0;mutated.push(bottom.id);
for(const id of ['1060:1327','1060:1336']){const n=await figma.getNodeByIdAsync(id);n.resize(370,98);mutated.push(n.id);}
const dentist=await figma.getNodeByIdAsync('1060:1336');const schedule=dentist.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Schedule'in n.componentProperties);schedule.setProperties({Schedule:'This Week'});mutated.push(schedule.id);
for(const id of ['1060:1247','1060:1261']){const t=await figma.getNodeByIdAsync(id);for(const seg of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(seg.fontName);const start=t.characters.indexOf('  ')+2;t.setRangeFontName(start,t.characters.length,{family:'SF Pro Rounded',style:'Semibold'});mutated.push(t.id);}
for(const id of ['1058:823','1058:846']){const t=await figma.getNodeByIdAsync(id);for(const seg of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(seg.fontName);t.fontName={family:'SF Pro Rounded',style:'Semibold'};mutated.push(t.id);}
// Keep blank workspaces aligned to their component families.
for(const row of cols){for(let j=1;j<row[0].children.length;j++){const group=row.map(c=>c.children[j]).slice(0,3);if(group.some(n=>!n))continue;const h=Math.max(...group.map(n=>n.height));for(const n of group){n.minHeight=h;mutated.push(n.id);}}}
return {...summary(),checks:{segmentedEnabled:true,buttonFont:'SF Pro Rounded Semibold',ownerColumnWidth:420}};
