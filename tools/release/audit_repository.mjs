// Read-only release audit. Findings contain paths/line numbers, never matched values.
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import {spawnSync} from "node:child_process";
const root=process.cwd();
const out=path.resolve(process.argv[2]||"tests/output/release_d2_5_private/audit.json");
if(!out.startsWith(root+path.sep)) throw Error("Audit output must remain inside project");
const files=[];
function walk(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true})){const p=path.join(dir,e.name);if(e.isSymbolicLink())continue;if(e.isDirectory())walk(p);else if(e.isFile())files.push(p)}}
walk(root);
const rel=p=>path.relative(root,p).split(path.sep).join("/");
const textExtensions=new Set([".gd",".tscn",".tres",".json",".md",".txt",".ps1",".mjs",".cfg",".ini",".toml",".yaml",".yml",".import",".svg",".env",".xml",".csv"]);
const findings=[],rows=[],hashes=new Map();
const checks=[
 ["credential_candidate",/(?:api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password)\s*["']?\s*[:=]\s*["']([^"'\s]{12,})["']/ig],
 ["bearer_candidate",/\bBearer\s+([A-Za-z0-9_.=-]{16,})/ig],
 ["private_key",/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/g],
 ["signed_url",/[?&](?:x-amz-signature|x-goog-signature|access_token|api_key|token)=[^\s"'&]+/ig],
 ["personal_absolute_path",/(?:[A-Z]:[\\/]+Users[\\/]+[^\\/\s"'<>]+|\/home\/[^\/\s"'<>]+|\/Users\/[^\/\s"'<>]+)/ig]
];
function category(p){
 if(p.startsWith(".vscode/")||/(^|\/)(\.env(?:\..*)?|mcp(?:\.local)?\.json|export_credentials\.cfg|.*\.(?:pem|key|pfx|p12))$/i.test(p))return "E";
 if(p.startsWith("builds/"))return "B";
 if(p.startsWith("tests/output/pixelorama_tool/"))return "C";
 if(p.startsWith(".godot/")||p.startsWith("tests/output/")||p.startsWith("art/exports/"))return "D";
 if(p.startsWith("assets/pixellab/source/")||p.startsWith("tools/")||p.startsWith("tests/")||p.startsWith("art/briefs/"))return "C";
 return "A";
}
for(const file of files){
 const p=rel(file),stat=fs.statSync(file),data=fs.readFileSync(file);
 const hash=crypto.createHash("sha256").update(data).digest("hex");
 const row={path:p,bytes:stat.size,sha256:hash,category:category(p)};
 rows.push(row);if(!hashes.has(hash))hashes.set(hash,[]);hashes.get(hash).push(row);
 if(stat.size>8*1024*1024||(!textExtensions.has(path.extname(p).toLowerCase())&&![".gitignore",".gitattributes",".editorconfig"].includes(path.basename(p))))continue;
 let content=data.toString("utf8");if(content.includes("\0"))continue;
 content.split(/\r?\n/).forEach((line,i)=>{
  for(const [kind,pattern] of checks){pattern.lastIndex=0;if(pattern.test(line))findings.push({path:p,line:i+1,kind,masked:"[REDACTED]",category:row.category})}
 });
}
const mainRows=rows.filter(x=>!x.path.startsWith("tests/output/")&&!x.path.startsWith(".godot/"));
const duplicates=[...hashes.values()].map(g=>g.filter(x=>!x.path.startsWith("tests/output/")&&!x.path.startsWith(".godot/"))).filter(g=>g.length>1&&g[0].bytes>0).map(g=>({bytes_each:g[0].bytes,paths:g.map(x=>x.path)}));
const result={schema_version:1,files:rows,findings,duplicates,largest:rows.toSorted((a,b)=>b.bytes-a.bytes).slice(0,30),source_largest:mainRows.toSorted((a,b)=>b.bytes-a.bytes).slice(0,20),physical_bytes:rows.reduce((n,x)=>n+x.bytes,0),source_input_bytes:mainRows.reduce((n,x)=>n+x.bytes,0),git:{present:fs.existsSync(path.join(root,".git")),history_scanned:false},limitations:["Pattern scan is not proof that no secret exists.","Opaque binaries and archives are not decoded for credentials.","There is no committed history when .git is absent."]};
fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,JSON.stringify(result,null,2)+"\n");
const publicFindings=findings.filter(x=>x.category!=="D"&&!x.path.startsWith("tests/output/"));
console.log(JSON.stringify({files:rows.length,source_input_bytes:result.source_input_bytes,findings:findings.length,non_generated_findings:publicFindings,duplicates,source_largest:result.source_largest.map(({path,bytes,category})=>({path,bytes,category}))},null,2));

