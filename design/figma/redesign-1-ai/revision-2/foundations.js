// Targeted update, executed through Figma MCP. Preserve legacy collections.
const page=await figma.getNodeByIdAsync('1095:368');await figma.setCurrentPageAsync(page);
const collections=await figma.variables.getLocalVariableCollectionsAsync();
if(collections.some(c=>c.name==='Defog / Tokens'))throw Error('Tokens already exist; inspect ledger before reuse.');
const prim=await createVariableCollection('Defog / Primitives',['Value']);
const semantic=await createVariableCollection('Defog / Tokens',['Light']);
const palette={Canvas:'#F8F6F2',Surface:'#FFFFFF',Ink:'#292332',Secondary:'#6B6373',Plum:'#7653A6',Lilac:'#EEE7F7',Peach:'#F9E2D5',Sage:'#E5EFE6',Forest:'#326B59'};
const primitives=await createSemanticTokens(prim.collection,prim.modeIds,Object.entries(palette).map(([name,hex])=>({name:'palette/'+name,type:'COLOR',values:{Value:hex},scopes:[],codeSyntax:{iOS:'DefogPalette.'+name.toLowerCase()}})));
const roles={Canvas:'surface/canvas',Surface:'surface/card',Ink:'text/primary',Secondary:'text/secondary',Plum:'accent/task',Lilac:'surface/task',Peach:'surface/guidance',Sage:'surface/goal',Forest:'accent/goal'};
const map=Object.entries(roles).map(([name,role])=>({name:role,type:'COLOR',values:{Light:{type:'VARIABLE_ALIAS',id:primitives.variables['palette/'+name].id}},scopes:role.startsWith('text')?['TEXT_FILL']:['FRAME_FILL','SHAPE_FILL','TEXT_FILL','STROKE_COLOR'],codeSyntax:{iOS:'DefogTokens.'+role.replace('/','_')}}));
for(const n of [4,8,12,16,20,24,32])map.push({name:'space/'+n,type:'FLOAT',values:{Light:n},scopes:['GAP'],codeSyntax:{iOS:'DefogTokens.space'+n}});
for(const n of [12,16,20,24,32])map.push({name:'radius/'+n,type:'FLOAT',values:{Light:n},scopes:['CORNER_RADIUS'],codeSyntax:{iOS:'DefogTokens.radius'+n}});
const tokens=await createSemanticTokens(semantic.collection,semantic.modeIds,map);
const changedStyles=[];for(const style of await figma.getLocalPaintStylesAsync()){const name=style.name.replace('Redesign 1 / ','');if(roles[name]&&style.name.startsWith('Redesign 1 / ')){style.paints=style.paints.map(p=>p.type==='SOLID'?figma.variables.setBoundVariableForPaint(p,'color',tokens.variables[roles[name]]):p);changedStyles.push(style.id);}}
const forest=figma.createPaintStyle();forest.name='Redesign 1 / Forest';forest.paints=[figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:50/255,g:107/255,b:89/255}},'color',tokens.variables['accent/goal'])];
return {createdNodeIds:[],mutatedNodeIds:[],collections:[{id:prim.collection.id,name:prim.collection.name,modes:prim.collection.modes},{id:semantic.collection.id,name:semantic.collection.name,modes:semantic.collection.modes}],variables:[...Object.values(primitives.variables),...Object.values(tokens.variables)].map(v=>({id:v.id,name:v.name,scopes:v.scopes,values:v.valuesByMode,codeSyntax:v.codeSyntax})),changedStyles,createdStyles:[forest.id],textStyles:(await figma.getLocalTextStylesAsync()).filter(s=>s.name.startsWith('Redesign 1 / ')).map(s=>({id:s.id,name:s.name,font:s.fontName,size:s.fontSize}))};
