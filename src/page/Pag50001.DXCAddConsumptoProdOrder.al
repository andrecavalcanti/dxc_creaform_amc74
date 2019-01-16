page 50001 "DXCAddConsumptoProdOrder"
{
    PageType = Card;
    SourceTable = "DXCAddConsumptoProdOrder";   

    CaptionML = ENU='DXC Add Consumption to Prod. Order',             
                ENC='DXC Add Consumption to Prod. Order';

    Editable = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Released Prod Order No.";"Released Prod Order No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Take Bin";"Take Bin")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            //Caption = 'ActionItems';
            group(ActionGroup100000008)
            {
                action(Post)
                {
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Post;
                    end;
                }
                action("Production Order")
                {
                    Image = Production;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Released Production Order";
                    RunPageLink = Status=CONST(Released),
                                  "No."=FIELD("Released Prod Order No.");
                }
                action("Bin Contents")
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU='Bin Contents',
                                ESM='Contenidos ubicación',
                                FRC='Contenu de la zone',
                                ENC='Bin Contents';
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code"=FIELD("Location Code"),
                                  "Item No."=FIELD("Item No.");
                    RunPageView = SORTING("Location Code","Bin Code","Item No.","Variant Code");
                    ToolTipML = ENU='View items in the bin if the selected line contains a bin code.',
                                ESM='Permite ver elementos en la ubicación si la línea seleccionada contiene un código de ubicación.',
                                FRC='Affichez les articles dans la zone si la ligne sélectionnée contient un code de zone.',
                                ENC='View items in the bin if the selected line contains a bin code.';
                }
            }
        }
    }

  
    trigger OnClosePage()
    begin
        DELETEALL;
    end;
}

