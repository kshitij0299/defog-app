// Run once after page.clone() created 1226:4050 and staging clone 1228:4341.
// Copy all roots, rebuild local masters, and isolate prototype state/reactions.
const page=await figma.getNodeByIdAsync('1226:4050');await figma.setCurrentPageAsync(page);figma.skipInvisibleInstanceChildren=false;
const source=await figma.getNodeByIdAsync('1095:368');const staging=await figma.getNodeByIdAsync('1228:4341');await source.loadAsync();await staging.loadAsync();
const sourceRoots=[...source.children],snapshot=[...page.children],working=[...staging.children];if(snapshot.length!==82||working.length!==82)throw Error('Unexpected root count; inspect before retry');
const fontMap=new Map();for(const t of source.findAllWithCriteria({types:['TEXT']}))for(const s of t.getStyledTextSegments(['fontName']))fontMap.set(JSON.stringify(s.fontName),s.fontName);await Promise.all([...fontMap.values()].map(f=>figma.loadFontAsync(f)));
const created=[],mutated=[],removed=[];for(const n of working){page.appendChild(n);n.x+=8000;mutated.push(n.id);}removed.push(staging.id);staging.remove();
const originalProto=await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:1125:2545');const allVars=await figma.variables.getLocalVariablesAsync();const originalVars=allVars.filter(v=>v.variableCollectionId===originalProto.id);
async function isolate(roots,label){
 const map={};const objectMap=new Map();const mismatches=[];
 function pair(a,b){map[a.id]=b.id;objectMap.set(a.id,b);if('children'in a&&'children'in b){if(a.children.length!==b.children.length){mismatches.push({a:a.id,b:b.id,ac:a.children.length,bc:b.children.length});return;}for(let i=0;i<a.children.length;i++)pair(a.children[i],b.children[i]);}}
 sourceRoots.forEach((a,i)=>pair(a,roots[i]));
 for(const s of source.findAllWithCriteria({types:['COMPONENT']})){let copy=objectMap.get(s.id);if(!copy)throw Error('Missing component '+s.id);if(copy.type!=='COMPONENT'){const parent=copy.parent,index=parent.children.indexOf(copy),x=copy.x,y=copy.y;const actual=s.clone();parent.insertChild(index,actual);actual.x=x;actual.y=y;removed.push(copy.id);copy.remove();created.push(actual.id);objectMap.set(s.id,actual);}}
 Object.keys(map).forEach(k=>delete map[k]);objectMap.clear();sourceRoots.forEach((a,i)=>pair(a,roots[i]));
 const componentMap=Object.fromEntries(source.findAllWithCriteria({types:['COMPONENT']}).map(s=>[s.id,objectMap.get(s.id)]));
 async function relink(a,b){if(a.type==='INSTANCE'&&b.type==='INSTANCE'){const old=await a.getMainComponentAsync();if(old&&componentMap[old.id]){b.swapComponent(componentMap[old.id]);mutated.push(b.id);}}if('children'in a&&'children'in b&&a.children.length===b.children.length){for(let i=0;i<a.children.length;i++)await relink(a.children[i],b.children[i]);}}
 for(let i=0;i<sourceRoots.length;i++)await relink(sourceRoots[i],roots[i]);
 Object.keys(map).forEach(k=>delete map[k]);objectMap.clear();sourceRoots.forEach((a,i)=>pair(a,roots[i]));
 const col=figma.variables.createVariableCollection('Redesign Two / '+label+' prototype');const vm={};for(const v of originalVars){const n=figma.variables.createVariable(v.name,col,v.resolvedType);n.scopes=v.scopes;n.description=v.description;n.hiddenFromPublishing=true;vm[v.id]=n;}
 function remap(value){if(typeof value==='string')return map[value]||vm[value]?.id||value;if(Array.isArray(value))return value.map(remap);if(value&&typeof value==='object')return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,remap(v)]));return value;}
 for(const v of originalVars)vm[v.id].setValueForMode(col.defaultModeId,remap(v.valuesByMode[originalProto.defaultModeId]));
 let reactions=0,bindings=0;const skippedSelfLinks=[];
 for(const [oldId,n]of objectMap){const old=await figma.getNodeByIdAsync(oldId);if('reactions'in old&&old.reactions.length){let top=n;while(top.parent&&top.parent.type!=='PAGE')top=top.parent;const next=old.reactions.map(r=>({trigger:remap(r.trigger),actions:remap(r.actions||[r.action]).filter(a=>{if(a?.type==='NODE'&&a.navigation==='NAVIGATE'&&a.destinationId===top.id){skippedSelfLinks.push({source:oldId,copy:n.id,destination:top.id});return false;}return true;})})).filter(r=>r.actions.length);try{await n.setReactionsAsync(next);}catch(e){throw Error('Reaction copy '+oldId+' -> '+n.id+' top '+top.id+': '+e.message);}mutated.push(n.id);reactions++;}
  if('boundVariables'in old){for(const [field,alias]of Object.entries(old.boundVariables||{})){if(alias?.type==='VARIABLE_ALIAS'&&vm[alias.id]&&'setBoundVariable'in n){n.setBoundVariable(field,vm[alias.id]);mutated.push(n.id);bindings++;}}}
  if(old.type==='INSTANCE'&&n.type==='INSTANCE'){for(const [key,p]of Object.entries(old.componentProperties)){const alias=p.boundVariables?.value;if(alias&&vm[alias.id]&&key in n.componentProperties){n.setProperties({[key]:{type:'VARIABLE_ALIAS',id:vm[alias.id].id}});mutated.push(n.id);bindings++;}}}
 }
 return {rootMap:Object.fromEntries(sourceRoots.map((s,i)=>[s.id,roots[i].id])),masters:Object.fromEntries(Object.entries(componentMap).map(([k,n])=>[k,n.id])),prototypeCollection:col.id,variables:Object.fromEntries(Object.entries(vm).map(([k,v])=>[k,v.id])),nodeMap:map,reactions,bindings,mismatches,skippedSelfLinks};
}
const left=await isolate(snapshot,'Preserved');const right=await isolate(working,'Working');
page.flowStartingPoints=[...source.flowStartingPoints.map(f=>({...f,nodeId:left.rootMap[f.nodeId],name:'Preserved · '+f.name})),...source.flowStartingPoints.map(f=>({...f,nodeId:right.rootMap[f.nodeId],name:'Working · '+f.name}))];
const state={page:page.id,source:source.id,offset:8000,snapshot:left,working:right,createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed};
figma.io.write('redesign-two-copy-ledger.json',JSON.stringify(state));
return {page:page.id,rootCounts:[snapshot.length,working.length],snapshot:{roots:left.rootMap,masters:left.masters,collection:left.prototypeCollection,reactions:left.reactions,bindings:left.bindings,mismatches:left.mismatches},working:{roots:right.rootMap,masters:right.masters,collection:right.prototypeCollection,reactions:right.reactions,bindings:right.bindings,mismatches:right.mismatches},createdNodeIds:created,removedNodeIds:removed,mutatedCount:mutated.length,fullLedger:'redesign-two-copy-ledger.json'};
