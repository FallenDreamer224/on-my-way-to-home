// Production placement from the reviewed G2 plan. Logical cells only; no art edits.
import fs from 'node:fs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const plan=read('resources/data/lunar_base_art_layout.json');
plan.phase='0.9.2';plan.production_world_changed=true;plan.compact_exterior=true;
plan.entrance_only=true;
for(const module of plan.modules){
 module.exterior_parent='airlock_module';
 module.origin=[-10,8];
}
plan.exterior_entry_cell=[-10,11];
plan.external_links=[];
plan.spawn=[-16,11];plan.companion_spawn=[-17,10];
// Preserve the installed world's existing mission perimeter.
plan.mission_area={origin:[-19,-19],size:[39,38]};
// The old small cube duplicated the active hatch and sealed the exterior approach lane.
plan.facades=plan.facades.filter(f=>!['airlock_module','small_habitat_module'].includes(f.id));
Object.assign(plan.room_port_overrides,{
 engineering:{hub:{point:[6,3],threshold:[7,3]}}
});
for(const m of plan.modules)for(const p of m.portals){
 const change=plan.room_port_overrides[m.id]?.[p.id];
 if(change){p.approach=change.point;p.threshold=change.threshold;}
}
// Exterior presentation contains only the base, unchanged lander and tutorial pickups.
plan.equipment=plan.equipment.filter(e=>e.id==='moon_lander');
plan.equipment[0].cell=[-17,13];
plan.equipment.push({id:'airlock_module',cell:[-10,8]});
plan.facades=[];
plan.prepared_access_cells=[];
plan.walkway_cells=[];
plan.sealed_service_cells=[];
plan.pickups={lunar_sample_a:[-17,11],lunar_sample_b:[-18,11],metal_scrap_a:[-18,10],supply_pack_a:[-19,10]};
plan.utility_cable_cells=[];
const occupied=new Set();
// A doorway must not occupy furniture or tie with a station's nearest-target position.
for(const room of read('resources/interiors/room_library.json').rooms){
 const blocked=new Set();for(const p of room.props)for(let y=0;y<p.footprint[1];y++)for(let x=0;x<p.footprint[0];x++)blocked.add([p.cell[0]+x,p.cell[1]+y].join(','));
 const targets=new Set(room.layout.facilities.map(f=>f.point.join(',')));
 for(const door of room.layout.doors){
  const point=plan.room_port_overrides[room.id]?.[door.id]?.point??door.point;
  if(blocked.has(point.join(','))||targets.has(point.join(',')))throw Error('Blocked/ambiguous room approach '+room.id+'/'+door.id);
  targets.add(point.join(','));
 }
}
for(const m of plan.modules.filter(m=>!m.exterior_parent))for(let y=0;y<m.size[1];y++)for(let x=0;x<m.size[0];x++){
 const at=[m.origin[0]+x,m.origin[1]+y];
 if(at[0]< -19||at[0]>19||at[1]< -19||at[1]>18||occupied.has(at.join(',')))throw Error('Module overlap/perimeter violation: '+m.id+' '+at);
 occupied.add(at.join(','));
}
const add=(a,b)=>a.map((n,i)=>n+b[i]);
const endpoint=(m,p)=>{
 const edge=add(m.origin,p.threshold);
 const step=p.threshold[0]===0?[-1,0]:p.threshold[0]===m.size[0]-1?[1,0]:p.threshold[1]===0?[0,-1]:[0,1];
 return{edge,outside:add(edge,step)};
};
const routes=[],seen=new Set(),corridor=new Map();
for(const link of plan.external_links){
 const m=plan.modules.find(t=>t.id===link.from),target=plan.modules.find(t=>t.id===link.to);
 const p={id:link.to,threshold:link.from_port};
 const id=[m.id,target.id].sort().join('/');if(seen.has(id))continue;seen.add(id);
 const other={id:link.from,threshold:link.to_port};
 const start=endpoint(m,p),end=endpoint(target,other),queue=[start.outside],prev=new Map([[start.outside.join(','),null]]);
 if(occupied.has(start.outside.join(','))||occupied.has(end.outside.join(',')))throw Error('Door exits into another hull '+id);
 for(let head=0;head<queue.length;head++){
  const at=queue[head];if(at.join(',')===end.outside.join(','))break;
  for(const step of [[1,0],[0,1],[-1,0],[0,-1]]){
   const next=add(at,step),key=next.join(',');if(next.some(n=>n< -18||n>17)||occupied.has(key)||prev.has(key))continue;
   prev.set(key,at);queue.push(next);
  }
 }
 if(!prev.has(end.outside.join(',')))throw Error('No connection '+id);
 const cells=[];for(let at=end.outside;at;at=prev.get(at.join(',')))cells.push(at);
 cells.reverse();for(const at of cells)corridor.set(at.join(','),at);
 routes.push({id,from:{module:m.id,door:p.id,...start},to:{module:target.id,door:other.id,...end},cells});
}
plan.routes=routes;plan.corridor_cells=[...corridor.values()];
plan.notes=['One compact airlock entrance accesses the nine existing furnished interior scenes. Interior and exterior maps are separate representations.','Only the base entrance, unchanged lander and four tutorial pickups remain outside. Existing interior utilities continue independently.','Terrain kinds, 40x40 surface, existing artwork and simulation are preserved.'];
fs.writeFileSync('resources/data/lunar_outpost_layout.json',JSON.stringify(plan,null,2)+'\n');
fs.writeFileSync('scenes/world/lunar_outpost.tscn',`[gd_scene load_steps=2 format=3]\n\n[ext_resource type="PackedScene" path="res://scenes/exterior/base_g2/lunar_base_assembly.tscn" id="1"]\n\n[node name="LunarOutpost" instance=ExtResource("1")]\nlayout = ${JSON.stringify(plan)}\n`);
console.log(`Production layout: ${plan.modules.length} envelopes, ${routes.length} links, ${corridor.size} passage cells, four retained pickup identities.`);
