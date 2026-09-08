// Local QA: actual ReportPage, installed production print DOM and PDF exporter.
const fs = require('fs');
const path = require('path');
const http = require('http');
const { chromium } = require('playwright');
const [webRoot, outputRoot, chrome] = process.argv.slice(2);
const root = path.resolve(webRoot);
fs.mkdirSync(outputRoot, {recursive:true});
const mime = {'.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.html':'text/html','.ttf':'font/ttf','.png':'image/png'};
const server = http.createServer((req,res)=>{
  const file=path.resolve(root,'.'+decodeURIComponent(new URL(req.url,'http://localhost').pathname));
  if(!file.startsWith(root+path.sep)&&file!==root){res.writeHead(403).end();return;}
  const target=file===root?path.join(root,'index.html'):file;
  if(!fs.existsSync(target)){res.writeHead(404).end();return;}
  res.setHeader('Content-Type',mime[path.extname(target)]||'application/octet-stream');
  fs.createReadStream(target).pipe(res);
});
(async()=>{
  await new Promise(r=>server.listen(0,'127.0.0.1',r));
  const url=`http://127.0.0.1:${server.address().port}/`;
  const browser=await chromium.launch({executablePath:chrome,headless:true});
  const records=[];
  try{
    for(const mode of ['known','unknown']) for(const width of [1440,390,360]){
      const height=width===1440?900:844;
      const page=await browser.newPage({viewport:{width,height},deviceScaleFactor:1,timezoneId:'Asia/Bangkok'});
      const errors=[],requests=[];
      page.on('pageerror',e=>errors.push(String(e)));
      page.on('request',r=>requests.push({method:r.method(),url:r.url()}));
      await page.goto(url+'?mode='+mode,{waitUntil:'networkidle'});
      await page.waitForFunction(()=>window.__or5rDocument&&window.__thaiBetaCaptureScrollMetrics&&document.querySelector('#knowme-print-root'));
      if(mode==='known') await page.waitForFunction(()=>document.querySelector('#knowme-print-root img')?.src.startsWith('data:image/png'));
      await page.waitForTimeout(1500);
      const document=await page.evaluate(()=>JSON.parse(window.__or5rDocument));
      const stem=`${mode}-${width}`;
      const write=(name,data)=>fs.writeFileSync(path.join(outputRoot,name),data);
      write(stem+'-canonical.json',JSON.stringify(document,null,2)+'\n');
      const dom=await page.locator('#knowme-print-root').evaluate(e=>({html:e.outerHTML,sections:[...e.querySelectorAll('.report-section')].map(s=>({title:s.querySelector('h2')?.textContent,paragraphs:[...s.querySelectorAll('p')].map(p=>p.textContent)})),images:[...e.querySelectorAll('img')].map(i=>i.src)}));
      write(stem+'-print-dom.html',dom.html);
      const projected=dom.sections.map(s=>({title:s.title,paragraphs:s.paragraphs}));
      const expected=document.sections.map(s=>({title:s.title,paragraphs:s.paragraphs}));
      if(JSON.stringify(projected)!==JSON.stringify(expected))throw Error(stem+' DOM canonical mismatch');
      if(mode==='unknown'&&(!document.infographicOmitted||dom.images.length))throw Error('Unknown infographic leak');
      if(mode==='known'&&width!==1440){
        write(stem+'-infographic.png',Buffer.from(dom.images[0].split(',')[1],'base64'));
      }
      const metrics=await page.evaluate(()=>window.__thaiBetaCaptureScrollMetrics);
      const steps=Math.max(1,Math.ceil(metrics.maxScroll/(metrics.clientHeight*0.78)));
      const tiles=[];
      for(let i=0;i<=steps;i++){
        await page.evaluate(f=>window.__setThaiBetaCaptureScrollFraction(f),i/steps);
        await page.waitForTimeout(180);
        const actual=await page.evaluate(()=>window.__thaiBetaCaptureScrollMetrics);
        const file=`${stem}-web-${String(i+1).padStart(2,'0')}.png`;
        await page.screenshot({path:path.join(outputRoot,file)});
        const error=Math.abs(actual.scrollTop-actual.maxScroll*i/steps);
        if(error>Math.max(2,actual.maxScroll*.005))throw Error('scroll geometry mismatch');
        tiles.push({file,...actual,requestedFraction:i/steps,positionError:error});
      }
      if(width===390){
        await page.evaluate(()=>{window.__or5rExportPdf();});
        await page.waitForFunction(()=>window.__or5rPdfBase64||window.__or5rPdfError,{},{timeout:120000});
        const pdf=await page.evaluate(()=>({data:window.__or5rPdfBase64,error:window.__or5rPdfError}));
        if(pdf.error)throw Error(pdf.error);
        write(mode+'-dedicated.pdf',Buffer.from(pdf.data,'base64'));
        await page.pdf({path:path.join(outputRoot,mode+'-browser-print.pdf'),printBackground:true,preferCSSPageSize:true,displayHeaderFooter:false});
      }
      if(errors.length)throw Error(JSON.stringify(errors));
      if(requests.some(r=>r.method!=='GET'))throw Error('Unexpected non-read network request');
      records.push({mode,width,height,canonicalParagraphs:document.sections.reduce((n,s)=>n+s.paragraphs.length,0),canonicalSections:document.sections.length,domParity:'EXACT',infographicOmitted:document.infographicOmitted,tiles,errors,requests});
      write('WEB_CAPTURE_VALIDATION.json',JSON.stringify({cases:records,status:'CAPTURED_NOT_YET_VISUALLY_REVIEWED'},null,2)+'\n');
      console.log(stem,tiles.length,'tiles; canonical/print DOM exact');
      await page.close();
    }
  }finally{await browser.close();server.close();}
})().catch(e=>{console.error(e);server.close();process.exitCode=1;});
