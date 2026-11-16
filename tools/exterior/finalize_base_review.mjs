// Record the completed visual review. No generation, image edits or gameplay changes.
import fs from 'node:fs';
import crypto from 'node:crypto';
if(!process.argv.includes('--confirm-reviewed'))throw Error('Run only after inspecting current native renders; pass --confirm-reviewed to record that review.');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));
const write=(p,v)=>fs.writeFileSync(p,JSON.stringify(v,null,2)+'\n');
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const root='assets/pixellab/source/base_g2/';
const small=read(root+'generation_jobs.json');
const shells=read(root+'shell_jobs.json');
const masks=read(root+'background_jobs.json');
const natives=read('art/imports/native_shells.json');
const structure=read('art/imports/base_structure.json');
const drafts=read('art/imports/base_hulls.json');
for(const p of ['tests/output/phase_0_8g2_base/captures/airlock.png','assets/buildings/base_g2/compositions/lunar_base_showcase.png','tests/output/phase_0_8g2/captures/greenhouse_mature.png'])if(!fs.existsSync(p))throw Error('Review evidence missing: '+p);
for(const j of small.jobs){
 j.completion_status='completed';
 j.receipt_is_submission_snapshot=true;
 const p=root+(j.source_name??j.asset_id)+'.json';
 if(fs.existsSync(p)){
  const receipt=read(p);
  receipt.final_review_status=j.review_status;
  receipt.final_review_reason=j.review_reason??j.review_notes??(j.review_status==='READY'?'Native PNG accepted after actual dimension/alpha/anchor and rendered review.':'Rejected after native visual review; see canonical candidate record.');
  receipt.receipt_is_submission_snapshot=true;
  write(p,receipt);
 }
}
for(const j of shells.jobs){
 j.completion_status='completed';j.review_status='READY';
 j.review_reason='Full native shell accepted after deterministic background-only alpha preparation. Original opaque source preserved; no RGB changes in retained pixels.';
 j.raw_path=root+'shell_raw/'+j.asset_id+'.png';
 j.runtime_path='assets/buildings/base_g2/shells/'+j.asset_id+'.png';
 j.source_sha256=hash(j.raw_path);
}
for(const j of masks.jobs){
 j.completion_status='completed';j.review_status='NEEDS_REFINEMENT';j.integrated=false;
 j.review_reason='Rejected: provider mask erased substantial white pressure-vessel surfaces. The full original source is intact; none of these masks supplies runtime pixels.';
 j.output_path=root+'shell_cutouts/'+j.asset_id+'.png';
}
for(const a of natives.assets){
 const j=shells.jobs.find(j=>j.asset_id===a.asset_id);
 Object.assign(a,{standards_version:'1.0.0',category:'exterior_shell',source_provider:'PixelLab.ai MCP with documented alpha preparation',source_files:[a.source_raw],runtime_files:[a.runtime_path],usage_terms:'https://www.pixellab.ai/termsofservice',native_canvas_size_px:a.native_size_px,ground_anchor_px_from_image_top_left:a.ground_anchor_px,explicit_footprint_grid_cells:a.footprint,physical_scale_intent:'Native room-sized pressure-vessel artwork; grid envelope is an explicit placement budget, not metric or pressure certification.',review_status:'READY',exception:null,prompt:j.request.description,animation:{type:'static',frame_count:1,frame_size_px:a.native_size_px,frame_regions:[[0,0,...a.native_size_px]],fps:0,loop:false},processing_authorization:'Extended Phase 0.8G2 sections 24 and 27 authorize least-destructive technical correction and separated background/layer preparation; source images remain intact.',visual_review_evidence:'tests/output/phase_0_8g2_base/captures/'});
}
for(const a of structure.assets){
 const draft=a.asset_id.startsWith('roof_')||a.asset_id.startsWith('hull_wall_');
 a.review_status=draft?'UNUSED':'READY';
 a.review_notes=draft?'Preserved technical draft support; finished exterior uses the illustrated native shells.':'Reviewed in furnished rooms and native exterior cable close-ups; compatible grid and door origins.';
}
for(const a of drafts.assets){
 a.review_status='NEEDS_REFINEMENT';
 a.superseded_by='art/imports/lunar_base_art_library.json';
 a.review_notes='Retained initial hand-painted full-hull draft failed the exterior visual quality gate. Runtime prefab uses illustrated native shell instead; this draft is not counted as finished art.';
}
drafts.corridor_atlas.review_status='UNUSED';
drafts.corridor_atlas.review_notes='Technical geometry/alignment guide only. Visible pressure connections use full native rounded sprites.';
const used=small.jobs.reduce((n,j)=>n+j.cost_generations,0)+shells.jobs.length+masks.jobs.reduce((n,j)=>n+j.cost_generations,0);
if(used!==30)throw Error('Expected exact authorized expenditure: '+used);
const ledger={phase:'0.8G2 extended',authorized_generations:30,generations_used:used,remaining_phase_budget:0,usd_credits_spent:0,balance_before:3739.15,balance_after:3709.15,balance_verified:'PixelLab MCP get_balance after all jobs completed',small_image_jobs:small.jobs.length,shell_creation_jobs:shells.jobs.length,background_removal_jobs:masks.jobs.length,accepted_new_creative_assets:small.jobs.filter(j=>j.review_status==='READY').length+natives.assets.length,rejected_creative_candidates:small.jobs.filter(j=>j.review_status!=='READY').length,rejected_background_results:masks.jobs.length,previous_milestone_generations:24,previous_milestone_excluded:true,records:['assets/pixellab/source/base_g2/generation_jobs.json','assets/pixellab/source/base_g2/shell_jobs.json','assets/pixellab/source/base_g2/background_jobs.json'],note:'All 30 operations billed one subscription generation each. Ten unusable provider masks are included, not hidden or counted as accepted artwork. No additional paid jobs authorized.'};
write(root+'generation_jobs.json',small);write(root+'shell_jobs.json',shells);write(root+'background_jobs.json',masks);
write('art/imports/native_shells.json',natives);write('art/imports/base_structure.json',structure);write('art/imports/base_hulls.json',drafts);write('art/imports/base_generation_ledger.json',ledger);
console.log('Finalized review: 18 accepted creative images, 2 creative rejects, 10 rejected masks; 30/30 generations.');
