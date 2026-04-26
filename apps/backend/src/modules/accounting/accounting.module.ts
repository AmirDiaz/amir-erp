import { Module } from '@nestjs/common';
import { AccountsController } from './accounts.controller';
import { JournalsController } from './journals.controller';
import { PostingService } from './posting.service';
@Module({
  controllers: [AccountsController, JournalsController],
  providers: [PostingService],
  exports: [PostingService],
})
export class AccountingModule {}
