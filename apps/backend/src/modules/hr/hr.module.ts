import { Module } from '@nestjs/common';
import { EmployeesController } from './employees.controller';
import { LeavesController } from './leaves.controller';
@Module({ controllers: [EmployeesController, LeavesController] })
export class HrModule {}
