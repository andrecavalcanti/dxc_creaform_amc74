codeunit 50002 "DXCAddConsumptionToProdOrder"
{
     var
        Text001 : Label '"Item %1 already exists on the component lines "';
        Text002 : Label 'Production Order Line not found';
        ProdOrderComp : Record "Prod. Order Component";
        ItemNo :  Code[20];
        Quantity : Decimal;
        TakeBin : Code[20];
        ProdOrder : Record "Production Order";

    
    procedure Post(PProdOrderNo : Code[20]; PItemNo : Code[20]; PQuantity : Decimal; PTakeBin : Code[20]);
    var
        //ProdOrder : Record "Production Order";
        ProdOrderLine : Record "Prod. Order Line";
        ProdOrderComp : Record "Prod. Order Component";
    begin

        ItemNo := PItemNo;
        Quantity := PQuantity;
        TakeBin := PTakeBin;

        ProdOrder.GET(ProdOrder.Status::Released,PProdOrderNo);

        ProdOrderLine.SETRANGE(Status,ProdOrderLine.Status::Released);
        ProdOrderLine.SETRANGE("Prod. Order No.",PProdOrderNo);
        if ProdOrderLine.FINDFIRST then begin
          CreateProdOrderComponent(ProdOrderLine,ProdOrderComp);
          CreateNewPick(ProdOrder);
          UpdateTakeBin(ProdOrderLine);
          CalcConsumptiononConsumpJnl(ProdOrder,ProdOrderComp);
          PostConsumptionJnl;
        end;
        
    end;

    local procedure CreateProdOrderComponent(PProdOrderLine : Record "Prod. Order Line";var PProdOrderComp : Record "Prod. Order Component") : Boolean;
    var
        NextProdOrderCompLineNo : Integer;
        ComponentSKU : Record "Stockkeeping Unit";
        GetPlanningParameters : Codeunit "Planning-Get Parameters";
        SKU : Record "Stockkeeping Unit";
        Item2 : Record Item;        
    begin


          ProdOrderComp.SETCURRENTKEY(Status,"Prod. Order No.","Prod. Order Line No.","Item No.");
          ProdOrderComp.SETRANGE(Status,PProdOrderLine.Status);
          ProdOrderComp.SETRANGE("Prod. Order No.",PProdOrderLine."Prod. Order No.");
          ProdOrderComp.SETRANGE("Prod. Order Line No.",PProdOrderLine."Line No.");
          ProdOrderComp.SETRANGE("Item No.", ItemNo);
        //  ProdOrderComp.SETRANGE("Variant Code",ProdBOMLine[Level]."Variant Code")P
        //  ProdOrderComp.SETRANGE("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
        //  ProdOrderComp.SETRANGE(Position,ProdBOMLine[Level].Position);
        //  ProdOrderComp.SETRANGE("Position 2",ProdBOMLine[Level]."Position 2");
        //  ProdOrderComp.SETRANGE("Position 3",ProdBOMLine[Level]."Position 3");
        //  ProdOrderComp.SETRANGE(Length,ProdBOMLine[Level].Length);
        //  ProdOrderComp.SETRANGE(Width,ProdBOMLine[Level].Width);
        //  ProdOrderComp.SETRANGE(Weight,ProdBOMLine[Level].Weight);
        //  ProdOrderComp.SETRANGE(Depth,ProdBOMLine[Level].Depth);
        //  ProdOrderComp.SETRANGE("Unit of Measure Code",ProdBOMLine[Level]."Unit of Measure Code");
        //  ProdOrderComp.SETRANGE("Text Set ID",ProdBOMLine[Level]."Text Set ID");  // #TMW17.10.01:T100
          if not ProdOrderComp.FINDFIRST then begin
            ProdOrderComp.RESET;
            ProdOrderComp.SETRANGE(Status,PProdOrderLine.Status);
            ProdOrderComp.SETRANGE("Prod. Order No.",PProdOrderLine."Prod. Order No.");
            ProdOrderComp.SETRANGE("Prod. Order Line No.",PProdOrderLine."Line No.");
            if ProdOrderComp.FINDLAST then
              NextProdOrderCompLineNo := ProdOrderComp."Line No." + 10000
            else
              NextProdOrderCompLineNo := 10000;
            ProdOrderComp.INIT;
            ProdOrderComp.SetIgnoreErrors;
        //    ProdOrderComp.BlockDynamicTracking(Blocked);
            ProdOrderComp.Status := PProdOrderLine.Status;
            ProdOrderComp."Prod. Order No." := PProdOrderLine."Prod. Order No.";
            ProdOrderComp."Prod. Order Line No." := PProdOrderLine."Line No.";
            ProdOrderComp."Line No." := NextProdOrderCompLineNo;
            ProdOrderComp.VALIDATE("Item No.",ItemNo);
        //    ProdOrderComp."Variant Code" := ProdBOMLine[Level]."Variant Code";
            ProdOrderComp."Location Code" := ProdOrder."Location Code";
        //    ProdOrderComp."Location Code" := SKU."Components at Location";
            ProdOrderComp."Bin Code" := GetDefaultBin;
        //    ProdOrderComp.Description := ProdBOMLine[Level].Description;
        //    ProdOrderComp.VALIDATE("Unit of Measure Code",ProdBOMLine[Level]."Unit of Measure Code");
        //    ProdOrderComp."Quantity per" := ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM;
        //    ProdOrderComp."Quantity per" := Quantity;
            ProdOrderComp.VALIDATE("Quantity per",Quantity);
        //    ProdOrderComp.Length := ProdBOMLine[Level].Length;
        //    ProdOrderComp.Width := ProdBOMLine[Level].Width;
        //    ProdOrderComp.Weight := ProdBOMLine[Level].Weight;
        //    ProdOrderComp.Depth := ProdBOMLine[Level].Depth;
        //    ProdOrderComp.Position := ProdBOMLine[Level].Position;
        //    ProdOrderComp."Position 2" := ProdBOMLine[Level]."Position 2";
        //    ProdOrderComp."Position 3" := ProdBOMLine[Level]."Position 3";
        //    ProdOrderComp."Lead-Time Offset" := ProdBOMLine[Level]."Lead-Time Offset";
        //    ProdOrderComp.VALIDATE("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
        //    ProdOrderComp.VALIDATE("Scrap %",ProdBOMLine[Level]."Scrap %");
        //    ProdOrderComp.VALIDATE("Calculation Formula",ProdBOMLine[Level]."Calculation Formula");
        //
            GetPlanningParameters.AtSKU(
              ComponentSKU,ProdOrderComp."Item No.",
              ProdOrderComp."Variant Code",
              ProdOrderComp."Location Code");

            //ProdOrderComp."Flushing Method" := ComponentSKU."Flushing Method";
            ProdOrderComp."Flushing Method" := ProdOrderComp."Flushing Method"::Manual;
            if (SKU."Manufacturing Policy" = SKU."Manufacturing Policy"::"Make-to-Order") and
                (ComponentSKU."Manufacturing Policy" = ComponentSKU."Manufacturing Policy"::"Make-to-Order") and
                (ComponentSKU."Replenishment System" = ComponentSKU."Replenishment System"::"Prod. Order")
            then begin
              ProdOrderComp."Planning Level Code" := PProdOrderLine."Planning Level Code" + 1;
              Item2.GET(ProdOrderComp."Item No.");
              ProdOrderComp."Item Low-Level Code" := Item2."Low-Level Code";
            end;
            ProdOrderComp.GetDefaultBin;
        //    OnAfterTransferBOMComponent(ProdOrderLine,ProdBOMLine[Level],ProdOrderComp);
            ProdOrderComp.INSERT(true);

            PProdOrderComp := ProdOrderComp;

            exit(true);


          end else begin
        //    ProdOrderComp.SetIgnoreErrors;
        //    ProdOrderComp.SETCURRENTKEY(Status,"Prod. Order No."); // Reset key
        //    ProdOrderComp.BlockDynamicTracking(Blocked);
        //    ProdOrderComp.VALIDATE(
        //      "Quantity per",
        //      ProdOrderComp."Quantity per" + ProdBOMLine[Level]."Quantity per" * LineQtyPerUOM / ItemQtyPerUOM);
        //    ProdOrderComp.VALIDATE("Routing Link Code",ProdBOMLine[Level]."Routing Link Code");
        //    ProdOrderComp.MODIFY;
            //CalcConsumptiononConsumpJnl(LclProdOrder,ProdOrderComp);
            //ERROR(Text001,ProdOrderComp."Item No.");
            PProdOrderComp := ProdOrderComp;
          end;
        //  IF ProdOrderComp.HasErrorOccured THEN
        //    ErrorOccured := TRUE;
        //  ProdOrderComp.AutoReserve;
    end;

    local procedure CreateNewPick(PProdOrder : Record "Production Order");
    begin

        PProdOrder.SetHideValidationDialog(true);
        PProdOrder.CreatePickDXC(USERID,0,false,false,false, ItemNo);
    end;

    local procedure UpdateTakeBin(PProdOrderLine : Record "Prod. Order Line");
    var
        WhseActivityHeader : Record "Warehouse Activity Header";
        WhseActivityLine : Record "Warehouse Activity Line";
    begin

        WhseActivityLine.SETRANGE("Activity Type",WhseActivityLine."Activity Type"::Pick);
        WhseActivityLine.SETRANGE("Source Type",DATABASE::"Prod. Order Component");
        WhseActivityLine.SETRANGE("Source Subtype",WhseActivityLine."Source Subtype"::"3");
        WhseActivityLine.SETRANGE("Source No.",PProdOrderLine."Prod. Order No.");
        WhseActivityLine.SETRANGE("Source Line No.",PProdOrderLine."Line No.");
        WhseActivityLine.SETRANGE("Source Document",WhseActivityLine."Source Document"::"Prod. Consumption");
        WhseActivityLine.SETRANGE("Item No.",ItemNo);
        WhseActivityLine.SETRANGE("Action Type",WhseActivityLine."Action Type"::Take);
        if WhseActivityLine.FINDFIRST then begin

          WhseActivityLine.VALIDATE("Bin Code",TakeBin);
          WhseActivityLine.MODIFY;

          RegisterPick(WhseActivityLine);

        end;
    end;

    local procedure RegisterPick(PWhseActivityLine : Record "Warehouse Activity Line");
    begin

        PWhseActivityLine.SETRANGE(Breakbulk);

        CODEUNIT.RUN(CODEUNIT::"Whse.-Activity-Register",PWhseActivityLine);
    end;

    local procedure CalcConsumptiononConsumpJnl(PProdOrder : Record "Production Order";PProdOrderComp : Record "Prod. Order Component");
    var
        CalcConsumption : Report "Calc. Consumption";
    begin

        PProdOrder.SETRECFILTER;
        PProdOrderComp.SETRECFILTER;

        CalcConsumption.SetTemplateAndBatchName('CONSUMP','DEFAULT');

        CalcConsumption.SETTABLEVIEW(PProdOrder);
        CalcConsumption.SETTABLEVIEW(PProdOrderComp);
        CalcConsumption.USEREQUESTPAGE := false;
        CalcConsumption.InitializeRequest(WORKDATE,1);
        //CalcConsumption.RUNMODAL;
        CalcConsumption.RUN;
    end;

    local procedure PostConsumptionJnl();
    var
        ItemJnlLine : Record "Item Journal Line";
    begin

        ItemJnlLine.SETRANGE("Journal Template Name",'CONSUMP');
        ItemJnlLine.SETRANGE("Journal Batch Name",'DEFAULT');
        ItemJnlLine.SETRANGE("Item No.",ItemNo);
        if ItemJnlLine.FINDFIRST then begin
          //ItemJnlLine.PostingItemJnlFromProduction(FALSE);
          CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post Batch",ItemJnlLine);
        end;
    end;

    local procedure GetDefaultBin() BinCode : Code[20];
    var
        WMSMgt : Codeunit "WMS Management";
        Location : Record Location;
    begin
        with ProdOrderComp do
          if "Location Code" <> '' then begin
            if Location.Code <> "Location Code" then
              Location.GET("Location Code");
            if Location."Bin Mandatory" and (not Location."Directed Put-away and Pick") then
              WMSMgt.GetDefaultBin("Item No.","Variant Code","Location Code",BinCode);
          end;
    end;
}