package com.example.orders.service;
import com.example.orders.model.OrderEvent;
import org.springframework.stereotype.Component;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
@Component
public class EventBus {
  private final Queue<OrderEvent> queue = new ConcurrentLinkedQueue<>();
  public void publish(OrderEvent e){ queue.add(e); }
  public Queue<OrderEvent> queue(){ return queue; }
}
