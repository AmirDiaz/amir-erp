/**
 * Amir ERP — public `/about` endpoint that signs every system response with
 * the author's name. The Flutter "About" page consumes this directly.
 *
 * Author: Amir Saoudi.
 */
import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import {
  APP_AUTHOR,
  APP_AUTHOR_EMAIL,
  APP_COPYRIGHT,
  APP_NAME,
  APP_SIGNATURE,
  APP_TAGLINE,
  APP_VERSION,
} from '../../common/branding';

@ApiTags('about')
@Controller({ path: 'about', version: VERSION_NEUTRAL })
export class AboutController {
  @Public()
  @Get()
  about() {
    return {
      name: APP_NAME,
      tagline: APP_TAGLINE,
      version: APP_VERSION,
      author: APP_AUTHOR,
      email: APP_AUTHOR_EMAIL,
      copyright: APP_COPYRIGHT,
      signature: APP_SIGNATURE,
      modules: [
        'accounting', 'invoicing', 'payments', 'taxes', 'reports',
        'sales', 'crm', 'quotations', 'contracts',
        'inventory', 'warehouses', 'procurement', 'partners',
        'pos', 'manufacturing', 'projects',
        'hr', 'payroll', 'expenses', 'assets',
        'notifications', 'workflows', 'plugins', 'branding',
      ],
    };
  }
}
