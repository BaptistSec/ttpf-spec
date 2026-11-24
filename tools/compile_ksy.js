const fs=require('fs'),K=require('kaitai-struct-compiler'),y=require('js-yaml');
K.compile('python', y.load(fs.readFileSync(process.argv[2],'utf8')), null, false).then(r=>{
 for (const [n,c] of Object.entries(r)) { fs.writeFileSync(process.argv[3]+'/'+n, c); console.log('wrote',n); }
}).catch(e=>{console.error('COMPILE ERROR',e);process.exit(1)});
