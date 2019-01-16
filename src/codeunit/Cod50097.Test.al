codeunit 50097 "Test"
{

    trigger OnRun();
    begin
    end;

    procedure Post(PProdOrderNo : Code[20];PItemNo : Code[20];PQuantity : Decimal;PTakeBin : Code[20]);
    begin
        MESSAGE('HI');
    end;
}

