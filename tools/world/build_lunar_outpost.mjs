// Production placement from the reviewed G2 plan. Logical cells only; no art edits.
import fs from 'node:fs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const plan=read('resources/data/lunar_base_art_layout.json');
plan.phase='0.9';plan.production_world_changed=true;
plan.spawn=[-16,11];plan.companion_spawn=[-17,10];
// The reviewed eastern shelter reaches column 19, inside the unchanged 40x40 surface.
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
// Keep a free lane inside the existing EVA perimeter beside the power and landing equipment.
for(const e of plan.equipment)if(['solar_panel_array','battery_power_unit','radiator_bank','utility_oxygen_tank','small_connector_utility_box','moon_lander'].includes(e.id))e.cell[0]+=2;
const equipmentCells={utility_oxygen_tank:[-16,-2],storage_crate_large:[7,-15],support_cargo_container:[10,-15],tool_case:[13,-15]};
for(const e of plan.equipment)if(equipmentCells[e.id])e.cell=equipmentCells[e.id];
// One authored outer-rim access corner joins the greenhouse maintenance lane.
plan.prepared_access_cells=[[13,-3],[-5,16],[-4,17],[-3,18]];
plan.walkway_cells=[[13,-3],[-6,16],[-5,16],[-5,17],[-4,17],[-4,18],[-3,18],[-2,18]];
plan.sealed_service_cells=[[-5,3],[4,3],[-4,7],[-3,7],[0,7],[1,7],[2,7],[3,7]];
plan.pickups={lunar_sample_a:[-17,11],lunar_sample_b:[-18,11],metal_scrap_a:[-18,10],supply_pack_a:[-19,10]};
const cable=new Map();
const cableLink=(a,b)=>{let at=[...a];cable.set(at.join(','),[...at]);for(const axis of [1,0])while(at[axis]!==b[axis]){at[axis]+=Math.sign(b[axis]-at[axis]);cable.set(at.join(','),[...at]);}};
const junction=plan.equipment.find(e=>e.id==='small_connector_utility_box').cell;
for(const id of ['solar_panel_array','battery_power_unit','radiator_bank','utility_oxygen_tank'])cableLink(junction,plan.equipment.find(e=>e.id===id).cell);
cableLink(junction,[-13,10]);
plan.utility_cable_cells=[...cable.values()];
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
for(const m of plan.modules)for(let y=0;y<m.size[1];y++)for(let x=0;x<m.size[0];x++){
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
for(const m of plan.modules)for(const p of m.portals){
 const target=plan.modules.find(t=>t.id===p.destination);if(!target)continue;
 const id=[m.id,target.id].sort().join('/');if(seen.has(id))continue;seen.add(id);
 const other=target.portals.find(q=>q.destination===m.id);if(!other)throw Error('Missing reciprocal door '+id);
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
plan.notes=['Production Moon placement using existing native art and furnished room scenes.','All nine reviewed G2 module origins/sizes are retained. The static mission area includes column 19 on the existing surface for the eastern shelter; safety logic remains active.','Power/lander equipment moves two columns inward for perimeter clearance. The old duplicate cube facade is omitted to leave a clear exterior approach.','Original terrain kinds, map dimensions and source Resources are preserved. Runtime occupancy and local access lanes are per-session.','Spawn and four retained pickup identities are staged beside the existing lander, outside shell overhang.','No full-base PNG, preview controls, disabled EVA policy or new simulation is used in production.'];
fs.writeFileSync('resources/data/lunar_outpost_layout.json',JSON.stringify(plan,null,2)+'\n');
fs.writeFileSync('scenes/world/lunar_outpost.tscn',`[gd_scene load_steps=2 format=3]\n\n[ext_resource type="PackedScene" path="res://scenes/exterior/base_g2/lunar_base_assembly.tscn" id="1"]\n\n[node name="LunarOutpost" instance=ExtResource("1")]\nlayout = ${JSON.stringify(plan)}\n`);
console.log(`Production layout: ${plan.modules.length} envelopes, ${routes.length} links, ${corridor.size} passage cells, four retained pickup identities.`);
