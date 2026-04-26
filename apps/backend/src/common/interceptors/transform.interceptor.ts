import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { APP_AUTHOR } from '../branding';

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, unknown> {
  intercept(context: ExecutionContext, next: CallHandler<T>): Observable<unknown> {
    const res = context.switchToHttp().getResponse();
    res.setHeader('X-Powered-By', `Amir ERP - ${APP_AUTHOR}`);
    return next.handle().pipe(
      map((data) => {
        if (data && typeof data === 'object' && 'ok' in (data as object)) return data;
        return { ok: true, data };
      }),
    );
  }
}
