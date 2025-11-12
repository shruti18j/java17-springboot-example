package com.example.orders.model;
public class OrderEvent {
  private String id; private String item; private int qty;
  public OrderEvent(){}
  public OrderEvent(String id,String item,int qty){this.id=id;this.item=item;this.qty=qty;}
  public String getId(){return id;} public void setId(String id){this.id=id;}
  public String getItem(){return item;} public void setItem(String item){this.item=item;}
  public int getQty(){return qty;} public void setQty(int qty){this.qty=qty;}
}
