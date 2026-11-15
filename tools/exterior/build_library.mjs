// Reproducible native 2D prefab preparation. Never edits input PNGs or the production world.
import fs from 'node:fs';
import path from 'node:path';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const q=JSON.stringify;
const vec=v=>`Vector2i(${v[0]}, ${v[1]})`;
const poly=p=>`PackedVector2Array(${p.flat().join(', ')})`;
const project=(i,j)=>[(i-j)*32,(i+j)*16];
const measurements=new Map(read('art/imports/exterior_measurements.json').map(x=>[x.path.replace(/^res:\/\//,''),x]));
const out='resources/exterior';
fs.mkdirSync(out,{recursive:true});fs.mkdirSync('scenes/exterior',{recursive:true});
const bindings={solar_panel_array:'solar',battery_power_unit:'battery',small_connector_utility_box:'distribution',work_control_console:'housekeeping',utility_oxygen_tank:'oxygen_supply',radiator_bank:'thermal_control',eclss_service_cabinet:'ventilation'};
const inventory=[];
for(const [pack,category] of [['base_pack_c','base'],['props_pack_b','prop'],['lander_pack_d','lander'],['terrain_pack_e','ground'],['exterior_g1','new_equipment']]){
 const manifest='art/imports/'+pack+'.json';if(!fs.existsSync(manifest))continue;
 for(const original of read(manifest).assets){
  const image=original.runtime_files[0];const id=path.posix.basename(image,'.png');
  const dims=original.native_canvas_size_px;
  const size=original.explicit_footprint_grid_cells??original.proposed_footprint_grid_cells??[1,1];
  const [w,d]=size;
  const anchor=original.ground_anchor_px_from_image_top_left;
  const bounds=original.opaque_bounds_px??measurements.get(image)?.bounds;
  if(!anchor||!dims||!bounds)throw Error('Missing measured metadata: '+id);
  original.opaque_bounds_px=bounds;
  const ground=category==='ground';
  const front=ground?[0,0]:project(w-.5,d-.5);
  const footprint=[project(-.5,-.5),project(w-.5,-.5),project(w-.5,d-.5),project(-.5,d-.5)].map(p=>[p[0]-front[0],p[1]-front[1]]);
  const cells=[];for(let j=0;j<d;j++)for(let i=0;i<w;i++)cells.push([i,j]);
  const solid=!ground&&!['landing_marker_decal','deployed_ramp','lunar_sample','metal_scrap','supply_pack','beacon_marker'].includes(id);
  const collision=solid?[project(-1,-1),project(w,-1),project(w,d),project(-1,d)].map(p=>[p[0]-front[0],p[1]-front[1]]):[];
  const reserved=[];if(solid)for(let j=-1;j<=d;j++)for(let i=-1;i<=w;i++)reserved.push([i,j]);
  const states=category==='base'||category==='new_equipment'||id==='moon_lander';
  const interaction=solid?[0,40]:[0,20];
  const record={asset_id:id,name:id.split('_').map(s=>s[0].toUpperCase()+s.slice(1)).join(' '),category,status:'READY',reused:category!=='new_equipment',source_manifest:manifest,source_files:original.source_files,runtime_path:image,scene_path:`scenes/exterior/${id}.tscn`,resource_path:`${out}/${id}.tres`,native_size_px:dims,visible_bounds_px:original.opaque_bounds_px,ground_anchor_px:anchor,footprint_grid_cells:size,occupied_cells:cells,grid_origin_px:front.map(x=>-x),footprint_polygon_px:footprint,collision_polygon_px:collision,navigation_reserved_cells:reserved,collision_enabled:solid,interaction_anchor_px:interaction,service_anchor_px:[-40,40],indicator_anchor_px:[0,-12],utility_binding_id:bindings[id]??'',supports_states:states,interaction_reference:id==='airlock_module'?'habitat_airlock_access':bindings[id]?'existing_utility_inspection':'',visual_review:'native_canvas_and_assembly_reviewed',orientation:'Single supplied 2:1-compatible view; no implicit sprite rotation',collision_policy:solid?'Half-cell ground-hardware clearance around the declared footprint; not a pixel-traced silhouette. Future routing must reserve navigation_reserved_cells, including the intersected outer ring.':'No blocking body; graphic is a pickup reference, ground overlay, marker or unimplemented ramp.',sorting_policy:ground||id==='landing_marker_decal'?'Ground decoration below actors':'Root is frontmost ground contact, child sprite offset only; root shares actor Y-sort canvas/Z',pivot_policy:ground?'tile_center':'frontmost_measured_ground_contact'};
  inventory.push(record);
  const stringArray=a=>`PackedStringArray(${a.map(q).join(', ')})`;
  const body=`[gd_resource type="Resource" script_class="ExteriorAssetDefinition" load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://scripts/world/exterior_asset_definition.gd" id="1"]\n[ext_resource type="Texture2D" path="res://${image}" id="2"]\n\n[resource]\nscript = ExtResource("1")\nasset_id = &${q(id)}\ndisplay_name = ${q(record.name)}\ncategory = &${q(category)}\ntexture = ExtResource("2")\nnative_size = ${vec(dims)}\nopaque_bounds = Rect2i(${original.opaque_bounds_px.join(', ')})\nground_anchor = ${vec(anchor)}\nfootprint_size = ${vec(size)}\noccupied_cells = Array[Vector2i]([${cells.map(vec).join(', ')}])\ngrid_origin = ${vec(record.grid_origin_px)}\nfootprint_polygon = ${poly(footprint)}\ncollision_polygon = ${poly(record.collision_polygon_px)}\ninteraction_anchor = ${vec(interaction)}\nservice_anchor = Vector2i(-40, 40)\nindicator_anchor = Vector2i(0, -12)\ncollision_enabled = ${solid}\nsupports_states = ${states}\nutility_binding_id = &${q(record.utility_binding_id)}\ninteraction_reference = &${q(record.interaction_reference)}\nprovenance_manifest = ${q('res://'+manifest)}\nsource_files = ${stringArray(original.source_files)}\n`;
  fs.writeFileSync(record.resource_path,body.replace('grid_origin = ',`navigation_reserved_cells = Array[Vector2i]([${reserved.map(vec).join(', ')}])\ngrid_origin = `));
  const scene=`[gd_scene load_steps=${states?4:3} format=3]\n\n[ext_resource type="Resource" path="res://${record.resource_path}" id="1"]\n[ext_resource type="Texture2D" path="res://${image}" id="2"]\n${states?'[ext_resource type="Script" path="res://scripts/world/exterior_state_indicator.gd" id="3"]\n':''}\n[node name="${id.split('_').map(s=>s[0].toUpperCase()+s.slice(1)).join('')}" type="Node2D"]\ntexture_filter = 1\ntexture_repeat = 1\nmetadata/definition = ExtResource("1")\n\n[node name="Sprite2D" type="Sprite2D" parent="."]\n${ground||id==='landing_marker_decal'?'z_index = -1\n':''}texture = ExtResource("2")\ncentered = false\noffset = Vector2(${-anchor[0]}, ${-anchor[1]})\n\n[node name="GroundPivot" type="Marker2D" parent="."]\n\n[node name="GridOrigin" type="Marker2D" parent="."]\nposition = Vector2(${record.grid_origin_px.join(', ')})\n\n[node name="InteractionAnchor" type="Marker2D" parent="."]\nposition = Vector2(${interaction.join(', ')})\n\n[node name="ServiceAnchor" type="Marker2D" parent="."]\nposition = Vector2(-40, 40)\n${solid?`\n[node name="Body" type="StaticBody2D" parent="."]\ncollision_layer = 1\ncollision_mask = 0\n\n[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="Body"]\npolygon = ${poly(collision)}\n`:''}${states?'\n[node name="StateIndicator" type="Node2D" parent="."]\nvisible = false\nposition = Vector2(0, -12)\nscript = ExtResource("3")\n':''}`;
  fs.writeFileSync(record.scene_path,scene);
 }
}
const gaps=[
 {concept:'main habitat / research / engineering / emergency shelter',status:'READY',solution:'Reuse the existing small habitat shell for these shared module roles; rooms remain the existing independent cutaway architecture, not a one-to-one exterior blueprint.'},
 {concept:'external pressure door',status:'READY',solution:'Closed doors are embedded in the supplied habitat/airlock artwork; InteractionAnchor reserves an access point. No new vacuum door logic.'},
 {concept:'pressurized connecting passage',status:'MISSING',solution:'Separate tube/corridor PNG is not available; do not imply utility_box is a pressurized corridor. Reserve a clear linkage area for Phase 0.9.'},
 {concept:'open/closed hatch animation',status:'MISSING',solution:'Only closed supplied texture is prepared; no opening/gas/collision toggling is invented.'},
 {concept:'exterior cables and cable supports',status:'MISSING',solution:'Reuse connector/utility box for junctions; continuous cable runs remain an explicit noncritical art gap.'},
 {concept:'transport pallet / packaged ground support',status:'NEEDS_INTEGRATION',solution:'Existing crates, tool cases, canisters and support cargo provide reusable components; no new pallet artwork is essential.'},
 {concept:'airlock approach / safety / navigation / service paths',status:'READY',solution:'Existing beacon, pole light, hazard stripe pad and footpath overlays; labels are Godot controls.'},
 {concept:'water / pressure / monitoring / maintenance equipment',status:'READY',solution:'Tank, sealed ECLSS cabinet, console, sensor and service markers are fictional near-future presentations; no engineering ratings.'}
];
fs.writeFileSync('art/imports/lunar_exterior_library.json',JSON.stringify({schema_version:1,standards_version:'1.0.0',tile_size_px:[64,32],phase:'0.8G1',production_world_changed:false,geometry_policy:'Native full canvases. Existing measured pivots retained. Solid envelopes are declared grid-clearance budgets, not traced silhouettes or certified dimensions.',assets:inventory,gaps},null,2)+'\n');
console.log(JSON.stringify({prefabs:inventory.length,solid:inventory.filter(x=>x.collision_enabled).length,with_optional_states:inventory.filter(x=>x.supports_states).length}));
