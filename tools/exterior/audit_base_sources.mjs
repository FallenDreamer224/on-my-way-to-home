// Supplemental G2 audit. Preserve original audits and every source/runtime duplicate.
import fs from 'node:fs';
import crypto from 'node:crypto';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):[p+'/'+e.name]);
const byPath=new Map();
const accept=(a,role)=>{for(const p of a.runtime_files??[])byPath.set(p,{asset_id:a.asset_id,status:a.review_status,role});for(const p of a.source_files??[])if(p.endsWith('.png'))byPath.set(p,{asset_id:a.asset_id,status:a.review_status,role:'selected_source'});};
for(const p of ['art/imports/base_g2.json','art/imports/native_shells.json','art/imports/base_structure.json'])for(const a of read(p).assets)accept(a,'prepared_native_art');
for(const j of read('assets/pixellab/source/base_g2/generation_jobs.json').jobs)if(j.review_status!=='READY')byPath.set(`assets/pixellab/source/base_g2/${j.source_name??j.asset_id}.png`,{asset_id:j.asset_id,status:'NEEDS_REFINEMENT',role:'rejected_creative_candidate'});
for(const j of read('assets/pixellab/source/base_g2/background_jobs.json').jobs)byPath.set(j.output_path,{asset_id:j.asset_id,status:'NEEDS_REFINEMENT',role:'rejected_provider_mask'});
for(const a of read('art/imports/base_hulls.json').assets){for(const p of [a.runtime_files[0],a.roof_path])byPath.set(p,{asset_id:a.asset_id,status:'NEEDS_REFINEMENT',role:'superseded_manual_hull_draft'});}
const paths=new Set(['assets/pixellab/source/base_g2','assets/buildings/base_g2','assets/environment/interiors_g2/structure'].flatMap(walk).filter(p=>p.endsWith('.png')));
for(const p of byPath.keys())paths.add(p);
const files=[...paths].sort().map(p=>{
 const b=fs.readFileSync(p),entry=byPath.get(p)??{asset_id:null,status:p.includes('/compositions/')?'READY':'UNUSED',role:p.includes('/compositions/')?'native_presentation_composition':'technical_passage_atlas_or_retained_draft'};
 return{path:p,...entry,sha256:hash(p),native_size_px:[b.readUInt32BE(16),b.readUInt32BE(20)]};
});
const groups=new Map();for(const f of files){if(!groups.has(f.sha256))groups.set(f.sha256,[]);groups.get(f.sha256).push(f.path);}
const duplicate_groups=[...groups].filter(([,v])=>v.length>1).map(([sha256,paths])=>({sha256,status:'DUPLICATE_CANDIDATE',paths,policy:'Intentional source/runtime or technical-role copies; retained, not deleted or counted as unique artwork.'}));
const structure=read('art/imports/base_structure.json').assets.filter(a=>a.review_status==='READY');
const small=read('art/imports/base_g2.json').assets;
const shells=read('art/imports/native_shells.json').assets;
const finished=[...structure,...small,...shells];
const unique=new Set(finished.map(a=>a.sha256)).size;
const audit={phase:'0.8G2 extended',earlier_audits:['art/imports/exterior_source_audit.json','art/imports/interior_source_audit.json'],files,duplicate_groups,counts:{audited_png_files:files.length,duplicate_groups:duplicate_groups.length,new_creative_images:small.length+shells.length,ready_original_structural_files:structure.length,ready_original_structural_unique_hashes:new Set(structure.map(a=>a.sha256)).size,finished_new_art_file_roles:finished.length,finished_new_art_unique_hashes:unique,reused_interior_prop_images:read('art/imports/interior_library.json').assets.filter(a=>a.reused).length,previously_accepted_interior_images:18,total_prepared_interior_props:34,room_scenes:9,exterior_asset_prefabs:15,presentation_composites:2},coverage:[{status:'READY',scope:'Native modular base/interior preview and source-preserving import.'},{status:'NEEDS_INTEGRATION',scope:'Production-world placement, mission/pickup entrances and finalized exterior service/portal sealing correspondence.'},{status:'MISSING',scope:'Alternate furniture facings, additional pressure elbow orientations/end-cap variants and optional secondary decorative details.'},{status:'NEEDS_REFINEMENT',scope:'Superseded full-hull blockouts and ten destructive provider masks; excluded from finished art.'}]};
fs.writeFileSync('art/imports/base_source_audit.json',JSON.stringify(audit,null,2)+'\n');
console.log(JSON.stringify(audit.counts));
