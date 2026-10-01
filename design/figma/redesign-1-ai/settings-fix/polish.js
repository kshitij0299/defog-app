// Prepend ../common.js. Historical targeted mutation.
// Each block ending in return is a separate use_figma call with common.js.

figma.skipInvisibleInstanceChildren=false;
const old=await figma.getNodeByIdAsync('1119:3051');removed.push(old.id);old.remove();
const connected=await figma.getNodeByIdAsync('1119:3072');await fonts(connected);fill(connected,'Surface');connected.cornerRadius=16;
const nr=connected.children[0];const tr=nr.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Detail Text#508:54'in n.componentProperties);tr.setProperties({'Detail Text#508:54':'openai/gpt-4o-mini','Show Drill-in#212:3':false});
for(const t of connected.findAllWithCriteria({types:['TEXT']})){if(t.characters==='Model'){t.textStyleId=textStyles.Body.id;mutated.push(t.id);}}
for(const s of connected.findAll(n=>/separator/i.test(n.name))){s.visible=false;mutated.push(s.id);}
mutated.push(connected.id,tr.id);
const edit=await figma.getNodeByIdAsync('1202:3371');await fonts(edit);tint(edit);
const foot=await figma.getNodeByIdAsync('1202:3294');const local=await figma.variables.getVariableByIdAsync('VariableID:1206:3171');foot.setBoundVariable('visible',local);mutated.push(foot.id);
// Scope artifact inventory: validate only touched layouts and their exact links.
const out={};for(const id of ['1097:1082','1119:2899','1119:3013','1202:3408']){
 const n=await figma.getNodeByIdAsync(id);out[id]={bounds:{w:n.width,h:n.height},fonts:[...new Set(n.findAllWithCriteria({types:['TEXT']}).flatMap(t=>t.getStyledTextSegments(['fontName']).map(s=>s.fontName.family)))],links:n.findAll(x=>'reactions'in x&&x.reactions.length).map(x=>({id:x.id,name:x.name})),rasterCount:n.findAll(x=>x.visible&&Array.isArray(x.fills)&&x.fills.some(p=>p.type==='IMAGE')&&x.parent.visible).length};}
return summary({validation:out});
figma.skipInvisibleInstanceChildren=false;
for(const id of ['1097:1082','1119:3013','1202:3053','1202:3113']){
 const scope=await figma.getNodeByIdAsync(id);await fonts(scope);
 for(const row of scope.findAllWithCriteria({types:['INSTANCE']}).filter(n=>'Title#519:116'in n.componentProperties)){
  row.primaryAxisAlignItems='MIN';row.counterAxisAlignItems='CENTER';
  const content=row.children.find(n=>n.name==='Contents');
  if(content){content.layoutSizingHorizontal='FILL';mutated.push(content.id);const line=content.children.find(n=>n.name==='Title and Trailing Accessories');if(line){line.layoutSizingHorizontal='FILL';const title=line.children.find(n=>n.type==='TEXT'&&n.name==='Title');if(title){title.layoutSizingHorizontal='FILL';title.textAlignHorizontal='LEFT';mutated.push(title.id);}mutated.push(line.id);}}
  mutated.push(row.id);
 }
}
return summary();
