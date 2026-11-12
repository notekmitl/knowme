import argparse
import json
import subprocess
import unicodedata
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw
from pypdf import PdfReader


def normalized(text):
    return ''.join(
        char for char in unicodedata.normalize('NFKD', text)
        if not char.isspace() and char != '\0'
        and not unicodedata.category(char).startswith('M')
    )


def inspect_pdf(pdf, output, renderer):
    label = pdf.stem.removeprefix('print-')
    paragraphs = json.loads(
        (pdf.parent / f'print-paragraphs-{label}.json').read_text(encoding='utf8')
    )
    reader = PdfReader(pdf)
    extracted = [page.extract_text() or '' for page in reader.pages]
    text = normalized(' '.join(extracted))
    missing = [index for index, para in enumerate(paragraphs, 1)
               if normalized(para) not in text]
    assert not missing, (label, missing)
    assert all(text.strip() for text in extracted), label

    page_dir = output / label
    page_dir.mkdir(exist_ok=True)
    subprocess.run([renderer, '-r', '110', '-png', str(pdf), str(page_dir / 'page')], check=True)
    images = sorted(page_dir.glob('page-*.png'), key=lambda p: int(p.stem.split('-')[-1]))
    assert len(images) == len(reader.pages)
    sheet = Image.new('RGB', (1280, 470 * ((len(images) + 2) // 3)), '#e8ebef')
    draw = ImageDraw.Draw(sheet)
    for index, path in enumerate(images):
        with Image.open(path) as source:
            page = source.convert('RGB')
            ink = ImageChops.difference(page, Image.new('RGB', page.size, 'white')).getbbox()
            assert ink is not None, path
            assert ink[0] > 0 and ink[1] > 0 and ink[2] < page.width and ink[3] < page.height, (path, ink)
            page.thumbnail((410, 443))
            x, y = (index % 3) * 426, (index // 3) * 470
            sheet.paste(page, (x + (426 - page.width) // 2, y + 22))
            draw.text((x + 12, y + 4), f'{label} · page {index + 1}', fill='black')
    sheet.save(output / f'{label}-pages.png')
    return {'case': label, 'pages': len(images), 'paragraphs_found': len(paragraphs), 'missing': missing}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--renderer', default='pdftoppm')
    parser.add_argument('pdfs', nargs='+', type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    result = [inspect_pdf(pdf, args.out, args.renderer) for pdf in args.pdfs]
    (args.out / 'pdf-results.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf8')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
