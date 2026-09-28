// Append after common.js. Build current-app context from local component instances.
async function instanceOf(id,parent,name){const c=await figma.getNodeByIdAsync(id);await fonts(c);const i=track(c.createInstance());parent.appendChild(i);if(name)i.name=name;return i;}
function ownText(i,label,value){const p=Object.keys(i.componentProperties).find(k=>k===label||k.startsWith(label+'#'));if(p)i.setProperties({[p]:value});}
async function componentCopy(id,name){const n=await figma.getNodeByIdAsync(id);await fonts(n);const copy=n.clone();page.appendChild(copy);const c=figma.createComponentFromNode(copy);created.push(c.id,...c.findAll(()=>true).map(n=>n.id));c.name=name;return c;}
function replace(old,i,{w=old.width,h=old.height}={}){const p=old.parent,index=p.children.indexOf(old);const x=old.x,y=old.y;p.insertChild(index,i);i.resize(w,h);if(p.layoutMode==='NONE'){i.x=x;i.y=y;}removed.push(old.id);old.remove();return i;}
const large=await componentCopy('984:103','Default');const lt=large.findAllWithCriteria({types:['TEXT']})[0];lt.textStyleId=styles['Large title'].id;exposeText(large,lt,'Title');await family(0,'Large title','SF Pro Rounded Bold · 34/41. The Home and Tasks context screens share this master.',[large]);
const inline=await componentCopy('984:447','Default');const oldButtons=inline.children.filter(n=>n.type==='INSTANCE');for(let j=0;j<oldButtons.length;j++){const i=await instanceOf(j?'1055:552':'1055:542',inline,j?'More':'Back');replace(oldButtons[j],i);i.isExposedInstance=true;const propName=inline.addComponentProperty(j?'Show more':'Show back','BOOLEAN',true);i.componentPropertyReferences={visible:propName};}const it=inline.findAllWithCriteria({types:['TEXT']}).find(t=>t.characters==='Guitar');it.textStyleId=styles.Headline.id;exposeText(inline,it,'Title');const marker=inline.findOne(n=>n.type==='ELLIPSE');const markerProp=inline.addComponentProperty('Show goal color','BOOLEAN',true);marker.componentPropertyReferences={visible:markerProp};await family(0,'Inline navigation','Native actions + editable SF Pro Rounded title. Back / More / goal color are configurable.',[inline]);
const toolsComp=track(figma.createComponent());toolsComp.name='Default';toolsComp.layoutMode='HORIZONTAL';toolsComp.resize(88,44);toolsComp.primaryAxisSizingMode='FIXED';toolsComp.counterAxisSizingMode='FIXED';toolsComp.fills=[];for(const id of ['1055:566','1055:559']){const i=await instanceOf(id,toolsComp);i.isExposedInstance=true;}await family(0,'Home toolbar','Daily summary and Settings actions. Local composition using native Apple buttons; app behavior unchanged.',[toolsComp]);
const originals=['984:87','984:163','984:436','984:330','984:521','984:591'];
const examples=[];
const targetMaps=[
 {'984:88':'1055:368','984:140':'1055:392','984:107':'1055:404','984:103':large.id,'1016:561':toolsComp.id,'984:153':'1058:671','984:145':'1058:728','984:143':'1058:712','984:151':'1058:712'},
 {'984:164':'1055:368','984:207':'1055:392','984:181':'1055:452','984:177':large.id,'993:600':'1055:559','984:213':'1058:671','984:227':'1058:671','984:210':'1058:712','984:224':'1058:712','984:238':'1058:712'},
 {'984:437':'1055:368','984:474':'1055:392','984:453':'1055:404','984:447':inline.id,'990:366':'1055:608','984:482':'1058:751','984:485':'1058:785'},
 {'984:331':'1055:368','984:346':'1055:392','993:618':'1055:542','984:353':'1058:696','984:359':'1058:696','984:367':'1058:809','984:371':'1058:854','1007:386':'1055:595'},
 {'984:522':'1055:368','984:538':'1055:392','993:648':'1055:542','995:352':'1055:675','995:356':'1055:663','995:360':'1055:675','993:672':'1055:690','1004:470':'1055:715','1004:473':'1055:715','1004:501':'1055:592'},
 {'984:592':'1055:368','984:605':'1055:392','993:676':'1055:862','1019:707':'1055:595','1019:709':'1055:595'}
];
function mapClones(a,b,map){map.set(a.id,b);if('children'in a&&'children'in b)for(let i=0;i<a.children.length;i++)mapClones(a.children[i],b.children[i],map);}
for(let k=0;k<originals.length;k++){
 const src=await figma.getNodeByIdAsync(originals[k]);await fonts(src);const copy=src.clone();cols[k][3].appendChild(copy);copy.name='Context / '+['Home','Tasks','Goal detail','Brain Dump','Settings','Onboarding'][k];created.push(copy.id);copy.resize(402,874);copy.clipsContent=true;
 const nodeMap=new Map();mapClones(src,copy,nodeMap);const local=[];
 for(const[oldId,master]of Object.entries(targetMaps[k])){const old=nodeMap.get(oldId);if(!old)throw Error('Missing cloned source '+oldId);const oldTexts=old.type==='TEXT'?[old.characters]:old.findAllWithCriteria({types:['TEXT']}).map(n=>n.characters);const i=await instanceOf(master,old.parent,old.name);const width=master==='1055:392'?402:old.width;replace(old,i,{w:width,h:old.height});
  const plain=oldTexts.filter(s=>/[A-Za-z]/.test(s));
  if([large.id,'1058:712','1058:671','1058:696','1058:809'].includes(master)&&plain[0])ownText(i,'Title',plain[0]);
  if(master==='1058:671'&&plain.some(s=>s.includes('dentist'))){const nested=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Schedule'in n.componentProperties);if(nested){nested.setProperties({Schedule:'This Week'});mutated.push(nested.id);}}
  if(master==='1058:728'){ownText(i,'Title','Guitar');ownText(i,'Detail','Updated today');}
  if(master==='1055:675'||master==='1055:663'){const field=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Value#519:17'in n.componentProperties);field.setProperties({'Value#519:17':oldId==='995:352'?'https://openrouter.ai/api/v1/chat/…':oldId==='995:356'?'API Key':'openai/gpt-4o-mini'});mutated.push(field.id);}
  if(master==='1055:715'){const r=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Title#519:116'in n.componentProperties);r.setProperties({'Title#519:116':oldId==='1004:470'?'What’s the difference?':'Version','Show Subtitle#525:450':false});const tr=r.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Detail Text#508:54'in n.componentProperties);tr.setProperties({'Detail Text#508:54':oldId==='1004:473'?'1.0':'','Show Symbol#212:5':false,'Show Drill-in#212:3':oldId==='1004:470'});mutated.push(r.id,tr.id);}
  if(master==='1055:595'||master==='1055:592'){const b=i.findAllWithCriteria({types:['INSTANCE']}).find(n=>'Label#488:0'in n.componentProperties);b.setProperties({'Label#488:0':oldId==='1007:386'?'Done':oldId==='1019:707'?'Skip':oldId==='1019:709'?'Next':'Test BYOM'});mutated.push(b.id);}
  local.push({id:i.id,mainId:master,sourceId:oldId});
 }
 // The clone is a component test bed; section/button typography follows the owner's Rounded direction.
 for(const t of copy.findAllWithCriteria({types:['TEXT']})){if(t.parent.type==='INSTANCE')continue;if(t.fontSize>=20&&/[A-Za-z]/.test(t.characters)){const st=t.fontSize>=30?styles['Large title']:styles.Title;t.textStyleId=st.id;mutated.push(t.id);}}
 text(cols[k][3],'Current-app content · linked component test bed\nEdit the local main components to update this example.',402,'Caption','secondary');
 examples.push({id:copy.id,sourceId:src.id,name:copy.name,board:k,linked:local,regions:copy.children.map(n=>({name:n.name,y:n.y,h:n.height}))});
}
return {...summary(),examples};
