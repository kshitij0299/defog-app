// Final mutation record: execute only after inspecting the current file.
await figma.setCurrentPageAsync(await figma.getNodeByIdAsync('1095:368'));
const mutatedNodeIds=[];
for(const [a,b]of [['1097:589','1166:2991'],['1097:823','1166:3076'],['1097:685','1166:3193']]){
 for(const [src,dest,name]of [[a,b,'Heading'],[b,a,'Navigation']]){
  const f=await figma.getNodeByIdAsync(src);const n=f.findOne(n=>n.name===name);
  await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[{type:'NODE',destinationId:dest,navigation:'NAVIGATE',transition:{type:'SMART_ANIMATE',duration:.28,easing:{type:'EASE_OUT'}},resetScrollPosition:true}]}]);
  if(name==='Navigation')n.primaryAxisAlignItems='SPACE_BETWEEN';mutatedNodeIds.push(n.id);
 }
}
for(const f of figma.currentPage.children.filter(n=>n.name.startsWith('Screen /'))){const intro=f.findOne(n=>n.name==='Goal introduction');if(intro){intro.cornerRadius=0;intro.clipsContent=false;mutatedNodeIds.push(intro.id);}}
return{mutatedNodeIds};
