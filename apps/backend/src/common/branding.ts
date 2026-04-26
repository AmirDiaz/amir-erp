/**
 * Amir ERP — branding constants. These are embedded into every artifact:
 *   - HTTP responses (`X-Powered-By`, `/about`)
 *   - Swagger / OpenAPI metadata
 *   - Generated PDFs (invoices, receipts) and exports
 *   - Splash / login / footer / about / admin in the Flutter client
 *   - package.json `author` field
 *
 * Author: Amir Saoudi.
 */
export const APP_NAME = 'Amir ERP';
export const APP_AUTHOR = 'Amir Saoudi';
export const APP_AUTHOR_EMAIL = 'amirsaoudi620@gmail.com';
export const APP_TAGLINE = 'Modern multi-tenant SaaS ERP';
export const APP_VERSION = '0.1.0';
export const APP_COPYRIGHT = `© ${new Date().getFullYear()} ${APP_AUTHOR}`;
export const APP_SIGNATURE = `Built by ${APP_AUTHOR} — ${APP_AUTHOR_EMAIL}`;
