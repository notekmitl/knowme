"""Verify content of real PDF bytes, never exporter plainText. Fail closed."""
import argparse, hashlib, json, re, subprocess, unicodedata
from pathlib import Path
from pypdf import PdfReader, PdfWriter
from pypdf.generic import ContentStream, NameObject

def normalize(s):
    return re.sub(r'\s|[\u200b\ufeff]', '', unicodedata.normalize('NFKD', s))

def verify(pdf, inventory, required):
    reader=PdfReader(pdf)
    pages=[p.extract_text() or '' for p in reader.pages]
    actual=normalize(''.join(re.sub(r'หน้า\s+\d+\s*/\s*\d+', '', p) for p in pages))
    expected=normalize(inventory['title']+inventory['subtitle']+''.join(s['title']+''.join(s['paragraphs']) for s in inventory['sections']))
    titles={normalize(s['title']) for s in inventory['sections'] if s['title']}
    missing=sum(max(0,expected.count(t)-actual.count(t)) for t in titles)
    extra=sum(max(0,actual.count(t)-expected.count(t)) for t in titles)
    cursor=0;order=0;paragraphs=0
    for s in inventory['sections']:
        for kind,value in [('title',s['title'])]+[('paragraph',p) for p in s['paragraphs']]:
            v=normalize(value);pos=actual.find(v,cursor)
            if pos<0:
                if kind=='paragraph':paragraphs+=1
                else:order+=1
            else:cursor=pos+len(v)
    result={'pdfSha256':hashlib.sha256(Path(pdf).read_bytes()).hexdigest(),'pages':len(pages),
        'requiredHeadingCount':actual.count(normalize(required)),
        'missingHeadings':missing,'extraHeadings':extra,'duplicateHeadings':extra,
        'sectionOrderMismatch':order,'paragraphMismatch':paragraphs,
        'normalizedFullPdfEqualsCompleteExpectedInventory':actual==expected,
        'method':'pypdf extracts actual PDF streams; NFKD/whitespace normalization and explicit page footer removal only; no Thai glyph deletion, inferred text, or render-text accumulator'}
    result['pass']=actual==expected and result['requiredHeadingCount']==1 and not any([missing,extra,order,paragraphs])
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('pdf');p.add_argument('inventory');p.add_argument('output');p.add_argument('--required',required=True);p.add_argument('--pdftoppm',required=True);p.add_argument('--negative-control',action='store_true');a=p.parse_args()
    inventory=json.loads(Path(a.inventory).read_text(encoding='utf-8'))
    target=Path(a.pdf)
    if a.negative_control:
        reader=PdfReader(target);writer=PdfWriter();writer.clone_document_from_reader(reader)
        matching=[i for i,page in enumerate(reader.pages) if normalize(a.required) in normalize(page.extract_text() or '')]
        assert len(matching)==1
        page=writer.pages[matching[0]];content=ContentStream(page.get_contents(),writer)
        # Deliberately remove actual text-paint operations on the required-title page.
        # Canonical inventory is unchanged. This is a test-only mutant, not product output.
        content.operations=[(args,op) for args,op in content.operations if op not in (b'Tj',b'TJ',b"'",b'"')]
        page[NameObject('/Contents')]=content
        target=Path(a.output).with_suffix('.mutant.pdf')
        with target.open('wb') as f:writer.write(f)
    result=verify(target,inventory,a.required)
    prefix=Path(a.output).with_suffix('')
    for stale_raster in prefix.parent.glob(prefix.name+'-*.png'):
        stale_raster.unlink()
    raster=subprocess.run([a.pdftoppm,'-r','72','-png',str(target),str(prefix)],capture_output=True)
    result['rasterExitCode']=raster.returncode
    result['rastersCreated']=len(list(prefix.parent.glob(prefix.name+'-*.png')))
    result['pass']=result['pass'] and raster.returncode==0 and result['rastersCreated']==result['pages']
    if a.negative_control:
        result['negativeControlRejected']=not result['pass'] and result['requiredHeadingCount']==0
        success=result['negativeControlRejected']
    else:success=result['pass']
    Path(a.output).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result));return 0 if success else 1

if __name__=='__main__':raise SystemExit(main())
