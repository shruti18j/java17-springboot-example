package com.example.orders.subscriber;
import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
@Service
public class OrderSubscriber {
  private final List<String> received = new CopyOnWriteArrayList<>();
  public OrderSubscriber(PubSubTemplate template) {
    template.subscribe("orders-topic", (message) -> {
      String payload = message.getPubsubMessage().getData().toStringUtf8();
      System.out.println("Received pubsub message: " + payload);
      received.add(payload);
      message.ack();
    });
  }
  public List<String> getReceived() { return received; }
}
