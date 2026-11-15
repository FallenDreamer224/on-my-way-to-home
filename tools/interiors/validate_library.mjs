import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const read = p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const hash = p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
let checks=0;
const check=(ok,message)=>{checks++;if(!ok)throw Error(message);};
const standards=read('art/asset_standards.json');
const imports=read('art/imports/interiors_g2.json');
const catalog=read('art/imports/interior_library.json');
const rooms=read('resources/interiors/room_library.json');
const jobs=read('assets/pixellab/source/interiors_g2/generation_jobs.json');
const source=read('resources/data/habitat_layout.json');
check(imports.standards_version===standards.standards_version,'Standards version mismatch');
check(rooms.tile_size_px.join(',')===standards.world.ground_tile_size_px.join(','),'Grid mismatch');
check(jobs.jobs.reduce((s,j)=>s+j.cost_generations,0)<=jobs.maximum_authorized_generations,'Generation cap exceeded');
check(jobs.jobs.length===24&&imports.assets.length===18,'Unexpected candidate/accepted counts');
const ids=new Set();
for(const a of catalog.assets){
 check(!ids.has(a.asset_id),'Duplicate ID');ids.add(a.asset_id);
 for(const p of [a.scene_path,a.resource_path,...a.source_files,...a.runtime_files])check(fs.existsSync(p),'Missing '+p);
 const png=fs.readFileSync(a.runtime_files[0]);
 check(png.readUInt32BE(16)===a.native_canvas_size_px[0]&&png.readUInt32BE(20)===a.native_canvas_size_px[1],'PNG dimensions');
 check(hash(a.source_files[0])===hash(a.runtime_files[0]),'Source/runtime bytes differ');
 if(!a.reused){
  check(a.sha256===hash(a.runtime_files[0]),'Hash metadata');
  check(a.generation_id&&a.prompt&&a.selected_candidate===0&&a.exception===null,'Incomplete intake');
  check(a.animation.frame_count===1&&a.animation.frame_regions[0].join(',')===[0,0,...a.native_canvas_size_px].join(','),'Static frame regions');
 }
}
for(const room of rooms.rooms){
 const original=source.rooms.find(r=>r.id===room.id);
 check(original&&room.size_cells.join(',')===original.size.join(','),'Room dimensions silently changed');
 check(fs.existsSync(room.scene_path),'Room scene missing');
 const blocked=new Set(room.layout.extra_blocked_cells.map(p=>p.join(',')));
 for(const p of room.props){
  check(ids.has(p.asset),'Unknown prop '+p.asset);
  for(let y=0;y<p.footprint[1];y++)for(let x=0;x<p.footprint[0];x++){
   const c=[p.cell[0]+x,p.cell[1]+y];
   check(c[0]>=1&&c[1]>=1&&c[0]<room.size_cells[0]-1&&c[1]<room.size_cells[1]-1,'Furniture outside floor');
   blocked.add(c.join(','));
  }
 }
 for(const station of room.layout.facilities)check(!blocked.has(station.point.join(',')),'Blocked interaction '+room.id+'/'+station.id);
 for(const portal of room.portals){
  check(!blocked.has(portal.approach.join(',')),'Blocked approach');
  check(room.layout.doors.some(d=>d.id===portal.id&&d.destination===portal.destination),'Portal identity changed');
  check(portal.destination!=='outside'||room.id==='crew_airlock','Ordinary door to vacuum');
 }
 check(!blocked.has(room.layout.spawn.join(','))&&!blocked.has(room.layout.companion_spawn.join(',')),'Blocked actor spawn');
}
const audit=[];
for(const a of catalog.assets)for(const p of [...a.source_files,...a.runtime_files])audit.push({path:p,status:'READY',asset_id:a.asset_id,sha256:hash(p)});
for(const j of jobs.jobs.filter(j=>j.review_status!=='READY')){const p=`assets/pixellab/source/interiors_g2/${j.source_name??j.asset_id}.png`;check(fs.existsSync(p),'Rejected source removed');audit.push({path:p,status:'NEEDS_REFINEMENT',reason:j.review_notes,sha256:hash(p)});}
const prior=read('art/imports/exterior_source_audit.json');
const groups=new Map();for(const a of audit){if(!groups.has(a.sha256))groups.set(a.sha256,[]);groups.get(a.sha256).push(a.path);}
const duplicate_groups=[...groups.values()].map(a=>[...new Set(a)]).filter(a=>a.length>1).map(paths=>({status:'DUPLICATE_CANDIDATE',policy:'Intentional source/runtime mirrors; preserve all originals.',paths}));
fs.writeFileSync('art/imports/interior_source_audit.json',JSON.stringify({phase:'0.8G2',existing_audit:'art/imports/exterior_source_audit.json',existing_file_count:prior.files?.length??162,files:[...new Map(audit.map(a=>[a.path,a])).values()],duplicate_groups,coverage:[{category:'all_13_functional_areas',status:'READY',notes:'Nine shared-function room scenes; isolated development integration.'},{category:'final_world_assembly',status:'NEEDS_INTEGRATION',notes:'Phase 0.9, not started.'},{category:'crop_failure_art',status:'UNUSED',notes:'Existing model pauses; no crop death/health state exists.'},{category:'alternate_furniture_facings',status:'MISSING',notes:'Single supplied views retained; no interpolated rotation.'}]},null,2)+'\n');
console.log(`PASS: ${checks} interior JSON/path/dimension/footprint/provenance checks; ${audit.length} source/runtime references audited.`);
