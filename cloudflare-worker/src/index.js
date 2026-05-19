/**
 * Cloudflare Worker — R2 Storage Proxy
 *
 * Worker ini memproxy akses ke bucket R2 dengan SSL yang valid via *.workers.dev
 * sehingga tidak perlu custom domain.
 *
 * Binding R2 bucket: env.BUCKET → dikonfigurasi di wrangler.toml
 */

export default {
  /**
   * @param {Request} request
   * @param {{ BUCKET: R2Bucket, ALLOWED_ORIGINS: string }} env
   */
  async fetch(request, env) {
    const cors = buildCorsHeaders(request, env);

    // ── CORS preflight ────────────────────────────────────────────────────
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }

    // ── Hanya izinkan GET dan HEAD ────────────────────────────────────────
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      return new Response('Method Not Allowed', { status: 405, headers: cors });
    }

    // ── Ambil object key dari path ────────────────────────────────────────
    const key = new URL(request.url).pathname.slice(1);
    if (!key) {
      return new Response('Not Found', { status: 404, headers: cors });
    }

    // ── Fetch dari R2 bucket ──────────────────────────────────────────────
    const object = await env.BUCKET.get(key);
    if (!object) {
      return new Response('Not Found', { status: 404, headers: cors });
    }

    // ── Susun response headers ────────────────────────────────────────────
    const headers = new Headers(cors);
    object.writeHttpMetadata(headers);
    headers.set('Cache-Control', 'public, max-age=31536000, immutable');
    headers.set('ETag', object.httpEtag);

    // HEAD request tidak perlu body
    const body = request.method === 'HEAD' ? null : object.body;

    return new Response(body, { status: 200, headers });
  },
};

/**
 * Build CORS headers.
 * ALLOWED_ORIGINS '*' = izinkan semua (safe untuk internal B2B app).
 */
function buildCorsHeaders(request, env) {
  const origin = request.headers.get('Origin') ?? '*';
  const allowed = env.ALLOWED_ORIGINS ?? '*';
  const allowedOrigin =
    allowed === '*' || allowed.split(',').map((s) => s.trim()).includes(origin)
      ? origin
      : 'null';

  return new Headers({
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Max-Age': '86400',
  });
}
