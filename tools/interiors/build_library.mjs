import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const read = p => JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const write = (p,s) => { fs.mkdirSync(path.dirname(p),{recursive:true}); fs.writeFileSync(p,s); };
const json = (p,v) => write(p,JSON.stringify(v,null,2)+'\n');
const v = p => `Vector2i(${p.join(', ')})`;
const point = (x,y) => [(x-y)*32,(x+y)*16];
const q = JSON.stringify;
const plan = read('tools/interiors/production_plan.json');
const jobs = read('assets/pixellab/source/interiors_g2/generation_jobs.json');
const measurements = read('art/imports/interior_measurements.json');
const assets = [];
for (const job of jobs.jobs.filter(j=>j.review_status==='READY')) {
  const spec = plan.assets.find(a=>a.id===job.asset_id);
  const source = `assets/pixellab/source/interiors_g2/${job.source_name??job.asset_id}.png`;
  const measured = measurements.find(m=>m.path==='res://'+source);
  if(!measured) throw Error('Unmeasured source '+source);
  if(measured.partial_alpha_pixels) throw Error('Unreviewed alpha '+source);
  const runtime = `assets/environment/interiors_g2/${job.asset_id}.png`;
  if(!fs.existsSync(runtime)) fs.copyFileSync(source,runtime);
  const hash=crypto.createHash('sha256').update(fs.readFileSync(runtime)).digest('hex');
  if(hash!==measured.sha256)throw Error('Source/runtime mismatch');
  assets.push({asset_id:job.asset_id,standards_version:'1.0.0',category:job.asset_id.startsWith('greens_')?'plant_overlay':'interior_furnishing',source_provider:'PixelLab.ai MCP',source_files:[source],runtime_files:[runtime],usage_terms:'https://www.pixellab.ai/termsofservice',native_canvas_size_px:measured.size,physical_scale_intent:'Native-scale furnishing or tray overlay beside existing 55-pixel human; fictional lunar adaptation, not equipment qualification.',review_status:'READY',exception:null,generation_id:job.job_id,provider_image_id:job.provider_image_id,prompt:job.request.description,selected_candidate:0,sha256:hash,ground_anchor_px_from_image_top_left:measured.bottom_anchor,visible_bounds_px:measured.bounds,footprint_grid_cells:spec.footprint,animation:{type:'static',direction:'single_isometric_view',frame_count:1,frame_size_px:measured.size,frame_regions:[[0,0,...measured.size]],fps:0,loop:false},reused:false,provenance:'art/imports/interiors_g2.json'});
}
for(const a of assets.filter(a=>a.asset_id.startsWith('greens_'))){
  const [x,y,w,h]=a.visible_bounds_px;
  a.attachment_anchor_px_from_image_top_left=[Math.floor(x+w/2),y+h];
  a.attachment_policy='Whole original image; centered visible foliage base attached to tray surface (-14,-46) relative to ground pivot. No trim or scale.';
}
json('art/imports/interiors_g2.json',{pack_id:'interiors_g2',standards_version:'1.0.0',assets});
const exterior=read('art/imports/lunar_exterior_library.json');
const reuse=['work_control_console','battery_power_unit','eclss_service_cabinet','utility_oxygen_tank','tool_case','supply_pack','small_resource_canister','small_equipment_box','small_connector_utility_box'];
const all=[...assets];
if(fs.existsSync('art/imports/base_g2.json'))for(const a of read('art/imports/base_g2.json').assets.filter(a=>a.category==='interior_equipment'))all.push(a);
for(const id of reuse){const a=exterior.assets.find(x=>x.asset_id===id);if(!a)throw Error(id);all.push({asset_id:id,native_canvas_size_px:a.native_size_px,visible_bounds_px:a.visible_bounds_px,ground_anchor_px_from_image_top_left:a.ground_anchor_px,footprint_grid_cells:a.footprint_grid_cells,runtime_files:[a.runtime_path],source_files:a.source_files,provenance:a.source_manifest,reused:true});}
for(const a of all){
 const [w,d]=a.footprint_grid_cells;
 const front=w&&d?point(w-.5,d-.5):[0,0];
 const grid=front.map(n=>-n);
 const resource=`resources/interiors/props/${a.asset_id}.tres`;
 const scene=`scenes/interiors/props/${a.asset_id}.tscn`;
 a.resource_path=resource;a.scene_path=scene;a.grid_origin_px=grid;
 write(resource,`[gd_resource type="Resource" script_class="InteriorPropDefinition" load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://scripts/interiors/interior_prop_definition.gd" id="1"]\n[ext_resource type="Texture2D" path="res://${a.runtime_files[0]}" id="2"]\n\n[resource]\nscript = ExtResource("1")\nasset_id = &${q(a.asset_id)}\ntexture = ExtResource("2")\nnative_size = ${v(a.native_canvas_size_px)}\nopaque_bounds = Rect2i(${a.visible_bounds_px.join(', ')})\nground_anchor = ${v(a.ground_anchor_px_from_image_top_left)}\nfootprint = ${v(a.footprint_grid_cells)}\ngrid_origin = ${v(grid)}\nprovenance = ${q(a.provenance)}\nsource_files = PackedStringArray(${a.source_files.map(q).join(', ')})\nreused = ${a.reused}\n`);
 write(scene,`[gd_scene load_steps=3 format=3]\n\n[ext_resource type="Resource" path="res://${resource}" id="1"]\n[ext_resource type="Texture2D" path="res://${a.runtime_files[0]}" id="2"]\n\n[node name="${a.asset_id}" type="Node2D"]\ntexture_filter = 1\nmetadata/definition = ExtResource("1")\n\n[node name="Sprite2D" type="Sprite2D" parent="."]\ntexture = ExtResource("2")\ncentered = false\noffset = Vector2(${-a.ground_anchor_px_from_image_top_left[0]}, ${-a.ground_anchor_px_from_image_top_left[1]})\n\n[node name="GroundPivot" type="Marker2D" parent="."]\n\n[node name="GridOrigin" type="Marker2D" parent="."]\nposition = Vector2(${grid.join(', ')})\n\n[node name="InteractionAnchor" type="Marker2D" parent="."]\nposition = Vector2(0, 24)\n`);
}
const original=read('resources/data/habitat_layout.json');
const place=(id,asset,x,y,extra={})=>({id,asset,cell:[x,y],...extra});
const furnishings={
 crew_airlock:[place('eva_supplies','eva_rack',3,1),place('emergency','supply_pack',5,1)],
 equipment_lock:[place('equipment','small_equipment_box',1,1),place('suits','eva_rack',3,1),place('dust','eclss_service_cabinet',6,1)],
 hub:[place('operations','work_control_console',3,1),place('main','habitat_table',3,5),place('personal_storage','small_equipment_box',5,5),place('seat','habitat_seat',5,6)],
 living:[place('sleep','sleep_bunk',1,1),place('galley','galley_station',3,1),place('hygiene','sanitation_station',6,1),place('drink','water_dispenser',3,5)],
 engineering:[place('eclss','eclss_service_cabinet',2,1),place('water','water_dispenser',4,1),place('power','battery_power_unit',6,1),place('reserve_tank','utility_oxygen_tank',4,5),place('junction','small_connector_utility_box',6,5)],
 health_lab:[place('medical','medical_station',1,1),place('exercise','exercise_station',4,1),place('science','sample_bench',5,1),place('sample_case','tool_case',5,5)],
 greenhouse:[place('tray_0','growing_tray_empty',3,1,{tray_index:0}),place('tray_1','growing_tray_empty',4,4,{tray_index:1}),place('monitor','work_control_console',1,1),place('nutrients','small_resource_canister',6,1),place('water_connection','small_connector_utility_box',6,3)],
 cargo:[place('cargo','storage_rack_loaded',2,1),place('empty_storage','storage_rack_empty',4,1),place('maintenance','maintenance_bench',4,4),place('tools','tool_case',6,4),place('spares','small_equipment_box',6,1)],
 shelter:[place('shelter','supply_pack',3,1),place('monitor','work_control_console',1,1),place('seat','habitat_seat',2,1)]
};
const rooms=[];
const basePlan=fs.existsSync('resources/data/lunar_base_art_layout.json')?read('resources/data/lunar_base_art_layout.json'):null;
if(basePlan){
 furnishings.living.find(p=>p.id==='galley').cell=[3,3];
 furnishings.living.push(place('locker','personal_locker',1,5));
 furnishings.equipment_lock.find(p=>p.id==='dust').asset='service_wall_panel';
 furnishings.engineering.push(place('filters','filter_cartridges',2,5));
 furnishings.health_lab.push(place('medical_storage','medical_storage',3,5));
 furnishings.greenhouse.find(p=>p.id==='nutrients').asset='nutrient_unit';
 furnishings.greenhouse.find(p=>p.id==='water_connection').asset='irrigation_unit';
}
for(const source of original.rooms){
 const layout=structuredClone(source);
 if(layout.id==='health_lab'){layout.extra_blocked_cells=[];layout.facilities.find(f=>f.id==='science').point=[6,3];layout.facilities.find(f=>f.id==='science').fixture=[5,1];}
 const overrides=basePlan?.room_port_overrides[layout.id]??{};
 for(const door of layout.doors)if(overrides[door.id])door.point=overrides[door.id].point;
 const props=furnishings[layout.id];
 for(const prop of props){const a=all.find(a=>a.asset_id===prop.asset);if(!a)throw Error('Missing accepted asset '+prop.asset);prop.footprint=a.footprint_grid_cells;prop.blocks_navigation=true;}
 // The art prototype keeps room dimensions and station IDs. Furniture expands only its own reservations.
 const portals=layout.doors.filter(d=>original.rooms.some(r=>r.id===d.destination)||d.destination==='outside').map(d=>({id:d.id,destination:d.destination,threshold:[d.point[0]<=layout.size[0]/2?0:layout.size[0]-1,d.point[1]],approach:d.point,pressure_boundary:layout.id==='crew_airlock'||d.destination==='crew_airlock',closed_state_source:layout.id==='crew_airlock'?'HabitatDirector.airlock':'ordinary interior passage; local preview toggle only'}));
 for(const portal of portals)if(overrides[portal.id])portal.threshold=overrides[portal.id].threshold;
 const record={id:layout.id,title:layout.title,source_layout:'resources/data/habitat_layout.json',original_size_cells:source.size,size_cells:layout.size,scene_path:`scenes/interiors/rooms/${layout.id}.tscn`,layout,props,portals,cutaway:'PNG back walls and low foreground partitions. Unit-scale source pixels retained.',physical_scale:basePlan?'Native hull envelope matches this room; exterior composition is an isolated preview.':'Logical cutaway, not an exterior building footprint or certified volume.',supported_connections:portals.map(d=>d.destination),exterior_module:basePlan?.modules.find(m=>m.id===layout.id)??null};
 record.floor_treatment=['crew_airlock','equipment_lock','engineering','greenhouse','cargo'].includes(layout.id)?'sealed_service':'general_habitat';
 rooms.push(record);
 write(record.scene_path,`[gd_scene load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://scripts/interiors/interior_room.gd" id="1"]\n[ext_resource type="Script" path="res://scripts/world/terrain_layer.gd" id="2"]\n\n[node name="${layout.id}" type="Node2D"]\ntexture_filter = 1\nscript = ExtResource("1")\nroom_id = &${q(layout.id)}\n\n[node name="Floor" type="TileMapLayer" parent="."]\nposition = Vector2(-32, -16)\nz_index = -10\nscript = ExtResource("2")\n\n[node name="Walls" type="StaticBody2D" parent="."]\ncollision_layer = 2\ncollision_mask = 1\n\n[node name="Construction" type="Node2D" parent="."]\nz_index = -1\n\n[node name="Actors" type="Node2D" parent="."]\ny_sort_enabled = true\n`);
}
// Embed runtime data in native Resources/scenes; provenance JSON remains a tooling input.
for(const a of all)fs.appendFileSync(a.resource_path,`attachment_anchor = ${v(a.attachment_anchor_px_from_image_top_left??a.ground_anchor_px_from_image_top_left)}\n`);
for(const room of rooms){
 const file=fs.readFileSync(room.scene_path,'utf8');
 write(room.scene_path,file.replace(`room_id = &${q(room.id)}\n`,`room_id = &${q(room.id)}\nprepared_data = ${JSON.stringify(room)}\n`));
}
const floorNames=['base_floor_panel_tile','utility_floor_pad_tile','hazard_stripe_floor_tile'];
let floor='[gd_resource type="TileSet" load_steps=8 format=3]\n\n';
floorNames.forEach((n,i)=>floor+=`[ext_resource type="Texture2D" path="res://assets/terrain/expansion_e/${n}.png" id="${i+1}"]\n`);
[1,2,1,3].forEach((texture,i)=>floor+=`\n[sub_resource type="TileSetAtlasSource" id="Source_${i}"]\ntexture = ExtResource("${texture}")\ntexture_region_size = Vector2i(64, 32)\n0:0/0 = 0\n`);
floor+='\n[resource]\ntile_shape = 1\ntile_layout = 5\ntile_size = Vector2i(64, 32)\n';
for(let i=0;i<4;i++)floor+=`sources/${i} = SubResource("Source_${i}")\n`;
write('resources/interiors/interior_floor.tres',floor);
for(let i=0;i<floorNames.length;i++)write(`scenes/interiors/modules/floor_${i}.tscn`,`[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Texture2D" path="res://assets/terrain/expansion_e/${floorNames[i]}.png" id="1"]\n\n[node name="FloorTile" type="Sprite2D"]\ntexture_filter = 1\ntexture = ExtResource("1")\n`);
const modules=['wall','corner','window','service','support','door','cable_straight','cable_corner','cable_vertical'];
for(let i=0;i<modules.length;i++)write(`scenes/interiors/modules/${modules[i]}.tscn`,`[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://scripts/interiors/interior_module.gd" id="1"]\n\n[node name="${modules[i]}" type="Node2D"]\ntexture_filter = 1\nscript = ExtResource("1")\nkind = ${i}\n`);
json('resources/interiors/room_library.json',{schema_version:1,phase:'0.8G2',tile_size_px:[64,32],production_layout_changed:false,simulation_owner:'Existing HabitatDirector, UtilityService and DailyLife only',rooms});
json('art/imports/interior_library.json',{schema_version:1,assets:all,modules,source_audit:'G1 162-file audit plus G2 24 retained candidate sources; all 64 external originals rechecked, no interior originals found',rejected_candidates:jobs.jobs.filter(j=>j.review_status!=='READY').map(j=>({asset_id:j.asset_id,status:j.review_status,reason:j.review_notes,source_file:`assets/pixellab/source/interiors_g2/${j.asset_id}.png`}))});
console.log(`Prepared ${all.length} prop scenes/resources, ${rooms.length} rooms and ${modules.length} construction modules.`);
