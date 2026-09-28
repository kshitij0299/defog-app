// Drafted by Muse Spark; reviewed and corrected by coordinator. Native editable nodes.
const SK={status:"51ddb19de206b67eae2d554b1d20c018feb754f4",tabSet:"1a05576da751e45de479836ff1f59971cedc2606",bg:"fc58d0b92f4465e62a155957411893a6c6ca3cc5",label:"be4259bb75a4279fc39e5100262719271f57a243"};
const PAGE_ID="967:1893",ROOT_NAME="Baseline / Home / Empty";
const page=await figma.getNodeByIdAsync(PAGE_ID);
if(!page || page.type!=="PAGE") throw new Error("Baseline page missing");
await figma.setCurrentPageAsync(page);
const existing=page.children.find(n=>n.name===ROOT_NAME);
if(existing) return {reused:true,rootId:existing.id,bounds:existing.absoluteBoundingBox};
const allFonts=await figma.listAvailableFontsAsync();
const hasF=(fam,sty)=>allFonts.some(f=>f.fontName.family===fam&&f.fontName.style===sty);
const fontValidation={roundedBold34:hasF("SF Pro Rounded","Bold"),roundedBold22:hasF("SF Pro Rounded","Bold"),regular15:hasF("SF Pro","Regular"),symbolRegular:hasF("SF Pro","Regular")};
const need=[{family:"SF Pro",style:"Regular"},{family:"SF Pro",style:"Medium"},{family:"SF Pro",style:"Semibold"},{family:"SF Pro",style:"Bold"},{family:"SF Pro Rounded",style:"Regular"},{family:"SF Pro Rounded",style:"Medium"},{family:"SF Pro Rounded",style:"Semibold"},{family:"SF Pro Rounded",style:"Bold"}];
await Promise.all(need.filter(fn=>hasF(fn.family,fn.style)).map(fn=>figma.loadFontAsync(fn)));
const [statusComp,tabSet,bgVar,labelVar,secVar]=await Promise.all([
figma.importComponentByKeyAsync(SK.status),figma.importComponentSetByKeyAsync(SK.tabSet),
figma.variables.importVariableByKeyAsync(SK.bg),figma.variables.importVariableByKeyAsync(SK.label),
figma.variables.importVariableByKeyAsync("ee3cc41d082224cc947f918704ead1f41ef41e80")]);
const statusInst=statusComp.createInstance();
const wantVar="Separate Search=True, Minimized=False, Tabs=4";
const tabVar=tabSet.findOne(n=>n.name===wantVar);
if(!tabVar)throw new Error("tab variant not found: "+wantVar);
const tabInst=tabVar.createInstance();
const disc=new Map();
for(const t of [...statusInst.findAll(n=>n.type==="TEXT"),...tabInst.findAll(n=>n.type==="TEXT")]){if(!("characters" in t))continue;const segs=t.getStyledTextSegments(["fontName"]);for(const s of segs){const k=s.fontName.family+"|"+s.fontName.style;if(!disc.has(k))disc.set(k,s.fontName);}}
await Promise.all([...disc.values()].map(fn=>figma.loadFontAsync(fn)));
const numTabs=tabInst.findAll(n=>n.type==="INSTANCE"&&/^Tab [0-9]+$/.test(n.name)).sort((a,b)=>parseInt(a.name.split(" ")[1])-parseInt(b.name.split(" ")[1]));
if(numTabs.length!==3)throw new Error("expected 3 numeric tabs, got "+numTabs.length);
for(const tb of numTabs){if(tb.type!=="INSTANCE")throw new Error("tab not instance: "+tb.name);const cp=tb.componentProperties;if(!cp||!("Label#5735:10" in cp)||!("Symbol#5735:9" in cp)||!("Selected" in cp)||!("Mode" in cp))throw new Error("tab props missing on "+tb.name);}
const searchTab=tabInst.findOne(n=>n.type==="INSTANCE"&&/Search/i.test(n.name));
if(!searchTab)throw new Error("Search Tab missing");
if(searchTab.type!=="INSTANCE")throw new Error("search not instance");
const scp=searchTab.componentProperties;
if(!scp||!("Symbol#5735:8" in scp))throw new Error("Search Symbol prop missing");
const stCP=statusInst.componentProperties;
if(!stCP||!("Time#5466:4" in stCP))throw new Error("Status Time prop missing");
const cHome=figma.util.getSfSymbolCharacter("house.fill"),cTasks=figma.util.getSfSymbolCharacter("checkmark.square.fill"),cGoals=figma.util.getSfSymbolCharacter("target"),cPlus=figma.util.getSfSymbolCharacter("plus"),cSun=figma.util.getSfSymbolCharacter("sun.max"),cGear=figma.util.getSfSymbolCharacter("gearshape");
statusInst.setProperties({"Time#5466:4":"9:41"});
numTabs[0].setProperties({"Label#5735:10":"Home","Symbol#5735:9":cHome,"Selected":"True","Mode":"Light"});
numTabs[1].setProperties({"Label#5735:10":"Tasks","Symbol#5735:9":cTasks,"Selected":"False","Mode":"Light"});
numTabs[2].setProperties({"Label#5735:10":"Goals","Symbol#5735:9":cGoals,"Selected":"False","Mode":"Light"});
searchTab.setProperties({"Symbol#5735:8":cPlus});
const coll=await figma.variables.getVariableCollectionByIdAsync(bgVar.variableCollectionId);
const lightModeId=coll.modes.find(m=>m.name.toLowerCase()==="light")?.modeId;
const secNote="Apple Labels/Secondary";
const created=[],texts=[];
const paint=(r,g,b,o=1)=>({type:"SOLID",color:{r,g,b},opacity:o});
const root=figma.createAutoLayout("VERTICAL");root.name=ROOT_NAME;created.push(root.id);
root.resize(402,874);root.layoutMode="VERTICAL";root.primaryAxisSizingMode="FIXED";root.counterAxisSizingMode="FIXED";root.primaryAxisAlignItems="MIN";root.counterAxisAlignItems="MIN";root.itemSpacing=0;root.paddingLeft=0;root.paddingRight=0;root.paddingTop=0;root.paddingBottom=0;root.clipsContent=true;root.cornerRadius=0;root.x=160;root.y=160;root.layoutSizingHorizontal="FIXED";root.layoutSizingVertical="FIXED";
root.fills=[figma.variables.setBoundVariableForPaint(paint(242/255,242/255,247/255),"color",bgVar)];
page.appendChild(root);
if(lightModeId){try{root.setExplicitVariableModeForCollection(bgVar.variableCollectionId,lightModeId);}catch(e){}}
root.appendChild(statusInst);statusInst.layoutSizingHorizontal="FILL";statusInst.layoutSizingVertical="FIXED";
const bar=figma.createAutoLayout("VERTICAL");bar.name="Toolbar";bar.resize(402,44);bar.layoutMode="HORIZONTAL";bar.primaryAxisSizingMode="FIXED";bar.counterAxisSizingMode="FIXED";bar.primaryAxisAlignItems="MAX";bar.counterAxisAlignItems="CENTER";bar.itemSpacing=0;bar.paddingLeft=0;bar.paddingRight=16;bar.paddingTop=0;bar.paddingBottom=0;bar.fills=[];root.appendChild(bar);bar.layoutSizingHorizontal="FILL";bar.layoutSizingVertical="FIXED";created.push(bar.id);
const cap=figma.createAutoLayout("VERTICAL");cap.name="ToolbarCapsule";cap.resize(120,44);cap.layoutMode="HORIZONTAL";cap.primaryAxisSizingMode="AUTO";cap.counterAxisSizingMode="FIXED";cap.primaryAxisAlignItems="CENTER";cap.counterAxisAlignItems="CENTER";cap.itemSpacing=16;cap.paddingLeft=12;cap.paddingRight=12;cap.paddingTop=10;cap.paddingBottom=10;cap.cornerRadius=22;cap.fills=[paint(1,1,1)];bar.appendChild(cap);cap.layoutSizingHorizontal="HUG";cap.layoutSizingVertical="FIXED";created.push(cap.id);
const sunT=figma.createText();sunT.name="Sun";sunT.fontName={family:"SF Pro",style:"Regular"};sunT.fontSize=20;sunT.lineHeight={unit:"PIXELS",value:24};sunT.characters=cSun;sunT.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",labelVar)];cap.appendChild(sunT);sunT.layoutSizingHorizontal="HUG";sunT.layoutSizingVertical="HUG";created.push(sunT.id);texts.push(sunT.id);
const gearT=figma.createText();gearT.name="Settings";gearT.fontName={family:"SF Pro",style:"Regular"};gearT.fontSize=20;gearT.lineHeight={unit:"PIXELS",value:24};gearT.characters=cGear;gearT.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",labelVar)];cap.appendChild(gearT);gearT.layoutSizingHorizontal="HUG";gearT.layoutSizingVertical="HUG";created.push(gearT.id);texts.push(gearT.id);
const titleWrap=figma.createAutoLayout("VERTICAL");titleWrap.name="TitleWrap";titleWrap.layoutMode="VERTICAL";titleWrap.primaryAxisSizingMode="AUTO";titleWrap.counterAxisSizingMode="AUTO";titleWrap.primaryAxisAlignItems="MIN";titleWrap.counterAxisAlignItems="MIN";titleWrap.itemSpacing=0;titleWrap.paddingLeft=16;titleWrap.paddingRight=0;titleWrap.paddingTop=14;titleWrap.paddingBottom=8;titleWrap.fills=[];root.appendChild(titleWrap);titleWrap.layoutSizingHorizontal="FILL";titleWrap.layoutSizingVertical="HUG";created.push(titleWrap.id);
const homeT=figma.createText();homeT.name="Home";homeT.fontName={family:"SF Pro Rounded",style:"Bold"};homeT.fontSize=34;homeT.lineHeight={unit:"PIXELS",value:41};homeT.characters="Home";homeT.textAutoResize="HEIGHT";homeT.resize(386,41);homeT.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",labelVar)];titleWrap.appendChild(homeT);homeT.layoutSizingHorizontal="FILL";homeT.layoutSizingVertical="HUG";created.push(homeT.id);texts.push(homeT.id);
const scroll=figma.createAutoLayout("VERTICAL");scroll.name="ScrollContent";scroll.layoutMode="VERTICAL";scroll.primaryAxisSizingMode="AUTO";scroll.counterAxisSizingMode="AUTO";scroll.primaryAxisAlignItems="MIN";scroll.counterAxisAlignItems="MIN";scroll.itemSpacing=20;scroll.paddingLeft=0;scroll.paddingRight=0;scroll.paddingTop=0;scroll.paddingBottom=0;scroll.fills=[];root.appendChild(scroll);scroll.layoutSizingHorizontal="FILL";scroll.layoutSizingVertical="HUG";created.push(scroll.id);
const s1=figma.createAutoLayout("VERTICAL");s1.name="ActiveGoals";s1.layoutMode="VERTICAL";s1.primaryAxisSizingMode="AUTO";s1.counterAxisSizingMode="AUTO";s1.primaryAxisAlignItems="MIN";s1.counterAxisAlignItems="MIN";s1.itemSpacing=12;s1.paddingLeft=16;s1.paddingRight=16;s1.paddingTop=16;s1.paddingBottom=0;s1.fills=[];scroll.appendChild(s1);s1.layoutSizingHorizontal="FILL";s1.layoutSizingVertical="HUG";created.push(s1.id);
const s1T=figma.createText();s1T.name="Active Goals";s1T.fontName={family:"SF Pro Rounded",style:"Bold"};s1T.fontSize=22;s1T.lineHeight={unit:"PIXELS",value:28};s1T.characters="Active Goals";s1T.textAutoResize="HEIGHT";s1T.resize(370,28);s1T.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",labelVar)];s1.appendChild(s1T);s1T.layoutSizingHorizontal="FILL";s1T.layoutSizingVertical="HUG";created.push(s1T.id);texts.push(s1T.id);
const s1B=figma.createText();s1B.name="Body";s1B.fontName={family:"SF Pro",style:"Regular"};s1B.fontSize=15;s1B.lineHeight={unit:"PIXELS",value:20};s1B.characters="No active goals. Add some via brain dump.";s1B.textAutoResize="HEIGHT";s1B.resize(370,20);if(secVar){s1B.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",secVar)];}else{s1B.fills=[paint(60/255,60/255,67/255,0.6)];}s1.appendChild(s1B);s1B.layoutSizingHorizontal="FILL";s1B.layoutSizingVertical="HUG";created.push(s1B.id);texts.push(s1B.id);
const s2=figma.createAutoLayout("VERTICAL");s2.name="TodaysTasks";s2.layoutMode="VERTICAL";s2.primaryAxisSizingMode="AUTO";s2.counterAxisSizingMode="AUTO";s2.primaryAxisAlignItems="MIN";s2.counterAxisAlignItems="MIN";s2.itemSpacing=12;s2.paddingLeft=16;s2.paddingRight=16;s2.paddingTop=16;s2.paddingBottom=0;s2.fills=[];scroll.appendChild(s2);s2.layoutSizingHorizontal="FILL";s2.layoutSizingVertical="HUG";created.push(s2.id);
const s2T=figma.createText();s2T.name="Today's Tasks";s2T.fontName={family:"SF Pro Rounded",style:"Bold"};s2T.fontSize=22;s2T.lineHeight={unit:"PIXELS",value:28};s2T.characters="Today's Tasks";s2T.textAutoResize="HEIGHT";s2T.resize(370,28);s2T.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",labelVar)];s2.appendChild(s2T);s2T.layoutSizingHorizontal="FILL";s2T.layoutSizingVertical="HUG";created.push(s2T.id);texts.push(s2T.id);
const s2B=figma.createText();s2B.name="Body";s2B.fontName={family:"SF Pro",style:"Regular"};s2B.fontSize=15;s2B.lineHeight={unit:"PIXELS",value:20};s2B.characters="Nothing for today. Add something?";s2B.textAutoResize="HEIGHT";s2B.resize(370,20);if(secVar){s2B.fills=[figma.variables.setBoundVariableForPaint(paint(0,0,0),"color",secVar)];}else{s2B.fills=[paint(60/255,60/255,67/255,0.6)];}s2.appendChild(s2B);s2B.layoutSizingHorizontal="FILL";s2B.layoutSizingVertical="HUG";created.push(s2B.id);texts.push(s2B.id);
const sp=figma.createAutoLayout("VERTICAL");sp.name="Spacer";sp.layoutMode="VERTICAL";sp.primaryAxisSizingMode="AUTO";sp.counterAxisSizingMode="AUTO";sp.fills=[];root.appendChild(sp);sp.layoutSizingHorizontal="FILL";sp.layoutSizingVertical="FILL";created.push(sp.id);
root.appendChild(tabInst);tabInst.layoutSizingHorizontal="FILL";tabInst.layoutSizingVertical="FIXED";
const homeComp=await figma.importComponentByKeyAsync("57e63be8a13766c2cd47d069a1ef133b4b9df69c");
const homeIndicator=homeComp.createInstance();root.appendChild(homeIndicator);homeIndicator.layoutPositioning="AUTO";homeIndicator.layoutSizingHorizontal="FILL";homeIndicator.layoutSizingVertical="FIXED";homeIndicator.resize(402,34);created.push(homeIndicator.id);
return {rootId:root.id,importedNodeIds:[statusComp.id,tabVar.id,statusInst.id,tabInst.id,bgVar.id,labelVar.id],createdNodeIds:created.concat([statusInst.id,tabInst.id]),textNodeIds:texts,counts:{created:created.length+2,imported:6,texts:texts.length,tabs:numTabs.length},bounds:{x:root.x,y:root.y,width:root.width,height:root.height,status:{width:statusInst.width,height:statusInst.height},tab:{width:tabInst.width,height:tabInst.height}},fontValidation,secondarySource:secNote,lightModeId};