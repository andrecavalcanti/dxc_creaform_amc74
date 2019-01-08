tableextension 50019 "DXCProdOrderExt" extends "Production Order" //MyTargetTableId
{
    fields
    {
        
    }

    var
        Text008 : TextConst ENU='Nothing to handle.',ESM='Nada a manipular.',FRC='Il n''y a rien à traiter.',ENC='Nothing to handle.';
        HideValidationDialog : Boolean;
    
    [Scope('Personalization')]
    procedure CreatePickDXC(AssignedUserID : Code[50];SortingMethod : Option;SetBreakBulkFilter : Boolean;DoNotFillQtyToHandle : Boolean;PrintDocument : Boolean;PItemNo : Code[20]);
    var
        ProdOrderCompLine : Record "Prod. Order Component";
        WhseWkshLine : Record "Whse. Worksheet Line";
        CreatePickFromWhseSource : Report "Whse.-Source - Create Document";
        ItemTrackingMgt : Codeunit "Item Tracking Management";
    begin
        ProdOrderCompLine.RESET;
        ProdOrderCompLine.SETRANGE(Status,Status);
        ProdOrderCompLine.SETRANGE("Prod. Order No.","No.");
        ProdOrderCompLine.SETRANGE("Item No.",PItemNo);
        if ProdOrderCompLine.FIND('-') then
          repeat
            ItemTrackingMgt.InitItemTrkgForTempWkshLine(
              WhseWkshLine."Whse. Document Type"::Production,ProdOrderCompLine."Prod. Order No.",
              ProdOrderCompLine."Prod. Order Line No.",DATABASE::"Prod. Order Component",
              ProdOrderCompLine.Status,ProdOrderCompLine."Prod. Order No.",
              ProdOrderCompLine."Prod. Order Line No.",ProdOrderCompLine."Line No.");
          until ProdOrderCompLine.NEXT = 0;
        COMMIT;

        Rec.TESTFIELD(Status,Status::Released);
        CALCFIELDS("Completely Picked");
        if "Completely Picked" then
          ERROR(Text008);

        ProdOrderCompLine.RESET;
        ProdOrderCompLine.SETRANGE(Status,Status);
        ProdOrderCompLine.SETRANGE("Prod. Order No.","No.");
        ProdOrderCompLine.SETRANGE("Item No.",PItemNo);
        ProdOrderCompLine.SETFILTER(
          "Flushing Method",'%1|%2|%3',
          ProdOrderCompLine."Flushing Method"::Manual,
          ProdOrderCompLine."Flushing Method"::"Pick + Forward",
          ProdOrderCompLine."Flushing Method"::"Pick + Backward");
        ProdOrderCompLine.SETRANGE("Planning Level Code",0);
        ProdOrderCompLine.SETFILTER("Expected Quantity",'>0');
        if ProdOrderCompLine.FIND('-') then begin
          CreatePickFromWhseSource.SetProdOrder(Rec);
          CreatePickFromWhseSource.SetHideValidationDialog(HideValidationDialog);
          if HideValidationDialog then
            CreatePickFromWhseSource.Initialize(AssignedUserID,SortingMethod,PrintDocument,DoNotFillQtyToHandle,SetBreakBulkFilter);
          CreatePickFromWhseSource.USEREQUESTPAGE(not HideValidationDialog);
          CreatePickFromWhseSource.RUNMODAL;
          CreatePickFromWhseSource.GetResultMessage(2);
          CLEAR(CreatePickFromWhseSource);
        end else
          if not HideValidationDialog then
            MESSAGE(Text008);
    end;

   
}