// Prepend common.js. Figma-specific scroll clearance; not an app defect.

const body=await figma.getNodeByIdAsync('1119:2735');await fonts(body);
const help=body.findAllWithCriteria({types:['TEXT']}).find(n=>n.characters==='Get a reminder after 3 days without opening Defog.');help.characters='Get a reminder after 3 days of inactivity.';mutated.push(help.id);
const tail=stack(body,'Bottom scroll clearance · 58pt',354,0);tail.resize(354,58);tail.primaryAxisSizingMode='FIXED';fill(tail,'Canvas');body.paddingBottom=0;mutated.push(body.id);
return summary({body:body.id,tail:tail.id,help:help.id});
