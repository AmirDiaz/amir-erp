import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';
import { APP_AUTHOR } from '../branding';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('Exception');

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message: string | string[] = 'Internal server error';
    let code: string | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const r = exception.getResponse() as { message?: string | string[]; error?: string } | string;
      if (typeof r === 'string') message = r;
      else { message = r.message ?? message; code = r.error; }
    } else if (exception instanceof Error) {
      message = exception.message;
      this.logger.error(exception.stack ?? exception.message);
    }

    res.setHeader('X-Powered-By', `Amir ERP - ${APP_AUTHOR}`);
    res.status(status).json({
      ok: false,
      statusCode: status,
      code,
      message,
      timestamp: new Date().toISOString(),
    });
  }
}
