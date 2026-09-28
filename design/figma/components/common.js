// Component review workspace. Run through Figma MCP after loading figma-use/library skills.
// Shared helpers adapt the skill's documentation and variant-grid patterns.
const page=await figma.getNodeByIdAsync('1053:375');
await figma.setCurrentPageAsync(page);
const created=[],mutated=[],removed=[],families=[];
const boardColumns=[['1053:406','1053:408','1053:410','1053:412'],['1053:417','1053:419','1053:421','1053:423'],['1053:428','1053:430','1053:432','1053:434'],['1053:439','1053:441','1053:443','1053:445'],['1053:450','1053:452','1053:454','1053:456'],['1053:461','1053:463','1053:465','1053:467']];
const cols=await Promise.all(boardColumns.map(r=>Promise.all(r.map(id=>figma.getNodeByIdAsync(id)))));
const styles=Object.fromEntries((await figma.getLocalTextStylesAsync()).filter(s=>s.name.startsWith('Defog / ')).map(s=>[s.name.slice(8),s]));
await Promise.all(['Regular','Medium','Semibold','Bold'].flatMap(style=>['SF Pro','SF Pro Rounded'].map(family=>figma.loadFontAsync({family,style}))));
await figma.loadFontAsync({family:'SF Pro',style:'Regular Italic'});
const colorKeys={bg:'a90ed703166e4696edc327f717296a29491d2124',surface:'8b0a221303d2f2bb0871eddd4274517a90e17762',label:'f53b56d4ed0520da1fb2c8586d67d82113ae1dcb',secondary:'4cd5aad6cbe2b035a0865fe9661e1e5458ab8f8c',blue:'a2a887a78db2624665e93ec4f131d7c56da46f24',red:'f4e6238e4191c097d036ef626da680586e7dbb17',fill:'d21cbd1dac580370515b7174549db004cdbd8ccc'};
const colors=Object.fromEntries(await Promise.all(Object.entries(colorKeys).map(async([k,v])=>[k,await figma.variables.importVariableByKeyAsync(v)])));
function paint(key){return figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color',colors[key]);}
function track(n){created.push(n.id);return n;}
function stack(parent,name,w,gap=12){const n=track(figma.createAutoLayout('VERTICAL'));parent.appendChild(n);n.name=name;n.fills=[];n.resize(w,1);n.layoutSizingVertical='HUG';n.itemSpacing=gap;return n;}
function text(parent,words,width,style='Callout',color='label'){const n=track(figma.createText());parent.appendChild(n);n.textStyleId=styles[style].id;n.characters=words;n.name=words.slice(0,60);n.fills=[paint(color)];n.textAutoResize='HEIGHT';n.resize(width,n.height);n.layoutSizingVertical='HUG';return n;}
async function fonts(n){for(const t of n.findAllWithCriteria({types:['TEXT']}))for(const s of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(s.fontName);}
function rounded(n){for(const t of n.findAllWithCriteria({types:['TEXT']})){if(/[A-Za-z]/.test(t.characters)){const f=t.fontName;if(typeof f==='object'){const style=['Regular','Medium','Semibold','Bold'].includes(f.style)?f.style:'Regular';t.fontName={family:'SF Pro Rounded',style};mutated.push(t.id);}}}}
function exposeText(c,t,label){const p=c.addComponentProperty(label,'TEXT',t.characters);t.componentPropertyReferences={...t.componentPropertyReferences,characters:p};return p;}
async function native(setKey,name){const s=await figma.importComponentSetByKeyAsync(setKey);await fonts(s);const c=s.children.find(c=>c.name===name);if(!c)throw Error('Native variant missing: '+name);return c;}
function wrapper(nativeComponent,name,width,height,properties={},round=true){const c=track(figma.createComponent());c.name=name;c.layoutMode='VERTICAL';c.fills=[];c.resize(width,height);c.primaryAxisSizingMode='FIXED';c.counterAxisSizingMode='FIXED';const i=track(nativeComponent.createInstance());c.appendChild(i);i.name='Apple native control';i.setProperties(properties);i.resize(width,height);i.layoutSizingHorizontal='FILL';i.layoutSizingVertical='FILL';i.isExposedInstance=true;if(round)rounded(i);return c;}
async function family(board,title,note,components){
  if(cols[board][0].children.some(n=>n.name===title))throw Error('Family already exists: '+title);
  const root=stack(cols[board][0],title,470,12);text(root,title,454,'Headline');text(root,note,454,'Caption','secondary');
  let main;
  if(components.length>1){main=track(figma.combineAsVariants(components,root));main.name='Defog / '+title;main.fills=[];let y=8;for(const c of components){c.x=8;c.y=y;y+=c.height+16;}main.resize(Math.max(...components.map(c=>c.width))+16,y);}
  else {main=components[0];root.appendChild(main);main.name='Defog / '+title;}
  main.description=note+' Component-review candidate. Edit this local main; context screens use its instances. Apple controls remain attached.';
  const height=Math.max(root.height,130);root.minHeight=height;
  const workspaces=[];
  for(let k=1;k<=2;k++){const area=stack(cols[board][k],title+' / Your version '+(k===1?'A':'B'),420,12);text(area,title,404,'Headline');const blank=track(figma.createFrame());area.appendChild(blank);blank.name='Your version '+(k===1?'A':'B')+' — '+title;blank.resize(420,Math.max(80,height-34));blank.fills=[paint('bg')];blank.strokes=[{type:'SOLID',color:{r:.78,g:.8,b:.84}}];blank.strokeWeight=1;blank.dashPattern=[6,6];blank.clipsContent=false;workspaces.push(blank.id);area.minHeight=height;}
  const info={title,board,mainId:main.id,type:main.type,variants:components.map(c=>({id:c.id,name:c.name,w:c.width,h:c.height})),workspaces};families.push(info);return info;
}
function summary(){return{createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed,families};}
