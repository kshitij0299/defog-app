// Append common.js. The player preserves text overrides when a variant changes, so bind the native label as well.
figma.skipInvisibleInstanceChildren=false;
const state=Object.fromEntries((await figma.variables.getLocalVariablesAsync()).filter(v=>v.variableCollectionId==='VariableCollectionId:1125:2545').map(v=>[v.name,v]));
const cards=[];
for(const f of page.children.filter(n=>n.name.startsWith('Screen /'))){for(const card of f.findAllWithCriteria({types:['INSTANCE']}).filter(n=>n.name.startsWith('Task /'))){await fonts(card);const key=(f.name==='Screen / review'?'review-':'')+card.name.slice(7);for(const [name,suffix]of [['Schedule','schedule'],['Goal link','goal']]){const pill=card.findOne(n=>n.type==='INSTANCE'&&n.name===name);const native=pill.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Label#488:193'in n.componentProperties);const v=state['task/'+key+'/'+suffix];if(native&&v){native.setProperties({'Label#488:193':{type:'VARIABLE_ALIAS',id:v.id}});mutated.push(native.id);}}cards.push(card.id);}}
for(const id of ['1097:685','1119:3096','1118:6620']){const body=(await figma.getNodeByIdAsync(id)).children.find(n=>n.name==='Scrollable content');body.itemSpacing=12;mutated.push(body.id);}
return summary({cards});
