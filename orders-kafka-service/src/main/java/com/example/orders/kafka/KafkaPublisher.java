package com.example.orders.kafka;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@Profile("kafka")
public class KafkaPublisher {
  private final KafkaTemplate<String,String> kafkaTemplate;
  @Value("${orders.topic:orders-topic}")
  private String topic;
  public KafkaPublisher(KafkaTemplate<String,String> kafkaTemplate){ this.kafkaTemplate = kafkaTemplate; }
  public void publish(String msg){ kafkaTemplate.send(topic, msg); }
}
