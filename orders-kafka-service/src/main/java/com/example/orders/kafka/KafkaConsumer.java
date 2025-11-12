package com.example.orders.kafka;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("kafka")
public class KafkaConsumer {
  @KafkaListener(topics = "${orders.topic:orders-topic}", groupId = "orders-consumer-group")
  public void consume(String message){
    System.out.println("Consumed Kafka message: " + message);
  }
}
