// Assemble reviewed native assets and an explicit room-to-hull plan. No source PNG edits.
import fs from 'node:fs';
import path from 'node:path';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const write=(p,s)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,s);};
const json=(p,v)=>write(p,JSON.stringify(v,null,2)+'\n');
const plan=read('tools/interiors/base_production_plan.json');
const jobs=read('assets/pixellab/source/base_g2/generation_jobs.json');
const measurements=read('art/imports/base_measurements.json');
const indoors=['service_wall_panel','overhead_lamp','filter_cartridges','medical_storage','nutrient_unit','irrigation_unit','personal_locker'];
const assets=[];
for(const j of jobs.jobs.filter(j=>j.review_status==='READY')){
 const source=`assets/pixellab/source/base_g2/${j.source_name??j.asset_id}.png`;
 const m=measurements.find(m=>m.path==='res://'+source);
 const spec=plan.assets.find(a=>a.id===j.asset_id)??{footprint:j.footprint??[1,1]};
 if(!m||m.partial_alpha_pixels)throw Error('Unmeasured/nonbinary source '+source);
 const runtime=`assets/${indoors.includes(j.asset_id)?'environment/interiors_g2':'buildings/base_g2'}/${j.asset_id}.png`;
 fs.mkdirSync(path.dirname(runtime),{recursive:true});if(!fs.existsSync(runtime))fs.copyFileSync(source,runtime);
 const anchor=j.asset_id.startsWith('pressure_hatch')?measurements.find(m=>m.path.endsWith('/pressure_hatch_closed.png')).bottom_anchor:m.bottom_anchor;
 assets.push({asset_id:j.asset_id,standards_version:'1.0.0',category:indoors.includes(j.asset_id)?'interior_equipment':'exterior_connection',source_provider:'PixelLab.ai MCP',source_files:[source],runtime_files:[runtime],usage_terms:'https://www.pixellab.ai/termsofservice',native_canvas_size_px:m.size,physical_scale_intent:'Native practical lunar base equipment, matching existing cool white/navy art. No engineering ratings implied.',review_status:'READY',exception:null,generation_id:j.job_id,provider_image_id:j.provider_image_id,prompt:j.request.description,selected_candidate:0,sha256:m.sha256,ground_anchor_px_from_image_top_left:anchor,visible_bounds_px:m.bounds,footprint_grid_cells:spec.footprint,animation:{type:'static',frame_count:1,frame_size_px:m.size,frame_regions:[[0,0,...m.size]],fps:0,loop:false},reused:false,provenance:'art/imports/base_g2.json'});
}
const imageGenerations=jobs.jobs.reduce((s,j)=>s+j.cost_generations,0);
const shellJobs=read('assets/pixellab/source/base_g2/shell_jobs.json').jobs;
const backgroundJobs=read('assets/pixellab/source/base_g2/background_jobs.json').jobs;
json('art/imports/base_g2.json',{pack_id:'base_g2',standards_version:'1.0.0',authorized_generations:30,used_generations:imageGenerations+shellJobs.length+backgroundJobs.length,image_generations:imageGenerations,shell_generations:shellJobs.length,rejected_background_generations:backgroundJobs.length,assets});
const positions={crew_airlock:[-13,-10],equipment_lock:[-13,-2],hub:[-4,-2],living:[-4,8],engineering:[-13,8],health_lab:[5,-2],greenhouse:[5,-10],cargo:[5,7],shelter:[14,-2]};
// Explicit preview changes: native room dimensions/IDs and existing actions are retained.
const overrides={
 crew_airlock:{outer:{point:[6,3],threshold:[7,3]},inner:{point:[4,5],threshold:[4,6]}},
 equipment_lock:{crew:{point:[2,1],threshold:[2,0]}},
 hub:{lock:{point:[1,4],threshold:[0,4]},living:{point:[3,7],threshold:[3,8]}},
 living:{hub:{point:[3,1],threshold:[3,0]}},
 engineering:{hub:{point:[6,2],threshold:[7,2]}}
};
const rooms=read('resources/interiors/room_library.json').rooms;
const modules=rooms.map(r=>({id:r.id,room_id:r.id,origin:positions[r.id],size:r.size_cells,height_px:r.id==='greenhouse'?96:80,room_scene:r.scene_path,portals:r.portals.map(p=>({...p,...(overrides[r.id]?.[p.id]??{}),approach:overrides[r.id]?.[p.id]?.point??p.approach}))}));
const occupied=new Set();for(const m of modules)for(let y=0;y<m.size[1];y++)for(let x=0;x<m.size[0];x++)occupied.add([m.origin[0]+x,m.origin[1]+y].join(','));
const add=(a,b)=>a.map((n,i)=>n+b[i]);
const endpoint=(m,p)=>{const a=add(m.origin,p.threshold);const s=p.threshold[0]===0?[-1,0]:p.threshold[0]===m.size[0]-1?[1,0]:p.threshold[1]===0?[0,-1]:[0,1];return{edge:a,outside:add(a,s)};};
const routes=[],seen=new Set(),corridor=new Map();
for(const m of modules)for(const p of m.portals){
 const target=modules.find(t=>t.id===p.destination);if(!target)continue;
 const key=[m.id,target.id].sort().join('/');if(seen.has(key))continue;seen.add(key);
 const reciprocal=target.portals.find(q=>q.destination===m.id);if(!reciprocal)throw Error('No reciprocal link '+key);
 const start=endpoint(m,p),end=endpoint(target,reciprocal);
 const queue=[start.outside],previous=new Map([[start.outside.join(','),null]]);let head=0;
 while(head<queue.length){const at=queue[head++];if(at.join(',')===end.outside.join(','))break;for(const step of [[1,0],[0,1],[-1,0],[0,-1]]){const next=add(at,step),k=next.join(',');if(next.some(n=>n<-20||n>19)||occupied.has(k)||previous.has(k))continue;previous.set(k,at);queue.push(next);}}
 if(!previous.has(end.outside.join(',')))throw Error('No corridor route '+key);
 const cells=[];let cursor=end.outside;while(cursor){cells.push(cursor);cursor=previous.get(cursor.join(','));}cells.reverse();for(const c of cells)corridor.set(c.join(','),c);
 routes.push({id:key,from:{module:m.id,door:p.id,...start},to:{module:target.id,door:reciprocal.id,...end},cells});
}
const setup={schema_version:1,phase:'0.8G2 extended',tile_size_px:[64,32],logical_region:{origin:[-20,-20],size:[40,40]},production_world_changed:false,room_port_overrides:overrides,modules,routes,corridor_cells:[...corridor.values()],spawn:[-15,-7],companion_spawn:[-16,-7],equipment:[
 {id:'solar_panel_array',cell:[-19,1]},{id:'battery_power_unit',cell:[-18,4]},{id:'radiator_bank',cell:[-19,7]},{id:'utility_oxygen_tank',cell:[-16,6]},{id:'communications_antenna',cell:[1,-15]},{id:'moon_lander',cell:[-19,13]},{id:'storage_crate_large',cell:[-14,17]},{id:'support_cargo_container',cell:[-16,17]},{id:'tool_case',cell:[-13,17]},{id:'beacon_marker',cell:[-15,-6]},{id:'field_sensor_tripod',cell:[15,-8]},{id:'small_connector_utility_box',cell:[-16,3]}
],facades:[{id:'small_habitat_module',module:'living',cell:[-2,14]},{id:'airlock_module',module:'crew_airlock',cell:[-14,-7]},{id:'greenhouse_module',module:'greenhouse',cell:[7,-5]}],notes:['Native hull envelope contains each full existing cutaway room; legacy small sprites are attached facade/entry bays, not enlarged or claimed to contain those rooms.','Outdoor corridors are sealed structural art; entry/interior transitions use existing HabitatDirector, not a new gas/door system.','The isolated preview uses the existing 40x40 terrain cell data with preview-only footprint occupancy. Final production placement remains Phase 0.9.']};
setup.facades=[{id:'small_habitat_module',module:'living',cell:[-2,16]},{id:'airlock_module',module:'crew_airlock',cell:[-5,-10]},{id:'greenhouse_module',module:'greenhouse',cell:[13,-7]}];
setup.spawn=[-4,-6];setup.companion_spawn=[-3,-6];
json('resources/data/lunar_base_art_layout.json',setup);
console.log(`Prepared ${assets.length} accepted PixelLab assets; ${modules.length} dimension-matched hulls, ${routes.length} pressure links, ${corridor.size} corridor cells.`);
