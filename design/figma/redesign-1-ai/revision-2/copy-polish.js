// Append common.js. Targeted fixes found in visual and free-worker review.
const changes=new Map([
['Choose a storage option. You can change it later in Settings.','Choose where to store your tasks and goals.'],
['Tasks and goals will appear here as you type.','Recognized tasks and goals appear here after a moment.'],
['YOUR RECORDING','Transcript'],
['Tap an item to edit it. Use its menus to change the schedule or linked goal.','Tap task text to edit. Use menus to change the schedule or linked goal.']]);
for(const f of page.children.filter(n=>n.name.startsWith('Screen / '))){await fonts(f);for(const t of f.findAllWithCriteria({types:['TEXT']})){if(changes.has(t.characters)){t.characters=changes.get(t.characters);mutated.push(t.id);}}}
for(const id of ['1118:6207','1118:6408']){const f=await figma.getNodeByIdAsync(id);const composer=f.findOne(n=>n.type==='FRAME'&&n.name==='Composer');const label=composer.children.find(n=>n.type==='TEXT'&&n.characters==='INPUT');if(label){removed.push(label.id);label.remove();}if(id==='1118:6408'){const actions=composer.children.find(n=>n.name==='Input actions');if(actions){removed.push(actions.id);actions.remove();}}}
const collection=await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:1125:2545');const ids=[];function variable(name,value){const v=figma.variables.createVariable(name,collection,'STRING');v.scopes=['TEXT_CONTENT'];v.setValueForMode(collection.defaultModeId,value);ids.push(v.id);return v;}
const status=variable('processingLabel','Basic processing'),cta=variable('processingAction','Set up AI'),mode=variable('settingsMode','Basic'),connection=variable('settingsConnection','Not configured');
for(const id of ['1118:6207','1097:685','1118:6620']){const f=await figma.getNodeByIdAsync(id);for(const t of f.findAllWithCriteria({types:['TEXT']})){if(t.characters==='Basic processing'){t.setBoundVariable('characters',status);mutated.push(t.id);}if(t.characters==='Set up AI'){t.setBoundVariable('characters',cta);mutated.push(t.id);}}}
const settings=await figma.getNodeByIdAsync('1097:1082');for(const t of settings.findAllWithCriteria({types:['TEXT']})){if(t.characters==='Basic'){t.setBoundVariable('characters',mode);mutated.push(t.id);}if(t.characters==='Not configured'){t.setBoundVariable('characters',connection);mutated.push(t.id);}if(t.characters==='This iPhone'){t.characters='On this iPhone';mutated.push(t.id);}}
function set(v,value){return{type:'SET_VARIABLE',variableId:v.id,variableValue:{type:'STRING',resolvedType:'STRING',value}};}
for(const[id,on]of [['1119:3093',true],['1119:2956',false],['1122:2267',false]]){const n=await figma.getNodeByIdAsync(id);const a=n.reactions[0].actions;await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[set(status,on?'AI model connected':'Basic processing'),set(cta,on?'AI settings':'Set up AI'),set(mode,on?'AI model':'Basic'),set(connection,on?'Connected':'Not configured'),...a]}]);mutated.push(n.id);}
return summary({variableIds:ids});
