import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
const root=process.cwd(), out=path.resolve("tests/output/release_d2_5_private");
fs.mkdirSync(out,{recursive:true});
const probe=path.join(out,"ignore_probe");
fs.mkdirSync(probe,{recursive:true});
if(!fs.existsSync(path.join(probe,".git"))){
 const r=spawnSync("git",["-C",probe,"init","-q"]);if(r.status)throw Error("Cannot create isolated ignore probe");
}
fs.copyFileSync(".gitignore",path.join(probe,".gitignore"));
const files=[];
function walk(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){if(e.isSymbolicLink())continue;const p=path.join(dir,e.name);if(e.isDirectory())walk(p);else files.push(path.relative(root,p).split(path.sep).join("/"))}}
walk(root);
const r=spawnSync("git",["-C",probe,"-c","core.excludesFile=NUL","check-ignore","--no-index","--stdin","-z"],{input:files.join("\0")+"\0",encoding:"utf8"});
if(![0,1].includes(r.status))throw Error("git check-ignore failed");
const ignored=new Set(r.stdout.split("\0").filter(Boolean));
const included=files.filter(p=>!ignored.has(p)).map(p=>({path:p,bytes:fs.statSync(p).size}));
const result={schema_version:1,kind:"prospective uncompressed Git input; no source repository/index/history created",included_bytes:included.reduce((s,x)=>s+x.bytes,0),included_files:included.length,excluded_files:ignored.size,largest_included:included.toSorted((a,b)=>b.bytes-a.bytes).slice(0,15),files:included};
fs.writeFileSync(path.join(out,"public_manifest.json"),JSON.stringify(result,null,2)+"\n");
console.log(JSON.stringify({included_bytes:result.included_bytes,included_files:included.length,excluded_files:ignored.size,largest:result.largest_included},null,2));

