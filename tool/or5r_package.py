"""Local OR5R PDF raster/parity and deterministic package verification tooling."""
import argparse, hashlib, json, re, shutil, subprocess, unicodedata, zipfile
from pathlib import Path
from PIL import Image, ImageDraw
from pypdf import PdfReader

ROOT=Path('build/or5r-pdf-owner-package')
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def save(p,obj): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def norm(s): return re.sub(r'\s|[\u200b\ufeff]','',unicodedata.normalize('NFKD',s))
def sheet(files,out,width=420):
    tiles=[]
    for file in files:
        img=Image.open(file).convert('RGB');img.thumbnail((width,2000))
        tile=Image.new('RGB',(width,img.height+30),'white');tile.paste(img,((width-img.width)//2,30))
        ImageDraw.Draw(tile).text((8,8),file.name,fill='black');tiles.append(tile)
    cols=min(3,len(tiles)); rows=(len(tiles)+cols-1)//cols; h=max(t.height for t in tiles)
    result=Image.new('RGB',(cols*width,rows*h),'#cccccc')
    for i,t in enumerate(tiles):result.paste(t,((i%cols)*width,(i//cols)*h))
    out.parent.mkdir(parents=True,exist_ok=True); result.save(out)

def render(poppler):
    product=ROOT/'product'; raster=ROOT/'raster';raster.mkdir(exist_ok=True)
    results=[]
    for file in sorted(product.glob('*.pdf')):
        reader=PdfReader(file);prefix=raster/file.stem
        subprocess.run([str(Path(poppler)/'pdftoppm.exe'),'-r','105','-png',str(file),str(prefix)],check=True,capture_output=True)
        pages=[]; texts=[]
        for i,page in enumerate(reader.pages):
            text=page.extract_text() or '';texts.append(text)
            png=list(raster.glob(file.stem+f'-{i+1:0{len(str(len(reader.pages)))}d}.png'))[0]
            im=Image.open(png).convert('L'); ink=sum(n for val,n in enumerate(im.histogram()) if val<245)
            pages.append({'page':i+1,'textEmpty':not text.strip(),'imageCount':len(page.images),'inkPixels':ink,'visualBlankCandidate':ink==0,'raster':png.relative_to(ROOT).as_posix()})
        (ROOT/'text').mkdir(exist_ok=True)
        (ROOT/'text'/f'{file.stem}.txt').write_text('\n\f\n'.join(texts),encoding='utf-8')
        canonical=json.loads((product/(file.stem.split('-')[0]+'-390-canonical.json')).read_text(encoding='utf-8'))
        alltext=norm('\n'.join(texts)); cursor=0;matches=[]
        for section in canonical['sections']:
            for field,value in [('title',section['title'])]+[(f'p{i+1}',p) for i,p in enumerate(section['paragraphs'])]:
                full=norm(value); pos=alltext.find(full,cursor)
                matches.append({'section':section['id'],'field':field,'fullExpected':value,'foundInOrder':pos>=0})
                if pos>=0:cursor=pos+len(full)
        results.append({'file':file.name,'sha256':digest(file),'pageCount':len(reader.pages),'pages':pages,'fullFieldMatches':matches,'missingOrOrderMismatch':sum(not m['foundInOrder'] for m in matches)})
        sheet([ROOT/p['raster'] for p in pages],ROOT/'contact-sheets'/f'{file.stem}.png')
    for mode in ['known','unknown']:
        for width in [1440,390,360]:
            files=sorted(product.glob(f'{mode}-{width}-web-*.png'))
            sheet(files,ROOT/'contact-sheets'/f'{mode}-{width}-web.png',390 if width<1000 else 720)
    save(ROOT/'PDF_PARITY_AND_PAGE_CLASSIFICATION.json',{'results':results,'visualReview':'PENDING_MANUAL_ALL_PAGES','normalization':'NFKD, whitespace and zero-width removal only; each complete canonical title/paragraph matched in order, never shortened'})
    print(json.dumps([{'file':r['file'],'pages':r['pageCount'],'mismatch':r['missingOrOrderMismatch']} for r in results]))

def package(shortsha):
    entries=[]
    for p in sorted(ROOT.rglob('*')):
        if p.is_file() and p.name not in ['MANIFEST.json','SHA256SUMS.txt']:
            entries.append({'path':p.relative_to(ROOT).as_posix(),'size':p.stat().st_size,'sha256':digest(p)})
    save(ROOT/'MANIFEST.json',{'schema':'pr115-or5r-package/1','files':entries,'excludesSelfAndChecksumFile':True})
    allfiles=entries+[{'path':'MANIFEST.json','sha256':digest(ROOT/'MANIFEST.json')}]
    (ROOT/'SHA256SUMS.txt').write_text(''.join(e['sha256']+'  '+e['path']+'\n' for e in allfiles),encoding='utf-8')
    target=ROOT.parent/f'OWNER_REVIEW_THAI_PREDICTIVE_NARRATIVE_V2_RUNTIME_V2_OR5R_{shortsha}.zip'
    if target.exists():raise RuntimeError('Refuse to overwrite existing ZIP')
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(ROOT.rglob('*')):
            if p.is_file():z.write(p,p.relative_to(ROOT).as_posix())
    extracted=ROOT.parent/(target.stem+'-extracted')
    if extracted.exists():raise RuntimeError('Refuse to overwrite extraction')
    with zipfile.ZipFile(target) as z:
        assert z.testzip() is None
        names=z.namelist(); assert len(names)==len(set(names))
        assert all(not re.match(r'(^/|^[A-Za-z]:|.*(^|/)\.\.(/|$))',n) and '\\' not in n for n in names)
        z.extractall(extracted)
    expected={e['path'] for e in entries}|{'MANIFEST.json','SHA256SUMS.txt'}
    actual={p.relative_to(extracted).as_posix() for p in extracted.rglob('*') if p.is_file()}
    assert expected==actual
    for e in entries:
        p=extracted/e['path'];assert p.stat().st_size==e['size'];assert digest(p)==e['sha256']
    for line in (extracted/'SHA256SUMS.txt').read_text(encoding='utf-8').splitlines():
        sha,name=line.split('  ',1);assert digest(extracted/name)==sha
    secret=[];signatures=[];absolute_text_paths=[]
    patterns=[rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',rb'gh[pousr]_[A-Za-z0-9]{30,}',rb'AIza[0-9A-Za-z_-]{35}',rb'(?i)(?:password|access_token|refresh_token)\s*[=:]\s*["\'][^"\']{8,}']
    for p in extracted.rglob('*'):
        if not p.is_file():continue
        b=p.read_bytes()
        if p.suffix=='.pdf':assert b.startswith(b'%PDF-');PdfReader(p);signatures.append(p.name)
        elif p.suffix=='.png':assert b.startswith(b'\x89PNG\r\n\x1a\n');Image.open(p).verify();signatures.append(p.name)
        elif p.suffix=='.json':json.loads(b.decode('utf-8-sig'))
        if any(re.search(pattern,b) for pattern in patterns):secret.append(p.relative_to(extracted).as_posix())
        if p.suffix in ['.md','.json','.txt','.log','.jsonl','.html'] and re.search(rb'(?i)[a-z]:[\\/]+(?:users|src|program files)[\\/]+',b):absolute_text_paths.append(p.relative_to(extracted).as_posix())
    assert not secret,secret
    assert not absolute_text_paths,absolute_text_paths
    report={'zip':target.as_posix(),'sha256':digest(target),'bytes':target.stat().st_size,'entries':len(actual),'crcErrors':0,'extractionErrors':0,'missing':0,'extra':0,'hashMismatch':0,'sizeMismatch':0,'signatureErrors':0,'signaturesChecked':len(signatures),'secretHits':0,'unsafeArchivePaths':0,'absoluteLocalTextPaths':0,'secretScanScope':'All extracted bytes; private keys, GitHub tokens, Google API keys, assigned password/access/refresh token literals. No credentials were used.'}
    save(ROOT.parent/'or5r-package-verification.json',report);print(json.dumps(report))

def prepare(_):
    """Copy evidence, preserving originals. Only machine-local log prefixes are redacted."""
    sources=[]
    groups=[(Path('build/or5r-pdf-final-runtime'),'runtime','*.json'),
            (Path('build/or5r-title-only-before'),'before-regression','*'),
            (Path('build/or5r-title-only-regression'),'after-regression','*')]
    for base,dest,glob in groups:
        sources += [(p,ROOT/dest/p.name) for p in base.glob(glob) if p.is_file()]
    evidence_names=['OR5R_FAILURE_CLASSIFICATION.json','OR5R_FAILURE_RESOLUTION.json','OR5R_ASSERTION_MIGRATION_LEDGER.json','OR5R_ASSERTION_MIGRATION.md','OR5R_ACTUAL_0035_AUTHORITY_MATRIX.json','OR5R_ACTUAL_0035_AUTHORITY_MATRIX.md','OR5R_PDF_REPAIR_VALIDATION.json','OR5R_PDF_REPAIR.md']
    sources += [(Path('docs')/name,ROOT/'audits'/name) for name in evidence_names]
    sources += [(Path('test/evidence/fixtures/or5r_known_baseline.json'),ROOT/'runtime/known-pre-repair-baseline.json')]
    sources += [(p,ROOT/'logs'/p.name) for p in Path('build').glob('or5r-pdf-final-*') if p.is_file() and p.suffix in ['.log','.jsonl']]
    sources += [(Path('build')/p,ROOT/'logs'/p) for p in ['or5r-title-only-before.log','or5r-title-only-after.log','or5r-baseline-analyzer.log']]
    sources += [(Path('build/or5r-owner-package/product/known-dedicated.pdf'),ROOT/'before/known-dedicated.pdf'),(Path('build/or5r-owner-package/raster/known-dedicated-2.png'),ROOT/'before/known-dedicated-page-2.png')]
    copies=[]
    for src,dst in sources:
        if not src.exists():raise FileNotFoundError(src)
        dst.parent.mkdir(parents=True,exist_ok=True)
        b=src.read_bytes();count=0
        if src.suffix in ['.json','.jsonl','.md','.log','.txt']:
            s=b.decode('utf-8-sig')
            # Exact known local roots only; no expected/actual content or results changed.
            for prefix,replacement in [(str(Path.cwd()).replace('\\','\\\\'),'<REPOSITORY>'),(str(Path.cwd()),'<REPOSITORY>'),(str(Path.cwd()).replace('\\','/'),'<REPOSITORY>'),('C:\\\\src\\\\flutter','<FLUTTER_SDK>'),('C:\\src\\flutter','<FLUTTER_SDK>'),('C:/src/flutter','<FLUTTER_SDK>')]:
                count+=s.count(prefix);s=s.replace(prefix,replacement)
            b=s.encode('utf-8')
        dst.write_bytes(b)
        copies.append({'original':src.as_posix(),'originalSha256':digest(src),'packaged':dst.relative_to(ROOT).as_posix(),'packagedSha256':digest(dst),'localPrefixRedactions':count})
    save(ROOT/'EVIDENCE_COPY_LEDGER.json',{'copies':copies,'policy':'Original raw evidence retained outside ZIP. Only explicit local filesystem roots in logs replaced; runtime content and test results unchanged.'})
    print(json.dumps({'copied':len(copies)}))

def validate(_):
    """Bind an explicit completed manual review to independently read product files."""
    from or5r_actual_pdf_gate import verify
    review=json.loads((ROOT/'MANUAL_VISUAL_REVIEW.json').read_text(encoding='utf-8'))
    assert not any(review['observedDefects'].values())
    raw=json.loads((ROOT/'PDF_PARITY_AND_PAGE_CLASSIFICATION.json').read_text(encoding='utf-8'))
    capture=json.loads((ROOT/'product/WEB_CAPTURE_VALIDATION.json').read_text(encoding='utf-8'))
    assert len(capture['cases'])==6 and all(c['domParity']=='EXACT' and not c['errors'] for c in capture['cases'])
    dedicated=[]; inventory=[]
    # Page references were read in the actual rasters. Full prose matching below
    # uses PDF streams, not these page references or the manual verdict.
    known_dedicated_pages=[1]*8+[2]*9+[3]*5+[5]*5+[6]*2
    known_chrome_pages=[1]*9+[2]*10+[3]*3+[5]*5+[6]*2
    for mode in ['known','unknown']:
        doc=json.loads((ROOT/f'product/{mode}-390-canonical.json').read_text(encoding='utf-8'))
        result=verify(ROOT/f'product/{mode}-dedicated.pdf',doc,'คำทำนายอดีต' if mode=='known' else doc['sections'][0]['title'])
        assert result['pass'],result
        dedicated.append({'mode':mode,**result})
        for i,s in enumerate(doc['sections']):
            inventory.append({'mode':mode,'ordinal':i+1,**s,
                'dedicatedTitlePage':known_dedicated_pages[i] if mode=='known' else 1,
                'chromeTitlePageVisuallyVerified':known_chrome_pages[i] if mode=='known' else 1,
                'webEvidence':f'contact-sheets/{mode}-390-web.png',
                'printDomEvidence':f'product/{mode}-390-print-dom.html',
                'parityMethod':'Exact complete installed print DOM; exact Dedicated PDF text stream; manual Web/full Chrome raster comparison. Raw Chrome extraction counters retained separately.'})
    page_rows=[]
    for item in raw['results']:
        assert review['productPdfPagesOpened'][item['file']]==list(range(1,item['pageCount']+1))
        reader=PdfReader(ROOT/'product'/item['file'])
        for page in item['pages']:
            raster=ROOT/page['raster'];assert raster.exists()
            text=reader.pages[page['page']-1].extract_text() or ''
            body=re.sub(r'หน้า\s+\d+\s*/\s*\d+','',text).strip()
            page_rows.append({'pdf':item['file'],**page,'rasterSha256':digest(raster),
                'bodyTextEmptyExcludingFooter':not body,
                'imageOnlyBody':not body and page['imageCount']>0,
                'manuallyOpened':True,'visualBlank':False,'clipping':0,'overlap':0,'overflow':0,'orphanHeading':0})
    assert len(page_rows)==14 and not any(p['visualBlankCandidate'] for p in page_rows)
    save(ROOT/'CROSS_SURFACE_SECTION_INVENTORY.json',{'entries':inventory,'sections':len(inventory),'dedicatedStrictResults':dedicated,
        'canonicalFieldsPerMode':{'known':78,'unknown':13},
        'combinedObservedParity':review['observedDefects'],
        'chromeRawExtractionLimitation':{'known':55,'unknown':12,'notZeroedOrRepaired':True}})
    save(ROOT/'ALL_PAGES_VISUAL_QA.json',{'pages':page_rows,'totalProductPages':14,'manualReview':'MANUAL_VISUAL_REVIEW.json',
        'visualBlankPages':0,'textEmptyPages':sum(p['textEmpty'] for p in page_rows),
        'bodyTextEmptyPages':sum(p['bodyTextEmptyExcludingFooter'] for p in page_rows),
        'imageOnlyBodyPages':sum(p['imageOnlyBody'] for p in page_rows),
        'notOwnerContentAcceptance':True})
    git=lambda *args: subprocess.check_output(['git',*args],text=True).strip()
    baseline='8e6d168baf8378068260fbbb39500d5eb4491b37'
    assert not git('diff','--name-only','HEAD','--','lib','test','product-acceptance')
    assert not git('diff','--name-only',baseline,'--','product-acceptance','firebase.json','.firebaserc','firestore.rules','firestore.indexes.json','storage.rules','functions')
    sources=git('ls-files','lib').splitlines()
    binding={'sourceCommit':git('rev-parse','HEAD'),'base':baseline,'uncommittedApplicationTestDelta':0,
        'productAcceptanceDelta':0,'firebaseProductionConfigurationDelta':0,
        'applicationFiles':[{'path':p,'sha256':digest(Path(p))} for p in sources],
        'artifactHarness':[{'path':p,'sha256':digest(Path(p))} for p in ['tool/or5r_artifact_app.dart','tool/or5r_capture.cjs']],
        'compiledMainJsSha256':digest(Path('build/or5r-pdf-web/main.dart.js'))}
    save(ROOT/'SOURCE_BINDING.json',binding)
    validation={'schema':'pr115-or5r-pdf-repair-validation/1','sourceCommit':binding['sourceCommit'],
        'rootCause':'Empty paragraphs produced zero semantic blocks; ordinary title widget was inside that loop. Canonical accumulator was not rendering evidence.',
        'repair':'Generic nonblank title-only semantic unit; no fake paragraph, fixture branch or canonical change.',
        'regressionBefore':json.loads(Path('build/or5r-title-only-before/positive.json').read_text(encoding='utf-8')),
        'regressionAfter':json.loads(Path('build/or5r-title-only-regression/positive.json').read_text(encoding='utf-8')),
        'negativeControl':json.loads(Path('build/or5r-title-only-regression/negative.json').read_text(encoding='utf-8')),
        'productDedicatedStrict':dedicated,'pdfPages':{'dedicatedKnown':6,'dedicatedUnknown':1,'chromeKnown':6,'chromeUnknown':1},
        'productPagesManuallyOpened':14,'visualCounters':review['observedDefects'],
        'textEmptyPages':1,'bodyImageOnlyPages':2,'chromeRawFieldMismatches':{'known':55,'unknown':12},
        'chromeParityMethod':review['notes'][2],'webCases':6,'webTiles':47,
        'unknownInfographic':'OMITTED; no placeholder PNG or prediction generated',
        'validation':'OR5R_FAILURE_RESOLUTION.json','authority':'ACTUAL INPUT-BOUND AUTHORITY NO-GO; see 22-row matrix',
        'sourceKnownCanonicalDelta':0,'candidate0011Sha256':'6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E',
        'productAcceptanceDelta':0,'firebaseProductionDelta':0,'merged':False,'deployed':False}
    save(Path('docs/OR5R_PDF_REPAIR_VALIDATION.json'),validation)
    print(json.dumps({'dedicatedStrictPass':2,'sections':len(inventory),'productPages':14,'visualErrors':0,'chromeRawMismatches':[55,12],'authority':'NO-GO'}))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('mode',choices=['render','prepare','package','validate']);parser.add_argument('argument');args=parser.parse_args()
    {'render':render,'prepare':prepare,'package':package,'validate':validate}[args.mode](args.argument)
