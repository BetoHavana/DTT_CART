public inherited sharing class SalesOrderUpdateServiceInput{
    public String soldToCode { get; set; }	
    public String shipToCode { get; set; }	
    public Apheresis apheresis { get; set; }
    public FinishedGoods finishedGoods { get; set; }
    public String salesOrderType { get; set; }
    public String projectedDeliveryDueDate { get; set; }
    public String SDPONo { get; set; }
    public String QTCPONo { get; set; }
    public String CARTOrderId { get; set; }
    public String CARTShipToAccount { get; set; }	
    public String atlasVendorCode { get; set; }	
    public ShipToAddress shipToAddress { get; set; }
    public class Apheresis {
        public String material { get; set; }
        public String quantity { get; set; }
        public String UOM { get; set; }	
    }
    public class FinishedGoods {
        public String material { get; set; }
        public String quantity { get; set; }
        public String UOM { get; set; }
        Public FinishedGoods(String material,String quantity,String UOM)
        {
            this.material=material;
            this.quantity=quantity;
            this.UOM=UOM;
        }
    }
    public class ShipToAddress {
        public String shipToName { get; set; }
        public String addressLine1 { get; set; }	
        public String addressLine2 { get; set; }
        public String addressLine3 { get; set; }
        public String addressLine4 { get; set; }
        public String city { get; set; }
        public String zipCodeNo { get; set; }
        public String stateRegion { get; set; }	
        public String country { get; set; }
    }
}