// Append common.js. Avoid Figma player's missing-font path for variable-bound SF Rounded text.
figma.skipInvisibleInstanceChildren=false;
const state=Object.fromEntries((await figma.variables.getLocalVariablesAsync()).filter(v=>v.variableCollectionId==='VariableCollectionId:1125:2545').map(v=>[v.name,v]));
const set=await figma.getNodeByIdAsync('1161:3119');await fonts(set);for(const c of set.children){const menu=c.children.find(n=>n.type==='INSTANCE');menu.name='Native menu / '+c.name.slice(5);mutated.push(menu.id);}
const changed=[];
for(const f of page.children.filter(n=>n.name.startsWith('Screen /'))){for(const card of f.findAllWithCriteria({types:['INSTANCE']}).filter(n=>n.name.startsWith('Task /'))){await fonts(card);const key=(f.name==='Screen / review'?'review-':'')+card.name.slice(7);for(const [name,suffix,w]of [['Schedule','schedule',98],['Goal link','goal',126]]){const pill=card.findOne(n=>n.type==='INSTANCE'&&n.name===name);const reactions=JSON.parse(JSON.stringify(pill.reactions));pill.resetOverrides();pill.name=name;pill.resize(w,44);pill.setProperties({Kind:{type:'VARIABLE_ALIAS',id:state['task/'+key+'/'+suffix].id}});await pill.setReactionsAsync(reactions);mutated.push(pill.id);changed.push(pill.id);}}}
return summary({changed});
