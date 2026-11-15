// Fetch only the official Windows release entry from Godot's multi-platform ZIP.
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import crypto from "node:crypto";
const archive="https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz";
const total=1281349702;
const output=path.resolve("tests/output/release_d3_private/templates");
fs.mkdirSync(output,{recursive:true});
async function range(start,end){
 const response=await fetch(archive,{headers:{Range:`bytes=${start}-${end}`,"Accept-Encoding":"identity","User-Agent":"On-My-Way-to-Home-release"}});
 if(response.status!==206){await response.body?.cancel();throw Error("Official archive server did not support partial transfer: HTTP "+response.status)}
 const bytes=Buffer.from(await response.arrayBuffer());
 if(bytes.length!==end-start+1)throw Error("Range length mismatch");
 return bytes;
}
const tailStart=total-131072,tail=await range(tailStart,total-1);
let eocd=-1;for(let i=tail.length-22;i>=0;i--)if(tail.readUInt32LE(i)===0x06054b50){eocd=i;break}
if(eocd<0)throw Error("Missing ZIP central directory");
const centralSize=tail.readUInt32LE(eocd+12),centralOffset=tail.readUInt32LE(eocd+16);
const central=centralOffset>=tailStart?tail.subarray(centralOffset-tailStart,centralOffset-tailStart+centralSize):await range(centralOffset,centralOffset+centralSize-1);
const entries=[];
for(let at=0;at<central.length;){
 if(central.readUInt32LE(at)!==0x02014b50)throw Error("Invalid ZIP directory");
 const nameLen=central.readUInt16LE(at+28),extra=central.readUInt16LE(at+30),comment=central.readUInt16LE(at+32);
 entries.push({name:central.subarray(at+46,at+46+nameLen).toString(),method:central.readUInt16LE(at+10),crc:central.readUInt32LE(at+16),compressed:central.readUInt32LE(at+20),size:central.readUInt32LE(at+24),offset:central.readUInt32LE(at+42)});
 at+=46+nameLen+extra+comment;
}
const table=Array.from({length:256},(_,n)=>{for(let j=0;j<8;j++)n=(n&1)?0xedb88320^(n>>>1):n>>>1;return n>>>0});
const records=[];
for(const filename of ["windows_release_x86_64.exe","version.txt"]){
 const entry=entries.find(e=>e.name==="templates/"+filename||e.name===filename);
 if(!entry)throw Error("Official ZIP lacks "+filename);
 const header=await range(entry.offset,entry.offset+29);
 if(header.readUInt32LE(0)!==0x04034b50)throw Error("Invalid ZIP local header");
 const start=entry.offset+30+header.readUInt16LE(26)+header.readUInt16LE(28);
 const compressed=await range(start,start+entry.compressed-1);
 const data=entry.method===8?zlib.inflateRawSync(compressed):compressed;
 let crc=0xffffffff;for(const n of data)crc=table[(crc^n)&255]^(crc>>>8);crc=(crc^0xffffffff)>>>0;
 if(data.length!==entry.size||crc!==entry.crc)throw Error("Official entry size/CRC verification failed");
 fs.writeFileSync(path.join(output,filename),data);
 const record={file:filename,bytes:data.length,crc32:crc.toString(16),sha256:crypto.createHash("sha256").update(data).digest("hex"),source:archive,archive_entry:entry.name,method:"HTTPS byte ranges from official archive; ZIP size/CRC verified; full archive digest not asserted"};
 records.push(record);console.log(filename+": "+data.length+" bytes; CRC verified");
}
fs.writeFileSync(path.join(output,"provenance.json"),JSON.stringify(records,null,2)+"\n");
console.log("Version: "+fs.readFileSync(path.join(output,"version.txt"),"utf8").trim());

