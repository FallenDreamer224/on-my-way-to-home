// File audit only. External files are read and hashed; never moved or rewritten.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const catalog=JSON.parse(fs.readFileSync('art/imports/lunar_exterior_library.json','utf8'));
const measured=new Map(JSON.parse(fs.readFileSync('art/imports/exterior_measurements.json','utf8')).map(x=>[x.path.replace(/^res:\/\//,''),x]));
const sourceIds=new Map(),runtimeIds=new Map(),runtimeHashes=new Map();
for(const a of catalog.assets){runtimeIds.set(a.runtime_path,a.asset_id);runtimeHashes.set(hash(a.runtime_path),a.asset_id);for(const s of a.source_files)sourceIds.set(s,a.asset_id)}
const files=[];
function visit(dir,prefix){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const full=path.join(dir,e.name),rel=prefix+'/'+e.name;if(e.isSymbolicLink())continue;if(e.isDirectory())visit(full,rel);else if(/\.(png|pxo)$/.test(e.name)){
 const digest=hash(full),bytes=fs.statSync(full).size;
 let size=null;if(e.name.endsWith('.png')){const b=fs.readFileSync(full);size=[b.readUInt32BE(16),b.readUInt32BE(20)]}
 const asset=runtimeIds.get(rel)??sourceIds.get(rel)??runtimeHashes.get(digest)??null;
 let status=asset?(runtimeIds.has(rel)||sourceIds.has(rel)?'READY':'DUPLICATE_CANDIDATE'):'UNUSED';
 let role=runtimeIds.has(rel)?'prepared_runtime':sourceIds.has(rel)?'selected_source':rel.startsWith('external://')?'external_original':'retained_candidate_or_technical_copy';
 if(rel.endsWith('.pxo')){status='READY';role='protected_authoring_source'}
 if(rel==='assets/pixellab/source/exterior_g1/greenhouse_module.png')status='NEEDS_REFINEMENT';
 if(rel==='assets/terrain/moon/moon_regolith_atlas_4x3.png')status='READY';
 files.push({path:rel,bytes,sha256:digest,native_size_px:size,status,role,represented_by:asset,measured_bounds_px:measured.get(rel)?.bounds??null,notes:status==='NEEDS_REFINEMENT'?'Rejected module-scale candidate. Original retained; never resized or integrated.':rel.endsWith('.pxo')?'Source available; not rewritten or re-exported in this phase.':status==='DUPLICATE_CANDIDATE'?'Byte-identical selected-art counterpart; retained without deletion.':status==='UNUSED'?'Preserved alternate/source format or technical atlas. Presence does not imply integration.':'See canonical catalog for footprint, ground pivot, collision, access and readiness.'});
}}}
for(const dir of ['assets/buildings','assets/environment/props_pack_b','assets/vehicles','assets/terrain'])visit(dir,dir);
for(const pack of ['base_pack_c','props_pack_b','lander_pack_d','terrain_pack_e','exterior_g1'])visit('assets/pixellab/source/'+pack,'assets/pixellab/source/'+pack);
if(process.argv[2])visit(process.argv[2],'external:/');
const duplicates=Object.entries(Object.groupBy(files,f=>f.sha256)).filter(([,v])=>v.length>1).map(([sha256,v])=>({sha256,status:'DUPLICATE_CANDIDATE',policy:'Selected source/runtime mirrors remain intentional; no file is deleted.',paths:v.map(x=>x.path)}));
const result={schema_version:1,phase:'0.8G1',external_root_policy:'external:// paths refer to the read-only user-supplied assets directory; no personal path is stored',assets:files,duplicate_groups:duplicates,coverage:catalog.gaps};
fs.writeFileSync('art/imports/exterior_source_audit.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({files:files.length,duplicate_groups:duplicates.length,statuses:Object.fromEntries(Object.entries(Object.groupBy(files,x=>x.status)).map(([k,v])=>[k,v.length]))}));
