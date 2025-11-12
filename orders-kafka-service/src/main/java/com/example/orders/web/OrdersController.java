package com.example.orders.web;
import com.example.orders.model.OrderEvent;
import com.example.orders.service.EventBus;
import com.example.orders.kafka.KafkaPublisher;
import com.example.orders.pubsub.PubSubPublisher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
public class OrdersController {
  private final EventBus eventBus;
  @Autowired(required = false) private KafkaPublisher kafkaPublisher;
  @Autowired(required = false) private PubSubPublisher pubSubPublisher;

  public OrdersController(EventBus eventBus){ this.eventBus = eventBus; }

  @PostMapping("/orders")
  public ResponseEntity<String> create(@RequestBody OrderEvent body){
    if (body.getId()==null || body.getId().isBlank()) body.setId(UUID.randomUUID().toString());
    String msg = body.getItem() + ":" + body.getQty();
    if (kafkaPublisher != null) { kafkaPublisher.publish(msg); }
    else if (pubSubPublisher != null) { pubSubPublisher.publish(msg); }
    else { eventBus.publish(body); }
    return ResponseEntity.ok("published:" + body.getId());
  }

  @GetMapping("/events")
  public List<OrderEvent> events(){ return eventBus.queue().stream().collect(Collectors.toList()); }
}
