// Historical targeted fix. Do not replay over later owner edits.
// Append after common.js. The overlay auto-layout initialization reset its height to HUG.
for(const id of ['1063:1394','1063:1507']){
 const n=await figma.getNodeByIdAsync(id);
 n.resize(402,874);
 n.primaryAxisSizingMode='FIXED';
 n.counterAxisSizingMode='FIXED';
 n.primaryAxisAlignItems='CENTER';
 n.counterAxisAlignItems='CENTER';
 mutated.push(id);
}
// The imported enabled segmented variant returned opacity 0.5; correct locally, retaining native linkage.
for(const id of ['1055:609','1055:633']){
 const n=await figma.getNodeByIdAsync(id);n.opacity=1;mutated.push(id);
}
return summary();
