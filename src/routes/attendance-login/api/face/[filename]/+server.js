import fs from 'fs';
import path from 'path';

export async function GET({ params }) {
  const { filename } = params;
  const filePath = path.join(process.cwd(), 'static', 'face', filename);

  try {
    if (!fs.existsSync(filePath)) {
      return new Response('File not found', { status: 404 });
    }

    const file = fs.readFileSync(filePath);
    const ext = path.extname(filename).toLowerCase();
    const mimeType = ext === '.png' ? 'image/png' : 'image/jpeg';

    return new Response(file, {
      status: 200,
      headers: {
        'Content-Type': mimeType,
        'Cache-Control': 'public, max-age=31536000'
      }
    });
  } catch (err) {
    console.error('Error serving image:', err);
    return new Response('Internal server error', { status: 500 });
  }
}