// PAUSED historical draft: do not execute or resume until owner agrees on Components and screen work.
// Append after the shared helper prefix in redesign-pilot.js (before const home=shell).
// Existing empty wrappers only. Native iOS27 instances remain attached.
const fieldSet=await figma.importComponentSetByKeyAsync('38117a30dd18e50d4c086b01121258a32567f920');
for(const t of fieldSet.findAllWithCriteria({types:['TEXT']}))for(const s of t.getStyledTextSegments(['fontName']))await figma.loadFontAsync(s.fontName);
function row(parent,title,subtitle='',{detail='',edit=false,checked=false,arrow=true}={}){
  const n=instance(parent,variant('row',subtitle?'Height=Tall':'Height=Regular'),title);
  n.setProperties({'Title#519:116':title,'Subtitle#519:149':subtitle,'Show Subtitle#525:450':!!subtitle,'Show Edit Button#508:289':edit,'Show Trailing#5534:8':!!detail||arrow});
  n.resize(370,subtitle?68:52);n.fills=[paint('surface')];n.cornerRadius=20;
  for(const i of n.findAllWithCriteria({types:['INSTANCE']})){
    if(i.name==='Contents - Trailing'){i.setProperties({'Detail Text#508:54':detail,'Show Symbol#212:5':false,'Show Drill-in#212:3':arrow});mutated.push(i.id);}
    if(i.name==='Edit Button'){i.setProperties({State:checked?'Selected':'Unselected'});mutated.push(i.id);}
  }
  return n;
}
function editor(parent,value,{placeholder=false,height=136}={}){
  const n=instance(parent,fieldSet.children.find(c=>c.name===(placeholder?'State=Placeholder':'State=Value Entered')),'Thoughts · editable text');
  n.setProperties({'Value#519:17':value});n.resize(370,height);n.layoutSizingVertical='FIXED';n.fills=[paint('surface')];n.cornerRadius=20;
  const contents=n.findOne(c=>c.type==='FRAME'&&c.name==='Contents');contents.resize(338,height);contents.layoutSizingVertical='FIXED';contents.paddingTop=16;contents.paddingBottom=16;contents.primaryAxisAlignItems='MIN';mutated.push(contents.id);
  for(const t of n.findAllWithCriteria({types:['TEXT']})){t.textAutoResize='HEIGHT';t.resize(338,t.height);t.layoutSizingVertical='HUG';t.fontSize=17;t.lineHeight={unit:'PIXELS',value:24};mutated.push(t.id);}
  for(const s of n.findAllWithCriteria({types:['INSTANCE']}).filter(i=>i.name==='_Separator')){s.visible=false;mutated.push(s.id);}
  return n;
}
function modal(id,title){
  const f=figma.currentPage.findOne(n=>n.id===id);if(f.children.length)throw Error('Already populated '+id);f.placeholder=false;f.fills=[paint('background')];mutated.push(f.id);
  const s=instance(f,status,'Status bar · 62pt');s.setProperties({'Time#5466:4':'9:41'});s.resize(402,62);
  const nav=toolbar(f,title,false,'xmark',null);
  const body=stack(f,'Content',402,24);body.paddingLeft=16;body.paddingRight=16;body.paddingTop=16;body.paddingBottom=20;body.layoutSizingVertical='FILL';
  const h=instance(f,variant('home','Device=iPhone, Orientation=Portrait'),'Home indicator · 34pt');h.resize(402,34);
  return {frame:f,nav,body};
}
function section(parent,label){const n=stack(parent,label,370,12);textNode(n,label,370,20,'Bold','label',true);return n;}
function footerAction(screen,label){fillSpace(screen.body);return button(screen.body,label,370);}
const empty=modal('1029:709','Brain dump');
const modeEmpty=row(empty.body,'Text processing','Local rules · no model connected',{detail:'',arrow:true});
textNode(empty.body,'What’s on your mind?',370,28,'Bold','label',true);
const emptyEditor=editor(empty.body,'A task, a goal, or a thought…',{placeholder:true,height:160});
const voiceEmpty=button(empty.body,'Use voice',370,true);
const hint=textNode(empty.body,'Try “Buy groceries today” or\n“I want to learn guitar.”',370,17,'Regular','secondary');
const loadExample=footerAction(empty,'Use example thoughts');
const preview=modal('1029:710','Brain dump');
const modePreview=row(preview.body,'Text processing','Local rules · no model connected');
const previewEditor=editor(preview.body,'Buy groceries today.\nCall the dentist this week.\nI want to learn guitar.',{height:128});
const previewHeader=textNode(preview.body,'Preview · not saved',370,20,'Bold','label',true);
const previews=stack(preview.body,'Recognized items',370,8);
row(previews,'Buy groceries today','Task · Today',{arrow:false});
row(previews,'Call dentist','Task · This Week',{arrow:false});
row(previews,'Guitar','Goal',{arrow:false});
const reviewAction=footerAction(preview,'Review 3 items');
const review=modal('1029:711','Review');
textNode(review.body,'Ready when you are.',370,28,'Bold','label',true);
textNode(review.body,'Check the details. Tap an item to edit it.',370,17,'Regular','secondary');
const tasks=section(review.body,'Tasks · 2');
const editGroceries=row(tasks,'Buy groceries today','Task',{detail:'Today'});
const editDentist=row(tasks,'Call dentist','Task',{detail:'This Week'});
const goals=section(review.body,'Goals · 1');const editGuitar=row(goals,'Guitar','A goal to work toward');
const save=footerAction(review,'Save 3 items');
const back=button(review.body,'Back to thoughts',370,true);
const populated=shell(await figma.getNodeByIdAsync('1029:712'),'Home',0,{large:true,leading:null,trailing:'gearshape'});
populated.body.paddingLeft=16;populated.body.paddingRight=16;populated.body.paddingTop=16;populated.body.paddingBottom=16;populated.body.itemSpacing=24;
textNode(populated.body,'A little room to move.',370,17,'Regular','secondary');
const today=section(populated.body,'Today');const homeTask=row(today,'Buy groceries today','Today',{edit:true,arrow:false});
const activeGoals=section(populated.body,'Your goals');const homeGoal=row(activeGoals,'Guitar','No entries yet');
const daily=row(populated.body,'Daily summary','See what you’ve done today');
const newCaptureHome=footerAction(populated,'New brain dump');
const taskList=shell(await figma.getNodeByIdAsync('1029:713'),'Tasks',1,{large:true,leading:null,trailing:'gearshape'});
taskList.body.paddingLeft=16;taskList.body.paddingRight=16;taskList.body.paddingTop=16;taskList.body.paddingBottom=16;taskList.body.itemSpacing=24;
const todayTasks=section(taskList.body,'Today');const groceries=row(todayTasks,'Buy groceries today','No linked goal',{edit:true});
const weekTasks=section(taskList.body,'This Week');const dentist=row(weekTasks,'Call dentist','No linked goal',{edit:true});
const someday=section(taskList.body,'Someday');textNode(someday,'Nothing here yet.',370,17,'Regular','secondary');
const completed=row(taskList.body,'Completed','',{detail:'0'});
const newCaptureTasks=footerAction(taskList,'New brain dump');
const goalList=shell(await figma.getNodeByIdAsync('1029:714'),'Goals',2,{large:true,leading:null,trailing:'gearshape'});
goalList.body.paddingLeft=16;goalList.body.paddingRight=16;goalList.body.paddingTop=16;goalList.body.paddingBottom=16;goalList.body.itemSpacing=24;
textNode(goalList.body,'Make room for what matters to you.',370,17,'Regular','secondary');
const guitar=row(goalList.body,'Guitar','No entries yet');
const newCaptureGoals=footerAction(goalList,'New brain dump');
return {createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed,frames:[empty,preview,review,populated,taskList,goalList].map(x=>({id:x.frame.id,name:x.frame.name,regions:x.frame.children.map(n=>({id:n.id,name:n.name,y:n.y,h:n.height})),bodyChildren:x.body.children.map(n=>({id:n.id,name:n.name,y:n.y,h:n.height}))})),actions:{modeEmpty:modeEmpty.id,modePreview:modePreview.id,voiceEmpty:voiceEmpty.id,loadExample:loadExample.id,review:reviewAction.id,save:save.id,back:back.id,editGroceries:editGroceries.id,editDentist:editDentist.id,editGuitar:editGuitar.id,homeTask:homeTask.id,homeGoal:homeGoal.id,daily:daily.id,groceries:groceries.id,dentist:dentist.id,completed:completed.id,guitar:guitar.id,newCaptureHome:newCaptureHome.id,newCaptureTasks:newCaptureTasks.id,newCaptureGoals:newCaptureGoals.id}};
