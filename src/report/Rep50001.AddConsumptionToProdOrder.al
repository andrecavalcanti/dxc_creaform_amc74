report 50001 "AddConsumptionToProdOrder"
{
    ProcessingOnly = true;
    CaptionML = ENU='Add Consumption to Prod. Order',             
                ENC='Add Consumption to Prod. Order';


    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Prod. Order No.";ProdOrderNo)
                {
                    TableRelation = "Production Order"."No." WHERE (Status=CONST(Released));
                }
                field("Item No.";ItemNo)
                {
                    TableRelation = Item."No.";
                }
                field(Quantity;Quantity)
                {
                }
                field("Take Bin";TakeBin)
                {

                    trigger OnLookup(Text : Text) : Boolean;
                    begin

                        ProdOrder.GET(ProdOrder.Status::Released,ProdOrderNo);

                          Bin.RESET;
                          Bin.SETFILTER("Location Code",ProdOrder."Location Code");
                          CLEAR(BinList);
                          BinList.SETRECORD(Bin);
                          BinList.SETTABLEVIEW(Bin);
                          BinList.LOOKUPMODE(true);
                          if BinList.RUNMODAL = ACTION::LookupOK then begin
                            BinList.GETRECORD(Bin);
                            TakeBin := Bin.Code;
                            //LookupExperiment := Bin."No.";
                          end else begin
                            //LookupExperiment := 'Bin NOT FOUND';
                          end;

                        // IF COPYSTR(ProdOrder."Location Code",1,1) = '0' THEN BEGIN
                        //  Bin.RESET;
                        //  Bin.SETFILTER("Location Code",'1*');
                        //  CLEAR(BinList);
                        //  BinList.SETRECORD(Bin);
                        //  BinList.SETTABLEVIEW(Bin);
                        //  BinList.LOOKUPMODE(TRUE);
                        //  IF BinList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                        //    BinList.GETRECORD(Bin);
                        //    TakeBin := Bin.Code;
                        //    //LookupExperiment := Bin."No.";
                        //  END ELSE BEGIN
                        //    //LookupExperiment := 'Bin NOT FOUND';
                        //  END;
                        // END ELSE BEGIN
                        //  Resource.RESET;
                        //  Resource.SETFILTER("No.",'M*');
                        //  CLEAR(ResourceList);
                        //  ResourceList.SETRECORD(Resource);
                        //  ResourceList.SETTABLEVIEW(Resource);
                        //  ResourceList.LOOKUPMODE(TRUE);
                        //  IF ResourceList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                        //    ResourceList.GETRECORD(Resource);
                        //    LookupExperiment := Resource."No.";
                        //  END ELSE BEGIN
                        //    LookupExperiment := 'RESOURCE NOT FOUND';
                        //  END;
                        //END;
                    end;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport();
    begin
        //test.Post(ProdOrderNo,ItemNo,Quantity,TakeBin);
        DXCAddConsumptionToProdOrder.Post(ProdOrderNo,ItemNo,Quantity,TakeBin);
    end;

    var
        ProdOrderNo : Code[20];
        ItemNo : Code[20];
        Quantity : Decimal;
        TakeBin : Code[20];
        //test : Codeunit Test;
        ProdOrder : Record "Production Order";
        Bin : Record Bin;
        BinList : Page "Bin List";
        DXCAddConsumptionToProdOrder :Codeunit DXCAddConsumptionToProdOrder;
}

