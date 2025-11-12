package com.example.orders.web;
import com.example.orders.subscriber.OrderSubscriber;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.*;
@RestController
public class OrdersController {
  @Autowired(required = false)
  private OrderSubscriber subscriber;
  private final List<Map<String,Object>> events = Collections.synchronizedList(new ArrayList<>());
  @PostMapping("/orders")
  public Map<String,Object> create(@RequestBody Map<String,Object> body){
    Map<String,Object> e = new HashMap<>(body);
    e.putIfAbsent("id", UUID.randomUUID().toString());
    events.add(e);
    return Map.of("status","published","id",e.get("id"));
  }
  @GetMapping("/events")
  public List<Map<String,Object>> events(){ return events; }
  @GetMapping("/pubsub-events")
  public List<String> pubsubEvents() { if (subscriber == null) return Collections.emptyList(); return subscriber.getReceived(); }
}
