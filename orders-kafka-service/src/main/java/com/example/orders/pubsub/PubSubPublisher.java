package com.example.orders.pubsub;
import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("pubsub")
public class PubSubPublisher {
  private final PubSubTemplate template;
  @Value("${orders.topic:orders-topic}")
  private String topic;
  public PubSubPublisher(PubSubTemplate template){ this.template = template; }
  public void publish(String message){ template.publish(topic, message); }
}
