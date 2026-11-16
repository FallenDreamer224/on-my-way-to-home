// Check actual native PNG headers, provenance, schema agreement and budget accounting.
import fs from 'node:fs';
import crypto from 'node:crypto';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const check=(ok,why)=>{checks++;if(!ok)throw Error(why);};
let checks=0;
const standards=read('art/asset_standards.json');
const library=read('art/imports/lunar_base_art_library.json');
const structure=read('art/imports/base_structure.json');
const small=read('art/imports/base_g2.json');
const shells=read('art/imports/native_shells.json');
const ledger=read('art/imports/base_generation_ledger.json');
for(const manifest of [library,structure,small,shells]){
 const ids=new Set();
 for(const a of manifest.assets){
  check(!ids.has(a.asset_id),'Duplicate ID '+a.asset_id);ids.add(a.asset_id);
  for(const field of standards.metadata_requirements.all_assets)check(Object.hasOwn(a,field),'Missing '+field+' for '+a.asset_id);
  check(a.standards_version===standards.standards_version,'Standards version '+a.asset_id);
  const bytes=fs.readFileSync(a.runtime_files[0]);
  check(bytes.subarray(0,8).toString('hex')==='89504e470d0a1a0a','PNG signature '+a.asset_id);
  const size=[bytes.readUInt32BE(16),bytes.readUInt32BE(20)];
  check(JSON.stringify(size)===JSON.stringify(a.native_canvas_size_px),'Actual PNG dimensions '+a.asset_id);
  check(hash(a.runtime_files[0])===a.sha256,'Native hash '+a.asset_id);
  for(const source of a.source_files)check(fs.existsSync(source),'Source missing '+source);
  const regions=a.animation.frame_regions;
  check(a.animation.frame_count===1&&regions.length===1,'Static frame count '+a.asset_id);
  check(JSON.stringify(regions[0])===JSON.stringify([0,0,...size]),'Whole native static frame '+a.asset_id);
  if(a.animation.frame_size_px)check(JSON.stringify(a.animation.frame_size_px)===JSON.stringify(size),'Frame canvas '+a.asset_id);
  if(a.generation_id)check(Boolean(a.prompt),'Generation prompt '+a.asset_id);
 }
}
for(const a of small.assets)check(hash(a.source_files[0])===a.sha256,'Byte-identical small source '+a.asset_id);
for(const a of shells.assets)check(hash(a.source_raw)===a.source_sha256&&a.rgb_pixels_modified===0&&!a.native_resampling,'Shell source/processing '+a.asset_id);
check(ledger.generations_used===30&&ledger.remaining_phase_budget===0&&ledger.balance_before-ledger.balance_after===30,'Exact budget');
check(small.used_generations===30&&small.assets.length===13&&library.assets.length===15,'Catalog totals');
const rooms=read('resources/interiors/room_library.json').rooms;
const plan=read('resources/data/lunar_base_art_layout.json');
for(const room of rooms){
 const module=plan.modules.find(m=>m.id===room.id);
 check(module&&JSON.stringify(module.size)===JSON.stringify(room.size_cells),'Room/envelope match '+room.id);
 check(fs.existsSync(room.scene_path),'Room scene '+room.id);
}
console.log(`PASS: ${checks} base JSON/dimension/hash/metadata/budget checks; ${library.assets.length} exterior definitions, ${structure.assets.length} structural PNG records.`);
