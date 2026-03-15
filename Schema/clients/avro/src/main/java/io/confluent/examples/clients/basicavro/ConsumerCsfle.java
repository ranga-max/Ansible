package io.confluent.examples.clients.basicavro;

import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Properties;
import java.util.Properties;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Collections;

public class ConsumerCsfle {

    private static final String TOPIC = "customer";

    public static void main(final String[] args) {
        final Properties props = buildConsumerProps();
        final KafkaConsumer<String, GenericRecord> consumer = new KafkaConsumer<>(props);

        consumer.subscribe(Collections.singletonList(TOPIC));

        System.out.println("Consuming from topic " + TOPIC + " ...");

        try {
            while (true) {
                final ConsumerRecords<String, GenericRecord> records =
                        consumer.poll(Duration.ofSeconds(1));

                for (final ConsumerRecord<String, GenericRecord> rec : records) {
                    final GenericRecord value = rec.value();
                    if (value == null) continue;

                    System.out.printf("Offset=%d key=%s id=%s name=%s ssn=%s%n",
                            rec.offset(),
                            rec.key(),
                            value.get("id"),
                            value.get("name"),
                            value.get("ssn"));  // decrypted by CSFLE
                }
            }
        } finally {
            consumer.close(Duration.ofSeconds(5));
        }
    }

    private static Properties buildConsumerProps() {
        final Properties props = new Properties();

        try (InputStream input = ProducerExample.class.getClassLoader().getResourceAsStream("consconfig.properties")) {
            if (input == null) {
                System.err.println("Error: 'consconfig.properties' not found in resources.");
            }
            props.load(input);
        } catch (final IOException e) {
            // Code to handle the exception
            System.err.println("An I/O error occurred: " + e.getMessage());
            e.printStackTrace(); 
        }

        // --- Kafka cluster ---
        //props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
        //          "<BOOTSTRAP_SERVERS>");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                  StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                 "io.confluent.kafka.serializers.KafkaAvroDeserializer");
        props.put(ConsumerConfig.GROUP_ID_CONFIG,
                 "csfle-aws-demo-group");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        // --- Schema Registry auth ---
        //props.put("schema.registry.url", "<SR_URL>");
        //props.put("basic.auth.credentials.source", "USER_INFO");
        //props.put("schema.registry.basic.auth.user.info",
        //          "<SR_API_KEY>:<SR_API_SECRET>");

        // --- CSFLE AWS non-shared KMS (same creds as producer) ---
        props.put("rule.executors._default_.param.access.key.id",
                  "xxx);
        props.put("rule.executors._default_.param.secret.access.key",
                  "yyy");

        // We rely on already-registered schema + rule
        props.put("auto.register.schemas", "false");
        props.put("use.latest.version", "true");

        return props;
    }
}
