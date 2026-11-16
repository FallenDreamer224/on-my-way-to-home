import fs from 'node:fs';
import path from 'node:path';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const write=(p,t)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,t);};
const vec=p=>`Vector2i(${p.join(', ')})`,poly=p=>`PackedVector2Array(${p.flat().join(', ')})`,q=JSON.stringify;
const project=(x,y)=>[(x-y)*32,(x+y)*16];
const hulls=read('art/imports/base_hulls.json');
if(fs.existsSync('art/imports/native_shells.json')){
 const shells=read('art/imports/native_shells.json').assets;
 const creation=read('assets/pixellab/source/base_g2/shell_jobs.json').jobs;
 const mapping={hub:'shell_core',living:'shell_habitat',engineering:'shell_habitat',health_lab:'shell_habitat',crew_airlock:'shell_service',equipment_lock:'shell_service',cargo:'shell_service',greenhouse:'shell_greenhouse',shelter:'shell_shelter'};
 for(const a of hulls.assets){
  const shell=shells.find(s=>s.asset_id===mapping[a.asset_id.replace('hull_','')]);
  const job=creation.find(j=>j.asset_id===shell.asset_id);
  a.native_shell=true;a.depth_strips=shell.depth_strips;
  a.runtime_files=[shell.runtime_path];a.native_canvas_size_px=shell.native_size_px;a.visible_bounds_px=shell.bounds_px;a.ground_anchor_px_from_image_top_left=shell.ground_anchor_px;
  a.animation={type:'static',frame_count:1,frame_size_px:shell.native_size_px,frame_regions:[[0,0,...shell.native_size_px]],fps:0,loop:false};
  a.review_status=shell.review_status;a.usage_terms='https://www.pixellab.ai/termsofservice';
  delete a.roof_path;
  a.source_files=[shell.source_raw,'tools/exterior/key_shell_background.gd','resources/data/lunar_base_art_layout.json'];a.source_provider='PixelLab.ai MCP with nondestructive alpha preparation';a.generation_id=job.job_id;a.prompt=job.request.description;a.sha256=shell.sha256;
  a.processing={recipe:shell.processing_recipe,source_sha256:shell.source_sha256,rgb_pixels_modified:0,resampling:false,provider_background_masks_used:false};
  a.physical_scale_intent='Native full-size pressure-shell art. Room-sized logical envelope is a conservative placement budget distinct from canvas/overhang; source feet/foreground datum measured, no sprite scaling.';
 }
}
const equipment=read('art/imports/base_g2.json').assets.filter(a=>a.category==='exterior_connection');
const records=[];
for(const a of [...hulls.assets,...equipment]){
 const size=a.explicit_footprint_grid_cells??a.footprint_grid_cells;
 const [w,d]=size,front=project(w-.5,d-.5),grid=front.map(n=>-n);
 const cells=[];for(let y=0;y<d;y++)for(let x=0;x<w;x++)cells.push([x,y]);
 const shape=[project(-.5,-.5),project(w-.5,-.5),project(w-.5,d-.5),project(-.5,d-.5)].map(p=>p.map((n,i)=>n-front[i]));
 const solid=a.category==='modular_hull_composite';
 const resource=`resources/exterior/base_g2/${a.asset_id}.tres`,scene=`scenes/exterior/base_g2/${a.asset_id}.tscn`;
 write(resource,`[gd_resource type="Resource" script_class="ExteriorAssetDefinition" load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://scripts/world/exterior_asset_definition.gd" id="1"]\n[ext_resource type="Texture2D" path="res://${a.runtime_files[0]}" id="2"]\n\n[resource]\nscript = ExtResource("1")\nasset_id = &${q(a.asset_id)}\ndisplay_name = ${q(a.asset_id.replaceAll('_',' '))}\ncategory = &${q(a.category)}\ntexture = ExtResource("2")\nnative_size = ${vec(a.native_canvas_size_px)}\nopaque_bounds = Rect2i(${a.visible_bounds_px.join(', ')})\nground_anchor = ${vec(a.ground_anchor_px_from_image_top_left)}\nfootprint_size = ${vec(size)}\noccupied_cells = Array[Vector2i]([${cells.map(vec).join(', ')}])\nnavigation_reserved_cells = Array[Vector2i]([${cells.map(vec).join(', ')}])\ngrid_origin = ${vec(grid)}\nfootprint_polygon = ${poly(shape)}\ncollision_polygon = ${poly(solid?shape:[])}\ninteraction_anchor = Vector2i(0, 40)\nservice_anchor = Vector2i(-40, 40)\ncollision_enabled = ${solid}\nprovenance_manifest = ${q(a.category==='modular_hull_composite'?'res://art/imports/lunar_base_art_library.json':'res://art/imports/base_g2.json')}\nsource_files = PackedStringArray(${a.source_files.map(q).join(', ')})\n`);
 write(scene,`[gd_scene load_steps=3 format=3]\n\n[ext_resource type="Resource" path="res://${resource}" id="1"]\n[ext_resource type="Texture2D" path="res://${a.runtime_files[0]}" id="2"]\n\n[node name="${a.asset_id}" type="Node2D"]\ntexture_filter = 1\nmetadata/definition = ExtResource("1")\n\n[node name="Sprite2D" type="Sprite2D" parent="."]\ntexture = ExtResource("2")\ncentered = false\noffset = Vector2(${-a.ground_anchor_px_from_image_top_left[0]}, ${-a.ground_anchor_px_from_image_top_left[1]})\n\n[node name="GridOrigin" type="Marker2D" parent="."]\nposition = Vector2(${grid.join(', ')})\n\n[node name="InteractionAnchor" type="Marker2D" parent="."]\nposition = Vector2(0, 40)\n`);
 if(solid&&a.native_shell){
  let native=fs.readFileSync(scene,'utf8').replace('texture_filter = 1','texture_filter = 1\ny_sort_enabled = true').replace('[node name="Sprite2D" type="Sprite2D" parent="."]','[node name="Sprite2D" type="Sprite2D" parent="."]\nvisible = false');
  native+='\n[node name="Roof" type="Node2D" parent="."]\ny_sort_enabled = true\n';
  for(let i=0;i<a.depth_strips.length;i++){
   const strip=a.depth_strips[i],r=strip.region,p=strip.depth_datum_px,anchor=a.ground_anchor_px_from_image_top_left;
   native+=`\n[node name="Depth_${i}" type="Sprite2D" parent="Roof"]\nposition = Vector2(${p[0]-anchor[0]}, ${p[1]-anchor[1]})\ntexture = ExtResource("2")\ncentered = false\noffset = Vector2(${-r[2]/2}, ${-p[1]})\nregion_enabled = true\nregion_rect = Rect2(${r.join(', ')})\n`;
  }
  native+=`\n[node name="Body" type="StaticBody2D" parent="."]\ncollision_layer = 2\ncollision_mask = 1\n\n[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="Body"]\npolygon = ${poly(shape)}\n`;
  write(scene,native);
 }else if(solid){
  let native=fs.readFileSync(scene,'utf8').replace('load_steps=3','load_steps=6');
  native=native.replace('[node name=',`[ext_resource type="Texture2D" path="res://${a.roof_path}" id="3"]\n[ext_resource type="Texture2D" path="res://assets/environment/interiors_g2/structure/hull_wall_${a.hull_height_px}_se.png" id="4"]\n[ext_resource type="Texture2D" path="res://assets/environment/interiors_g2/structure/hull_wall_${a.hull_height_px}_sw.png" id="5"]\n\n[node name=`);
  native=native.replace('texture_filter = 1','texture_filter = 1\ny_sort_enabled = true').replace('[node name="Sprite2D" type="Sprite2D" parent="."]','[node name="Sprite2D" type="Sprite2D" parent="."]\nvisible = false');
  const origin=a.ground_anchor_px_from_image_top_left.map((n,i)=>n-front[i]);
  native+=`\n[node name="Roof" type="Sprite2D" parent="."]\nposition = Vector2(${-front[0]}, ${-front[1]})\ntexture = ExtResource("3")\ncentered = false\noffset = Vector2(${-origin[0]}, ${-origin[1]})\n`;
  for(const [axis,length,tex,anchor]of [['i',w,4,[8,a.hull_height_px+16]],['j',d,5,[40,a.hull_height_px+16]]])for(let k=0;k<length;k++){
   const at=axis==='i'?project(k-.5,d-.5):project(w-.5,k-.5),end=axis==='i'?[32,16]:[-32,16];
   native+=`\n[node name="Wall_${axis}_${k}" type="Sprite2D" parent="."]\nposition = Vector2(${at[0]-front[0]+end[0]}, ${at[1]-front[1]+end[1]})\ntexture = ExtResource("${tex}")\ncentered = false\noffset = Vector2(${-anchor[0]-end[0]}, ${-anchor[1]-end[1]})\n`;
  }
  native+=`\n[node name="Body" type="StaticBody2D" parent="."]\ncollision_layer = 2\ncollision_mask = 1\n\n[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="Body"]\npolygon = ${poly(shape)}\n`;
  write(scene,native);
 }
 records.push({...a,scene_path:scene,resource_path:resource,grid_origin_px:grid,collision_policy:solid?'Declared envelope reserves the original room grid; native shared-texture depth regions sort with actors. Footprints are conservative game placement budgets, not pixel-traced or certified physical volumes.':'Independent prepared sprite; scene binding owns interaction and collision.'});
}
let atlas='[gd_resource type="TileSet" load_steps=3 format=3]\n\n[ext_resource type="Texture2D" path="res://assets/buildings/base_g2/passage_atlas.png" id="1"]\n\n[sub_resource type="TileSetAtlasSource" id="Source"]\ntexture = ExtResource("1")\ntexture_region_size = Vector2i(64, 112)\n';
for(let i=0;i<16;i++)atlas+=`${i%4}:${Math.floor(i/4)}/0 = 0\n${i%4}:${Math.floor(i/4)}/0/texture_origin = Vector2i(0, -40)\n`;
atlas+='\n[resource]\ntile_shape = 1\ntile_layout = 5\ntile_size = Vector2i(64, 32)\nsources/0 = SubResource("Source")\n';
write('resources/exterior/base_g2/pressure_passages.tres',atlas);
write('art/imports/lunar_base_art_library.json',JSON.stringify({phase:'0.8G2 extended',assets:records,corridor_atlas:hulls.corridor_atlas},null,2)+'\n');
const plan=read('resources/data/lunar_base_art_layout.json');
write('scenes/exterior/base_g2/lunar_base_assembly.tscn',`[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://scripts/world/lunar_base_assembly.gd" id="1"]\n\n[node name="LunarBaseAssembly" type="Node2D"]\ntexture_filter = 1\ny_sort_enabled = true\nscript = ExtResource("1")\nlayout = ${JSON.stringify(plan)}\n`);
console.log(`Prepared ${records.length} native exterior Resources/prefabs and batched pressure-passage TileSet.`);
