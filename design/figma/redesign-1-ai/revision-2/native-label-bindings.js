// Append common.js. Audit inactive instances explicitly; each schedule slot has its own native label.
figma.skipInvisibleInstanceChildren=false;
const vars=Object.fromEntries((await figma.variables.getLocalVariablesAsync()).filter(n=>n.variableCollectionId==='VariableCollectionId:1125:2545').map(n=>[n.name,n]));
const f=await figma.getNodeByIdAsync('1097:823');await fonts(f);
for(const i of f.findAllWithCriteria({types:['INSTANCE']}).filter(n=>n.name.startsWith('Task / '))){const key=i.name.slice(7);const group=i.parent.parent.name;for(const[name,suffix]of [['Schedule','schedule'],['Goal link','goal']]){const wrap=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>n.name===name);const n=wrap.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Label#488:193'in n.componentProperties);const t=n.findAllWithCriteria({types:['TEXT']}).find(t=>t.name==='Label');t.setBoundVariable('characters',null);n.setProperties({'Label#488:193':suffix==='schedule'?group:{type:'VARIABLE_ALIAS',id:vars['task/'+key+'/'+suffix].id}});mutated.push(n.id,t.id);}}
return summary();
