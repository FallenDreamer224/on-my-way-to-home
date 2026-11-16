import fs from 'node:fs';
import path from 'node:path';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const audit=read('art/imports/base_source_audit.json').counts;
const ledger=read('art/imports/base_generation_ledger.json');
const reportPath='docs/phase_0_8G2_lunar_base_art.md',inventoryPath='docs/ASSET_INVENTORY.md';
const report=fs.readFileSync(reportPath,'utf8'),inventory=fs.readFileSync(inventoryPath,'utf8');
let checks=0;
const check=(ok,msg)=>{checks++;if(!ok)throw Error(msg);};
check(report.includes(`**${audit.finished_new_art_unique_hashes} unique new finished PNG components**`),'Report finished-art count');
check(report.includes(`**${audit.total_prepared_interior_props} prop scenes/Resources**`),'Report prop count');
check(report.includes(`Physical new PNG count is **${audit.audited_png_files}**`),'Report source-inclusive count');
check(report.includes(`**${ledger.generations_used} / ${ledger.authorized_generations}**`),'Report exact budget');
check(inventory.includes(`${audit.finished_new_art_unique_hashes} unique PNGs:`),'Inventory finished-art count');
check(inventory.includes(`${audit.ready_original_structural_files} READY`),'Inventory structural count');
check(inventory.includes(`**${audit.total_prepared_interior_props} native prop scenes/Resources**`),'Inventory prop count');
check(inventory.includes(`125 including raw sources`),'Inventory file count');
check(report.includes('COMPLETE WITH LIMITATIONS')&&inventory.includes('NEEDS_INTEGRATION'),'Integration limits remain explicit');
for(const [file,text]of [[reportPath,report],[inventoryPath,inventory.slice(inventory.indexOf('<!-- INTERIORS_G2_BEGIN -->'))]]){
 for(const match of text.matchAll(/\]\(([^)]+)\)/g)){
  const target=match[1];if(/^(https?:|#)/.test(target))continue;
  check(fs.existsSync(path.resolve(path.dirname(file),target.split('#')[0])),'Missing current document link '+file+' -> '+target);
 }
}
console.log(`PASS: ${checks} current base report/inventory count, budget, limitation and link checks. Historical deleted-report links are outside this scoped check.`);
