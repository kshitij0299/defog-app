// Execute through Figma MCP. Historical construction record; inspect before reuse.
const page=await figma.getNodeByIdAsync('1095:368');await figma.setCurrentPageAsync(page);
const created=[],mutated=[],removed=[];
await Promise.all(['Regular','Medium','Semibold','Bold'].flatMap(style=>['SF Pro','SF Pro Rounded'].map(family=>figma.loadFontAsync({family,style}))));
const textStyles=Object.fromEntries((await figma.getLocalTextStylesAsync()).filter(s=>s.name.startsWith('Redesign 1 / ')).map(s=>[s.name.slice(13),s]));
const paintStyles=Object.fromEntries((await figma.getLocalPaintStylesAsync()).filter(s=>s.name.startsWith('Redesign 1 / ')).map(s=>[s.name.slice(13),s]));
const C={Canvas:'#F8F6F2',Surface:'#FFFFFF',Ink:'#292332',Secondary:'#6B6373',Plum:'#7653A6',Lilac:'#EEE7F7',Peach:'#F9E2D5',Sage:'#E5EFE6'};
function rgb(hex){return{r:parseInt(hex.slice(1,3),16)/255,g:parseInt(hex.slice(3,5),16)/255,b:parseInt(hex.slice(5,7),16)/255};}
function paint(name){return{type:'SOLID',color:rgb(C[name])};}
function keep(n){created.push(n.id);return n;}
function fill(n,color){n.fillStyleId=paintStyles[color].id;}
function stack(parent,name,w,gap=12,dir='VERTICAL'){const n=keep(figma.createAutoLayout(dir));parent.appendChild(n);n.name=name;n.fills=[];n.resize(w,1);n.primaryAxisSizingMode=dir==='VERTICAL'?'AUTO':'FIXED';n.counterAxisSizingMode=dir==='VERTICAL'?'FIXED':'AUTO';n.itemSpacing=gap;return n;}
function txt(parent,value,w,style='Body',color='Ink'){const t=keep(figma.createText());parent.appendChild(t);t.name=value.slice(0,48);t.textStyleId=textStyles[style].id;t.characters=value;fill(t,color);t.textAutoResize='HEIGHT';t.resize(w,t.height);return t;}
function symbol(parent,name,size=24,color='Plum'){const t=keep(figma.createText());parent.appendChild(t);t.name='SF Symbol / '+name;t.fontName={family:'SF Pro',style:'Regular'};t.fontSize=size;t.lineHeight={unit:'PIXELS',value:size+4};t.characters=figma.util.getSfSymbolCharacter(name);fill(t,color);t.textAutoResize='WIDTH_AND_HEIGHT';return t;}
async function fonts(n){for(const t of n.findAllWithCriteria({types:['TEXT']}))for(const s of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(s.fontName);}
function tint(n){for(const x of [n,...n.findAll(()=>true)])if('fills'in x&&Array.isArray(x.fills)&&x.fills.some(p=>p.type==='SOLID'&&p.color.b>.8&&p.color.r<.1&&p.color.g>.3&&p.color.g<.65)){x.fills=x.fills.map(p=>p.type==='SOLID'&&p.color.b>.8&&p.color.r<.1?paint('Plum'):p);mutated.push(x.id);}}
function rounded(n,weight='Semibold'){for(const t of n.findAllWithCriteria({types:['TEXT']}))if(/[A-Za-z]/.test(t.characters)){t.fontName={family:'SF Pro Rounded',style:weight};mutated.push(t.id);}}
async function variant(key,name){const s=await figma.importComponentSetByKeyAsync(key);const c=s.children.find(c=>c.name===name);if(!c)throw Error('Missing native variant '+name);await fonts(c);return c;}
function comp(name,w,gap=12,dir='VERTICAL'){const c=keep(figma.createComponent());c.name='AI1 / '+name;c.layoutMode=dir;c.resize(w,1);c.primaryAxisSizingMode=dir==='VERTICAL'?'AUTO':'FIXED';c.counterAxisSizingMode=dir==='VERTICAL'?'FIXED':'AUTO';c.itemSpacing=gap;c.fills=[];c.description='Redesign 1 exploration. Local main; edit to update instances. Not implemented.';return c;}
function prop(c,t,label){const key=c.addComponentProperty(label,'TEXT',t.characters);t.componentPropertyReferences={...t.componentPropertyReferences,characters:key};return key;}
function own(i,label,value){const k=Object.keys(i.componentProperties).find(k=>k===label||k.startsWith(label+'#'));if(k){i.setProperties({[k]:value});mutated.push(i.id);}}
async function inst(id,parent,name){const c=typeof id==='string'?await figma.getNodeByIdAsync(id):id;await fonts(c);const i=keep(c.createInstance());parent.appendChild(i);if(name)i.name=name;return i;}
function nativeText(i,label){const n=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Label#488:0'in n.componentProperties);if(n){n.setProperties({'Label#488:0':label});mutated.push(n.id);}}
function nativeSymbol(i,name){const n=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Label#5429:13'in n.componentProperties);if(n){n.setProperties({'Label#5429:13':figma.util.getSfSymbolCharacter(name)});mutated.push(n.id);}}
async function wrap(c,name,w,h,props={},round=false){const main=comp(name,w);main.resize(w,h);main.primaryAxisSizingMode='FIXED';main.counterAxisSizingMode='FIXED';const i=await inst(c,main,'Apple native control');i.setProperties(props);i.resize(w,h);i.layoutSizingHorizontal='FILL';i.layoutSizingVertical='FILL';i.isExposedInstance=true;if(round)rounded(i);tint(i);return main;}
function summary(extra={}){return{createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed,...extra};}
